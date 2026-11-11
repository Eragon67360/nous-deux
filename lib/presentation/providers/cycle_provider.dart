import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    show PostgresChangeEvent, PostgresChangeFilter, PostgresChangeFilterType;

import 'package:nousdeux/core/constants/period_reminder_prefs.dart';
import 'package:nousdeux/core/services/period_reminder_service.dart';
import 'package:nousdeux/data/repositories/cycle_repository_impl.dart';
import 'package:nousdeux/domain/cycle/cycle_stats.dart';
import 'package:nousdeux/domain/entities/cycle_checkin_entity.dart';
import 'package:nousdeux/domain/entities/period_log_entity.dart';
import 'package:nousdeux/domain/repositories/cycle_repository.dart';
import 'package:nousdeux/presentation/providers/auth_provider.dart';
import 'package:nousdeux/presentation/providers/nous_provider.dart';
import 'package:nousdeux/presentation/providers/pairing_provider.dart';
import 'package:nousdeux/presentation/providers/period_provider.dart';
import 'package:nousdeux/presentation/providers/profile_provider.dart';
import 'package:nousdeux/presentation/providers/realtime_provider.dart';

final cycleRepositoryProvider = Provider<CycleRepository>((ref) {
  return CycleRepositoryImpl();
});

/// What the Règles tab is about for me.
enum CycleRole {
  /// Not asked yet: the tab asks once.
  unasked,

  /// I track my cycle (R1, plus my partner's if they track and share).
  tracker,

  /// I don't track; I follow my partner's cycle (R3).
  supporter,
}

/// Null while my profile loads.
final myCycleRoleProvider = Provider<CycleRole?>((ref) {
  final profile = ref.watch(myProfileProvider).valueOrNull;
  if (profile == null) return null;
  return switch (profile.tracksCycle) {
    null => CycleRole.unasked,
    true => CycleRole.tracker,
    false => CycleRole.supporter,
  };
});

/// Check-ins of the couple I may read, live; restarts with the couple.
final cycleCheckinsProvider = StreamProvider<List<CycleCheckinEntity>>((ref) {
  ref.watch(myCoupleProvider.select((c) => c.valueOrNull?.id));
  return ref.watch(cycleRepositoryProvider).watchCheckins();
});

CycleStats _statsFor(Ref ref, String? userId) {
  // Keeps "today" current while the tab stays open.
  ref.watch(minuteTickProvider);
  final logs =
      ref.watch(periodLogsProvider).valueOrNull ?? const <PeriodLogEntity>[];
  return CycleStats.from([
    for (final log in logs)
      if (userId != null && log.userId == userId) log,
  ], ref.watch(clockProvider)());
}

/// My cycle, from my own logs.
final myCycleStatsProvider = Provider<CycleStats>((ref) {
  return _statsFor(ref, ref.watch(currentUserProvider).valueOrNull?.id);
});

/// My partner's cycle, from the logs they share with me (none while they
/// don't).
final partnerCycleStatsProvider = Provider<CycleStats>((ref) {
  return _statsFor(ref, ref.watch(myProfileProvider).valueOrNull?.partnerId);
});

/// The cycle the guide speaks about: mine if I track, else my partner's
/// (empty while they don't share it).
final guideCycleProvider = Provider<({CycleStats stats, bool mine})>((ref) {
  final mine = ref.watch(myCycleRoleProvider) == CycleRole.tracker;
  return (
    stats: ref.watch(mine ? myCycleStatsProvider : partnerCycleStatsProvider),
    mine: mine,
  );
});

CycleCheckinEntity? _todayCheckin(Ref ref, String? userId) {
  if (userId == null) return null;
  final now = ref.watch(clockProvider)();
  final today = DateTime(now.year, now.month, now.day);
  final all = ref.watch(cycleCheckinsProvider).valueOrNull ?? const [];
  for (final c in all) {
    if (c.userId == userId && c.day == today) return c;
  }
  return null;
}

/// What I checked in today.
final myTodayCheckinProvider = Provider<CycleCheckinEntity?>((ref) {
  return _todayCheckin(ref, ref.watch(currentUserProvider).valueOrNull?.id);
});

/// What my partner checked in today, while they share it.
final partnerTodayCheckinProvider = Provider<CycleCheckinEntity?>((ref) {
  return _todayCheckin(
    ref,
    ref.watch(myProfileProvider).valueOrNull?.partnerId,
  );
});

/// My private note for a day.
final cycleNoteProvider = FutureProvider.family<String?, DateTime>((ref, day) {
  return ref.watch(cycleRepositoryProvider).noteFor(day);
});

/// The evening before my partner's next period is expected: when the
/// reminder fires. Null while they don't share their cycle.
final partnerReminderDayProvider = Provider<DateTime?>((ref) {
  final next = ref.watch(partnerCycleStatsProvider).nextStart;
  if (next == null) return null;
  return DateTime(next.year, next.month, next.day - 1);
});

/// Whether the partner reminder is on (stored on this device).
final partnerReminderEnabledProvider = FutureProvider<bool>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(periodPartnerReminderEnabledKey) ?? false;
});

/// Turns the partner reminder on or off. [partnerReminderSyncProvider] then
/// schedules it.
Future<void> setPartnerReminderEnabled(
  WidgetRef ref, {
  required bool enabled,
}) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(periodPartnerReminderEnabledKey, enabled);
  if (!enabled) await cancelPartnerPeriodReminder();
  ref.invalidate(partnerReminderEnabledProvider);
}

/// Keeps the reminder on the expected date while it is on: a new period
/// moves it, and it is cancelled once my partner stops sharing their cycle.
/// Watched by the main shell.
final partnerReminderSyncProvider = FutureProvider<void>((ref) async {
  if (!await ref.watch(partnerReminderEnabledProvider.future)) return;
  final day = ref.watch(partnerReminderDayProvider);
  final lang = ref.watch(
    myProfileProvider.select((p) => p.valueOrNull?.language ?? 'fr'),
  );
  if (day == null) {
    await cancelPartnerPeriodReminder();
  } else {
    await schedulePartnerPeriodReminder(day, lang);
  }
});

/// Reloads what my partner shares as soon as they change a Règles setting,
/// so a switch turned off hides their data here right away (the rows already
/// loaded would otherwise stay until the next reload). Watched by the main
/// shell.
final partnerCycleSettingsLiveProvider = Provider<void>((ref) {
  final partnerId = ref.watch(
    myProfileProvider.select((p) => p.valueOrNull?.partnerId),
  );
  if (partnerId == null || partnerId.isEmpty) return;
  final channel = ref
      .read(realtimeChannelFactoryProvider)('profile-cycle-$partnerId')
      .onPostgresChanges(
        event: PostgresChangeEvent.update,
        schema: 'public',
        table: 'profiles',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'id',
          value: partnerId,
        ),
        callback: (payload) {
          final row = payload.newRecord;
          final known = ref.read(partnerProfileProvider).valueOrNull;
          if (known != null &&
              row['tracks_cycle'] == known.tracksCycle &&
              row['share_cycle'] == known.shareCycle &&
              row['share_checkins'] == known.shareCheckins) {
            return;
          }
          ref.invalidate(partnerProfileProvider);
          ref.invalidate(periodLogsProvider);
          ref.invalidate(cycleCheckinsProvider);
        },
      )
      .subscribe();
  ref.onDispose(channel.unsubscribe);
});
