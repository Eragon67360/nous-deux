import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:nousdeux/data/models/profile_model.dart';

class ProfileRemoteDatasource {
  ProfileRemoteDatasource([SupabaseClient? client])
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  static const String _table = 'profiles';

  Future<ProfileModel?> getById(String id) async {
    final res = await _client.from(_table).select().eq('id', id).maybeSingle();
    if (res == null) return null;
    return ProfileModel.fromJson(Map<String, dynamic>.from(res));
  }

  Future<ProfileModel> upsert(Map<String, dynamic> data) async {
    final res = await _client
        .from(_table)
        .upsert(data, onConflict: 'id')
        .select()
        .single();
    return ProfileModel.fromJson(Map<String, dynamic>.from(res));
  }

  Future<ProfileModel> update(String id, Map<String, dynamic> data) async {
    final res = await _client
        .from(_table)
        .update(data)
        .eq('id', id)
        .select()
        .single();
    return ProfileModel.fromJson(Map<String, dynamic>.from(res));
  }
}
