import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:nousdeux/core/errors/failures.dart';
import 'package:nousdeux/data/datasources/pairing_remote_datasource.dart';
import 'package:nousdeux/data/datasources/ping_remote_datasource.dart';
import 'package:nousdeux/domain/entities/ping_entity.dart';
import 'package:nousdeux/domain/repositories/ping_repository.dart';

class PingRepositoryImpl implements PingRepository {
  PingRepositoryImpl({
    PingRemoteDatasource? pings,
    PairingRemoteDatasource? pairing,
  }) : _pings = pings ?? PingRemoteDatasource(),
       _pairing = pairing ?? PairingRemoteDatasource();

  final PingRemoteDatasource _pings;
  final PairingRemoteDatasource _pairing;

  @override
  Stream<List<PingEntity>> watchPings() async* {
    final couple = await _pairing.getMyCouple();
    if (couple == null || couple.user2Id == null) {
      yield const [];
      return;
    }
    yield* _pings
        .watch(couple.id)
        .map((rows) => rows.map((r) => r.toEntity()).toList());
  }

  @override
  Future<PingResult> send(PingKind kind) async {
    try {
      final model = await _pings.send(kind);
      return (ping: model.toEntity(), failure: null);
    } on PostgrestException catch (e) {
      final problem = switch (e.message) {
        'cooldown' => PingProblem.cooldown,
        'not_paired' => PingProblem.notPaired,
        _ => null,
      };
      return (
        ping: null,
        failure: problem != null ? PingFailure(problem) : ServerFailure(e.message),
      );
    } catch (e) {
      return (ping: null, failure: UnknownFailure(e.toString()));
    }
  }
}
