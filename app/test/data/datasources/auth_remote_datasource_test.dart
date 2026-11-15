import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:nousdeux/data/datasources/auth_remote_datasource.dart';

void main() {
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
