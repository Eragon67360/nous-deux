import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nous_deux/data/repositories/auth_repository_impl.dart';
import 'package:nous_deux/domain/entities/user_entity.dart';
import 'package:nous_deux/domain/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl();
});

/// Current auth user; null if signed out.
final currentUserProvider = StreamProvider<UserEntity?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});
