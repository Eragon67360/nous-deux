import 'package:intl/intl.dart';

import 'package:nousdeux/core/constants/period_education.dart' show CyclePhase;
import 'package:nousdeux/core/l10n/app_languages.dart';
import 'package:nousdeux/core/l10n/l10n.dart';

/// Strings for the Règles tab (cycle page, partner page, sharing, guide).
/// Use lang 'fr' or 'en'. Names are the partner's display name.

String _date(String lang, DateTime d) =>
    DateFormat.MMMEd(AppLanguages.dateLocale(lang)).format(d);

/// The partner's name, or a stand-in while they have none.
String cyclePartnerName(String lang, String? username) {
  final name = username?.trim();
  if (name != null && name.isNotEmpty) return name;
  return l10nFor(lang).cyclePartnerFallback;
}

// --- Who tracks ---
String cycleAskTitle(String lang) => l10nFor(lang).cycleAskTitle;
String cycleAskBody(String lang) => l10nFor(lang).cycleAskBody;

// --- Consent (cycle data is health data) ---
String cycleConsent(String lang) => l10nFor(lang).cycleConsent;
String cycleConsentTitle(String lang) => l10nFor(lang).cycleConsentTitle;
String cycleConsentAccept(String lang) => l10nFor(lang).cycleConsentAccept;
String cyclePrivacyPolicy(String lang) => l10nFor(lang).cyclePrivacyPolicy;
String cyclePrivacyUrl(String lang) =>
    'https://nous-deux.app/${AppLanguages.resolve(lang)}/politique-de-confidentialite';
String cycleStopTitle(String lang) => l10nFor(lang).cycleStopTitle;
String cycleStopBody(String lang) => l10nFor(lang).cycleStopBody;
String cycleStopKeep(String lang) => l10nFor(lang).cycleStopKeep;
String cycleStopDelete(String lang) => l10nFor(lang).cycleStopDelete;
String cycleDataDeleted(String lang) => l10nFor(lang).cycleDataDeleted;
String cycleAskYes(String lang) => l10nFor(lang).cycleAskYes;
String cycleAskNo(String lang) => l10nFor(lang).cycleAskNo;
String settingsTracksCycle(String lang) => l10nFor(lang).settingsTracksCycle;

// --- Phases ---
String cyclePhaseLabel(String lang, CyclePhase phase) =>
    l10nFor(lang).cyclePhaseLabel(phase.name);

// --- My cycle (R1) ---
String cycleDayWord(String lang) => l10nFor(lang).cycleDayWord;
String cycleOfAbout(String lang, int length) =>
    l10nFor(lang).cycleOfAbout(length);
String cycleRingLabel(String lang, int day, int length) =>
    l10nFor(lang).cycleRingLabel(day, length);

/// The big line under the ring.
String cycleHeadline(
  String lang, {
  required bool ongoing,
  required int dayOfCycle,
  required int? daysUntil,
}) {
  final l = l10nFor(lang);
  if (ongoing) return l.cycleHeadlineOngoing(dayOfCycle);
  final d = daysUntil;
  if (d == null) return '';
  return d >= 0 ? l.cycleHeadlineIn(d) : l.cycleHeadlineLate(-d);
}

/// Where the expected date comes from.
String cycleBasis(String lang, DateTime next, int cyclesUsed) =>
    l10nFor(lang).cycleBasis(_date(lang, next), cyclesUsed);

String cycleNoDataTitle(String lang) => l10nFor(lang).cycleNoDataTitle;
String cycleNoDataBody(String lang) => l10nFor(lang).cycleNoDataBody;
String cycleStarted(String lang) => l10nFor(lang).cycleStarted;
String cycleEnded(String lang) => l10nFor(lang).cycleEnded;
String cycleOtherDay(String lang) => l10nFor(lang).cycleOtherDay;
String cycleToday(String lang) => l10nFor(lang).cycleToday;
String cycleSeenBy(String lang, String name) => l10nFor(lang).cycleSeenBy(name);
String cycleSeenByNobody(String lang) => l10nFor(lang).cycleSeenByNobody;
String cycleNoteLabel(String lang) => l10nFor(lang).cycleNoteLabel;
String cycleNoteHint(String lang) => l10nFor(lang).cycleNoteHint;
String cycleNoteSaved(String lang) => l10nFor(lang).cycleNoteSaved;
String cycleThisWeek(String lang) => l10nFor(lang).cycleThisWeek;
String cycleReadChapter(String lang, String title) =>
    l10nFor(lang).cycleReadChapter(title);
