import 'package:flutter_test/flutter_test.dart';

import 'package:nousdeux/core/utils/phone_utils.dart';

void main() {
  group('normalizePhone', () {
    test('drops the French trunk zero', () {
      expect(normalizePhone('06 12 34 56 78'), '+33612345678');
    });

    test('keeps numbers that already have a country code', () {
      expect(normalizePhone('+1 234 567 8900'), '+12345678900');
    });

    test('turns the 00 international prefix into +', () {
      expect(normalizePhone('0044 20 7946 0958'), '+442079460958');
    });

    test('strips dots, dashes and parentheses', () {
      expect(normalizePhone('06.12-34 (56) 78'), '+33612345678');
    });

    test('adds the default country code to bare local numbers', () {
      expect(normalizePhone('612345678'), '+33612345678');
    });

    test('returns empty for blank input', () {
      expect(normalizePhone('   '), '');
    });
  });
}
