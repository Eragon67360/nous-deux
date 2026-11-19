import 'package:flutter_test/flutter_test.dart';

import 'package:nousdeux/domain/pill/pill_schedule.dart';

void main() {
  // A 21 + 7 pack started on Saturday 7 November 2026.
  final pack = PillSchedule(PackType.p21x7, DateTime(2026, 11, 7));

  test('the wire names match the database', () {
    expect(PackType.values.map((t) => t.wire), ['21_7', '28', 'continuous']);
    expect(PackType.fromWire('28'), PackType.p28);
    expect(PackType.fromWire('nope'), isNull);
  });

  test('day 1 is pill 1, day 21 is pill 21', () {
    expect(pack.dayInPack(DateTime(2026, 11, 7)), 1);
    expect(pack.pillNumber(DateTime(2026, 11, 7)), 1);
    expect(pack.pillNumber(DateTime(2026, 11, 18)), 12);
    expect(pack.pillNumber(DateTime(2026, 11, 27)), 21);
    expect(pack.isPillDay(DateTime(2026, 11, 27)), isTrue);
  });

  test('days 22 to 28 are the pause, then a new pack starts', () {
    expect(pack.dayInPack(DateTime(2026, 11, 28)), 22);
    expect(pack.isPillDay(DateTime(2026, 11, 28)), isFalse);
    expect(pack.pillNumber(DateTime(2026, 12, 4)), isNull);
    expect(pack.dayInPack(DateTime(2026, 12, 5)), 1);
    expect(pack.pillNumber(DateTime(2026, 12, 5)), 1);
    expect(pack.nextPackStart(DateTime(2026, 11, 18)), DateTime(2026, 12, 5));
    expect(pack.nextPackStart(DateTime(2026, 12, 5)), DateTime(2027, 1, 2));
  });

  test('the pause around a day: this one, or the next', () {
    expect(pack.pauseAround(DateTime(2026, 11, 18)), (
      from: DateTime(2026, 11, 28),
      to: DateTime(2026, 12, 4),
    ));
    expect(pack.pauseAround(DateTime(2026, 11, 30)), (
      from: DateTime(2026, 11, 28),
      to: DateTime(2026, 12, 4),
    ));
    expect(
      PillSchedule(
        PackType.p28,
        DateTime(2026, 11, 7),
      ).pauseAround(DateTime(2026, 11, 18)),
      isNull,
    );
  });

  test('a start in the future counts back the same way', () {
    // 5 Dec 2026 starts a pack: 4 Dec is the last day of the one before.
    final later = PillSchedule(PackType.p21x7, DateTime(2026, 12, 5));
    expect(later.dayInPack(DateTime(2026, 12, 4)), 28);
    expect(later.pillNumber(DateTime(2026, 11, 18)), 12);
  });

  test('the clocks changing on 25 October moves nothing', () {
    final october = PillSchedule(PackType.p21x7, DateTime(2026, 10, 20));
    expect(october.dayInPack(DateTime(2026, 10, 25)), 6);
    expect(october.dayInPack(DateTime(2026, 10, 26, 23, 59)), 7);
  });

  test('28 and continuous packs have a pill every day', () {
    for (final type in [PackType.p28, PackType.continuous]) {
      final s = PillSchedule(type, DateTime(2026, 11, 7));
      for (var i = 0; i < 60; i++) {
        expect(s.isPillDay(DateTime(2026, 11, 7 + i)), isTrue);
      }
      expect(s.pillsInPack, 28);
    }
    expect(
      PillSchedule(
        PackType.p28,
        DateTime(2026, 11, 7),
      ).pillNumber(DateTime(2026, 12, 4)),
      28,
    );
    expect(pack.pillsInPack, 21);
  });
}
