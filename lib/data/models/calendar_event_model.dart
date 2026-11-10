import 'package:nousdeux/domain/entities/calendar_event_entity.dart';

class CalendarEventModel {
  CalendarEventModel({
    required this.id,
    required this.coupleId,
    required this.title,
    this.description,
    required this.startTime,
    this.endTime,
    required this.createdBy,
    this.isCountdown = false,
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
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory CalendarEventModel.fromJson(Map<String, dynamic> json) {
    return CalendarEventModel(
      id: json['id'] as String,
      coupleId: json['couple_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: json['end_time'] != null
          ? DateTime.parse(json['end_time'] as String)
          : null,
      createdBy: json['created_by'] as String,
      isCountdown: json['is_countdown'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'couple_id': coupleId,
      'title': title,
      'description': description,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'created_by': createdBy,
      'is_countdown': isCountdown,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  CalendarEventEntity toEntity() {
    return CalendarEventEntity(
      id: id,
      coupleId: coupleId,
      title: title,
      description: description,
      startTime: startTime,
      endTime: endTime,
      createdBy: createdBy,
      isCountdown: isCountdown,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
