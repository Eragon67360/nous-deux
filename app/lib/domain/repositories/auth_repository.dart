import 'package:nousdeux/core/errors/failures.dart';
import 'package:nousdeux/domain/entities/user_entity.dart';

/// Result type for auth operations.
typedef AuthResult = ({UserEntity? user, Failure? failure});

abstract class AuthRepository {
  /// Stream of auth state changes (signed in / signed out).
  Stream<UserEntity?> get authStateChanges;

  /// Current user if signed in.
  UserEntity? get currentUser;

  /// Send OTP to [phone] (e.g. +33612345678).
  Future<AuthResult> signInWithOtp({required String phone});

  /// Verify OTP and sign in.
  Future<AuthResult> verifyOtp({required String phone, required String token});

  /// Sign in with Google (getIdToken then Supabase signInWithIdToken).
  Future<AuthResult> signInWithGoogle();

  /// Sign in with Apple (get credential then Supabase signInWithIdToken).
  Future<AuthResult> signInWithApple();

  /// Sign out.
  Future<void> signOut();
}
