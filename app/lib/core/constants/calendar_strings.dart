import 'package:intl/intl.dart';

import 'package:nousdeux/core/l10n/app_languages.dart';
import 'package:nousdeux/core/l10n/l10n.dart';

/// Calendar screen strings. Use lang 'fr' or 'en'.
String calendarTitle(String lang) => l10nFor(lang).calendarTitle;
String calendarToday(String lang) => l10nFor(lang).calendarToday;
String calendarAdd(String lang) => l10nFor(lang).calendarAdd;
String calendarPartner(String lang) => l10nFor(lang).calendarPartner;
String calendarMe(String lang) => l10nFor(lang).calendarMe;
String calendarDeleteEventTitle(String lang) =>
    l10nFor(lang).calendarDeleteEventTitle;
String calendarDeleteEventConfirm(String lang, String title) =>
    l10nFor(lang).calendarDeleteEventConfirm(title);
String calendarCancel(String lang) => l10nFor(lang).calendarCancel;
String calendarDelete(String lang) => l10nFor(lang).calendarDelete;
String calendarNothingInMonth(String lang, String month) =>
    l10nFor(lang).calendarNothingInMonth(month);
String calendarCreateEvent(String lang) => l10nFor(lang).calendarCreateEvent;
String calendarPreviousMonth(String lang) =>
    l10nFor(lang).calendarPreviousMonth;
String calendarNextMonth(String lang) => l10nFor(lang).calendarNextMonth;

// Calendar access, asked on the follow screen
String calendarImportAllowAccess(String lang) =>
    l10nFor(lang).calendarImportAllowAccess;
String calendarImportOpenSettings(String lang) =>
    l10nFor(lang).calendarImportOpenSettings;
// Event form
String calendarEventEdit(String lang) => l10nFor(lang).calendarEventEdit;
String calendarEventNew(String lang) => l10nFor(lang).calendarEventNew;
String calendarEventTitleLabel(String lang) =>
    l10nFor(lang).calendarEventTitleLabel;
String calendarEventTitleRequired(String lang) =>
    l10nFor(lang).calendarEventTitleRequired;
String calendarEventDescriptionLabel(String lang) =>
    l10nFor(lang).calendarEventDescriptionLabel;
String calendarEventStart(String lang) => l10nFor(lang).calendarEventStart;
String calendarEventEnd(String lang) => l10nFor(lang).calendarEventEnd;
String calendarEventSave(String lang) => l10nFor(lang).calendarEventSave;
String calendarEventCountdown(String lang) =>
    l10nFor(lang).calendarEventCountdown;
String calendarEventCountdownHint(String lang) =>
    l10nFor(lang).calendarEventCountdownHint;
String calendarEventEndBeforeStart(String lang) =>
    l10nFor(lang).calendarEventEndBeforeStart;

// Phone calendar: following it (docs/CALENDAR_SYNC.md).
String calendarFollowLabel(String lang) => l10nFor(lang).calendarFollowLabel;
String calendarFollowTitle(String lang) => l10nFor(lang).calendarFollowTitle;
String calendarFollowIntro(String lang, String partnerName) =>
    l10nFor(lang).calendarFollowIntro(partnerName);
String calendarFollowTip(String lang) => l10nFor(lang).calendarFollowTip;
String calendarFollowLastSync(String lang) =>
    l10nFor(lang).calendarFollowLastSync;
String calendarFollowFootnote(String lang) =>
    l10nFor(lang).calendarFollowFootnote;
String calendarFollowOtherPhone(String lang) =>
    l10nFor(lang).calendarFollowOtherPhone;
String calendarFollowGone(String lang) => l10nFor(lang).calendarFollowGone;
String calendarFollowDropGone(String lang) =>
    l10nFor(lang).calendarFollowDropGone;
String calendarFollowFailed(String lang) => l10nFor(lang).calendarFollowFailed;
String calendarFollowNone(String lang) => l10nFor(lang).calendarFollowNone;
String calendarFollowPermission(String lang) =>
    l10nFor(lang).calendarFollowPermission;

/// "Il y a 5 min", "5 min ago": how long ago [at] was, at [now].
String calendarAgo(String lang, DateTime at, DateTime now) {
  final l = l10nFor(lang);
  final ago = now.difference(at);
  if (ago.inMinutes < 1) return l.timeAgoJustNow;
  if (ago.inHours < 1) return l.timeAgoMinutes(ago.inMinutes);
  if (ago.inHours < 24) return l.timeAgoHours(ago.inHours);
  return l.timeAgoOnDay(
    DateFormat.MMMd(AppLanguages.dateLocale(lang)).format(at),
  );
}

/// The partner's calendar freshness in the header ("Alex · il y a 5 min").
String calendarPartnerFresh(String lang, String name, String ago) =>
    '$name · $ago';

/// Where a synced event comes from. French elides "de" before a vowel.
String calendarSyncedFrom(String lang, String name, {required bool mine}) {
  if (mine) return l10nFor(lang).calendarSyncedFromMine;
  // French writes « d'Alex » but « de Camille ».
  final vowel = RegExp(
    r'^[aeiouyhàâäéèêëîïôöùûüAEIOUYHÀÂÄÉÈÊËÎÏÔÖÙÛÜ]',
  ).hasMatch(name);
  return l10nFor(lang).calendarSyncedFrom(name, vowel ? 'vowel' : 'other');
}

String calendarSyncedReadOnly(String lang, String name, {required bool mine}) =>
    mine
    ? l10nFor(lang).calendarSyncedReadOnlyMine
    : l10nFor(lang).calendarSyncedReadOnly(name);

String calendarAllDay(String lang) => l10nFor(lang).calendarAllDay;
