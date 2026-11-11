import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:nousdeux/core/errors/failures.dart';
import 'package:nousdeux/data/datasources/cycle_remote_datasource.dart';
import 'package:nousdeux/data/datasources/pairing_remote_datasource.dart';
import 'package:nousdeux/domain/entities/cycle_checkin_entity.dart';
import 'package:nousdeux/domain/repositories/cycle_repository.dart';

class CycleRepositoryImpl implements CycleRepository {
  CycleRepositoryImpl({
    CycleRemoteDatasource? cycleDs,
    PairingRemoteDatasource? pairingDs,
  }) : _cycle = cycleDs ?? CycleRemoteDatasource(),
       _pairing = pairingDs ?? PairingRemoteDatasource();

  final CycleRemoteDatasource _cycle;
  final PairingRemoteDatasource _pairing;

  String? get _userId => Supabase.instance.client.auth.currentUser?.id;

  Future<String?> _coupleId() async => (await _pairing.getMyCouple())?.id;

  @override
  Stream<List<CycleCheckinEntity>> watchCheckins() async* {
    final coupleId = await _coupleId();
    if (coupleId == null) {
      yield const [];
      return;
    }
    yield* _cycle.watchCheckins(coupleId);
  }

  @override
  Future<Failure?> saveCheckin({
    required DateTime day,
    required List<String> symptoms,
    String? mood,
  }) async {
    final uid = _userId;
    if (uid == null) return const AuthFailure('Not signed in');
    try {
      final coupleId = await _coupleId();
      if (coupleId == null) return const AuthFailure('No couple');
      await _cycle.saveCheckin(
        userId: uid,
        coupleId: coupleId,
        day: day,
        symptoms: symptoms,
        mood: mood,
      );
      return null;
    } on PostgrestException catch (e) {
      return ServerFailure(e.message);
    } catch (e) {
      return UnknownFailure(e.toString());
    }
  }

  @override
  Future<String?> noteFor(DateTime day) async {
    final uid = _userId;
    if (uid == null) return null;
    try {
      return await _cycle.getNote(userId: uid, day: day);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Failure?> saveNote(DateTime day, String note) async {
    final uid = _userId;
    if (uid == null) return const AuthFailure('Not signed in');
    try {
      await _cycle.saveNote(userId: uid, day: day, note: note);
      return null;
    } on PostgrestException catch (e) {
      return ServerFailure(e.message);
    } catch (e) {
      return UnknownFailure(e.toString());
    }
  }
}
