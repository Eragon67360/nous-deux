import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:nousdeux/data/datasources/live_rows.dart';
import 'package:nousdeux/data/models/period_log_model.dart';
import 'package:nousdeux/core/utils/date_only.dart';

class PeriodRemoteDatasource {
  PeriodRemoteDatasource([SupabaseClient? client])
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;
  static const String _table = 'period_logs';

  /// The couple's period logs, latest first, live (deletes included, see
  /// [watchCoupleRows]).
  Stream<List<PeriodLogModel>> watchLogs(String coupleId) {
    return watchCoupleRows(_client, table: _table, coupleId: coupleId).map(
      (rows) =>
          rows.map(PeriodLogModel.fromJson).toList()
            ..sort((a, b) => b.startDate.compareTo(a.startDate)),
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
      query = query.gte('start_date', formatDay(start));
    }
    if (end != null) {
      query = query.lte('start_date', formatDay(end));
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
      'start_date': formatDay(startDate),
      'mood': mood,
      'symptoms': symptoms ?? [],
      'notes': notes,
    };
    if (endDate != null) {
      data['end_date'] = formatDay(endDate);
    }
    final res = await _client.from(_table).insert(data).select().single();
    return PeriodLogModel.fromJson(Map<String, dynamic>.from(res as Map));
  }

  /// Full update of the editable fields. Null clears the end date, mood or
  /// notes.
  Future<PeriodLogModel> update(
    String id, {
    required DateTime startDate,
    required DateTime? endDate,
    required String? mood,
    required List<String> symptoms,
    required String? notes,
  }) async {
    final res = await _client
        .from(_table)
        .update({
          'start_date': formatDay(startDate),
          'end_date': endDate == null ? null : formatDay(endDate),
          'mood': mood,
          'symptoms': symptoms,
          'notes': notes,
        })
        .eq('id', id)
        .select()
        .single();
    return PeriodLogModel.fromJson(Map<String, dynamic>.from(res as Map));
  }

  Future<void> delete(String id) async {
    await _client.from(_table).delete().eq('id', id);
  }
}
