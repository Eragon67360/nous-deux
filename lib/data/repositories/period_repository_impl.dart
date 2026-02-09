import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:nousdeux/core/errors/failures.dart';
import 'package:nousdeux/data/datasources/pairing_remote_datasource.dart';
import 'package:nousdeux/data/datasources/period_remote_datasource.dart';
import 'package:nousdeux/domain/entities/period_log_entity.dart';
import 'package:nousdeux/domain/repositories/period_repository.dart';

class PeriodRepositoryImpl implements PeriodRepository {
  PeriodRepositoryImpl({
    PeriodRemoteDatasource? periodDs,
    PairingRemoteDatasource? pairingDs,
  }) : _period = periodDs ?? PeriodRemoteDatasource(),
       _pairing = pairingDs ?? PairingRemoteDatasource();

  final PeriodRemoteDatasource _period;
  final PairingRemoteDatasource _pairing;

  Future<String?> _getCoupleId() async {
    final couple = await _pairing.getMyCouple();
    return couple?.id;
  }

  @override
  Stream<List<PeriodLogEntity>> watchLogs() async* {
    final coupleId = await _getCoupleId();
    if (coupleId == null) {
      yield [];
      return;
    }
    yield* _period
        .watchLogs(coupleId)
        .map((list) => list.map((e) => e.toEntity()).toList());
  }

  @override
  Future<PeriodLogsResult> getLogs({DateTime? start, DateTime? end}) async {
    try {
      final coupleId = await _getCoupleId();
      if (coupleId == null) {
        return (logs: <PeriodLogEntity>[], failure: null);
      }
      final list = await _period.getLogs(
        coupleId: coupleId,
        start: start,
        end: end,
      );
      return (logs: list.map((e) => e.toEntity()).toList(), failure: null);
    } on PostgrestException catch (e) {
      return (logs: <PeriodLogEntity>[], failure: ServerFailure(e.message));
    } catch (e) {
      return (logs: <PeriodLogEntity>[], failure: UnknownFailure(e.toString()));
    }
  }

  @override
  Future<PeriodLogResult> createLog({
    required DateTime startDate,
    DateTime? endDate,
    String? mood,
    List<String>? symptoms,
    String? notes,
  }) async {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) {
      return (log: null, failure: const AuthFailure('Not signed in'));
    }
    try {
      final coupleId = await _getCoupleId();
      if (coupleId == null) {
        return (log: null, failure: const AuthFailure('No couple'));
      }
      final model = await _period.create(
        userId: uid,
        coupleId: coupleId,
        startDate: startDate,
        endDate: endDate,
        mood: mood,
        symptoms: symptoms,
        notes: notes,
      );
      return (log: model.toEntity(), failure: null);
    } on PostgrestException catch (e) {
      return (log: null, failure: ServerFailure(e.message));
    } catch (e) {
      return (log: null, failure: UnknownFailure(e.toString()));
    }
  }

  @override
  Future<PeriodLogResult> updateLog({
    required String id,
    DateTime? startDate,
    DateTime? endDate,
    String? mood,
    List<String>? symptoms,
    String? notes,
  }) async {
    try {
      final model = await _period.update(
        id,
        startDate: startDate,
        endDate: endDate,
        mood: mood,
        symptoms: symptoms,
        notes: notes,
      );
      return (log: model.toEntity(), failure: null);
    } on PostgrestException catch (e) {
      return (log: null, failure: ServerFailure(e.message));
    } catch (e) {
      return (log: null, failure: UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Failure?> deleteLog(String id) async {
    try {
      await _period.delete(id);
      return null;
    } on PostgrestException catch (e) {
      return ServerFailure(e.message);
    } catch (e) {
      return UnknownFailure(e.toString());
    }
  }
}
