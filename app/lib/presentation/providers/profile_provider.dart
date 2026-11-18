import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nousdeux/core/errors/failures.dart';
import 'package:nousdeux/data/repositories/profile_repository_impl.dart';
import 'package:nousdeux/domain/entities/profile_entity.dart';
import 'package:nousdeux/domain/repositories/profile_repository.dart';
import 'package:nousdeux/presentation/providers/auth_provider.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl();
});

/// Current user's profile. Call [ref.refresh(myProfileProvider)] after onboarding/update.
///
/// No profile (null) means the account is gone, and the router signs out.
/// A profile that can't load for any other reason (no network, a timeout, a
/// server error) is a [ProfileUnavailableException]: the router keeps the
/// session and offers to try again. A refresh that fails after a profile
/// loaded keeps that profile as the value.
final myProfileProvider = FutureProvider<ProfileEntity?>((ref) async {
  final user = ref.watch(currentUserProvider).valueOrNull;
  if (user == null) return null;
  final repo = ref.watch(profileRepositoryProvider);
  final result = await repo.getOrCreateMyProfile();
  final failure = result.failure;
  if (failure == null) return result.profile;
  if (failure is NotFoundFailure) return null;
  throw ProfileUnavailableException(failure);
});

/// The profile couldn't load, though the account exists as far as we know.
class ProfileUnavailableException implements Exception {
  const ProfileUnavailableException(this.failure);

  final Failure failure;

  @override
  String toString() => 'ProfileUnavailableException($failure)';
}

/// Partner's profile (when current user has a partner). Used for display name in calendar/period.
final partnerProfileProvider = FutureProvider<ProfileEntity?>((ref) async {
  final my = await ref.watch(myProfileProvider.future);
  final partnerId = my?.partnerId;
  if (partnerId == null || partnerId.isEmpty) return null;
  final repo = ref.watch(profileRepositoryProvider);
  final result = await repo.getProfile(partnerId);
  return result.failure != null ? null : result.profile;
});
