import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:nousdeux/core/errors/failures.dart';
import 'package:nousdeux/data/datasources/pairing_remote_datasource.dart';
import 'package:nousdeux/domain/repositories/pairing_repository.dart';

class PairingRepositoryImpl implements PairingRepository {
  PairingRepositoryImpl({PairingRemoteDatasource? datasource})
    : _datasource = datasource ?? PairingRemoteDatasource();

  final PairingRemoteDatasource _datasource;

  @override
  Future<PairingResult> getMyCouple() async {
    try {
      final couple = await _datasource.getMyCouple();
      return (couple: couple?.toEntity(), failure: null);
    } on AuthException catch (e) {
      return (couple: null, failure: AuthFailure(e.message));
    } on PostgrestException catch (e) {
      return (couple: null, failure: ServerFailure(e.message));
    } catch (e) {
      return (couple: null, failure: UnknownFailure(e.toString()));
    }
  }

  @override
  Future<PairingResult> createCoupleAndGetCode() async {
    try {
      final couple = await _datasource.createCouple();
      return (couple: couple.toEntity(), failure: null);
    } on AuthException catch (e) {
      return (couple: null, failure: AuthFailure(e.message));
    } on PostgrestException catch (e) {
      return (couple: null, failure: ServerFailure(e.message));
    } catch (e) {
      return (couple: null, failure: UnknownFailure(e.toString()));
    }
  }

  @override
  Future<PairingResult> joinByCode(String code) async {
    try {
      final couple = await _datasource.joinByCode(code);
      return (couple: couple.toEntity(), failure: null);
    } on AuthException catch (e) {
      return (couple: null, failure: AuthFailure(e.message));
    } on PostgrestException catch (e) {
      return (couple: null, failure: ServerFailure(e.message));
    } catch (e) {
      return (couple: null, failure: UnknownFailure(e.toString()));
    }
  }
}
