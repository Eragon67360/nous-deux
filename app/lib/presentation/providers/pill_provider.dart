import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:nousdeux/core/errors/failures.dart';
import 'package:nousdeux/data/repositories/pill_repository_impl.dart';
import 'package:nousdeux/domain/entities/pill_entities.dart';
import 'package:nousdeux/domain/repositories/pill_repository.dart';
import 'package:nousdeux/presentation/providers/auth_provider.dart';
import 'package:nousdeux/presentation/providers/nous_provider.dart';
import 'package:nousdeux/presentation/providers/profile_provider.dart';
import 'package:nousdeux/presentation/providers/realtime_provider.dart';

final pillRepositoryProvider = Provider<PillRepository>(
  (ref) => PillRepositoryImpl(),
);

DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

/// My pill settings, or null when I don't track a pill (or am signed out).
final pillSettingsProvider = FutureProvider<PillSettings?>((ref) async {
  final user = ref.watch(currentUserProvider).valueOrNull;
  if (user == null) return null;
  return ref.watch(pillRepositoryProvider).mySettings();
});

/// My days of the current pack and of the last seven days, today included
/// (the pack grid and « Cette semaine »).
final pillWeekProvider = FutureProvider<List<PillIntake>>((ref) async {
  final user = ref.watch(currentUserProvider).valueOrNull;
  if (user == null) return const [];
  final settings = await ref.watch(pillSettingsProvider.future);
  final today = _day(ref.watch(clockProvider)());
  var from = DateTime(today.year, today.month, today.day - 6);
  if (settings != null) {
    final packStart = DateTime(
      today.year,
      today.month,
      today.day - settings.schedule.dayInPack(today) + 1,
    );
    if (packStart.isBefore(from)) from = packStart;
  }
  return ref.watch(pillRepositoryProvider).myIntakes(from: from);
});

enum PillTodayState {
  /// I don't track a pill.
  notTracking,

  /// A day off in a 21 + 7 pack.
  pauseDay,

  /// Not ticked yet, up to an hour after the reminder time.
  due,

  /// Not ticked an hour after the reminder time (board screen 4).
  late,
  taken,

  /// Noted as missed.
  missed,
}

/// Today's pill, as the Règles tab shows it.
class PillToday {
  const PillToday(this.state, {this.settings, this.pillNumber, this.takenAt});

  final PillTodayState state;
  final PillSettings? settings;

  /// Today's pill in its pack; null on a day off.
  final int? pillNumber;
  final DateTime? takenAt;
}

/// Today's pill state, or null while my settings or days load.
final pillTodayProvider = Provider<PillToday?>((ref) {
  ref.watch(minuteTickProvider);
  final settingsAsync = ref.watch(pillSettingsProvider);
  if (!settingsAsync.hasValue) return null;
  final settings = settingsAsync.requireValue;
  if (settings == null) return const PillToday(PillTodayState.notTracking);
  final week = ref.watch(pillWeekProvider);
  if (!week.hasValue) return null;
  final now = ref.watch(clockProvider)();
  final today = _day(now);
  final number = settings.schedule.pillNumber(today);
  final intake = week.requireValue.where((i) => i.day == today).firstOrNull;
  if (intake != null) {
    return PillToday(
      intake.taken ? PillTodayState.taken : PillTodayState.missed,
      settings: settings,
      pillNumber: number,
      takenAt: intake.takenAt,
    );
  }
  if (number == null) {
    return PillToday(PillTodayState.pauseDay, settings: settings);
  }
  final t = settings.reminderTime;
  final lateFrom = DateTime(
    today.year,
    today.month,
    today.day,
    t.hour + 1,
    t.minute,
  );
  return PillToday(
    now.isBefore(lateFrom) ? PillTodayState.due : PillTodayState.late,
    settings: settings,
    pillNumber: number,
  );
});

/// Ticks [day]'s pill as taken at [at], then reloads my days.
final markPillTakenProvider =
    Provider<Future<Failure?> Function(DateTime day, DateTime at)>((ref) {
      return (day, at) async {
        final failure = await ref
            .read(pillRepositoryProvider)
            .markTaken(day, at);
        ref.invalidate(pillWeekProvider);
        return failure;
      };
    });

/// What my partner shares about today's pill; nothing without a partner.
final partnerPillTodayProvider = FutureProvider<PartnerPillToday>((ref) async {
  final partnerId = ref.watch(
    myProfileProvider.select((p) => p.valueOrNull?.partnerId),
  );
  if (partnerId == null || partnerId.isEmpty) return PartnerPillToday.nothing;
  final today = _day(ref.watch(clockProvider)());
  return ref.watch(pillRepositoryProvider).partnerToday(today);
});

/// Reads my partner's pill line again as soon as they tick it (Realtime on
/// their `pill_intakes`, which the database only shows me while shared).
/// Watched where the line shows.
final partnerPillLiveProvider = Provider<void>((ref) {
  final partnerId = ref.watch(
    myProfileProvider.select((p) => p.valueOrNull?.partnerId),
  );
  if (partnerId == null || partnerId.isEmpty) return;
  final channel = ref
      .read(realtimeChannelFactoryProvider)('pill-$partnerId')
      .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'pill_intakes',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'user_id',
          value: partnerId,
        ),
        callback: (_) => ref.invalidate(partnerPillTodayProvider),
      )
      .subscribe();
  ref.onDispose(channel.unsubscribe);
});
