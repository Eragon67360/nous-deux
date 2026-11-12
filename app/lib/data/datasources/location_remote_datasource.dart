import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:nousdeux/data/models/location_sharing_model.dart';

class LocationRemoteDatasource {
  LocationRemoteDatasource([SupabaseClient? client])
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;
  static const String _table = 'location_sharing';

  Future<LocationSharingModel?> getByUserId(String userId) async {
    final res = await _client
        .from(_table)
        .select()
        .eq('user_id', userId)
        .maybeSingle();
    if (res == null) return null;
    return LocationSharingModel.fromJson(Map<String, dynamic>.from(res));
  }

  /// Get partner's row. RLS allows SELECT when in same couple.
  Future<LocationSharingModel?> getPartnerByUserId(String partnerUserId) async {
    final res = await _client
        .from(_table)
        .select()
        .eq('user_id', partnerUserId)
        .maybeSingle();
    if (res == null) return null;
    return LocationSharingModel.fromJson(Map<String, dynamic>.from(res));
  }

  /// Upsert current user's row: insert if missing, else update.
  Future<LocationSharingModel> upsertMyLocation({
    required String userId,
    required String coupleId,
    required bool isSharing,
    double? lat,
    double? lng,
  }) async {
    final existing = await getByUserId(userId);
    final payload = <String, dynamic>{
      'is_sharing': isSharing,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };
    if (lat != null && lng != null) {
      payload['latitude'] = lat;
      payload['longitude'] = lng;
    }

    if (existing == null) {
      payload['user_id'] = userId;
      payload['couple_id'] = coupleId;
      final res = await _client
          .from(_table)
          .insert(payload)
          .select()
          .single();
      return LocationSharingModel.fromJson(Map<String, dynamic>.from(res));
    }

    final res = await _client
        .from(_table)
        .update(payload)
        .eq('user_id', userId)
        .select()
        .single();
    return LocationSharingModel.fromJson(Map<String, dynamic>.from(res));
  }
}
