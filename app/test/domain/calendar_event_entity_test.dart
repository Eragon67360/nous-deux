import 'package:flutter_test/flutter_test.dart';

import '../helpers/fixtures.dart';

void main() {
  group('looksAllDay', () {
    test('midnight to midnight, or to 23:59, is all day', () {
      expect(
        event(
          start: DateTime(2026, 11, 20),
          end: DateTime(2026, 11, 20),
        ).looksAllDay,
        isTrue,
      );
      expect(
        event(
          start: DateTime(2026, 11, 20),
          end: DateTime(2026, 11, 21),
        ).looksAllDay,
        isTrue,
      );
      expect(
        event(
          start: DateTime(2026, 11, 20),
          end: DateTime(2026, 11, 20, 23, 59, 59),
        ).looksAllDay,
        isTrue,
      );
    });

    test('anything with a time is not', () {
      expect(
        event(
          start: DateTime(2026, 11, 20),
          end: DateTime(2026, 11, 20, 1),
        ).looksAllDay,
        isFalse,
      );
      expect(
        event(
          start: DateTime(2026, 11, 20, 9),
          end: DateTime(2026, 11, 21),
        ).looksAllDay,
        isFalse,
      );
      expect(event(start: DateTime(2026, 11, 20)).looksAllDay, isFalse);
    });
  });
}
