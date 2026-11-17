import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

import 'package:nousdeux/core/l10n/app_languages.dart';

void main() {
  test('speaks French and English, and falls back to English', () {
    expect(AppLanguages.supported, ['fr', 'en']);
    expect(AppLanguages.fallback, 'en');
    expect(AppLanguages.locales, [const Locale('fr'), const Locale('en')]);
  });

  test('resolve keeps a supported code and sends anything else to English', () {
    expect(AppLanguages.resolve('fr'), 'fr');
    expect(AppLanguages.resolve('en'), 'en');
    expect(AppLanguages.resolve('de'), 'en');
    expect(AppLanguages.resolve(''), 'en');
    expect(AppLanguages.resolve(null), 'en');
  });

  test("forDevice uses the phone's language, whatever its region", () {
    expect(AppLanguages.forDevice(const Locale('fr', 'FR')), 'fr');
    expect(AppLanguages.forDevice(const Locale('fr', 'CA')), 'fr');
    expect(AppLanguages.forDevice(const Locale('en', 'GB')), 'en');
    expect(AppLanguages.forDevice(const Locale('de', 'DE')), 'en');
  });

  test('names each language in its own words', () {
    expect(AppLanguages.nativeName('fr'), 'Français');
    expect(AppLanguages.nativeName('en'), 'English');
  });

  test('every language has a date locale that intl knows', () {
    expect(AppLanguages.dateLocale('fr'), 'fr_FR');
    expect(AppLanguages.dateLocale('en'), 'en_US');
    expect(AppLanguages.dateLocale('de'), 'en_US');
    expect(AppLanguages.dateLocale(null), 'en_US');
    // DateFormat resolves fr_FR to intl's `fr` data the same way.
    for (final locale in AppLanguages.dateLocales) {
      final resolved = Intl.verifiedLocale(
        locale,
        DateFormat.localeExists,
        onFailure: (_) => null,
      );
      expect(resolved, isNotNull, reason: locale);
    }
  });

  test('every language has a name and a date locale', () {
    for (final code in AppLanguages.supported) {
      expect(AppLanguages.nativeName(code), isNot(code), reason: code);
      expect(() => AppLanguages.dateLocale(code), returnsNormally);
    }
  });
}
