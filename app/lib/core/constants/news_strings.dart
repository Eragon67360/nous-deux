import 'package:intl/intl.dart';

import 'package:nousdeux/core/l10n/app_languages.dart';
import 'package:nousdeux/core/l10n/l10n.dart';

// Nouveautés: the team's messages to everyone (docs/NOUVEAUTES.md).

String newsTitle(String lang) => l10nFor(lang).newsTitle;
String newsSignature(String lang) => l10nFor(lang).newsSignature;
String newsUnread(String lang, int count) => l10nFor(lang).newsUnread(count);
String newsEmpty(String lang) => l10nFor(lang).newsEmpty;
String newsLoadFailed(String lang) => l10nFor(lang).newsLoadFailed;
String settingsNewsPush(String lang) => l10nFor(lang).settingsNewsPush;
String settingsNewsPushSubtitle(String lang) =>
    l10nFor(lang).settingsNewsPushSubtitle;

/// The avatar's tooltip on the Nous tab while [count] messages are unread.
String newsAvatarUnread(String lang, int count) =>
    l10nFor(lang).newsAvatarUnread(count);

/// A message's day as its gold label: « 20 NOV. », "20 NOV".
String newsDate(String lang, DateTime sentAt) => DateFormat(
  'd MMM',
  AppLanguages.dateLocale(lang),
).format(sentAt.toLocal()).toUpperCase();
