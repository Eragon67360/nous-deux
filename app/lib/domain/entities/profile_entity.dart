import 'package:equatable/equatable.dart';

class ProfileEntity extends Equatable {
  const ProfileEntity({
    required this.id,
    this.username,
    required this.gender,
    this.partnerId,
    this.language = 'fr',
    this.avatarUrl,
    this.onboardingCompletedAt,
    this.tracksCycle,
    this.shareCycle = true,
    this.shareCheckins = true,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String? username;
  final String gender;
  final String? partnerId;
  final String language;
  final String? avatarUrl;
  final DateTime? onboardingCompletedAt;

  /// Whether this person tracks a cycle in the app; null until asked.
  final bool? tracksCycle;

  /// The partner may see this person's period dates (day, phase, expected
  /// date) and get the reminder.
  final bool shareCycle;

  /// The partner may see this person's daily check-ins.
  final bool shareCheckins;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get hasPartner => partnerId != null && partnerId!.isNotEmpty;

  bool get hasCompletedOnboarding => onboardingCompletedAt != null;

  @override
  List<Object?> get props => [
    id,
    username,
    gender,
    partnerId,
    language,
    avatarUrl,
    onboardingCompletedAt,
    tracksCycle,
    shareCycle,
    shareCheckins,
    createdAt,
    updatedAt,
  ];
}
