import 'package:nousdeux/core/errors/failures.dart';
import 'package:nousdeux/domain/entities/calendar_event_entity.dart';

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
    bool isCountdown = false,
  });

  /// Update an event. Every editable field is sent; a null description
  /// clears it.
  Future<CalendarEventResult> updateEvent({
    required String id,
    required String title,
    required String? description,
    required DateTime startTime,
    required DateTime endTime,
    required bool isCountdown,
  });

  /// Delete event.
  Future<Failure?> deleteEvent(String id);
}
