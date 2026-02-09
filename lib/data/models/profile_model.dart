import 'package:nous_deux/domain/entities/profile_entity.dart';

class ProfileModel {
  ProfileModel({
    required this.id,
    this.username,
    required this.gender,
    this.partnerId,
    this.language = 'fr',
    this.fcmToken,
    this.onboardingCompletedAt,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String? username;
  final String gender;
  final String? partnerId;
  final String language;
  final String? fcmToken;
  final DateTime? onboardingCompletedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String,
      username: json['username'] as String?,
      gender: json['gender'] as String? ?? 'woman',
      partnerId: json['partner_id'] as String?,
      language: json['language'] as String? ?? 'fr',
      fcmToken: json['fcm_token'] as String?,
      onboardingCompletedAt: json['onboarding_completed_at'] != null
          ? DateTime.parse(json['onboarding_completed_at'] as String)
          : null,
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
      'username': username,
      'gender': gender,
      'partner_id': partnerId,
      'language': language,
      'fcm_token': fcmToken,
      'onboarding_completed_at': onboardingCompletedAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  ProfileEntity toEntity() {
    return ProfileEntity(
      id: id,
      username: username,
      gender: gender,
      partnerId: partnerId,
      language: language,
      onboardingCompletedAt: onboardingCompletedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static ProfileModel fromEntity(ProfileEntity e) {
    return ProfileModel(
      id: e.id,
      username: e.username,
      gender: e.gender,
      partnerId: e.partnerId,
      language: e.language,
      onboardingCompletedAt: e.onboardingCompletedAt,
      createdAt: e.createdAt,
      updatedAt: e.updatedAt,
    );
  }
}
