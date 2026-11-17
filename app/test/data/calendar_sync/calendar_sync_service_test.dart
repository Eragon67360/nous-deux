import 'package:device_calendar/device_calendar.dart' show Calendar;
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nousdeux/core/errors/failures.dart';
import 'package:nousdeux/data/calendar_sync/calendar_follow_prefs.dart';
import 'package:nousdeux/data/calendar_sync/calendar_sync_service.dart';
import 'package:nousdeux/data/calendar_sync/phone_calendar.dart';
import 'package:nousdeux/domain/calendar/phone_event.dart';
import 'package:nousdeux/domain/entities/calendar_event_entity.dart';

import '../../helpers/fakes.dart';
import '../../helpers/fixtures.dart';

/// Plays the phone's calendars: [events] per calendar id, or null when the
/// calendar can't be read.
class FakePhoneCalendar implements PhoneCalendar {
  FakePhoneCalendar(this.phoneEvents);

  List<PhoneEvent>? phoneEvents;
  int reads = 0;

  @override
  Future<List<Calendar>?> calendars() async => [Calendar(id: 'cal-1')];

  @override
  Future<List<PhoneEvent>?> events(
    Set<String> calendarIds,
    DateTime from,
    DateTime to,
  ) async {
    reads++;
    return phoneEvents == null ? null : [...phoneEvents!];
  }
}

final _now = DateTime(2026, 11, 17, 12);

PhoneEvent _phone(String key, String title, {int day = 20}) => PhoneEvent(
  key: key,
  title: title,
  start: DateTime(2026, 11, day, 9),
  end: DateTime(2026, 11, day, 10),
);

CalendarEventEntity _copy(
  String id,
  String key,
  String title, {
  int day = 20,
  int month = 11,
  String createdBy = meId,
}) => CalendarEventEntity(
  id: id,
  coupleId: coupleId,
  title: title,
  startTime: DateTime(2026, month, day, 9),
  endTime: DateTime(2026, month, day, 10),
  createdBy: createdBy,
  sourceKey: key,
);

void main() {
  late FakePhoneCalendar phone;
  late FakeCalendarRepository calendar;
  late FakeProfileRepository profiles;
  late CalendarFollowPrefs prefs;
  late CalendarSyncService service;

  Future<void> setUpWith({
    List<PhoneEvent>? events,
    List<CalendarEventEntity> existing = const [],
    Set<String> followed = const {'cal-1'},
    bool thisPhone = true,
  }) async {
    SharedPreferences.setMockInitialValues({});
    prefs = CalendarFollowPrefs();
    await prefs.setFollowed(followed);
    final install = await prefs.installId();
    phone = FakePhoneCalendar(events);
    calendar = FakeCalendarRepository(existing);
    profiles = FakeProfileRepository(
      mine: profile(
        calendarSyncDevice: thisPhone
            ? install
            : '00000000-0000-4000-8000-000000000000',
      ),
    );
    service = CalendarSyncService(
      phone: phone,
      calendar: calendar,
      profiles: profiles,
      prefs: prefs,
      now: () => _now,
    );
  }

  test(
    'the first run copies every phone event, the second changes nothing',
    () async {
      await setUpWith(events: [_phone('k1', 'Dentiste'), _phone('k2', 'Yoga')]);

      expect(await service.run(), CalendarSyncOutcome.synced);
      expect(calendar.events.map((e) => (e.title, e.sourceKey)), [
        ('Dentiste', 'k1'),
        ('Yoga', 'k2'),
      ]);
      expect(profiles.mine!.calendarSyncedAt, isNotNull);

      calendar.createCalls.clear();
      expect(await service.run(), CalendarSyncOutcome.synced);
      expect(calendar.createCalls, isEmpty);
      expect(calendar.syncedUpdateCalls, isEmpty);
      expect(calendar.deletedIds, isEmpty);
    },
  );

  test(
    'a title changed on the phone updates the copy; a deleted one goes',
    () async {
      await setUpWith(
        events: [_phone('k1', 'Dentiste (Dr Martin)')],
        existing: [_copy('id1', 'k1', 'Dentiste'), _copy('id2', 'k2', 'Yoga')],
      );

      expect(await service.run(), CalendarSyncOutcome.synced);
      expect(calendar.syncedUpdateCalls.map((c) => (c.id, c.title)), [
        ('id1', 'Dentiste (Dr Martin)'),
      ]);
      expect(calendar.deletedIds, ['id2']);
      expect(calendar.createCalls, isEmpty);
    },
  );

  test('an unreadable calendar changes nothing on the server', () async {
    await setUpWith(events: null, existing: [_copy('id1', 'k1', 'Dentiste')]);

    expect(await service.run(), CalendarSyncOutcome.noAccess);
    expect(calendar.deletedIds, isEmpty);
    expect(calendar.createCalls, isEmpty);
    expect(profiles.mine!.calendarSyncedAt, isNull);
  });

  test('when another phone follows, this one stops without deleting', () async {
    await setUpWith(
      events: [],
      existing: [_copy('id1', 'k1', 'Dentiste')],
      thisPhone: false,
    );

    expect(await service.run(), CalendarSyncOutcome.otherPhone);
    expect(await prefs.followed(), isEmpty);
    expect(phone.reads, 0);
    expect(calendar.deletedIds, isEmpty);
  });

  test('nothing followed: nothing read, nothing written', () async {
    await setUpWith(events: [_phone('k1', 'Dentiste')], followed: {});

    expect(await service.run(), CalendarSyncOutcome.notFollowing);
    expect(phone.reads, 0);
    expect(calendar.createCalls, isEmpty);
  });

  test('a failing write stops the run and keeps the last sync time', () async {
    await setUpWith(events: [_phone('k1', 'Dentiste')]);
    calendar.nextFailure = const ServerFailure('boom');

    expect(await service.run(), CalendarSyncOutcome.failed);
    expect(profiles.mine!.calendarSyncedAt, isNull);
  });

  test('two runs at once write once', () async {
    await setUpWith(events: [_phone('k1', 'Dentiste')]);

    final results = await Future.wait([service.run(), service.run()]);
    expect(results, [CalendarSyncOutcome.synced, CalendarSyncOutcome.synced]);
    expect(calendar.createCalls, hasLength(1));
  });

  test('following a calendar names this phone and copies its events', () async {
    await setUpWith(events: [_phone('k1', 'Dentiste')], followed: {});
    profiles.mine = profile();

    expect(await service.follow({'cal-1'}), CalendarSyncOutcome.synced);
    expect(profiles.mine!.calendarSyncDevice, await prefs.installId());
    expect(await prefs.followed(), {'cal-1'});
    expect(calendar.events.single.sourceKey, 'k1');
  });

  test(
    'stopFollowing removes my copies in the window, and only those',
    () async {
      final ordinary = event(id: 'id-own', start: DateTime(2026, 11, 21));
      await setUpWith(
        events: [],
        existing: [
          _copy('id-mine', 'k1', 'Dentiste'),
          _copy('id-old', 'k2', 'Yoga', month: 9),
          _copy('id-partner', 'k3', 'Foot', createdBy: partnerId),
          ordinary,
        ],
      );

      await service.stopFollowing();
      expect(calendar.deletedIds, ['id-mine']);
      expect(await prefs.followed(), isEmpty);
      expect(profiles.mine!.calendarSyncDevice, isNull);
    },
  );

  test('the install id is a stable UUID', () async {
    await setUpWith(events: []);
    final id = await prefs.installId();
    expect(id, matches(RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-')));
    expect(await CalendarFollowPrefs().installId(), id);
  });
}
