import 'package:nous_deux/core/errors/failures.dart';
import 'package:nous_deux/domain/entities/calendar_event_entity.dart';

typedef CalendarEventResult = ({CalendarEventEntity? event, Failure? failure});
typedef CalendarEventsResult = ({
  List<CalendarEventEntity> events,
  Failure? failure,
});

abstract class CalendarRepository {
  /// Stream of calendar events for the current couple (realtime).
  Stream<List<CalendarEventEntity>> watchEvents();

  /// Fetch events in a date range.
  Future<CalendarEventsResult> getEvents({
    required DateTime start,
    required DateTime end,
  });

  /// Create event.
  Future<CalendarEventResult> createEvent({
    required String title,
    String? description,
    required DateTime startTime,
    DateTime? endTime,
  });

  /// Update event.
  Future<CalendarEventResult> updateEvent({
    required String id,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
  });

  /// Delete event.
  Future<Failure?> deleteEvent(String id);
}
