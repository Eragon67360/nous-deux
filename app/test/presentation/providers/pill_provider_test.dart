import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nousdeux/domain/entities/pill_entities.dart';
import 'package:nousdeux/domain/pill/pill_schedule.dart';
import 'package:nousdeux/presentation/providers/auth_provider.dart';
import 'package:nousdeux/presentation/providers/pill_provider.dart';
import 'package:nousdeux/presentation/providers/profile_provider.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/test_app.dart';

// Wednesday 18 November 2026: pill 12 of a 21 + 7 pack started on 7 Nov.
PillSettings settings({DateTime? startedOn, bool reminderOn = true}) =>
    PillSettings(
      packType: PackType.p21x7,
      packStartedOn: startedOn ?? DateTime(2026, 11, 7),
      reminderOn: reminderOn,
      reminderTime: (hour: 21, minute: 0),
      reminderText: ReminderText.discreet,
      shareWithPartner: true,
    );

Future<ProviderContainer> _container(TestDeps deps) async {
  final c = ProviderContainer(overrides: deps.overrides);
  addTearDown(c.dispose);
  await c.read(currentUserProvider.future);
  await c.read(myProfileProvider.future);
  return c;
}

Future<PillToday> _today(TestDeps deps) async {
  final c = await _container(deps);
  await c.read(pillSettingsProvider.future);
  await c.read(pillWeekProvider.future);
  return c.read(pillTodayProvider)!;
}

void main() {
  test('nobody tracking: nothing to show', () async {
    final today = await _today(TestDeps(now: DateTime(2026, 11, 18, 20)));
    expect(today.state, PillTodayState.notTracking);
  });

  test(
    'before the reminder and up to an hour after: due, with the pill number',
    () async {
      for (final at in [
        DateTime(2026, 11, 18, 8),
        DateTime(2026, 11, 18, 21, 59),
      ]) {
        final today = await _today(TestDeps(now: at, pillSettings: settings()));
        expect(today.state, PillTodayState.due, reason: '$at');
        expect(today.pillNumber, 12);
      }
    },
  );

  test('an hour after the reminder, not ticked: late', () async {
    final today = await _today(
      TestDeps(now: DateTime(2026, 11, 18, 22), pillSettings: settings()),
    );
    expect(today.state, PillTodayState.late);
  });

  test('ticked today: taken, with its time', () async {
    final at = DateTime(2026, 11, 18, 21, 4);
    final today = await _today(
      TestDeps(
        now: DateTime(2026, 11, 18, 23),
        pillSettings: settings(),
        pillIntakes: [PillIntake.taken(DateTime(2026, 11, 18), at)],
      ),
    );
    expect(today.state, PillTodayState.taken);
    expect(today.takenAt, at);
  });

  test('noted as missed today: missed', () async {
    final today = await _today(
      TestDeps(
        now: DateTime(2026, 11, 18, 23),
        pillSettings: settings(),
        pillIntakes: [PillIntake.missed(DateTime(2026, 11, 18))],
      ),
    );
    expect(today.state, PillTodayState.missed);
  });

  test('in the pause week: a day off', () async {
    final today = await _today(
      TestDeps(now: DateTime(2026, 11, 30, 22), pillSettings: settings()),
    );
    expect(today.state, PillTodayState.pauseDay);
    expect(today.pillNumber, isNull);
  });

  test('ticking saves the day and reloads the week', () async {
    final deps = TestDeps(
      now: DateTime(2026, 11, 18, 21, 5),
      pillSettings: settings(),
    );
    final c = await _container(deps);
    await c.read(pillSettingsProvider.future);
    await c.read(pillWeekProvider.future);
    await c.read(markPillTakenProvider)(
      DateTime(2026, 11, 18),
      DateTime(2026, 11, 18, 21, 5),
    );
    await c.read(pillWeekProvider.future);
    expect(deps.pill.takenCalls, [DateTime(2026, 11, 18)]);
    expect(c.read(pillTodayProvider)!.state, PillTodayState.taken);
  });

  group('the partner', () {
    TestDeps paired({PartnerPillToday? partner}) => TestDeps(
      now: DateTime(2026, 11, 18, 22),
      myProfile: profile(partner: partnerId),
      partner: partnerProfile(),
      couple: couple(pairingCode: null),
      partnerPill: partner,
    );

    test('reads whether today\'s pill is expected and ticked', () async {
      final deps = paired(
        partner: PartnerPillToday(
          tracking: true,
          expected: true,
          takenAt: DateTime(2026, 11, 18, 21, 4),
        ),
      );
      final c = await _container(deps);
      final p = await c.read(partnerPillTodayProvider.future);
      expect(p.takenAt, DateTime(2026, 11, 18, 21, 4));
      expect(deps.pill.partnerDays, [DateTime(2026, 11, 18)]);
    });

    test('reads it again when the partner ticks', () async {
      final deps = paired(
        partner: const PartnerPillToday(
          tracking: true,
          expected: true,
          takenAt: null,
        ),
      );
      final c = await _container(deps);
      c.listen(partnerPillLiveProvider, (_, _) {});
      await c.read(partnerPillTodayProvider.future);
      final channel = deps.realtime.named('pill-$partnerId');
      expect(channel.table, 'pill_intakes');
      expect(channel.filter?.value, partnerId);

      deps.pill.partner = PartnerPillToday(
        tracking: true,
        expected: true,
        takenAt: DateTime(2026, 11, 18, 22, 1),
      );
      channel.emitUpdate({'user_id': partnerId});
      final p = await c.read(partnerPillTodayProvider.future);
      expect(p.takenAt, DateTime(2026, 11, 18, 22, 1));
      expect(deps.pill.partnerDays, hasLength(2));
    });

    test('without a partner, nothing is asked', () async {
      final deps = TestDeps(now: DateTime(2026, 11, 18, 22));
      final c = await _container(deps);
      final p = await c.read(partnerPillTodayProvider.future);
      expect(p.tracking, isFalse);
      expect(deps.pill.partnerDays, isEmpty);
    });
  });
}
