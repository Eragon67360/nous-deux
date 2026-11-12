import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nousdeux/data/repositories/auth_repository_impl.dart';
import 'package:nousdeux/domain/entities/user_entity.dart';
import 'package:nousdeux/domain/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl();
});

/// Current auth user; null if signed out.
final currentUserProvider = StreamProvider<UserEntity?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});
