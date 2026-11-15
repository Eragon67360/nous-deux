import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:nousdeux/data/models/couple_model.dart';

import 'package:nousdeux/core/errors/failures.dart';
import 'package:nousdeux/core/utils/date_only.dart';

class PairingRemoteDatasource {
  PairingRemoteDatasource([SupabaseClient? client])
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  static const String _table = 'couples';

  /// Sets `together_since` on the current couple (a calendar day).
  Future<void> updateTogetherSince(String coupleId, DateTime day) async {
    await _client
        .from(_table)
        .update({'together_since': formatDay(day)})
        .eq('id', coupleId);
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

  /// The current user's invite: their waiting couple, or a new one whose code
  /// the database draws (RPC create_couple).
  Future<CoupleModel> createCouple() async {
    final res = await _client.rpc('create_couple');
    return CoupleModel.fromJson(Map<String, dynamic>.from(res as Map));
  }

  /// Joins the couple whose code was typed or scanned (RPC join_couple). The
  /// database checks the code and limits wrong guesses; [today] is the
  /// joiner's local day, the server's being UTC.
  Future<CoupleModel> joinByCode(String code, {DateTime? today}) async {
    final normalizedCode = code.trim().toUpperCase();
    if (normalizedCode.isEmpty) {
      throw const PairingException(PairingProblem.invalidCode);
    }
    final status = await _client.rpc(
      'join_couple',
      params: {
        'p_code': normalizedCode,
        'p_day': formatDay(today ?? DateTime.now()),
      },
    );
    final problem = switch (status) {
      'joined' => null,
      'code_used' => PairingProblem.codeUsed,
      'own_code' => PairingProblem.ownCode,
      'already_paired' => PairingProblem.alreadyPaired,
      'too_many_attempts' => PairingProblem.tooManyAttempts,
      _ => PairingProblem.invalidCode,
    };
    if (problem != null) throw PairingException(problem);
    final couple = await getMyCouple();
    if (couple == null) {
      throw const PairingException(PairingProblem.invalidCode);
    }
    return couple;
  }

  /// Leave current couple (RPC: clear partner_id on both profiles, delete couple row).
  Future<void> leaveCouple() async {
    await _client.rpc('leave_couple');
  }
}

/// A join attempt the server refused, with the reason.
class PairingException implements Exception {
  const PairingException(this.problem);

  final PairingProblem problem;

  @override
  String toString() => 'PairingException($problem)';
}
