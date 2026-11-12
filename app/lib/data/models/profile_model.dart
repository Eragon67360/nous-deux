import 'package:nousdeux/domain/entities/profile_entity.dart';

class ProfileModel {
  ProfileModel({
    required this.id,
    this.username,
    required this.gender,
    this.partnerId,
    this.language = 'fr',
    this.avatarUrl,
    this.fcmToken,
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
  final String? fcmToken;
  final DateTime? onboardingCompletedAt;
  final bool? tracksCycle;
  final bool shareCycle;
  final bool shareCheckins;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String,
      username: json['username'] as String?,
      gender: json['gender'] as String? ?? 'woman',
      partnerId: json['partner_id'] as String?,
      language: json['language'] as String? ?? 'fr',
      avatarUrl: json['avatar_url'] as String?,
      fcmToken: json['fcm_token'] as String?,
      onboardingCompletedAt: json['onboarding_completed_at'] != null
          ? DateTime.parse(json['onboarding_completed_at'] as String)
          : null,
      tracksCycle: json['tracks_cycle'] as bool?,
      shareCycle: json['share_cycle'] as bool? ?? true,
      shareCheckins: json['share_checkins'] as bool? ?? true,
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
      'avatar_url': avatarUrl,
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
      avatarUrl: avatarUrl,
      onboardingCompletedAt: onboardingCompletedAt,
      tracksCycle: tracksCycle,
      shareCycle: shareCycle,
      shareCheckins: shareCheckins,
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
      avatarUrl: e.avatarUrl,
      onboardingCompletedAt: e.onboardingCompletedAt,
      tracksCycle: e.tracksCycle,
      shareCycle: e.shareCycle,
      shareCheckins: e.shareCheckins,
      createdAt: e.createdAt,
      updatedAt: e.updatedAt,
    );
  }
}
