import 'package:equatable/equatable.dart';

class PeriodLogEntity extends Equatable {
  const PeriodLogEntity({
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

  @override
  List<Object?> get props => [
        id,
        userId,
        coupleId,
        startDate,
        endDate,
        mood,
        symptoms,
        notes,
        createdAt,
        updatedAt,
      ];
}
