import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:nousdeux/data/repositories/app_builds_repository_impl.dart';

AppBuildsRepositoryImpl repo(http.Response Function(http.Request) answer) =>
    AppBuildsRepositoryImpl(
      SupabaseClient(
        'https://api.test',
        'anon',
        httpClient: MockClient((request) async {
          final r = answer(request);
          return http.Response(
            r.body,
            r.statusCode,
            request: request,
            headers: {'content-type': 'application/json'},
          );
        }),
      ),
    );

void main() {
  test('reads the platform row', () async {
    late Uri asked;
    final row = await repo((request) {
      asked = request.url;
      return http.Response(
        jsonEncode([
          {
            'latest_build': 30,
            'min_build': 0,
            'note': {'fr': 'Le suivi de la pilule.'},
          },
        ]),
        200,
      );
    }).published('ios');
    expect(asked.queryParameters['platform'], 'eq.ios');
    expect(row?.latestBuild, 30);
    expect(row?.note, {'fr': 'Le suivi de la pilule.'});
  });

  test('no row reads as none', () async {
    expect(
      await repo((_) => http.Response('[]', 200)).published('ios'),
      isNull,
    );
  });

  test('a failed read is an error, not "nothing to show"', () {
    // The screen keeps its last answer on an error; "none" would take the
    // obligatory screen away in the metro.
    expect(
      repo((_) => http.Response('{"message":"down"}', 503)).published('ios'),
      throwsA(isA<PostgrestException>()),
    );
  });
}
