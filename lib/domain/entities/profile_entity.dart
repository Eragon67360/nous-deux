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
    createdAt,
    updatedAt,
  ];
}
