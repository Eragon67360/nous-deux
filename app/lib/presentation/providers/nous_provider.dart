import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nousdeux/core/utils/date_only.dart';
import 'package:nousdeux/data/repositories/ping_repository_impl.dart';
import 'package:nousdeux/domain/entities/calendar_event_entity.dart';
import 'package:nousdeux/domain/entities/ping_entity.dart';
import 'package:nousdeux/domain/nous/nous_dates.dart';
import 'package:nousdeux/domain/repositories/ping_repository.dart';
import 'package:nousdeux/presentation/providers/auth_provider.dart';
import 'package:nousdeux/presentation/providers/calendar_provider.dart';
import 'package:nousdeux/presentation/providers/pairing_provider.dart';

/// "Now", injectable so tests can pin the date.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

/// Ticks every minute so time-based text (days together, "12 min ago",
/// countdowns) stays current while the tab is kept alive. Watch it, then
/// read [clockProvider].
final minuteTickProvider = StreamProvider<int>((ref) {
  return Stream.periodic(const Duration(minutes: 1), (i) => i + 1);
});

final pingRepositoryProvider = Provider<PingRepository>((ref) {
  return PingRepositoryImpl();
});

/// Both people's latest little note, live. Empty until paired.
final couplePingsProvider = StreamProvider<List<PingEntity>>((ref) {
  final couple = ref.watch(myCoupleProvider).valueOrNull;
  if (couple == null || !couple.isPaired) return Stream.value(const []);
  return ref.watch(pingRepositoryProvider).watchPings();
});

/// The newest note in [pings] whose sender passes [test].
PingEntity? latestPing(
  Iterable<PingEntity> pings,
  bool Function(String senderId) test,
) {
  PingEntity? latest;
  for (final ping in pings) {
    if (!test(ping.senderId)) continue;
    if (latest == null || ping.sentAt.isAfter(latest.sentAt)) latest = ping;
  }
  return latest;
}

PingEntity? _latestWhere(Ref ref, bool Function(String senderId) test) {
  return latestPing(
    ref.watch(couplePingsProvider).valueOrNull ?? const [],
    test,
  );
}

/// The partner's latest note, if any.
final partnerLastPingProvider = Provider<PingEntity?>((ref) {
  final me = ref.watch(currentUserProvider).valueOrNull?.id;
  if (me == null) return null;
  return _latestWhere(ref, (sender) => sender != me);
});

/// My latest note, if any (for the 30-second limit).
final myLastPingProvider = Provider<PingEntity?>((ref) {
  final me = ref.watch(currentUserProvider).valueOrNull?.id;
  if (me == null) return null;
  return _latestWhere(ref, (sender) => sender == me);
});

/// The day the relationship started: the stored day, else the day the
/// couple was created. Null until paired.
final togetherSinceProvider = Provider<DateTime?>((ref) {
  final couple = ref.watch(myCoupleProvider).valueOrNull;
  if (couple == null || !couple.isPaired) return null;
  if (couple.togetherSince != null) return couple.togetherSince;
  final created = couple.createdAt;
  return created == null ? null : dayOf(created.toLocal());
});

/// Countdown events still to come, soonest first.
final upcomingCountdownsProvider = Provider<List<CalendarEventEntity>>((ref) {
  ref.watch(minuteTickProvider);
  final events = ref.watch(calendarEventsProvider).valueOrNull ?? const [];
  return upcomingCountdowns(events, ref.watch(clockProvider)());
});
