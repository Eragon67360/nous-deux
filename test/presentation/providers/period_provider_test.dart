import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nousdeux/core/constants/period_education.dart';
import 'package:nousdeux/core/constants/period_reminder_prefs.dart';
import 'package:nousdeux/domain/entities/period_log_entity.dart';
import 'package:nousdeux/presentation/providers/auth_provider.dart';
import 'package:nousdeux/presentation/providers/period_provider.dart';

import '../../helpers/fakes.dart';
import '../../helpers/fixtures.dart';

void main() {
  /// A container whose period stream emits [logs], signed in as [me].
  Future<ProviderContainer> containerWith(List<PeriodLogEntity> logs) async {
    final container = ProviderContainer(
      overrides: [
        periodRepositoryProvider.overrideWithValue(FakePeriodRepository(logs)),
        authRepositoryProvider.overrideWithValue(FakeAuthRepository(user: me)),
      ],
    );
    addTearDown(container.dispose);
    // Keep the streams alive and let them emit.
    container.listen(currentCyclePhaseProvider, (_, _) {});
    container.listen(nextPartnerPmsDateProvider, (_, _) {});
    await container.read(periodLogsProvider.future);
    await container.read(currentUserProvider.future);
    return container;
  }

  Future<CyclePhase?> phaseForDaysSinceStart(int days) async {
    final c = await containerWith([periodLog(start: utcDaysAgo(days))]);
    return c.read(currentCyclePhaseProvider);
  }

  group('currentCyclePhaseProvider (28-day cycle from the latest start)', () {
    test('is null without logs', () async {
      final c = await containerWith([]);
      expect(c.read(currentCyclePhaseProvider), isNull);
    });

    test('is null while logs are loading', () {
      final container = ProviderContainer(
        overrides: [
          periodLogsProvider.overrideWith((ref) => const Stream.empty()),
        ],
      );
      addTearDown(container.dispose);
      expect(container.read(currentCyclePhaseProvider), isNull);
    });

    test('is null when the stream errors', () async {
      final container = ProviderContainer(
        overrides: [
          periodLogsProvider.overrideWith(
            (ref) => Stream.error(Exception('offline')),
          ),
        ],
      );
      addTearDown(container.dispose);
      container.listen(currentCyclePhaseProvider, (_, _) {});
      await expectLater(
        container.read(periodLogsProvider.future),
        throwsException,
      );
      expect(container.read(currentCyclePhaseProvider), isNull);
    });

    test('days 1-5 are menstrual', () async {
      expect(await phaseForDaysSinceStart(0), CyclePhase.menstrual); // day 1
      expect(await phaseForDaysSinceStart(4), CyclePhase.menstrual); // day 5
    });

    test('days 6-12 are follicular', () async {
      expect(await phaseForDaysSinceStart(5), CyclePhase.follicular); // day 6
      expect(await phaseForDaysSinceStart(11), CyclePhase.follicular); // day 12
    });

    test('days 13-15 are ovulation', () async {
      expect(await phaseForDaysSinceStart(12), CyclePhase.ovulation); // day 13
      expect(await phaseForDaysSinceStart(14), CyclePhase.ovulation); // day 15
    });

    test('days 16-28 are luteal', () async {
      expect(await phaseForDaysSinceStart(15), CyclePhase.luteal); // day 16
      expect(await phaseForDaysSinceStart(27), CyclePhase.luteal); // day 28
    });

    test('wraps around every 28 days', () async {
      expect(await phaseForDaysSinceStart(28), CyclePhase.menstrual); // day 1
      expect(
        await phaseForDaysSinceStart(28 + 6),
        CyclePhase.follicular,
      ); // day 7
      expect(await phaseForDaysSinceStart(56 + 20), CyclePhase.luteal);
    });

    test('is null when the latest start is in the future', () async {
      expect(await phaseForDaysSinceStart(-1), isNull);
    });

    test('uses the most recent start, whatever the list order', () async {
      final c = await containerWith([
        periodLog(id: 'old', start: utcDaysAgo(40)),
        periodLog(id: 'new', start: utcDaysAgo(2)),
        periodLog(id: 'older', start: utcDaysAgo(70)),
      ]);
      expect(c.read(currentCyclePhaseProvider), CyclePhase.menstrual);
    });

    test("counts the partner's logs too", () async {
      final c = await containerWith([
        periodLog(id: 'mine', start: utcDaysAgo(20)),
        periodLog(id: 'theirs', userId: partnerId, start: utcDaysAgo(1)),
      ]);
      expect(c.read(currentCyclePhaseProvider), CyclePhase.menstrual);
    });
  });

  group('nextPartnerPmsDateProvider', () {
    test("is the partner's latest start + 21 days", () async {
      final c = await containerWith([
        periodLog(id: 'p1', userId: partnerId, start: DateTime.utc(2026, 1, 3)),
        periodLog(id: 'p2', userId: partnerId, start: DateTime.utc(2026, 2, 1)),
      ]);
      expect(c.read(nextPartnerPmsDateProvider), DateTime.utc(2026, 2, 22));
    });

    test("ignores the current user's own logs", () async {
      final c = await containerWith([
        periodLog(id: 'mine', start: DateTime.utc(2026, 3, 1)),
        periodLog(
          id: 'theirs',
          userId: partnerId,
          start: DateTime.utc(2026, 2, 1),
        ),
      ]);
      expect(c.read(nextPartnerPmsDateProvider), DateTime.utc(2026, 2, 22));
    });

    test('drops the time of day of the start', () async {
      final c = await containerWith([
        periodLog(userId: partnerId, start: DateTime.utc(2026, 2, 1, 15, 30)),
      ]);
      expect(c.read(nextPartnerPmsDateProvider), DateTime.utc(2026, 2, 22));
    });

    test('is null when only the current user logged', () async {
      final c = await containerWith([
        periodLog(start: DateTime.utc(2026, 3, 1)),
      ]);
      expect(c.read(nextPartnerPmsDateProvider), isNull);
    });

    test('is null when signed out', () async {
      final container = ProviderContainer(
        overrides: [
          periodRepositoryProvider.overrideWithValue(
            FakePeriodRepository([
              periodLog(userId: partnerId, start: DateTime.utc(2026, 2, 1)),
            ]),
          ),
          authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
        ],
      );
      addTearDown(container.dispose);
      container.listen(nextPartnerPmsDateProvider, (_, _) {});
      await container.read(periodLogsProvider.future);
      await container.read(currentUserProvider.future);
      expect(container.read(nextPartnerPmsDateProvider), isNull);
    });
  });

  group('partnerReminderEnabledProvider', () {
    test('defaults to off', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);
      expect(
        await container.read(partnerReminderEnabledProvider.future),
        isFalse,
      );
    });

    test('reads the stored preference', () async {
      SharedPreferences.setMockInitialValues({
        periodPartnerReminderEnabledKey: true,
      });
      final container = ProviderContainer();
      addTearDown(container.dispose);
      expect(
        await container.read(partnerReminderEnabledProvider.future),
        isTrue,
      );
    });
  });
}
