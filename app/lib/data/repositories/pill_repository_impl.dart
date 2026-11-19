import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/timezone.dart' as tz;

import 'package:nousdeux/core/errors/failures.dart';
import 'package:nousdeux/domain/entities/pill_entities.dart';
import 'package:nousdeux/domain/pill/pill_schedule.dart';
import 'package:nousdeux/domain/repositories/pill_repository.dart';

String _date(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

String _time(TimeOfDayValue t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

TimeOfDayValue _parseTime(String raw) {
  final parts = raw.split(':');
  return (hour: int.parse(parts[0]), minute: int.parse(parts[1]));
}

DateTime _parseDay(String raw) {
  final d = DateTime.parse(raw);
  return DateTime(d.year, d.month, d.day);
}

class PillRepositoryImpl implements PillRepository {
  SupabaseClient get _client => Supabase.instance.client;

  String? get _userId => _client.auth.currentUser?.id;

  Future<Failure?> _guard(Future<void> Function(String uid) write) async {
    final uid = _userId;
    if (uid == null) return const AuthFailure('Not signed in');
    try {
      await write(uid);
      return null;
    } on PostgrestException catch (e) {
      return ServerFailure(e.message);
    } catch (e) {
      return UnknownFailure(e.toString());
    }
  }

  @override
  Future<PillSettings?> mySettings() async {
    final uid = _userId;
    if (uid == null) return null;
    final row = await _client
        .from('pill_tracking')
        .select(
          'pack_type, pack_started_on, reminder_on, reminder_time, reminder_text, share_with_partner, time_zone',
        )
        .eq('user_id', uid)
        .maybeSingle();
    if (row == null) return null;
    final type = PackType.fromWire(row['pack_type'] as String?);
    if (type == null) return null;
    return PillSettings(
      packType: type,
      packStartedOn: _parseDay(row['pack_started_on'] as String),
      reminderOn: row['reminder_on'] as bool? ?? true,
      reminderTime: _parseTime(row['reminder_time'] as String? ?? '21:00'),
      reminderText: ReminderText.fromWire(row['reminder_text'] as String?),
      shareWithPartner: row['share_with_partner'] as bool? ?? true,
      timeZone: row['time_zone'] as String? ?? 'UTC',
    );
  }

  @override
  Future<Failure?> saveSettings(PillSettings s) => _guard(
    (uid) => _client.from('pill_tracking').upsert({
      'user_id': uid,
      'pack_type': s.packType.wire,
      'pack_started_on': _date(s.packStartedOn),
      'reminder_on': s.reminderOn,
      'reminder_time': _time(s.reminderTime),
      'reminder_text': s.reminderText.wire,
      'share_with_partner': s.shareWithPartner,
      // Always the phone's zone now: "today" for the partner's line.
      'time_zone': tz.local.name,
    }),
  );

  @override
  Future<List<PillIntake>> myIntakes({required DateTime from}) async {
    final uid = _userId;
    if (uid == null) return const [];
    final rows = await _client
        .from('pill_intakes')
        .select('day, status, taken_at')
        .eq('user_id', uid)
        .gte('day', _date(from))
        .order('day');
    return [
      for (final r in rows)
        r['status'] == 'taken' && r['taken_at'] != null
            ? PillIntake.taken(
                _parseDay(r['day'] as String),
                DateTime.parse(r['taken_at'] as String).toLocal(),
              )
            : PillIntake.missed(_parseDay(r['day'] as String)),
    ];
  }

  @override
  Future<Failure?> markTaken(DateTime day, DateTime at) => _guard(
    (uid) => _client.from('pill_intakes').upsert({
      'user_id': uid,
      'day': _date(day),
      'status': 'taken',
      'taken_at': at.toUtc().toIso8601String(),
    }, onConflict: 'user_id,day'),
  );

  @override
  Future<Failure?> markMissed(DateTime day) => _guard(
    (uid) => _client.from('pill_intakes').upsert({
      'user_id': uid,
      'day': _date(day),
      'status': 'missed',
      'taken_at': null,
    }, onConflict: 'user_id,day'),
  );

  @override
  Future<Failure?> unmark(DateTime day) => _guard(
    (uid) => _client
        .from('pill_intakes')
        .delete()
        .eq('user_id', uid)
        .eq('day', _date(day)),
  );

  @override
  Future<Failure?> stopTracking() =>
      _guard((_) => _client.rpc('stop_pill_tracking'));

  @override
  Future<PartnerPillToday> partnerToday(DateTime day) async {
    // The server answers for my partner's own today, whatever [day] is here.
    final rows = await _client.rpc('partner_pill_today');
    final list = rows is List ? rows : const [];
    if (list.isEmpty) return PartnerPillToday.nothing;
    final r = list.first as Map<String, dynamic>;
    final takenAt = r['taken_at'] as String?;
    return PartnerPillToday(
      tracking: r['tracking'] as bool? ?? false,
      expected: r['expected'] as bool? ?? false,
      takenAt: takenAt == null ? null : DateTime.parse(takenAt).toLocal(),
    );
  }
}
