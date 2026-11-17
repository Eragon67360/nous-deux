import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nousdeux/core/errors/failures.dart';
import 'package:nousdeux/data/calendar_sync/calendar_follow_prefs.dart';
import 'package:nousdeux/data/calendar_sync/calendar_sync_service.dart';
import 'package:nousdeux/domain/calendar/phone_event.dart';
import 'package:nousdeux/domain/entities/calendar_event_entity.dart';

import '../../helpers/fakes.dart';
import '../../helpers/fixtures.dart';

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
    phone = FakePhoneCalendar(
      events: events == null ? null : {'cal-1': events},
    );
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

      expect(await service.stopFollowing(), isTrue);
      expect(calendar.deletedIds, ['id-mine']);
      expect(await prefs.followed(), isEmpty);
      expect(profiles.mine!.calendarSyncDevice, isNull);
    },
  );

  test('a trip that started before the window is not copied twice', () async {
    final trip = PhoneEvent(
      key: 'k-trip',
      title: 'Voyage',
      start: DateTime(2026, 10, 1),
      end: DateTime(2026, 11, 30),
    );
    await setUpWith(
      events: [trip],
      existing: [
        CalendarEventEntity(
          id: 'id-trip',
          coupleId: coupleId,
          title: 'Voyage',
          startTime: DateTime(2026, 10, 1),
          endTime: DateTime(2026, 11, 30),
          createdBy: meId,
          sourceKey: 'k-trip',
        ),
      ],
    );

    expect(await service.run(), CalendarSyncOutcome.synced);
    expect(calendar.createCalls, isEmpty);
    expect(calendar.deletedIds, isEmpty);
  });

  test('following another calendar during a sync copies it too', () async {
    await setUpWith(events: [_phone('k1', 'Dentiste')]);
    phone.perCalendar!['cal-2'] = [_phone('k2', 'Yoga', day: 21)];
    phone.hold = Completer<void>();

    final first = service.run();
    final followed = service.follow({'cal-1', 'cal-2'});
    phone.hold!.complete();
    expect(await first, CalendarSyncOutcome.synced);
    expect(await followed, CalendarSyncOutcome.synced);
    expect(
      calendar.events.map((e) => e.sourceKey),
      unorderedEquals(['k1', 'k2']),
    );
  });

  test(
    'stopFollowing on a phone that no longer syncs deletes nothing',
    () async {
      await setUpWith(
        events: [],
        existing: [_copy('id-mine', 'k1', 'Dentiste')],
        thisPhone: false,
      );
      final other = profiles.mine!.calendarSyncDevice;

      expect(await service.stopFollowing(), isTrue);
      expect(calendar.deletedIds, isEmpty);
      expect(profiles.mine!.calendarSyncDevice, other);
      expect(await prefs.followed(), isEmpty);
    },
  );

  test('stopFollowing that fails keeps following, to try again', () async {
    await setUpWith(events: [], existing: [_copy('id-mine', 'k1', 'Dentiste')]);
    final install = await prefs.installId();
    calendar.nextFailure = const ServerFailure('offline');

    expect(await service.stopFollowing(), isFalse);
    expect(await prefs.followed(), {'cal-1'});
    expect(profiles.mine!.calendarSyncDevice, install);
  });

  test(
    'stopFollowing waits for a running sync, then removes its copies',
    () async {
      await setUpWith(events: [_phone('k1', 'Dentiste')]);
      phone.hold = Completer<void>();

      final running = service.run();
      final stopping = service.stopFollowing();
      phone.hold!.complete();
      await running;
      expect(await stopping, isTrue);
      expect(calendar.events.where((e) => e.isSynced), isEmpty);
    },
  );

  test('an error while syncing is a failed run, not a crash', () async {
    await setUpWith(events: [_phone('k1', 'Dentiste')]);
    phone.error = StateError('plugin gone');

    expect(await service.run(), CalendarSyncOutcome.failed);
    expect(calendar.createCalls, isEmpty);
  });

  test('the install id is a stable UUID', () async {
    await setUpWith(events: []);
    final id = await prefs.installId();
    expect(id, matches(RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-')));
    expect(await CalendarFollowPrefs().installId(), id);
  });
}
