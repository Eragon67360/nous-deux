import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:nousdeux/data/models/ping_model.dart';
import 'package:nousdeux/domain/entities/ping_entity.dart';

class PingRemoteDatasource {
  PingRemoteDatasource([SupabaseClient? client])
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;
  static const String _table = 'couple_pings';

  /// Sends through the `send_ping` RPC, which checks the couple and the
  /// 30-second limit (raises `cooldown` or `not_paired`).
  Future<PingModel> send(PingKind kind) async {
    final res = await _client.rpc('send_ping', params: {'p_kind': kind.wire});
    final model = PingModel.fromJson(Map<String, dynamic>.from(res as Map));
    if (model == null) throw StateError('Unknown ping kind in response');
    return model;
  }

  /// Both people's latest note for the couple, live.
  Stream<List<PingModel>> watch(String coupleId) {
    return _client
        .from(_table)
        .stream(primaryKey: ['couple_id', 'sender_id'])
        .eq('couple_id', coupleId)
        .map(
          (rows) => rows
              .map((r) => PingModel.fromJson(Map<String, dynamic>.from(r)))
              .whereType<PingModel>()
              .toList(),
        );
  }
}
