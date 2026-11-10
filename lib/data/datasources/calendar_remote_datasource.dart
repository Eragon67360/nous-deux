import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:nousdeux/data/models/calendar_event_model.dart';

class CalendarRemoteDatasource {
  CalendarRemoteDatasource([SupabaseClient? client])
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;
  static const String _table = 'calendar_events';

  String? get _userId => _client.auth.currentUser?.id;

  /// Stream of calendar events for couple (realtime). Emits initial fetch then updates on INSERT/UPDATE/DELETE.
  Stream<List<CalendarEventModel>> watchEvents(String coupleId) {
    return _client
        .from(_table)
        .stream(primaryKey: ['id'])
        .eq('couple_id', coupleId)
        .order('start_time')
        .map(
          (event) => (event as List)
              .map(
                (e) => CalendarEventModel.fromJson(
                  Map<String, dynamic>.from(e as Map),
                ),
              )
              .toList(),
        );
  }

  Future<List<CalendarEventModel>> getEvents({
    required String coupleId,
    required DateTime start,
    required DateTime end,
  }) async {
    final startStr = start.toUtc().toIso8601String();
    final endStr = end.toUtc().toIso8601String();
    final res = await _client
        .from(_table)
        .select()
        .eq('couple_id', coupleId)
        .gte('start_time', startStr)
        .lte('start_time', endStr)
        .order('start_time');
    return (res as List)
        .map(
          (e) =>
              CalendarEventModel.fromJson(Map<String, dynamic>.from(e as Map)),
        )
        .toList();
  }

  Future<CalendarEventModel> create({
    required String coupleId,
    required String title,
    String? description,
    required DateTime startTime,
    DateTime? endTime,
  }) async {
    final uid = _userId;
    if (uid == null) throw Exception('Not signed in');
    final res = await _client
        .from(_table)
        .insert({
          'couple_id': coupleId,
          'title': title,
          'description': description,
          'start_time': startTime.toUtc().toIso8601String(),
          'end_time': endTime?.toUtc().toIso8601String(),
          'created_by': uid,
        })
        .select()
        .single();
    return CalendarEventModel.fromJson(Map<String, dynamic>.from(res as Map));
  }

  /// Full update of the editable fields. A null [description] clears it.
  Future<CalendarEventModel> update({
    required String id,
    required String title,
    required String? description,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    final res = await _client
        .from(_table)
        .update({
          'title': title,
          'description': description,
          'start_time': startTime.toUtc().toIso8601String(),
          'end_time': endTime.toUtc().toIso8601String(),
        })
        .eq('id', id)
        .select()
        .single();
    return CalendarEventModel.fromJson(Map<String, dynamic>.from(res as Map));
  }

  Future<void> delete(String id) async {
    await _client.from(_table).delete().eq('id', id);
  }
}
