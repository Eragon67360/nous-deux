import 'dart:async';

import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';

/// Runs once per test file, before its `main`.
///
/// - Fonts: AppTheme uses google_fonts, which would try to download DM Sans and
///   Instrument Serif. Tests never touch the network: runtime fetching is off,
///   and the theme is built by `testTheme` (test/helpers/test_app.dart) inside a
///   zone that swallows the resulting "font not in assets" errors. Text then
///   renders with the test fallback font, which is fine for finders.
/// - Dates: screens format with the `fr_FR` / `en_US` locales, as main() does.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  GoogleFonts.config.allowRuntimeFetching = false;
  await initializeDateFormatting('fr_FR');
  await initializeDateFormatting('en_US');
  await testMain();
}
