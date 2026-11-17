import 'package:equatable/equatable.dart';

class CalendarEventEntity extends Equatable {
  const CalendarEventEntity({
    required this.id,
    required this.coupleId,
    required this.title,
    this.description,
    required this.startTime,
    this.endTime,
    required this.createdBy,
    this.isCountdown = false,
    this.sourceKey,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String coupleId;
  final String title;
  final String? description;
  final DateTime startTime;
  final DateTime? endTime;
  final String createdBy;

  /// Counted down to on the Nous tab.
  final bool isCountdown;

  /// Set when the event is a copy from its author's followed phone calendar
  /// (docs/CALENDAR_SYNC.md); such events are changed on that phone.
  final String? sourceKey;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isSynced => sourceKey != null;

  /// Starts and ends at midnight (or ends at 23:59): an all-day event, as
  /// phone calendars send them; there is no all-day flag (docs/CALENDAR_SYNC.md).
  bool get looksAllDay {
    bool midnight(DateTime d) => d.hour == 0 && d.minute == 0;
    final end = endTime;
    return midnight(startTime) &&
        end != null &&
        (midnight(end) || (end.hour == 23 && end.minute == 59));
  }

  @override
  List<Object?> get props => [
    id,
    coupleId,
    title,
    description,
    startTime,
    endTime,
    createdBy,
    isCountdown,
    sourceKey,
    createdAt,
    updatedAt,
  ];
}
