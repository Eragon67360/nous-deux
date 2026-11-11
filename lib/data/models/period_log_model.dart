import 'package:nousdeux/core/utils/date_only.dart';
import 'package:nousdeux/domain/entities/period_log_entity.dart';

class PeriodLogModel {
  PeriodLogModel({
    required this.id,
    required this.userId,
    required this.coupleId,
    required this.startDate,
    this.endDate,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String userId;
  final String coupleId;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory PeriodLogModel.fromJson(Map<String, dynamic> json) {
    final startRaw = json['start_date'];
    final endRaw = json['end_date'];
    return PeriodLogModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      coupleId: json['couple_id'] as String,
      startDate: parseDay(startRaw),
      endDate: endRaw == null ? null : parseDay(endRaw),
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
      'start_date': formatDay(startDate),
      'end_date': endDate != null ? formatDay(endDate!) : null,
      'created_at': createdAt?.toUtc().toIso8601String(),
      'updated_at': updatedAt?.toUtc().toIso8601String(),
    };
  }

  PeriodLogEntity toEntity() {
    return PeriodLogEntity(
      id: id,
      userId: userId,
      coupleId: coupleId,
      startDate: startDate,
      endDate: endDate,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
