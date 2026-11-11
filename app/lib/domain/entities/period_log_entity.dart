import 'package:equatable/equatable.dart';

/// One period: its dates only. How the day felt lives in cycle check-ins,
/// private words in cycle notes.
class PeriodLogEntity extends Equatable {
  const PeriodLogEntity({
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

  @override
  List<Object?> get props => [
    id,
    userId,
    coupleId,
    startDate,
    endDate,
    createdAt,
    updatedAt,
  ];
}
