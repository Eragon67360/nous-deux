import 'package:flutter_test/flutter_test.dart';

import 'package:nousdeux/domain/entities/calendar_event_entity.dart';
import 'package:nousdeux/domain/nous/nous_dates.dart';

CalendarEventEntity _event(String id, DateTime start, {bool countdown = true}) =>
    CalendarEventEntity(
      id: id,
      coupleId: 'c1',
      title: id,
      startTime: start,
      createdBy: 'u1',
      isCountdown: countdown,
    );

void main() {
  group('daysTogether', () {
    test('counts calendar days, not 24-hour blocks', () {
      expect(daysTogether(DateTime(2026, 11, 9), DateTime(2026, 11, 10, 0, 5)), 1);
      expect(daysTogether(DateTime(2025, 9, 24), DateTime(2026, 11, 10)), 412);
    });

    test('is 0 on the first day and never negative', () {
      expect(daysTogether(DateTime(2026, 11, 10), DateTime(2026, 11, 10, 23)), 0);
      expect(daysTogether(DateTime(2026, 12, 1), DateTime(2026, 11, 10)), 0);
    });

    test('ignores daylight saving changes', () {
      // Europe switches to winter time on 25 Oct 2026.
      expect(daysTogether(DateTime(2026, 10, 24), DateTime(2026, 10, 26)), 2);
    });
  });

  group('nextAnniversary', () {
    test('later this year', () {
      final a = nextAnniversary(DateTime(2024, 12, 1), DateTime(2026, 11, 10));
      expect(a.date, DateTime(2026, 12, 1));
      expect(a.years, 2);
      expect(a.inDays, 21);
    });

    test('already passed this year: next year', () {
      final a = nextAnniversary(DateTime(2025, 9, 24), DateTime(2026, 11, 10));
      expect(a.date, DateTime(2027, 9, 24));
      expect(a.years, 2);
      expect(a.inDays, 318);
    });

    test('today is the day', () {
      final a = nextAnniversary(DateTime(2023, 11, 10), DateTime(2026, 11, 10, 18));
      expect(a.date, DateTime(2026, 11, 10));
      expect(a.years, 3);
      expect(a.inDays, 0);
    });

    test('a new couple waits for their first year', () {
      final a = nextAnniversary(DateTime(2026, 11, 1), DateTime(2026, 11, 10));
      expect(a.date, DateTime(2027, 11, 1));
      expect(a.years, 1);
    });

    test('29 February falls on 28 February in other years', () {
      final a = nextAnniversary(DateTime(2024, 2, 29), DateTime(2026, 1, 10));
      expect(a.date, DateTime(2026, 2, 28));
      expect(a.years, 2);
    });
  });

  group('upcomingCountdowns', () {
    final now = DateTime(2026, 11, 10, 12);

    test('keeps future countdown events, soonest first', () {
      final result = upcomingCountdowns([
        _event('lyon', DateTime(2026, 11, 20)),
        _event('past', DateTime(2026, 11, 1)),
        _event('not-a-countdown', DateTime(2026, 11, 12), countdown: false),
        _event('dinner', DateTime(2026, 11, 11, 19)),
      ], now);
      expect(result.map((e) => e.id), ['dinner', 'lyon']);
    });

    test('daysUntil counts calendar days', () {
      expect(daysUntil(DateTime(2026, 11, 20, 9), now), 10);
      expect(daysUntil(DateTime(2026, 11, 10, 20), now), 0);
    });
  });
}
