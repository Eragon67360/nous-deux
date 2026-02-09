import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nousdeux/data/repositories/profile_repository_impl.dart';
import 'package:nousdeux/domain/entities/profile_entity.dart';
import 'package:nousdeux/domain/repositories/profile_repository.dart';
import 'package:nousdeux/presentation/providers/auth_provider.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl();
});

/// Current user's profile. Call [ref.refresh(myProfileProvider)] after onboarding/update.
final myProfileProvider = FutureProvider<ProfileEntity?>((ref) async {
  final user = ref.watch(currentUserProvider).valueOrNull;
  if (user == null) return null;
  final repo = ref.watch(profileRepositoryProvider);
  final result = await repo.getOrCreateMyProfile();
  return result.failure != null ? null : result.profile;
});
