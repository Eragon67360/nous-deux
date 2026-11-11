import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nousdeux/core/constants/period_education.dart';
import 'package:nousdeux/presentation/providers/cycle_provider.dart';
import 'package:nousdeux/presentation/providers/period_provider.dart';
import 'package:nousdeux/presentation/providers/profile_provider.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/test_app.dart';

void main() {
  // TestDeps' "now": Tuesday 10 November 2026, 18:00.
  final today = DateTime(2026, 11, 10);
  DateTime daysAgo(int n) => DateTime(today.year, today.month, today.day - n);

  /// A container over [deps] with the cycle providers loaded.
  Future<ProviderContainer> load(TestDeps deps) async {
    final container = ProviderContainer(overrides: deps.overrides);
    addTearDown(container.dispose);
    container.listen(myCycleStatsProvider, (_, _) {});
    container.listen(partnerCycleStatsProvider, (_, _) {});
    container.listen(cycleCheckinsProvider, (_, _) {});
    await container.read(myProfileProvider.future);
    await container.read(partnerProfileProvider.future);
    await container.read(periodLogsProvider.future);
    await container.read(cycleCheckinsProvider.future);
    return container;
  }

  TestDeps paired({
    bool? tracksCycle,
    List<dynamic> logs = const [],
    List<dynamic> checkins = const [],
    bool partnerShares = true,
  }) => TestDeps(
    myProfile: profile(partner: partnerId, tracksCycle: tracksCycle),
    partner: partnerProfile(shareCycle: partnerShares),
    couple: couple(),
    logs: [...logs.cast()],
    checkins: [...checkins.cast()],
  );

  group('myCycleRoleProvider', () {
    test('is null while my profile loads', () {
      final container = ProviderContainer(
        overrides: [
          myProfileProvider.overrideWith(
            (ref) => Future.delayed(const Duration(days: 1)),
          ),
        ],
      );
      addTearDown(container.dispose);
      expect(container.read(myCycleRoleProvider), isNull);
    });

    test('follows tracks_cycle: unasked, tracker, supporter', () async {
      for (final (tracks, role) in [
        (null, CycleRole.unasked),
        (true, CycleRole.tracker),
        (false, CycleRole.supporter),
      ]) {
        final c = await load(paired(tracksCycle: tracks));
        expect(c.read(myCycleRoleProvider), role, reason: '$tracks');
      }
    });
  });

  test('each person\'s stats come from their own logs only', () async {
    final c = await load(
      paired(
        logs: [
          periodLog(id: 'mine', start: daysAgo(3)),
          periodLog(id: 'theirs', userId: partnerId, start: daysAgo(20)),
        ],
      ),
    );
    expect(c.read(myCycleStatsProvider).dayOfCycle, 4);
    expect(c.read(partnerCycleStatsProvider).dayOfCycle, 21);
  });

  test(
    'the guide speaks about my cycle if I track, else my partner\'s',
    () async {
      final logs = [
        periodLog(id: 'mine', start: daysAgo(1)),
        periodLog(id: 'theirs', userId: partnerId, start: daysAgo(20)),
      ];
      final tracker = await load(paired(tracksCycle: true, logs: logs));
      expect(tracker.read(guideCycleProvider).mine, isTrue);
      expect(
        tracker.read(guideCycleProvider).stats.phase,
        CyclePhase.menstrual,
      );

      final supporter = await load(paired(tracksCycle: false, logs: logs));
      expect(supporter.read(guideCycleProvider).mine, isFalse);
      expect(supporter.read(guideCycleProvider).stats.phase, CyclePhase.luteal);
    },
  );

  test('today\'s check-ins are told apart by person and day', () async {
    final c = await load(
      paired(
        checkins: [
          checkin(day: today, symptoms: ['cramps']),
          checkin(day: daysAgo(1), mood: 'tired'),
          checkin(userId: partnerId, day: today, mood: 'good'),
        ],
      ),
    );
    expect(c.read(myTodayCheckinProvider)?.symptoms, ['cramps']);
    expect(c.read(partnerTodayCheckinProvider)?.mood, 'good');
  });

  group('partnerReminderDayProvider', () {
    test('is the day before the partner\'s expected period', () async {
      final c = await load(
        paired(
          logs: [periodLog(userId: partnerId, start: daysAgo(20))],
        ),
      );
      // Started 21 Oct, 28 days → expected 18 Nov, reminder on the 17th.
      expect(c.read(partnerReminderDayProvider), DateTime(2026, 11, 17));
    });

    test('is null while nothing is shared', () async {
      final c = await load(paired());
      expect(c.read(partnerReminderDayProvider), isNull);
    });
  });

  group('partnerCycleSettingsLiveProvider', () {
    test('reloads what the partner shares when they flip a switch', () async {
      final deps = paired();
      final c = await load(deps);
      c.listen(partnerCycleSettingsLiveProvider, (_, _) {});
      final before = deps.period.watchCalls;

      deps.realtime.named('profile-cycle-$partnerId').emitUpdate({
        'id': partnerId,
        'tracks_cycle': null,
        'share_cycle': false,
        'share_checkins': true,
      });
      await c.read(periodLogsProvider.future);

      expect(deps.period.watchCalls, before + 1);
    });

    test('ignores updates that change no Règles setting', () async {
      final deps = paired();
      final c = await load(deps);
      c.listen(partnerCycleSettingsLiveProvider, (_, _) {});
      final before = deps.period.watchCalls;

      deps.realtime.named('profile-cycle-$partnerId').emitUpdate({
        'id': partnerId,
        'tracks_cycle': null,
        'share_cycle': true,
        'share_checkins': true,
        'avatar_url': 'new.png',
      });
      await c.read(periodLogsProvider.future);

      expect(deps.period.watchCalls, before);
    });
  });
}
