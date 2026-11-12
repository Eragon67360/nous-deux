import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:nousdeux/core/constants/app_constants.dart';
import 'package:nousdeux/core/utils/apple_nonce.dart';

/// Remote data source for Supabase Auth (phone OTP, Google, Apple).
class AuthRemoteDatasource {
  AuthRemoteDatasource({SupabaseClient? client, GoogleSignIn? googleSignIn})
    : _client = client ?? Supabase.instance.client,
      _googleSignIn = googleSignIn ?? _defaultGoogleSignIn();

  final SupabaseClient _client;
  final GoogleSignIn _googleSignIn;

  /// Without the web client id, Android returns no ID token at all.
  static GoogleSignIn _defaultGoogleSignIn() {
    String? orNull(String v) => v.isEmpty ? null : v;
    return GoogleSignIn(
      clientId: defaultTargetPlatform == TargetPlatform.iOS
          ? orNull(AppConstants.googleIosClientId)
          : null,
      serverClientId: orNull(AppConstants.googleWebClientId),
    );
  }

  User? get currentUser => _client.auth.currentUser;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  /// Send OTP to phone (E.164 format). Returns null when OTP is sent (no session yet).
  Future<AuthResponse?> signInWithOtp({required String phone}) async {
    await _client.auth.signInWithOtp(phone: phone);
    final user = _client.auth.currentUser;
    if (user != null) {
      return AuthResponse(session: _client.auth.currentSession, user: user);
    }
    return null;
  }

  /// Verify OTP and complete sign-in.
  Future<AuthResponse> verifyOtp({
    required String phone,
    required String token,
  }) {
    return _client.auth.verifyOTP(
      phone: phone,
      token: token,
      type: OtpType.sms,
    );
  }

  /// Sign in with Google: get ID token and pass to Supabase.
  Future<AuthResponse> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw AuthException('Google sign-in cancelled');
    }
    final googleAuth = await googleUser.authentication;
    final idToken = googleAuth.idToken;
    if (idToken == null) {
      throw AuthException('No Google ID token');
    }
    return _client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
    );
  }

  /// Sign in with Apple (iOS): get the ID token, with a nonce, and pass it
  /// to Supabase.
  Future<AuthResponse> signInWithApple() async {
    final nonce = appleNonce();
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: nonce.hashed,
    );
    final idToken = credential.identityToken;
    if (idToken == null) {
      throw AuthException('No Apple ID token');
    }
    return _client.auth.signInWithIdToken(
      provider: OAuthProvider.apple,
      idToken: idToken,
      nonce: nonce.raw,
    );
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _client.auth.signOut();
  }
}
