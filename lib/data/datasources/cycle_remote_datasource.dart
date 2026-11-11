import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:nousdeux/core/utils/date_only.dart';
import 'package:nousdeux/data/datasources/live_rows.dart';
import 'package:nousdeux/domain/entities/cycle_checkin_entity.dart';

/// Daily check-ins (shared with the partner, per the owner's setting) and
/// private notes (never shared). Row access is enforced by the database.
class CycleRemoteDatasource {
  CycleRemoteDatasource([SupabaseClient? client])
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;
  static const String _checkins = 'cycle_checkins';
  static const String _notes = 'cycle_notes';

  static CycleCheckinEntity checkinFromJson(Map<String, dynamic> json) {
    return CycleCheckinEntity(
      userId: json['user_id'] as String,
      day: parseDay(json['day'] as String),
      symptoms: (json['symptoms'] as List?)?.cast<String>() ?? const [],
      mood: json['mood'] as String?,
    );
  }

  /// The couple's check-ins the caller may read, live.
  Stream<List<CycleCheckinEntity>> watchCheckins(String coupleId) {
    return watchCoupleRows(
      _client,
      table: _checkins,
      coupleId: coupleId,
    ).map((rows) => rows.map(checkinFromJson).toList());
  }

  /// Writes the caller's check-in for [day]; an empty one is deleted.
  Future<void> saveCheckin({
    required String userId,
    required String coupleId,
    required DateTime day,
    required List<String> symptoms,
    required String? mood,
  }) async {
    if (symptoms.isEmpty && (mood == null || mood.isEmpty)) {
      await _client
          .from(_checkins)
          .delete()
          .eq('user_id', userId)
          .eq('day', formatDay(day));
      return;
    }
    await _client.from(_checkins).upsert({
      'user_id': userId,
      'couple_id': coupleId,
      'day': formatDay(day),
      'symptoms': symptoms,
      'mood': mood,
    }, onConflict: 'user_id,day');
  }

  /// The caller's private note for [day], if any.
  Future<String?> getNote({required String userId, required DateTime day}) {
    return _client
        .from(_notes)
        .select('note')
        .eq('user_id', userId)
        .eq('day', formatDay(day))
        .maybeSingle()
        .then((row) => row?['note'] as String?);
  }

  /// Saves the caller's private note for [day]; a blank one is deleted.
  Future<void> saveNote({
    required String userId,
    required DateTime day,
    required String note,
  }) async {
    final text = note.trim();
    if (text.isEmpty) {
      await _client
          .from(_notes)
          .delete()
          .eq('user_id', userId)
          .eq('day', formatDay(day));
      return;
    }
    await _client.from(_notes).upsert({
      'user_id': userId,
      'day': formatDay(day),
      'note': text,
    }, onConflict: 'user_id,day');
  }
}
