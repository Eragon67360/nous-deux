import 'dart:async';

import 'package:intl/date_symbol_data_local.dart';

import 'package:nousdeux/core/l10n/app_languages.dart';

/// Runs once per test file, before its `main`.
///
/// - Fonts: Manrope is bundled (pubspec.yaml), so nothing is fetched. Widget
///   tests still render with the test font, which is fine for finders.
/// - Dates: screens format with each language's date locale, as main() does.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  for (final locale in AppLanguages.dateLocales) {
    await initializeDateFormatting(locale);
  }
  await testMain();
}
