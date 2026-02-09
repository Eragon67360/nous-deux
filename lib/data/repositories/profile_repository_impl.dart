import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:nous_deux/core/errors/failures.dart';
import 'package:nous_deux/data/datasources/profile_remote_datasource.dart';
import 'package:nous_deux/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl({ProfileRemoteDatasource? datasource})
      : _datasource = datasource ?? ProfileRemoteDatasource();

  final ProfileRemoteDatasource _datasource;

  String? get _userId => Supabase.instance.client.auth.currentUser?.id;

  @override
  Future<ProfileResult> getOrCreateMyProfile() async {
    final uid = _userId;
    if (uid == null) {
      return (profile: null, failure: const AuthFailure('Not signed in'));
    }
    try {
      var profile = await _datasource.getById(uid);
      profile ??= await _datasource.upsert({
        'id': uid,
        'gender': 'woman',
        'language': 'fr',
      });
      return (profile: profile.toEntity(), failure: null);
    } on PostgrestException catch (e) {
      return (profile: null, failure: ServerFailure(e.message));
    } catch (e) {
      return (profile: null, failure: UnknownFailure(e.toString()));
    }
  }

  @override
  Future<ProfileResult> getProfile(String profileId) async {
    try {
      final profile = await _datasource.getById(profileId);
      return (profile: profile?.toEntity(), failure: null);
    } on PostgrestException catch (e) {
      return (profile: null, failure: ServerFailure(e.message));
    } catch (e) {
      return (profile: null, failure: UnknownFailure(e.toString()));
    }
  }

  @override
  Future<ProfileResult> updateProfile({
    String? username,
    String? gender,
    String? language,
  }) async {
    final uid = _userId;
    if (uid == null) {
      return (profile: null, failure: const AuthFailure('Not signed in'));
    }
    try {
      final data = <String, dynamic>{};
      if (username != null) data['username'] = username;
      if (gender != null) data['gender'] = gender;
      if (language != null) data['language'] = language;
      if (data.isEmpty) {
        final existing = await _datasource.getById(uid);
        return (profile: existing?.toEntity(), failure: null);
      }
      final profile = await _datasource.update(uid, data);
      return (profile: profile.toEntity(), failure: null);
    } on PostgrestException catch (e) {
      return (profile: null, failure: ServerFailure(e.message));
    } catch (e) {
      return (profile: null, failure: UnknownFailure(e.toString()));
    }
  }

  @override
  Future<ProfileResult> updateFcmToken(String? token) async {
    final uid = _userId;
    if (uid == null) {
      return (profile: null, failure: const AuthFailure('Not signed in'));
    }
    try {
      final profile = await _datasource.update(uid, {'fcm_token': token});
      return (profile: profile.toEntity(), failure: null);
    } on PostgrestException catch (e) {
      return (profile: null, failure: ServerFailure(e.message));
    } catch (e) {
      return (profile: null, failure: UnknownFailure(e.toString()));
    }
  }
}
