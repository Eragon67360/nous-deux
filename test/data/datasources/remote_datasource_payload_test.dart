import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:nousdeux/data/datasources/calendar_remote_datasource.dart';
import 'package:nousdeux/data/datasources/period_remote_datasource.dart';

// What the datasources send to PostgREST. A real SupabaseClient is pointed at
// an in-memory HTTP client: no network, no Supabase.initialize.

const _eventRow = {
  'id': 'e1',
  'couple_id': 'c1',
  'title': 'Dîner',
  'description': null,
  'start_time': '2026-03-14T19:30:00.000Z',
  'end_time': null,
  'created_by': 'u1',
};

const _logRow = {
  'id': 'l1',
  'user_id': 'u1',
  'couple_id': 'c1',
  'start_date': '2026-03-01',
  'end_date': null,
  'mood': null,
  'symptoms': <String>[],
  'notes': null,
};

/// A client that answers every request with [row] and records the requests.
SupabaseClient _client(Map<String, Object?> row, List<http.Request> requests) {
  final client = SupabaseClient(
    'https://example.test',
    'anon-key',
    authOptions: const AuthClientOptions(autoRefreshToken: false),
    httpClient: MockClient((request) async {
      requests.add(request);
      return http.Response(
        jsonEncode(row),
        200,
        headers: {'content-type': 'application/json; charset=utf-8'},
        request: request, // postgrest reads response.request
      );
    }),
  );
  addTearDown(client.dispose);
  return client;
}

Map<String, dynamic> _body(http.Request r) =>
    jsonDecode(r.body) as Map<String, dynamic>;

void main() {
  group('CalendarRemoteDatasource', () {
    test('update sends every editable field, times in UTC', () async {
      final requests = <http.Request>[];
      final ds = CalendarRemoteDatasource(_client(_eventRow, requests));

      final updated = await ds.update(
        id: 'e1',
        title: 'Dîner',
        description: 'Chez ses parents',
        startTime: DateTime.utc(2026, 3, 14, 19, 30),
        endTime: DateTime.utc(2026, 3, 14, 21),
      );

      final r = requests.single;
      expect(r.method, 'PATCH');
      expect(r.url.path, '/rest/v1/calendar_events');
      expect(r.url.queryParameters['id'], 'eq.e1');
      expect(_body(r), {
        'title': 'Dîner',
        'description': 'Chez ses parents',
        'start_time': '2026-03-14T19:30:00.000Z',
        'end_time': '2026-03-14T21:00:00.000Z',
      });
      expect(updated.id, 'e1');
    });

    test('clearing the description on edit clears it in the database', () async {
      // Regression: update() used to drop null fields, so an emptied
      // description was never removed.
      final requests = <http.Request>[];
      final ds = CalendarRemoteDatasource(_client(_eventRow, requests));

      await ds.update(
        id: 'e1',
        title: 'Dîner',
        description: null,
        startTime: DateTime.utc(2026, 3, 14, 19, 30),
        endTime: DateTime.utc(2026, 3, 14, 21),
      );

      expect(_body(requests.single), containsPair('description', null));
    });

    test('create refuses to run signed out, before any request', () async {
      final requests = <http.Request>[];
      final ds = CalendarRemoteDatasource(_client(_eventRow, requests));

      await expectLater(
        ds.create(coupleId: 'c1', title: 'Dîner', startTime: DateTime(2026)),
        throwsA(isA<Exception>()),
      );
      expect(requests, isEmpty);
    });
  });

  group('PeriodRemoteDatasource', () {
    test('create sends date-only columns and an empty symptom list', () async {
      final requests = <http.Request>[];
      final ds = PeriodRemoteDatasource(_client(_logRow, requests));

      final created = await ds.create(
        userId: 'u1',
        coupleId: 'c1',
        startDate: DateTime(2026, 3, 1, 15, 30),
      );

      final r = requests.single;
      expect(r.method, 'POST');
      expect(r.url.path, '/rest/v1/period_logs');
      expect(_body(r), {
        'user_id': 'u1',
        'couple_id': 'c1',
        'start_date': '2026-03-01',
        'mood': null,
        'symptoms': <String>[],
        'notes': null,
      });
      expect(created.startDate, DateTime(2026, 3, 1));
    });

    test('create includes the end date only when given', () async {
      final requests = <http.Request>[];
      final ds = PeriodRemoteDatasource(_client(_logRow, requests));

      await ds.create(
        userId: 'u1',
        coupleId: 'c1',
        startDate: DateTime(2026, 3, 1),
        endDate: DateTime(2026, 3, 5),
        mood: 'tired',
        symptoms: ['cramps'],
        notes: 'Canapé',
      );

      expect(_body(requests.single), {
        'user_id': 'u1',
        'couple_id': 'c1',
        'start_date': '2026-03-01',
        'end_date': '2026-03-05',
        'mood': 'tired',
        'symptoms': ['cramps'],
        'notes': 'Canapé',
      });
    });

    test('update sends every editable field, dates as YYYY-MM-DD', () async {
      final requests = <http.Request>[];
      final ds = PeriodRemoteDatasource(_client(_logRow, requests));

      await ds.update(
        'l1',
        startDate: DateTime(2026, 3, 2),
        endDate: DateTime(2026, 3, 6),
        mood: 'tired',
        symptoms: const [],
        notes: 'Canapé',
      );

      final r = requests.single;
      expect(r.method, 'PATCH');
      expect(r.url.queryParameters['id'], 'eq.l1');
      expect(_body(r), {
        'start_date': '2026-03-02',
        'end_date': '2026-03-06',
        'mood': 'tired',
        'symptoms': <String>[],
        'notes': 'Canapé',
      });
    });

    test('clearing the end date, mood or notes on edit clears them', () async {
      // Regression: update() used to drop null fields, so a saved mood or
      // note could never be removed.
      final requests = <http.Request>[];
      final ds = PeriodRemoteDatasource(_client(_logRow, requests));

      await ds.update(
        'l1',
        startDate: DateTime(2026, 3, 1),
        endDate: null,
        mood: null,
        symptoms: const ['cramps'],
        notes: null,
      );

      final body = _body(requests.single);
      expect(body, containsPair('end_date', null));
      expect(body, containsPair('mood', null));
      expect(body, containsPair('notes', null));
    });
  });
}
