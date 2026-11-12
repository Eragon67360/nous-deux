import 'package:flutter_test/flutter_test.dart';

import 'package:nousdeux/core/constants/period_education.dart';
import 'package:nousdeux/domain/cycle/cycle_stats.dart';

import '../../helpers/fixtures.dart';

void main() {
  CycleStats stats(List<(DateTime, DateTime?)> periods, DateTime today) =>
      CycleStats.from([
        for (final (i, (start, end)) in periods.indexed)
          periodLog(id: 'p$i', start: start, end: end),
      ], today);

  test('without logs: no day, no phase, defaults', () {
    final s = CycleStats.from(const [], DateTime(2026, 11, 11));
    expect(s.hasData, isFalse);
    expect(s.dayOfCycle, isNull);
    expect(s.phase, isNull);
    expect(s.nextStart, isNull);
    expect(s.cycleLength, 28);
    expect(s.periodLength, 5);
    expect(s.cyclesUsed, 0);
  });

  test('one period: counts days and expects 28 days', () {
    final s = stats([
      (DateTime(2026, 10, 21), DateTime(2026, 10, 25)),
    ], DateTime(2026, 11, 11, 22, 30));
    expect(s.dayOfCycle, 22);
    expect(s.nextStart, DateTime(2026, 11, 18));
    expect(s.daysUntilNext, 7);
    expect(s.phase, CyclePhase.luteal);
    expect(s.periodLength, 5);
  });

  test('averages the finished cycles', () {
    final s = stats([
      (DateTime(2026, 7, 1), DateTime(2026, 7, 4)),
      (DateTime(2026, 7, 30), DateTime(2026, 8, 3)),
      (DateTime(2026, 8, 26), DateTime(2026, 8, 31)),
      (DateTime(2026, 9, 23), DateTime(2026, 9, 27)),
      (DateTime(2026, 10, 21), DateTime(2026, 10, 25)),
    ], DateTime(2026, 11, 11));
    // 29, 27, 28, 28 days.
    expect(s.cyclesUsed, 4);
    expect(s.cycleLength, 28);
    expect(s.shortestCycle, 27);
    expect(s.longestCycle, 29);
    expect(s.periodLength, 5);
    expect(s.history.map((c) => c.length), [28, 28, 27, 29]);
    expect(s.history.first.start, DateTime(2026, 9, 23));
  });

  test('a longer personal cycle moves the expected date and the phases', () {
    final s = stats([
      (DateTime(2026, 8, 1), null),
      (DateTime(2026, 9, 4), null),
      (DateTime(2026, 10, 8), null),
    ], DateTime(2026, 10, 27));
    expect(s.cycleLength, 34);
    expect(s.nextStart, DateTime(2026, 11, 11));
    // Day 20 of 34: ovulation around day 20.
    expect(s.dayOfCycle, 20);
    expect(s.phase, CyclePhase.ovulation);
  });

  test('a skipped month is left out of the average', () {
    final s = stats([
      (DateTime(2026, 6, 1), null),
      (DateTime(2026, 6, 29), null),
      (DateTime(2026, 8, 24), null), // nothing logged for July: 56 days
      (DateTime(2026, 11, 1), null), // 69 days: ignored
    ], DateTime(2026, 11, 5));
    expect(s.history.map((c) => c.length), [69, 56, 28]);
    expect(s.cyclesUsed, 2);
    expect(s.cycleLength, 42);
  });

  test(
    'an open period is ongoing for its first days, then treated as over',
    () {
      final early = stats([
        (DateTime(2026, 11, 9), null),
      ], DateTime(2026, 11, 11));
      expect(early.periodOngoing, isTrue);
      expect(early.phase, CyclePhase.menstrual);

      final later = stats([
        (DateTime(2026, 11, 1), null),
      ], DateTime(2026, 11, 12));
      expect(later.periodOngoing, isFalse);
      expect(later.phase, CyclePhase.follicular);
    },
  );

  test('a noted end closes the period even before the usual length', () {
    final s = stats([
      (DateTime(2026, 11, 8), DateTime(2026, 11, 10)),
    ], DateTime(2026, 11, 11));
    expect(s.periodOngoing, isFalse);
    expect(s.phase, CyclePhase.follicular);
  });

  test('late: days until next goes negative', () {
    final s = stats([
      (DateTime(2026, 10, 1), DateTime(2026, 10, 5)),
    ], DateTime(2026, 11, 2));
    expect(s.daysUntilNext, -4);
    expect(s.phase, CyclePhase.luteal);
  });

  test('day counts survive the switch to winter time', () {
    // Europe switches clocks on 25 October 2026.
    final s = stats([
      (DateTime(2026, 10, 24), null),
    ], DateTime(2026, 10, 26, 1));
    expect(s.dayOfCycle, 3);
  });

  test('ignores a start logged in the future', () {
    final s = stats([
      (DateTime(2026, 10, 21), null),
      (DateTime(2026, 12, 1), null),
    ], DateTime(2026, 11, 11));
    expect(s.lastStart, DateTime(2026, 10, 21));
  });
}
