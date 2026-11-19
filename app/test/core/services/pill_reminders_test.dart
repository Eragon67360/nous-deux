import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'package:nousdeux/core/services/local_notifications.dart';
import 'package:nousdeux/core/services/pill_reminders.dart';
import 'package:nousdeux/domain/entities/pill_entities.dart';
import 'package:nousdeux/domain/pill/pill_schedule.dart';
import 'package:nousdeux/presentation/providers/auth_provider.dart';
import 'package:nousdeux/presentation/providers/pill_provider.dart';
import 'package:nousdeux/presentation/providers/profile_provider.dart';

import '../../helpers/test_app.dart';

// A 21 + 7 pack started on Saturday 7 November 2026: the pause runs from
// 28 November to 4 December.
PillSettings settings({
  ReminderText text = ReminderText.discreet,
  bool reminderOn = true,
  DateTime? startedOn,
  String timeZone = 'Europe/Paris',
}) => PillSettings(
  packType: PackType.p21x7,
  packStartedOn: startedOn ?? DateTime(2026, 11, 7),
  reminderOn: reminderOn,
  reminderTime: (hour: 21, minute: 0),
  reminderText: text,
  timeZone: timeZone,
);

List<PlannedReminder> plan({
  PillSettings? s,
  List<PillIntake> intakes = const [],
  DateTime? now,
  String lang = 'fr',
}) => planPillReminders(
  settings: s ?? settings(),
  intakes: intakes,
  now: now ?? DateTime(2026, 11, 18, 12),
  lang: lang,
);

