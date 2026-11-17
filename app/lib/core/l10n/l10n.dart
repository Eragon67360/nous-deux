import 'dart:ui';

import 'package:nousdeux/core/l10n/app_languages.dart';
import 'package:nousdeux/l10n/generated/app_localizations.dart';

export 'package:nousdeux/l10n/generated/app_localizations.dart';

final _byLanguage = <String, AppLocalizations>{};

/// The app's text in [lang], or in English when the app doesn't speak it.
///
/// Works anywhere, without a BuildContext, so the string functions in
/// `lib/core/constants/*_strings.dart` and the notification service can use
/// it. The texts themselves live in `lib/l10n/app_<lang>.arb`.
AppLocalizations l10nFor(String lang) {
  final code = AppLanguages.resolve(lang);
  return _byLanguage[code] ??= lookupAppLocalizations(Locale(code));
}
