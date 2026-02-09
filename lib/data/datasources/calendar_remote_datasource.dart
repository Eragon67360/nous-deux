import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:nous_deux/data/models/calendar_event_model.dart';

class CalendarRemoteDatasource {
  CalendarRemoteDatasource([SupabaseClient? client])
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;
  static const String _table = 'calendar_events';

  String? get _userId => _client.auth.currentUser?.id;

  /// Stream of calendar events for couple. Emits initial fetch; use repo invalidation for refetch after mutations.
  Stream<List<CalendarEventModel>> watchEvents(String coupleId) async* {
    final list = await getEvents(
      coupleId: coupleId,
      start: DateTime(2000),
      end: DateTime(2100),
    );
    yield list;
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

  Future<CalendarEventModel> update({
    required String id,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    final data = <String, dynamic>{};
    if (title != null) data['title'] = title;
    if (description != null) data['description'] = description;
    if (startTime != null) {
      data['start_time'] = startTime.toUtc().toIso8601String();
    }
    if (endTime != null) {
      data['end_time'] = endTime.toUtc().toIso8601String();
    }
    if (data.isEmpty) {
      final res = await _client.from(_table).select().eq('id', id).single();
      return CalendarEventModel.fromJson(Map<String, dynamic>.from(res as Map));
    }
    final res = await _client
        .from(_table)
        .update(data)
        .eq('id', id)
        .select()
        .single();
    return CalendarEventModel.fromJson(Map<String, dynamic>.from(res as Map));
  }

  Future<void> delete(String id) async {
    await _client.from(_table).delete().eq('id', id);
  }
}