void main() {
  setUpAll(() {
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Europe/Paris'));
  });

  test(
    'a reminder at 21:00 and another at 21:30 on each pill day, none in the pause',
    () {
      final reminders = plan();
      final days = {
        for (final r in reminders) DateTime(r.at.year, r.at.month, r.at.day),
      };
      expect(days.contains(DateTime(2026, 11, 18)), isTrue);
      expect(days.contains(DateTime(2026, 11, 27)), isTrue);
      for (var d = 28; d <= 30; d++) {
        expect(
          days.contains(DateTime(2026, 11, d)),
          isFalse,
          reason: 'pause day $d Nov',
        );
      }
      expect(days.contains(DateTime(2026, 12, 4)), isFalse);
      expect(days.contains(DateTime(2026, 12, 5)), isTrue);
      final today = reminders
          .where((r) => r.at.day == 18 && r.at.month == 11)
          .toList();
      expect(today.map((r) => '${r.at.hour}:${r.at.minute}'), [
        '21:0',
        '21:30',
      ]);
    },
  );

  test('a month planned, then one last reminder to open the app', () {
    final reminders = plan(s: settings(startedOn: DateTime(2026, 11, 18)));
    final keepAlive = reminders.last;
    expect(keepAlive.id, pillKeepAliveId);
    expect(
      DateTime(keepAlive.at.year, keepAlive.at.month, keepAlive.at.day),
      DateTime(2026, 12, 18),
    );
    expect(keepAlive.body, isNot(contains('pilule')));
    // Under iOS's 64 pending notifications, with the period reminder and a snooze.
    expect(reminders.length + 2, lessThanOrEqualTo(64));
  });

  test('ids stay in the pill range and never repeat', () {
    final ids = plan().map((r) => r.id).toList();
    expect(ids.toSet().length, ids.length);
    expect(
      ids.every((id) => id >= pillReminderFirstId && id <= pillKeepAliveId),
      isTrue,
    );
  });

  test('ticked today: nothing more today', () {
    final reminders = plan(
      intakes: [
        PillIntake.taken(DateTime(2026, 11, 18), DateTime(2026, 11, 18, 9)),
      ],
    );
    expect(reminders.where((r) => r.at.day == 18 && r.at.month == 11), isEmpty);
    expect(
      reminders.where((r) => r.at.day == 19 && r.at.month == 11),
      hasLength(2),
    );
  });

  test('between the two reminders, only the second is left today', () {
    final reminders = plan(now: DateTime(2026, 11, 18, 21, 10));
    final today = reminders
        .where((r) => r.at.day == 18 && r.at.month == 11)
        .toList();
    expect(today, hasLength(1));
    expect(today.single.at.minute, 30);
  });

  test('21:00 stays 21:00 when the clocks change on 25 October', () {
    final reminders = plan(
      s: settings(startedOn: DateTime(2026, 10, 20)),
      now: DateTime(2026, 10, 24, 10),
    );
    final first = reminders.firstWhere(
      (r) => r.at.day == 24 && r.at.hour == 21 && r.at.minute == 0,
    );
    final after = reminders.firstWhere(
      (r) => r.at.day == 26 && r.at.hour == 21 && r.at.minute == 0,
    );
    expect(first.at.toUtc(), DateTime.utc(2026, 10, 24, 19));
    expect(after.at.toUtc(), DateTime.utc(2026, 10, 26, 20));
  });

  test('the discreet text never names the pill or its number', () {
    for (final lang in ['fr', 'en']) {
      for (final r in plan(lang: lang).take(2)) {
        final text = '${r.title} ${r.body}'.toLowerCase();
        expect(text, isNot(contains('pilule')));
        expect(text, isNot(contains('pill')));
        expect(text, isNot(contains('12')));
        expect(r.iosCategory, 'pill_discreet_$lang');
      }
    }
  });

  test('the clear text says it, with the pill number', () {
    final first = plan(s: settings(text: ReminderText.clear)).first;
    expect(first.title, 'Pilule');
    expect(first.body, contains('12'));
    expect(first.actions.map((a) => a.id), [pillTakenAction, pillSnoozeAction]);
    expect(first.actions.first.opensApp, isTrue);
    expect(first.actions.last.opensApp, isFalse);
  });

  test('the payload names the day', () {
    final first = plan().first;
    expect(pillDayFromPayload(first.payload), DateTime(2026, 11, 18));
    expect(pillDayFromPayload('{"kind":"other"}'), isNull);
    expect(pillDayFromPayload(null), isNull);
  });

  group('a new pack (Evah, 2026-11-19)', () {
    // Day 1 after the pause: Saturday 5 December.
    bool onDay(PlannedReminder r, int month, int day) =>
        r.at.month == month && r.at.day == day;

    test('its first reminder says a new pack starts', () {
      final first = plan(
        s: settings(text: ReminderText.clear),
      ).firstWhere((r) => onDay(r, 12, 5) && r.at.hour == 21);
      expect(
        first.body,
        "C'est l'heure de votre pilule\u00a0: premier comprimé d'une nouvelle plaquette.",
      );
    });

    test('a heads-up at 9:00 that morning, in the chosen style', () {
      final clear = plan(
        s: settings(text: ReminderText.clear),
      ).where((r) => onDay(r, 12, 5) && r.at.hour == 9).single;
      expect(clear.title, 'Pilule');
      expect(
        clear.body,
        "Nouvelle plaquette aujourd'hui\u00a0: emportez-la si vous sortez.",
      );
      expect(clear.actions, isEmpty);
      expect(pillDayFromPayload(clear.payload), DateTime(2026, 12, 5));

      final discreet = plan().where((r) => onDay(r, 12, 5) && r.at.hour == 9);
      expect(discreet.single.title, 'Petit rappel');
      expect(
        discreet.single.body,
        "Votre rappel de 21:00 reprend aujourd'hui.",
      );
    });

    test('no heads-up when the reminder is itself in the morning', () {
      final s = PillSettings(
        packType: PackType.p21x7,
        packStartedOn: DateTime(2026, 11, 7),
        reminderTime: (hour: 10, minute: 0),
        reminderText: ReminderText.clear,
        timeZone: 'Europe/Paris',
      );
      final day1 = plan(s: s).where((r) => onDay(r, 12, 5)).toList();
      expect(day1.map((r) => '${r.at.hour}:${r.at.minute}'), ['10:0', '10:30']);
    });

    test('a 28 pack: no heads-up, but its first pill says new pack', () {
      final s = PillSettings(
        packType: PackType.p28,
        packStartedOn: DateTime(2026, 11, 7),
        reminderText: ReminderText.clear,
        timeZone: 'Europe/Paris',
      );
      final day1 = plan(s: s).where((r) => onDay(r, 12, 5)).toList();
      expect(day1.map((r) => r.at.hour), [21, 21]);
      expect(day1.first.body, contains('nouvelle plaquette'));
    });

    test('continuous: never a new pack', () {
      final s = PillSettings(
        packType: PackType.continuous,
        packStartedOn: DateTime(2026, 11, 7),
        reminderText: ReminderText.clear,
        timeZone: 'Europe/Paris',
      );
      final reminders = plan(s: s);
      expect(reminders.where((r) => r.at.hour == 9), isEmpty);
      expect(reminders.where((r) => r.body.contains('plaquette')), isEmpty);
    });

    test('every plan stays within iOS\'s 64 pending notifications', () {
      for (final type in PackType.values) {
        final s = PillSettings(
          packType: type,
          packStartedOn: DateTime(2026, 11, 7),
          timeZone: 'Europe/Paris',
        );
        // Plus the period reminder and a snooze.
        expect(plan(s: s).length + 2, lessThanOrEqualTo(64), reason: '$type');
      }
    });
  });

  group('kept up to date on the phone', () {
    Future<(TestDeps, ProviderContainer)> start(TestDeps deps) async {
      final c = ProviderContainer(overrides: deps.overrides);
      addTearDown(c.dispose);
      await c.read(currentUserProvider.future);
      await c.read(myProfileProvider.future);
      return (deps, c);
    }

    test('the plan replaces what was scheduled', () async {
      final (deps, c) = await start(
        TestDeps(now: DateTime(2026, 11, 18, 12), pillSettings: settings()),
      );
      await deps.notifications.schedule(
        id: pillReminderFirstId + 40,
        at: tz.TZDateTime(tz.local, 2026, 11, 1),
        channel: LocalChannel.pillReminder,
        title: 'old',
        body: 'old',
      );
      await c.read(pillReminderSyncProvider.future);
      expect(deps.notifications.cancelled, contains(pillReminderFirstId + 40));
      expect(
        deps.notifications.scheduled.values.where((n) => n.title == 'old'),
        isEmpty,
      );
      expect(deps.notifications.scheduled, isNotEmpty);
    });

    test(
      'the phone zone is saved once, alone, and the plan follows it',
      () async {
        final (deps, c) = await start(
          TestDeps(
            now: DateTime(2026, 11, 18, 12),
            pillSettings: settings(timeZone: 'UTC'),
          ),
        );
        // The settings came with UTC; the phone is in Paris.
        await c.read(pillReminderSyncProvider.future);
        await c.read(pillReminderSyncProvider.future);
        expect(deps.pill.savedZones, ['Europe/Paris']);
        // Only the zone: the cached settings may be older than the row.
        expect(deps.pill.savedSettings, isEmpty);
        expect(deps.notifications.scheduled, isNotEmpty);
        // A resume reloads the days; the zone is not saved again.
        c.invalidate(pillWeekProvider);
        await c.read(pillReminderSyncProvider.future);
        expect(deps.pill.savedZones, ['Europe/Paris']);
        final before = deps.notifications.cancelled.length;
        c.read(localZoneProvider.notifier).state = 'America/New_York';
        await c.read(pillReminderSyncProvider.future);
        await c.read(pillReminderSyncProvider.future);
        expect(deps.pill.savedZones, ['Europe/Paris', 'America/New_York']);
        expect(deps.notifications.cancelled.length, greaterThan(before));
      },
    );

    test('a row that keeps its old zone is not saved again', () async {
      final (deps, c) = await start(
        TestDeps(
          now: DateTime(2026, 11, 18, 12),
          pillSettings: settings(timeZone: 'UTC'),
        ),
      );
      deps.pill.dropZoneWrites = true;
      await c.read(pillReminderSyncProvider.future);
      await c.read(pillReminderSyncProvider.future);
      await c.read(pillReminderSyncProvider.future);
      expect(deps.pill.savedZones, ['Europe/Paris']);
      expect(deps.notifications.scheduled, isNotEmpty);
    });

    test('after a new zone, the plan comes from the row read again', () async {
      final (deps, c) = await start(
        TestDeps(
          now: DateTime(2026, 11, 18, 12),
          pillSettings: settings(timeZone: 'UTC'),
        ),
      );
      // Another phone moved the reminder to 22:00 meanwhile.
      deps.pill.rowAfterZoneSave = PillSettings(
        packType: PackType.p21x7,
        packStartedOn: DateTime(2026, 11, 7),
        reminderTime: (hour: 22, minute: 0),
      );
      final sub = c.listen(pillReminderSyncProvider, (_, _) {});
      addTearDown(sub.close);
      await pumpEventQueue();
      expect(deps.pill.savedZones, ['Europe/Paris']);
      final first = deps.notifications.scheduled[pillReminderFirstId];
      expect(first?.at.hour, 22);
    });

    test('a failed read after saving the zone keeps the reminders', () async {
      final (deps, c) = await start(
        TestDeps(
          now: DateTime(2026, 11, 18, 12),
          pillSettings: settings(timeZone: 'UTC'),
        ),
      );
      // Planned on an earlier run.
      for (final r in plan(now: DateTime(2026, 11, 18, 12))) {
        await deps.notifications.schedule(
          id: r.id,
          at: r.at,
          channel: LocalChannel.pillReminder,
          title: r.title,
          body: r.body,
        );
      }
      final before = deps.notifications.scheduled.length;
      await c.read(pillSettingsProvider.future);
      deps.pill.failSettingsReads = 1;
      // The save succeeds, the read that follows doesn't (weak roaming).
      final sub = c.listen(pillReminderSyncProvider, (_, _) {});
      addTearDown(sub.close);
      await pumpEventQueue();
      expect(deps.pill.savedZones, ['Europe/Paris']);
      expect(deps.notifications.scheduled.length, before);
    });

    test('a trip and back saves each new zone', () async {
      final (deps, c) = await start(
        TestDeps(
          now: DateTime(2026, 11, 18, 12),
          pillSettings: settings(timeZone: 'UTC'),
        ),
      );
      final sub = c.listen(pillReminderSyncProvider, (_, _) {});
      addTearDown(sub.close);
      await pumpEventQueue();
      c.read(localZoneProvider.notifier).state = 'America/New_York';
      await pumpEventQueue();
      c.read(localZoneProvider.notifier).state = 'Europe/Paris';
      await pumpEventQueue();
      expect(deps.pill.savedZones, [
        'Europe/Paris',
        'America/New_York',
        'Europe/Paris',
      ]);
    });

    test('reminders off, or no tracking: nothing scheduled', () async {
      final (offDeps, off) = await start(
        TestDeps(
          now: DateTime(2026, 11, 18, 12),
          pillSettings: settings(reminderOn: false),
        ),
      );
      await off.read(pillReminderSyncProvider.future);
      expect(offDeps.notifications.scheduled, isEmpty);
      final (noneDeps, none) = await start(
        TestDeps(now: DateTime(2026, 11, 18, 12)),
      );
      await none.read(pillReminderSyncProvider.future);
      expect(noneDeps.notifications.scheduled, isEmpty);
    });

    test('« Dans 30 min » adds one more reminder half an hour later', () async {
      final (deps, _) = await start(
        TestDeps(now: DateTime(2026, 11, 18, 21), pillSettings: settings()),
      );
      final first = plan(now: DateTime(2026, 11, 18, 12)).first;
      await snoozePillReminder(
        deps.notifications,
        first.payload,
        now: DateTime(2026, 11, 18, 21, 2),
      );
      final snoozed = deps.notifications.scheduled[pillSnoozeId]!;
      expect(snoozed.at.toUtc(), DateTime.utc(2026, 11, 18, 20, 32));
      expect(snoozed.title, first.title);
    });
  });
}
