import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:nousdeux/core/errors/failures.dart';
import 'package:nousdeux/data/datasources/location_remote_datasource.dart';
import 'package:nousdeux/domain/repositories/location_repository.dart';

class LocationRepositoryImpl implements LocationRepository {
  LocationRepositoryImpl({LocationRemoteDatasource? datasource})
      : _datasource = datasource ?? LocationRemoteDatasource();

  final LocationRemoteDatasource _datasource;

  @override
  Future<LocationSharingResult> getMyLocationSharing() async {
    try {
      final uid = Supabase.instance.client.auth.currentUser?.id;
      if (uid == null) return (entity: null, failure: AuthFailure('Not signed in'));
      final model = await _datasource.getByUserId(uid);
      return (entity: model?.toEntity(), failure: null);
    } on AuthException catch (e) {
      return (entity: null, failure: AuthFailure(e.message));
    } on PostgrestException catch (e) {
      return (entity: null, failure: ServerFailure(e.message));
    } catch (e) {
      return (entity: null, failure: UnknownFailure(e.toString()));
    }
  }

  @override
  Future<LocationSharingResult> getPartnerLocationSharing(String partnerUserId) async {
    try {
      final model = await _datasource.getPartnerByUserId(partnerUserId);
      return (entity: model?.toEntity(), failure: null);
    } on AuthException catch (e) {
      return (entity: null, failure: AuthFailure(e.message));
    } on PostgrestException catch (e) {
      return (entity: null, failure: ServerFailure(e.message));
    } catch (e) {
      return (entity: null, failure: UnknownFailure(e.toString()));
    }
  }

  @override
  Future<LocationSharingResult> setMyLocationSharing({
    required bool isSharing,
    required String coupleId,
    double? lat,
    double? lng,
  }) async {
    try {
      final uid = Supabase.instance.client.auth.currentUser?.id;
      if (uid == null) return (entity: null, failure: AuthFailure('Not signed in'));
      final model = await _datasource.upsertMyLocation(
        userId: uid,
        coupleId: coupleId,
        isSharing: isSharing,
        lat: lat,
        lng: lng,
      );
      return (entity: model.toEntity(), failure: null);
    } on AuthException catch (e) {
      return (entity: null, failure: AuthFailure(e.message));
    } on PostgrestException catch (e) {
      return (entity: null, failure: ServerFailure(e.message));
    } catch (e) {
      return (entity: null, failure: UnknownFailure(e.toString()));
    }
  }
}
