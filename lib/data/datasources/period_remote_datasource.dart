import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:nousdeux/data/models/period_log_model.dart';

class PeriodRemoteDatasource {
  PeriodRemoteDatasource([SupabaseClient? client])
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;
  static const String _table = 'period_logs';

  /// Stream of period logs for the couple (realtime). Emits initial fetch then updates on INSERT/UPDATE/DELETE.
  Stream<List<PeriodLogModel>> watchLogs(String coupleId) {
    return _client
        .from(_table)
        .stream(primaryKey: ['id'])
        .eq('couple_id', coupleId)
        .order('start_date', ascending: false)
        .map(
          (event) => (event as List)
              .map(
                (e) => PeriodLogModel.fromJson(
                  Map<String, dynamic>.from(e as Map),
                ),
              )
              .toList(),
        );
  }

  /// Fetch period logs for a couple, optionally filtered by user and date range.
  Future<List<PeriodLogModel>> getLogs({
    required String coupleId,
    String? userId,
    DateTime? start,
    DateTime? end,
  }) async {
    var query = _client.from(_table).select().eq('couple_id', coupleId);
    if (userId != null) {
      query = query.eq('user_id', userId);
    }
    if (start != null) {
      query = query.gte('start_date', _dateOnly(start));
    }
    if (end != null) {
      query = query.lte('start_date', _dateOnly(end));
    }
    final res = await query.order('start_date', ascending: false);
    return (res as List)
        .map(
          (e) => PeriodLogModel.fromJson(Map<String, dynamic>.from(e as Map)),
        )
        .toList();
  }

  /// Create a period log. user_id and couple_id must be set by caller (repo).
  Future<PeriodLogModel> create({
    required String userId,
    required String coupleId,
    required DateTime startDate,
    DateTime? endDate,
    String? mood,
    List<String>? symptoms,
    String? notes,
  }) async {
    final data = <String, dynamic>{
      'user_id': userId,
      'couple_id': coupleId,
      'start_date': _dateOnly(startDate),
      'mood': mood,
      'symptoms': symptoms ?? [],
      'notes': notes,
    };
    if (endDate != null) {
      data['end_date'] = _dateOnly(endDate);
    }
    final res = await _client.from(_table).insert(data).select().single();
    return PeriodLogModel.fromJson(Map<String, dynamic>.from(res as Map));
  }

  Future<PeriodLogModel> update(
    String id, {
    DateTime? startDate,
    DateTime? endDate,
    String? mood,
    List<String>? symptoms,
    String? notes,
  }) async {
    final data = <String, dynamic>{};
    if (startDate != null) data['start_date'] = _dateOnly(startDate);
    if (endDate != null) data['end_date'] = _dateOnly(endDate);
    if (mood != null) data['mood'] = mood;
    if (symptoms != null) data['symptoms'] = symptoms;
    if (notes != null) data['notes'] = notes;

    if (data.isEmpty) {
      final res = await _client.from(_table).select().eq('id', id).single();
      return PeriodLogModel.fromJson(Map<String, dynamic>.from(res as Map));
    }
    final res = await _client
        .from(_table)
        .update(data)
        .eq('id', id)
        .select()
        .single();
    return PeriodLogModel.fromJson(Map<String, dynamic>.from(res as Map));
  }

  Future<void> delete(String id) async {
    await _client.from(_table).delete().eq('id', id);
  }

  static String _dateOnly(DateTime d) {
    final y = d.year;
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }
}
