import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:nousdeux/core/errors/failures.dart';
import 'package:nousdeux/data/datasources/pairing_remote_datasource.dart';
import 'package:nousdeux/data/datasources/ping_remote_datasource.dart';
import 'package:nousdeux/data/models/ping_model.dart';
import 'package:nousdeux/data/repositories/ping_repository_impl.dart';
import 'package:nousdeux/domain/entities/ping_entity.dart';

class _ThrowingPings extends PingRemoteDatasource {
  _ThrowingPings(this.message) : super(SupabaseClient('https://example.test', 'k'));

  final String message;

  @override
  Future<PingModel> send(PingKind kind) =>
      Future.error(PostgrestException(message: message, code: 'P0001'));
}

PingRepositoryImpl _repo(String message) {
  final client = SupabaseClient('https://example.test', 'k');
  return PingRepositoryImpl(
    pings: _ThrowingPings(message),
    pairing: PairingRemoteDatasource(client),
  );
}

void main() {
  for (final (message, problem) in [
    ('cooldown', PingProblem.cooldown),
    ('not_paired', PingProblem.notPaired),
  ]) {
    test('"$message" from send_ping becomes $problem', () async {
      final repo = _repo(message);
      final result = await repo.send(PingKind.kiss);
      expect(result.failure, PingFailure(problem));
    });
  }

  test('any other database error stays a server failure', () async {
    final repo = _repo('boom');
    final result = await repo.send(PingKind.kiss);
    expect(result.failure, const ServerFailure('boom'));
  });

  group('PingModel.fromJson', () {
    test('reads a row', () {
      final m = PingModel.fromJson({
        'couple_id': 'c1',
        'sender_id': 'u1',
        'kind': 'on_my_way',
        'sent_at': '2026-11-10T17:00:00Z',
      })!;
      expect(m.kind, PingKind.onMyWay);
      expect(m.sentAt, DateTime.utc(2026, 11, 10, 17));
    });

    test('skips a kind this version does not know', () {
      expect(
        PingModel.fromJson({
          'couple_id': 'c1',
          'sender_id': 'u1',
          'kind': 'hug',
          'sent_at': '2026-11-10T17:00:00Z',
        }),
        isNull,
      );
    });
  });

  test('wire names match the database CHECK constraint', () {
    expect(PingKind.values.map((k) => k.wire), [
      'thinking_of_you',
      'good_night',
      'on_my_way',
      'miss_you',
      'kiss',
    ]);
  });
}
