import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'package:nousdeux/core/services/local_notifications.dart';
import 'package:nousdeux/core/services/pill_reminders.dart';
import 'package:nousdeux/domain/entities/pill_entities.dart';
import 'package:nousdeux/domain/pill/pill_schedule.dart';
import 'package:nousdeux/presentation/providers/auth_provider.dart';
import 'package:nousdeux/presentation/providers/profile_provider.dart';

import '../../helpers/test_app.dart';

// A 21 + 7 pack started on Saturday 7 November 2026: the pause runs from
// 28 November to 4 December.
PillSettings settings({
  ReminderText text = ReminderText.discreet,
  bool reminderOn = true,
  DateTime? startedOn,
}) => PillSettings(
  packType: PackType.p21x7,
  packStartedOn: startedOn ?? DateTime(2026, 11, 7),
  reminderOn: reminderOn,
  reminderTime: (hour: 21, minute: 0),
  reminderText: text,
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

  test('ids stay in the pill range and never repeat', () {
    final ids = plan().map((r) => r.id).toList();
    expect(ids.toSet().length, ids.length);
    expect(
      ids.every((id) => id >= pillReminderFirstId && id < pillSnoozeId),
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
