import 'package:device_calendar/device_calendar.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tzdata;

import 'package:nousdeux/domain/calendar/calendar_sync_plan.dart';
import 'package:nousdeux/domain/calendar/phone_event.dart';
import 'package:nousdeux/domain/entities/calendar_event_entity.dart';

final _from = DateTime(2026, 11, 1);
final _to = DateTime(2027, 5, 1);

PhoneEvent _phone(
  String key, {
  String title = 'Dentiste',
  DateTime? start,
  DateTime? end,
}) => PhoneEvent(
  key: key,
  title: title,
  start: start ?? DateTime(2026, 11, 20, 9),
  end: end ?? DateTime(2026, 11, 20, 10),
);

CalendarEventEntity _synced(
  String id,
  String? key, {
  String title = 'Dentiste',
  DateTime? start,
  DateTime? end,
}) => CalendarEventEntity(
  id: id,
  coupleId: 'c1',
  title: title,
  startTime: start ?? DateTime(2026, 11, 20, 9),
  endTime: end ?? DateTime(2026, 11, 20, 10),
  createdBy: 'me',
  sourceKey: key,
);

void main() {
  setUpAll(tzdata.initializeTimeZones);

  group('phoneEventKey', () {
    test('is 64 lowercase hex characters and stable', () {
      final start = DateTime.utc(2026, 11, 20, 8);
      final key = phoneEventKey('cal-1', 'ev-1', start);
      expect(key, matches(RegExp(r'^[0-9a-f]{64}$')));
      expect(phoneEventKey('cal-1', 'ev-1', start), key);
    });

    test('tells occurrences, events and calendars apart', () {
      final start = DateTime.utc(2026, 11, 20, 8);
      final key = phoneEventKey('cal-1', 'ev-1', start);
      expect(
        phoneEventKey('cal-1', 'ev-1', start.add(const Duration(days: 7))),
        isNot(key),
      );
      expect(phoneEventKey('cal-1', 'ev-2', start), isNot(key));
      expect(phoneEventKey('cal-2', 'ev-1', start), isNot(key));
    });

    test('depends on the instant, not the time zone it is written in', () {
      final utc = DateTime.utc(2026, 11, 20, 8);
      final paris = TZDateTime(getLocation('Europe/Paris'), 2026, 11, 20, 9);
      expect(phoneEventKey('c', 'e', paris), phoneEventKey('c', 'e', utc));
    });
  });

  group('phoneEventFrom', () {
    Location paris() => getLocation('Europe/Paris');

    test('keeps the title and the instants of a timed event', () {
      final e = Event(
        'cal-1',
        eventId: 'ev-1',
        title: '  Dentiste ',
        start: TZDateTime(paris(), 2026, 11, 20, 9),
        end: TZDateTime(paris(), 2026, 11, 20, 10),
      );
      final p = phoneEventFrom(e)!;
      expect(p.title, 'Dentiste');
      expect(p.start.isAtSameMomentAs(DateTime.utc(2026, 11, 20, 8)), isTrue);
      expect(p.end!.isAtSameMomentAs(DateTime.utc(2026, 11, 20, 9)), isTrue);
      expect(p.start.isUtc, isFalse);
      expect(p.key, phoneEventKey('cal-1', 'ev-1', e.start!));
    });

    test('skips an event without an id, a start or a title', () {
      final start = TZDateTime(paris(), 2026, 11, 20, 9);
      expect(phoneEventFrom(Event('cal-1', title: 'X', start: start)), isNull);
      expect(phoneEventFrom(Event('cal-1', eventId: 'e', title: 'X')), isNull);
      expect(
        phoneEventFrom(Event('cal-1', eventId: 'e', start: start)),
        isNull,
      );
      expect(
        phoneEventFrom(
          Event('cal-1', eventId: 'e', title: '   ', start: start),
        ),
        isNull,
      );
      expect(
        phoneEventFrom(Event(null, eventId: 'e', title: 'X', start: start)),
        isNull,
      );
    });

    test('cuts a long title to 200 characters', () {
      final e = Event(
        'cal-1',
        eventId: 'ev-1',
        title: '🎂' * 250,
        start: TZDateTime(paris(), 2026, 11, 20, 9),
      );
      expect(phoneEventFrom(e)!.title.runes.length, 200);
    });

    test(
      'an iPhone all-day event (no time zone, read as UTC) keeps its day',
      () {
        // EventKit starts an all-day event at the phone's local midnight and
        // gives it no time zone, so the plugin builds it in UTC.
        final midnight = DateTime(2026, 11, 20).millisecondsSinceEpoch;
        final nextMidnight = DateTime(2026, 11, 21).millisecondsSinceEpoch;
        final p = phoneEventFrom(
          Event(
            'cal-1',
            eventId: 'ev-1',
            title: 'Anniversaire',
            start: TZDateTime.fromMillisecondsSinceEpoch(UTC, midnight),
            end: TZDateTime.fromMillisecondsSinceEpoch(UTC, nextMidnight),
            allDay: true,
          ),
          floatingAllDay: true,
        )!;
        expect(p.start, DateTime(2026, 11, 20));
        expect(p.end, DateTime(2026, 11, 21));
      },
    );

    test('an all-day event keeps its day, whatever its time zone', () {
      for (final zone in ['Europe/Paris', 'America/New_York', 'UTC']) {
        final where = getLocation(zone);
        final p = phoneEventFrom(
          Event(
            'cal-1',
            eventId: 'ev-1',
            title: 'Anniversaire',
            start: TZDateTime(where, 2026, 11, 20),
            end: TZDateTime(where, 2026, 11, 21),
            allDay: true,
          ),
        )!;
        expect(p.start, DateTime(2026, 11, 20), reason: zone);
        expect(p.end, DateTime(2026, 11, 21), reason: zone);
        expect(p.start.isUtc, isFalse, reason: zone);
      }
    });
  });

  group('planCalendarSync', () {
    SyncPlan plan(List<PhoneEvent> phone, List<CalendarEventEntity> synced) =>
        planCalendarSync(phone: phone, synced: synced, from: _from, to: _to);

    test('a new phone event is inserted', () {
      final p = plan([_phone('k1')], []);
      expect(p.toInsert, [_phone('k1')]);
      expect(p.toUpdate, isEmpty);
      expect(p.toDelete, isEmpty);
    });

    test('an unchanged event needs nothing', () {
      expect(plan([_phone('k1')], [_synced('id1', 'k1')]).isEmpty, isTrue);
    });

    test('the same instants written in UTC are unchanged', () {
      final phone = _phone(
        'k1',
        start: DateTime(2026, 11, 20, 9).toUtc(),
        end: DateTime(2026, 11, 20, 10).toUtc(),
      );
      expect(plan([phone], [_synced('id1', 'k1')]).isEmpty, isTrue);
    });

    test('a new title or end on the phone updates the copy', () {
      final renamed = _phone('k1', title: 'Dentiste (Dr Martin)');
      expect(plan([renamed], [_synced('id1', 'k1')]).toUpdate, [
        (id: 'id1', event: renamed),
      ]);
      final longer = _phone('k1', end: DateTime(2026, 11, 20, 11));
      expect(plan([longer], [_synced('id1', 'k1')]).toUpdate, [
        (id: 'id1', event: longer),
      ]);
    });

    test('an event gone from the phone is deleted inside the window', () {
      final p = plan([], [_synced('id1', 'k1')]);
      expect(p.toDelete, ['id1']);
    });

    test('a copy that started before the window stays as history', () {
      final old = _synced('id1', 'k1', start: DateTime(2026, 10, 1, 9));
      expect(plan([], [old]).isEmpty, isTrue);
    });

    test('the same phone event listed twice is inserted once', () {
      expect(plan([_phone('k1'), _phone('k1')], []).toInsert, [_phone('k1')]);
    });

    test('moving one occurrence replaces only that one', () {
      final mondays = [
        for (var w = 0; w < 3; w++) DateTime(2026, 11, 2 + 7 * w, 18),
      ];
      final synced = [
        for (var w = 0; w < 3; w++)
          CalendarEventEntity(
            id: 'id$w',
            coupleId: 'c1',
            title: 'Yoga',
            startTime: mondays[w],
            createdBy: 'me',
            sourceKey: 'k$w',
          ),
      ];
      final moved = DateTime(2026, 11, 10, 18);
      final phone = [
        PhoneEvent(key: 'k0', title: 'Yoga', start: mondays[0]),
        PhoneEvent(key: 'k1-moved', title: 'Yoga', start: moved),
        PhoneEvent(key: 'k2', title: 'Yoga', start: mondays[2]),
      ];
      final p = plan(phone, synced);
      expect(p.toDelete, ['id1']);
      expect(p.toInsert.map((e) => e.key), ['k1-moved']);
      expect(p.toUpdate, isEmpty);
    });

    test('events written in Nous Deux are never touched', () {
      expect(plan([], [_synced('id1', null)]).isEmpty, isTrue);
    });
  });

  test('a calendar event reads as synced from its source key', () {
    expect(_synced('id1', 'k1').isSynced, isTrue);
    expect(_synced('id1', null).isSynced, isFalse);
  });
}
