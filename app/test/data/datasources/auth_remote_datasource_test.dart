import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:nousdeux/data/datasources/auth_remote_datasource.dart';

/// Google sign-in that fails to sign out, as it does without Play services.
class _FailingGoogleSignIn extends GoogleSignIn {
  @override
  Future<GoogleSignInAccount?> signOut() async =>
      throw PlatformException(code: 'sign_out_failed');
}

/// Google sign-in that signs out without a platform channel.
class _QuietGoogleSignIn extends GoogleSignIn {
  @override
  Future<GoogleSignInAccount?> signOut() async => null;
}

/// A client signed in with a stored session (no network needed: a token
/// that isn't a JWT has no expiry), whose server answers [logoutStatus].
Future<(SupabaseClient, List<http.Request>)> _signedInClient(
  int logoutStatus,
) async {
  final requests = <http.Request>[];
  final client = SupabaseClient(
    'https://example.test',
    'anon-key',
    authOptions: const AuthClientOptions(autoRefreshToken: false),
    httpClient: MockClient((request) async {
      requests.add(request);
      return http.Response('', logoutStatus, request: request);
    }),
  );
  addTearDown(client.dispose);
  await client.auth.recoverSession(
    jsonEncode({
      'access_token': 'not-a-jwt',
      'token_type': 'bearer',
      'refresh_token': 'refresh',
      'user': {
        'id': 'u-1',
        'aud': 'authenticated',
        'app_metadata': <String, dynamic>{},
        'user_metadata': <String, dynamic>{},
        'created_at': '2026-11-17T00:00:00Z',
      },
    }),
  );
  expect(client.auth.currentSession, isNotNull);
  return (client, requests);
}

void main() {
  group('signOut', () {
    test('a server that fails to revoke the session still signs out here '
        '(GlitchTip APP-5: 504)', () async {
      final (client, requests) = await _signedInClient(504);

      await AuthRemoteDatasource(
        client: client,
        googleSignIn: _QuietGoogleSignIn(),
      ).signOut();

      expect(client.auth.currentSession, isNull);
      expect(requests.map((r) => r.url.path), contains('/auth/v1/logout'));
    });

    test('Google failing to sign out does not keep the session', () async {
      final (client, requests) = await _signedInClient(204);

      await AuthRemoteDatasource(
        client: client,
        googleSignIn: _FailingGoogleSignIn(),
      ).signOut();

      expect(client.auth.currentSession, isNull);
      expect(requests.map((r) => r.url.path), contains('/auth/v1/logout'));
    });
  });

  test(
    'the Apple authorization code goes to save_apple_authorization',
    () async {
      final requests = <http.Request>[];
      final client = SupabaseClient(
        'https://example.test',
        'anon-key',
        authOptions: const AuthClientOptions(autoRefreshToken: false),
        httpClient: MockClient((request) async {
          requests.add(request);
          return http.Response('', 204, request: request);
        }),
      );
      addTearDown(client.dispose);

      await AuthRemoteDatasource(
        client: client,
        googleSignIn: GoogleSignIn(),
      ).saveAppleAuthorization('c-one-time-code');

      expect(requests, hasLength(1));
      expect(requests.single.method, 'POST');
      expect(requests.single.url.path, '/rest/v1/rpc/save_apple_authorization');
      expect(jsonDecode(requests.single.body), {'code': 'c-one-time-code'});
    },
  );
}
