import 'package:flutter_test/flutter_test.dart';

import 'package:nousdeux/core/utils/date_only.dart';

void main() {
  group('parseDay', () {
    test('a plain date stays that local day', () {
      expect(parseDay('2026-11-10'), DateTime(2026, 11, 10));
    });

    test('a timestamp without a zone keeps the day as written', () {
      expect(parseDay('2026-11-10T23:30:00'), DateTime(2026, 11, 10));
      expect(parseDay('2026-11-10T00:10:00'), DateTime(2026, 11, 10));
    });

    test('a timestamp with a zone keeps its UTC day, like Postgres', () {
      expect(parseDay('2026-11-10T00:00:00+00:00'), DateTime(2026, 11, 10));
      expect(parseDay('2026-11-11T01:00:00+02:00'), DateTime(2026, 11, 10));
    });
  });

  test('formatDay pads month and day', () {
    expect(formatDay(DateTime(2026, 3, 4, 23, 59)), '2026-03-04');
  });

  test('dayOf drops the time', () {
    expect(dayOf(DateTime(2026, 11, 10, 18, 42)), DateTime(2026, 11, 10));
  });
}
