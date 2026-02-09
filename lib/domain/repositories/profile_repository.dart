import 'package:nous_deux/core/errors/failures.dart';
import 'package:nous_deux/domain/entities/profile_entity.dart';

typedef ProfileResult = ({ProfileEntity? profile, Failure? failure});

abstract class ProfileRepository {
  /// Get current user's profile. Creates one if missing.
  Future<ProfileResult> getOrCreateMyProfile();

  /// Get profile by id (own or partner only, by RLS).
  Future<ProfileResult> getProfile(String profileId);

  /// Update my profile (username, gender, language).
  Future<ProfileResult> updateProfile({
    String? username,
    String? gender,
    String? language,
  });

  /// Update FCM token for push notifications.
  Future<ProfileResult> updateFcmToken(String? token);
}
