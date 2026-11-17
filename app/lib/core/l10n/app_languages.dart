import 'dart:ui';

/// The languages the app speaks, in one place. The language picker, the
/// locales the app declares, the phone-to-app rule and the date formats all
/// read this list, so adding a language starts here (docs/LOCALIZATION.md).
abstract final class AppLanguages {
  AppLanguages._();

  /// Language codes, as stored in `profiles.language`.
  static const List<String> supported = ['fr', 'en'];

  /// What anything unsupported falls back to.
  static const String fallback = 'en';

  /// Each language in its own words, as language pickers show them.
  static const Map<String, String> _nativeNames = {
    'fr': 'Français',
    'en': 'English',
  };

  /// The `intl` locale whose date formats each language uses.
  static const Map<String, String> _dateLocales = {
    'fr': 'fr_FR',
    'en': 'en_US',
  };

  /// [supported] as locales, for `MaterialApp.supportedLocales`.
  static List<Locale> get locales => [
    for (final code in supported) Locale(code),
  ];

  static bool isSupported(String? code) => supported.contains(code);

  /// [code] when the app speaks it, else [fallback].
  static String resolve(String? code) => isSupported(code) ? code! : fallback;

  /// The app's language on a phone set to [locale]: its language when the
  /// app speaks it (any region: fr_CA is French), else [fallback].
  static String forDevice(Locale locale) => resolve(locale.languageCode);

  /// The name of [code] in that language ("Français", "English").
  static String nativeName(String code) => _nativeNames[code] ?? code;

  /// The `intl` locale for dates in [code], or in [fallback] when the app
  /// doesn't speak it.
  static String dateLocale(String? code) => _dateLocales[resolve(code)]!;

  /// Every date locale the app needs loaded at start.
  static Iterable<String> get dateLocales => supported.map(dateLocale);
}
