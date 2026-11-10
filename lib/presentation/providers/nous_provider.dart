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

final pingRepositoryProvider = Provider<PingRepository>((ref) {
  return PingRepositoryImpl();
});

/// Both people's latest little note, live. Empty until paired.
final couplePingsProvider = StreamProvider<List<PingEntity>>((ref) {
  final couple = ref.watch(myCoupleProvider).valueOrNull;
  if (couple == null || !couple.isPaired) return Stream.value(const []);
  return ref.watch(pingRepositoryProvider).watchPings();
});

PingEntity? _latestWhere(Ref ref, bool Function(String senderId) test) {
  final pings = ref.watch(couplePingsProvider).valueOrNull ?? const [];
  for (final ping in pings) {
    if (test(ping.senderId)) return ping;
  }
  return null;
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
  final events = ref.watch(calendarEventsProvider).valueOrNull ?? const [];
  return upcomingCountdowns(events, ref.watch(clockProvider)());
});
