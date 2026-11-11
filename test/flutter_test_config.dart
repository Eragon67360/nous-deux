import 'dart:async';

import 'package:intl/date_symbol_data_local.dart';

/// Runs once per test file, before its `main`.
///
/// - Fonts: Manrope is bundled (pubspec.yaml), so nothing is fetched. Widget
///   tests still render with the test font, which is fine for finders.
/// - Dates: screens format with the `fr_FR` / `en_US` locales, as main() does.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  await initializeDateFormatting('fr_FR');
  await initializeDateFormatting('en_US');
  await testMain();
}
