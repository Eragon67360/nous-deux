import 'package:intl/intl.dart';

import 'package:nousdeux/core/l10n/app_languages.dart';
import 'package:nousdeux/core/l10n/l10n.dart';
import 'package:nousdeux/domain/entities/pill_entities.dart';
import 'package:nousdeux/domain/pill/pill_schedule.dart';

// Pill tracking (docs/PILL.md): the Règles section, its setup and settings.

String pillLabel(String lang) => l10nFor(lang).pillLabel;
String pillSetupQuestion(String lang) => l10nFor(lang).pillSetupQuestion;
String pillSetupWhy(String lang) => l10nFor(lang).pillSetupWhy;
String pillSetupYes(String lang) => l10nFor(lang).pillSetupYes;
String pillSetupNo(String lang) => l10nFor(lang).pillSetupNo;
String pillSetupLater(String lang) => l10nFor(lang).pillSetupLater;
String pillReminderLabel(String lang) => l10nFor(lang).pillReminderLabel;
String pillTodayLabel(String lang) => l10nFor(lang).pillTodayLabel;
String pillNumberToday(String lang, int number) =>
    l10nFor(lang).pillNumberToday(number);
String pillPackLabel(String lang) => l10nFor(lang).pillPackLabel;
String pillPackType(String lang, PackType type) =>
    l10nFor(lang).pillPackType(type.name);

/// One line on what the pack type means, under its choice.
String pillPackTypeNote(String lang, PackType type) =>
    l10nFor(lang).pillPackTypeNote(type.name);
String pillHealthNote(String lang) => l10nFor(lang).pillHealthNote;
String pillContinue(String lang) => l10nFor(lang).pillContinue;
String pillConsentTitle(String lang) => l10nFor(lang).pillConsentTitle;
String pillConsent(String lang) => l10nFor(lang).pillConsent;
String pillTrackLink(String lang) => l10nFor(lang).pillTrackLink;
String pillReminderAt(String lang, TimeOfDayValue t) =>
    l10nFor(lang).pillReminderAt(pillClock(lang, t));
String pillOfPack(String lang, int total) => l10nFor(lang).pillOfPack(total);
String pillNotTickedToday(String lang) => l10nFor(lang).pillNotTickedToday;
String pillTakenAt(String lang, DateTime at) =>
    l10nFor(lang).pillTakenAt(pillTime(lang, at));
String pillTakeButton(String lang) => l10nFor(lang).pillTakeButton;
String pillUntick(String lang) => l10nFor(lang).pillUntick;
String pillDayOff(String lang) => l10nFor(lang).pillDayOff;
String pillThisWeek(String lang) => l10nFor(lang).pillThisWeek;
String pillWeekMissed(String lang) => l10nFor(lang).pillWeekMissed;
String pillWeekOff(String lang) => l10nFor(lang).pillWeekOff;
String pillTookItAt(String lang) => l10nFor(lang).pillTookItAt;
String pillTakingNow(String lang) => l10nFor(lang).pillTakingNow;
String pillIfMissed(String lang) => l10nFor(lang).pillIfMissed;
String pillIfMissedBody(String lang) => l10nFor(lang).pillIfMissedBody;
String pillOfficialSheet(String lang, String name) =>
    l10nFor(lang).pillOfficialSheet(name);
String pillNoteMissed(String lang) => l10nFor(lang).pillNoteMissed;
String pillNotedMissed(String lang) => l10nFor(lang).pillNotedMissed;
String pillNoScore(String lang) => l10nFor(lang).pillNoScore;
String pillYesterdayPending(String lang) => l10nFor(lang).pillYesterdayPending;
String pillTookItYesterday(String lang) => l10nFor(lang).pillTookItYesterday;
String pillBreakUntil(String lang, DateTime last) =>
    l10nFor(lang).pillBreakUntil(pillShortDate(lang, last));
String pillPartnerTaken(String lang, DateTime at) =>
    l10nFor(lang).pillPartnerTaken(pillTime(lang, at));
String pillPartnerNotYet(String lang) => l10nFor(lang).pillPartnerNotYet;
String pillSettingsTitle(String lang) => l10nFor(lang).pillSettingsTitle;
String pillReminderDaily(String lang) => l10nFor(lang).pillReminderDaily;
String pillReminderTime(String lang) => l10nFor(lang).pillReminderTime;
String pillLockScreen(String lang) => l10nFor(lang).pillLockScreen;
String pillPackTypeLabel(String lang) => l10nFor(lang).pillPackTypeLabel;
String pillTodayPill(String lang) => l10nFor(lang).pillTodayPill;
String pillWithPartner(String lang, String name) =>
    l10nFor(lang).pillWithPartner(name);
String pillShareWith(String lang, String name) =>
    l10nFor(lang).pillShareWith(name);
String pillShareWithNote(String lang) => l10nFor(lang).pillShareWithNote;
String pillStop(String lang) => l10nFor(lang).pillStop;
String pillStopNote(String lang, String name) =>
    l10nFor(lang).pillStopNote(name);
String pillStopConfirmTitle(String lang) => l10nFor(lang).pillStopConfirmTitle;
String pillStopConfirmBody(String lang) => l10nFor(lang).pillStopConfirmBody;
String pillStopConfirm(String lang) => l10nFor(lang).pillStopConfirm;

/// What the lock screen says, as the settings' choices show it.
String pillLockScreenChoice(String lang, ReminderText style) =>
    l10nFor(lang).pillReminderTitle(style.wire);

/// « Jour 12 sur 21 · arrêt du 28 nov. au 4 déc. », or « Jour 3 sur 28 ».
String pillPackLine(String lang, PillSchedule s, DateTime day) {
  final pause = s.pauseAround(day);
  if (pause == null) return l10nFor(lang).pillPackLine(s.dayInPack(day));
  // In the break, when it ends rather than « Jour 24 sur 21 ».
  if (!s.isPillDay(day)) return pillBreakUntil(lang, pause.to);
  return l10nFor(lang).pillPackLine21(
    s.dayInPack(day),
    pillShortDate(lang, pause.from),
    pillShortDate(lang, pause.to),
  );
}

String pillNextPack(String lang, DateTime date) =>
    l10nFor(lang).pillNextPack(pillShortDate(lang, date));

/// A reminder time in the language's style: « 21:00 », "9:00 PM".
String pillClock(String lang, TimeOfDayValue t) => DateFormat.jm(
  AppLanguages.dateLocale(lang),
).format(DateTime(2000, 1, 1, t.hour, t.minute));

String pillTime(String lang, DateTime at) =>
    pillClock(lang, (hour: at.hour, minute: at.minute));

/// « 28 nov. », "28 Nov".
String pillShortDate(String lang, DateTime d) =>
    DateFormat('d MMM', AppLanguages.dateLocale(lang)).format(d);

/// « jeu. », "Thu".
String pillWeekday(String lang, DateTime d) =>
    DateFormat.E(AppLanguages.dateLocale(lang)).format(d);

/// Under the lock-screen choice: the reminder as it will show.
String pillLockScreenPreview(String lang, String title, String body) =>
    l10nFor(lang).pillLockScreenPreview(title, body);
