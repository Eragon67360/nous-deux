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
