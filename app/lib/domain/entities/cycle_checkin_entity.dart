import 'package:equatable/equatable.dart';

/// How one person's day felt: symptoms and mood, one per person and day.
/// The partner sees it while the owner shares their check-ins.
class CycleCheckinEntity extends Equatable {
  const CycleCheckinEntity({
    required this.userId,
    required this.day,
    this.symptoms = const [],
    this.mood,
  });

  final String userId;

  /// The calendar day, at local midnight.
  final DateTime day;
  final List<String> symptoms;
  final String? mood;

  bool get isEmpty => symptoms.isEmpty && (mood == null || mood!.isEmpty);

  @override
  List<Object?> get props => [userId, day, symptoms, mood];
}
