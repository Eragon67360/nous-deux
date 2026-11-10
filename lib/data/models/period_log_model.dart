import 'package:nousdeux/domain/entities/period_log_entity.dart';

class PeriodLogModel {
  PeriodLogModel({
    required this.id,
    required this.userId,
    required this.coupleId,
    required this.startDate,
    this.endDate,
    this.mood,
    this.symptoms = const [],
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String userId;
  final String coupleId;
  final DateTime startDate;
  final DateTime? endDate;
  final String? mood;
  final List<String> symptoms;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory PeriodLogModel.fromJson(Map<String, dynamic> json) {
    final startRaw = json['start_date'];
    final endRaw = json['end_date'];
    return PeriodLogModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      coupleId: json['couple_id'] as String,
      startDate: _parseDay(startRaw),
      endDate: endRaw == null ? null : _parseDay(endRaw),
      mood: json['mood'] as String?,
      symptoms: json['symptoms'] != null
          ? List<String>.from(json['symptoms'] as List)
          : [],
      notes: json['notes'] as String?,
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
      'user_id': userId,
      'couple_id': coupleId,
      'start_date': _dateOnly(startDate),
      'end_date': endDate != null ? _dateOnly(endDate!) : null,
      'mood': mood,
      'symptoms': symptoms,
      'notes': notes,
      'created_at': createdAt?.toUtc().toIso8601String(),
      'updated_at': updatedAt?.toUtc().toIso8601String(),
    };
  }

  /// `start_date` / `end_date` are Postgres DATE columns: calendar days with
  /// no timezone. Parse "YYYY-MM-DD" as a local date (not UTC midnight, which
  /// shows as the previous day west of UTC).
  static DateTime _parseDay(Object raw) {
    final text = '$raw';
    if (text.length == 10) return DateTime.parse(text);
    // A full timestamp: keep the calendar day it names in UTC, as Postgres
    // would when casting it to DATE.
    final t = DateTime.parse(text).toUtc();
    return DateTime(t.year, t.month, t.day);
  }

  static String _dateOnly(DateTime d) {
    final y = d.year;
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  PeriodLogEntity toEntity() {
    return PeriodLogEntity(
      id: id,
      userId: userId,
      coupleId: coupleId,
      startDate: startDate,
      endDate: endDate,
      mood: mood,
      symptoms: List.unmodifiable(symptoms),
      notes: notes,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
