import 'dart:math';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:nousdeux/core/constants/app_constants.dart';
import 'package:nousdeux/data/models/couple_model.dart';

class PairingRemoteDatasource {
  PairingRemoteDatasource([SupabaseClient? client])
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;
  final Random _random = Random();

  static const String _table = 'couples';

  String _generateCode() {
    const chars = AppConstants.pairingCodeChars;
    return List.generate(
      AppConstants.pairingCodeLength,
      (_) => chars[_random.nextInt(chars.length)],
    ).join();
  }

  Future<CoupleModel?> getMyCouple() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return null;
    final res = await _client
        .from(_table)
        .select()
        .or('user1_id.eq.$uid,user2_id.eq.$uid')
        .maybeSingle();
    if (res == null) return null;
    return CoupleModel.fromJson(Map<String, dynamic>.from(res));
  }

  /// Create couple with user1_id = current user and a unique pairing_code.
  Future<CoupleModel> createCouple() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) throw AuthException('Not signed in');
    String code;
    int attempts = 0;
    while (true) {
      code = _generateCode();
      final existing = await _client
          .from(_table)
          .select('id')
          .eq('pairing_code', code)
          .maybeSingle();
      if (existing == null) break;
      if (++attempts > 10)
        throw AuthException('Could not generate unique code');
    }
    final res = await _client
        .from(_table)
        .insert({'user1_id': uid, 'pairing_code': code})
        .select()
        .single();
    return CoupleModel.fromJson(Map<String, dynamic>.from(res));
  }

  /// Join couple by code: set user2_id = current user where pairing_code = code and user2_id is null.
  Future<CoupleModel> joinByCode(String code) async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) throw AuthException('Not signed in');
    final normalizedCode = code.trim().toUpperCase();
    if (normalizedCode.isEmpty)
      throw PostgrestException(message: 'Code requis');

    final existing = await _client
        .from(_table)
        .select()
        .eq('pairing_code', normalizedCode)
        .maybeSingle();
    if (existing == null) {
      throw PostgrestException(message: 'Code invalide');
    }
    final coupleId = existing['id'] as String;
    final user2Id = existing['user2_id'];
    if (user2Id != null && (user2Id as String).isNotEmpty) {
      throw PostgrestException(message: 'Ce code a déjà été utilisé');
    }
    final user1Id = existing['user1_id'] as String;
    if (user1Id == uid) {
      throw PostgrestException(
        message: 'Vous ne pouvez pas rejoindre votre propre lien',
      );
    }

    await _client.from(_table).update({'user2_id': uid}).eq('id', coupleId);

    final res = await _client.from(_table).select().eq('id', coupleId).single();
    return CoupleModel.fromJson(Map<String, dynamic>.from(res));
  }
}
