import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:nousdeux/core/errors/failures.dart';
import 'package:nousdeux/data/datasources/auth_remote_datasource.dart';
import 'package:nousdeux/domain/entities/user_entity.dart';
import 'package:nousdeux/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({AuthRemoteDatasource? datasource})
    : _datasource = datasource ?? AuthRemoteDatasource();

  final AuthRemoteDatasource _datasource;

  static UserEntity? _userFromSupabase(User? user) {
    if (user == null) return null;
    return UserEntity(id: user.id, phone: user.phone, email: user.email);
  }

  @override
  Stream<UserEntity?> get authStateChanges => _datasource.authStateChanges.map(
    (state) => _userFromSupabase(state.session?.user),
  );

  @override
  UserEntity? get currentUser => _userFromSupabase(_datasource.currentUser);

  @override
  Future<AuthResult> signInWithOtp({required String phone}) async {
    try {
      final res = await _datasource.signInWithOtp(phone: phone);
      if (res != null && res.user != null) {
        return (user: _userFromSupabase(res.user), failure: null);
      }
      // OTP sent; no session yet
      return (user: null, failure: null);
    } on AuthException catch (e) {
      return (user: null, failure: AuthFailure(e.message));
    } catch (e) {
      return (user: null, failure: UnknownFailure(e.toString()));
    }
  }

  @override
  Future<AuthResult> verifyOtp({
    required String phone,
    required String token,
  }) async {
    try {
      final res = await _datasource.verifyOtp(phone: phone, token: token);
      return (user: _userFromSupabase(res.user), failure: null);
    } on AuthException catch (e) {
      return (user: null, failure: AuthFailure(e.message));
    } catch (e) {
      return (user: null, failure: UnknownFailure(e.toString()));
    }
  }

  @override
  Future<AuthResult> signInWithGoogle() async {
    try {
      final res = await _datasource.signInWithGoogle();
      return (user: _userFromSupabase(res.user), failure: null);
    } on AuthException catch (e) {
      return (user: null, failure: AuthFailure(e.message));
    } catch (e) {
      return (user: null, failure: UnknownFailure(e.toString()));
    }
  }

  @override
  Future<AuthResult> signInWithApple() async {
    try {
      final res = await _datasource.signInWithApple();
      return (user: _userFromSupabase(res.user), failure: null);
    } on AuthException catch (e) {
      return (user: null, failure: AuthFailure(e.message));
    } catch (e) {
      return (user: null, failure: UnknownFailure(e.toString()));
    }
  }

  @override
  Future<void> signOut() => _datasource.signOut();
}