String cycleHistoryLink(String lang) => l10nFor(lang).cycleHistoryLink;
String cycleSharingLink(String lang, String name) =>
    l10nFor(lang).cycleSharingLink(name);
String cyclePartnerLink(String lang, String name) =>
    l10nFor(lang).cyclePartnerLink(name);
String cycleLoggedStart(String lang, DateTime day) =>
    l10nFor(lang).cycleLoggedStart(_date(lang, day));
String cycleLoggedEnd(String lang, DateTime day) =>
    l10nFor(lang).cycleLoggedEnd(_date(lang, day));
String cycleUndo(String lang) => l10nFor(lang).cycleUndo;
String cycleShortDate(String lang, DateTime day) =>
    DateFormat.MMMd(AppLanguages.dateLocale(lang)).format(day);
// States of one's own in today's check-in ("Besoin de chocolat").
String cycleOtherState(String lang) => l10nFor(lang).cycleOtherState;
String cycleNewStateHint(String lang) => l10nFor(lang).cycleNewStateHint;
String cycleAddState(String lang) => l10nFor(lang).cycleAddState;
String cycleOwnStateHint(String lang) => l10nFor(lang).cycleOwnStateHint;
String cycleStateRemoved(String lang, String state) =>
    l10nFor(lang).cycleStateRemoved(state);
String cycleTooManyStates(String lang) => l10nFor(lang).cycleTooManyStates;
String cycleSaveFailed(String lang) => l10nFor(lang).cycleSaveFailed;
String cycleNeedsCouple(String lang) => l10nFor(lang).cycleNeedsCouple;

/// What the person who tracks may like to know, per phase.
String cycleSelfTip(String lang, CyclePhase phase) =>
    l10nFor(lang).cycleSelfTip(phase.name);

// --- Log sheet ---
String cycleSheetStarted(String lang) => l10nFor(lang).cycleSheetStarted;
String cycleSheetEnded(String lang) => l10nFor(lang).cycleSheetEnded;
String cycleSheetWhen(String lang) => l10nFor(lang).cycleSheetWhen;
String cycleYesterday(String lang) => l10nFor(lang).cycleYesterday;
String cycleAnotherDay(String lang) => l10nFor(lang).cycleAnotherDay;
String cycleSave(String lang) => l10nFor(lang).cycleSave;
String cycleSheetFootnote(String lang) => l10nFor(lang).cycleSheetFootnote;

// --- History ---
String cycleHistoryTitle(String lang) => l10nFor(lang).cycleHistoryTitle;
String cycleAverage(String lang) => l10nFor(lang).cycleAverage;
String cyclePeriod(String lang) => l10nFor(lang).cyclePeriod;
String cycleDaysWord(String lang) => l10nFor(lang).cycleDaysWord;
String cycleRegularity(String lang, int count, int shortest, int longest) =>
    shortest == longest
    ? l10nFor(lang).cycleRegularitySame(count, shortest)
    : l10nFor(lang).cycleRegularityRange(count, shortest, longest);
String cycleNeedTwo(String lang) => l10nFor(lang).cycleNeedTwo;
String cycleCurrentRow(String lang, int day) =>
    l10nFor(lang).cycleCurrentRow(day);
String cycleSpanRow(String lang, int length, int? periodDays) =>
    periodDays == null
    ? l10nFor(lang).cycleSpanRow(length)
    : l10nFor(lang).cycleSpanRowWithPeriod(length, periodDays);

String cycleRestOfCycle(String lang) => l10nFor(lang).cycleRestOfCycle;
String cycleHistoryHint(String lang) => l10nFor(lang).cycleHistoryHint;
String cycleHistoryEmpty(String lang) => l10nFor(lang).cycleHistoryEmpty;

// --- Partner's cycle (R3) ---
String cyclePartnerLabel(String lang, String name) =>
    l10nFor(lang).cyclePartnerLabel(name);
String cyclePartnerHeadline(
  String lang,
  String name, {
  required bool ongoing,
  required int day,
}) => ongoing
    ? l10nFor(lang).cyclePartnerHeadlineOngoing(name, day)
    : l10nFor(lang).cyclePartnerHeadlineDay(name, day);
