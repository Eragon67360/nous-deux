import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nous_deux/data/repositories/calendar_repository_impl.dart';
import 'package:nous_deux/domain/entities/calendar_event_entity.dart';
import 'package:nous_deux/domain/repositories/calendar_repository.dart';

final calendarRepositoryProvider = Provider<CalendarRepository>((ref) {
  return CalendarRepositoryImpl();
});

/// Stream of calendar events for the current couple. Refetch by invalidating.
final calendarEventsProvider = StreamProvider<List<CalendarEventEntity>>((ref) {
  return ref.watch(calendarRepositoryProvider).watchEvents();
});