String cyclePartnerNext(String lang, DateTime next, int? daysUntil) {
  final date = _date(lang, next);
  return daysUntil != null && daysUntil < 0
      ? l10nFor(lang).cyclePartnerNextLate(date)
      : l10nFor(lang).cyclePartnerNext(date);
}

String cyclePartnerNotShared(String lang, String name) =>
    l10nFor(lang).cyclePartnerNotShared(name);
String cyclePartnerNothingYet(String lang, String name) =>
    l10nFor(lang).cyclePartnerNothingYet(name);
String cyclePartnerNotTracking(String lang, String name) =>
    l10nFor(lang).cyclePartnerNotTracking(name);
String cycleNoPartner(String lang) => l10nFor(lang).cycleNoPartner;
String cycleWhatHelps(String lang) => l10nFor(lang).cycleWhatHelps;
String cyclePartnerNoted(String lang, String name) =>
    l10nFor(lang).cyclePartnerNoted(name);
String cycleLittleNote(String lang) => l10nFor(lang).cycleLittleNote;
String cycleRemindMe(String lang) => l10nFor(lang).cycleRemindMe;
String cycleRemindOn(String lang, DateTime day) =>
    l10nFor(lang).cycleRemindOn(_date(lang, day));
String cycleRemindNoDate(String lang) => l10nFor(lang).cycleRemindNoDate;

/// Three things that tend to help, per phase, for the partner.
List<String> cyclePartnerTips(String lang, CyclePhase phase) {
  final l = l10nFor(lang);
  return [
    l.cyclePartnerTip1(phase.name),
    l.cyclePartnerTip2(phase.name),
    l.cyclePartnerTip3(phase.name),
  ];
}

// --- Sharing (R3) ---
String cycleSharingTitle(String lang, String name) =>
    l10nFor(lang).cycleSharingTitle(name);
String cycleSharingIntro(String lang) => l10nFor(lang).cycleSharingIntro;
String cycleShareCycle(String lang) => l10nFor(lang).cycleShareCycle;
String cycleShareCycleHint(String lang) => l10nFor(lang).cycleShareCycleHint;
String cycleShareCheckins(String lang) => l10nFor(lang).cycleShareCheckins;
String cycleShareCheckinsHint(String lang) =>
    l10nFor(lang).cycleShareCheckinsHint;
String cycleNotesRow(String lang) => l10nFor(lang).cycleNotesRow;
String cycleNotesAlwaysPrivate(String lang) =>
    l10nFor(lang).cycleNotesAlwaysPrivate;
String cycleStopSharing(String lang) => l10nFor(lang).cycleStopSharing;

// --- Guide (R4) ---
String guideLabel(String lang) => l10nFor(lang).guideLabel;
String guideTitle(String lang) => l10nFor(lang).guideTitle;
String guideForYouNow(String lang, int day) =>
    l10nFor(lang).guideForYouNow(day);
String guideForPartnerNow(String lang, String name, int day) =>
    l10nFor(lang).guideForPartnerNow(name, day);
String guideNowTitle(String lang, CyclePhase phase) =>
    l10nFor(lang).guideNowTitle(cyclePhaseLabel(lang, phase));
String guideChapter(String lang, int n) => l10nFor(lang).guideChapter(n);
String guideRead(String lang) => l10nFor(lang).guideRead;
String guideFootnote(String lang) => l10nFor(lang).guideFootnote;
String guideContents(String lang) => l10nFor(lang).guideContents;
String guideNext(String lang, String title) => l10nFor(lang).guideNext(title);
String guideSearch(String lang) => l10nFor(lang).guideSearch;
String guideNoMatch(String lang, String query) =>
    l10nFor(lang).guideNoMatch(query);
String guideBody(String lang) => l10nFor(lang).guideBody;
String guideMood(String lang) => l10nFor(lang).guideMood;
String guideWhatHelps(String lang) => l10nFor(lang).guideWhatHelps;
String guideYouAreHere(String lang) => l10nFor(lang).guideYouAreHere;
String guidePartnerIsHere(String lang, String name) =>
    l10nFor(lang).guidePartnerIsHere(name);
String guideSources(String lang) => l10nFor(lang).guideSources;
String guideDaysShort(String lang, String range) =>
    l10nFor(lang).guideDaysShort(range);

/// A label before its text in the guide; French puts a space before the colon.
String guideLabelPrefix(String lang, String label) =>
    l10nFor(lang).guideLabelPrefix(label);
