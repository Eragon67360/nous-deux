// Nous tab strings (days together, countdowns, little notes).
// Keep the received-note wording in sync with
// supabase/functions/notify-partner-ping/index.ts.

import 'package:intl/intl.dart';

import 'package:nousdeux/core/errors/failures.dart';
import 'package:nousdeux/core/l10n/app_languages.dart';
import 'package:nousdeux/domain/entities/ping_entity.dart';
import 'package:nousdeux/core/l10n/l10n.dart';

String nousTitle(String lang) => l10nFor(lang).nousTitle;
String nousSettingsTooltip(String lang) => l10nFor(lang).nousSettingsTooltip;

String nousTogetherSince(String lang) => l10nFor(lang).nousTogetherSince;
String nousDaysUnit(String lang, int n) => l10nFor(lang).nousDaysUnit(n);
String nousSinceDate(String lang, DateTime day) => l10nFor(
  lang,
).nousSinceDate(DateFormat.yMMMMd(AppLanguages.dateLocale(lang)).format(day));

String nousEdit(String lang) => l10nFor(lang).nousEdit;
String nousPickStartHelp(String lang) => l10nFor(lang).nousPickStartHelp;
String nousStartSaved(String lang) => l10nFor(lang).nousStartSaved;

String nousSendNote(String lang) => l10nFor(lang).nousSendNote;

/// The words of a note: a preset's, or the [text] of one's own.
String pingLabel(String lang, PingKind kind, {String? text}) =>
    kind == PingKind.custom ? text ?? '' : l10nFor(lang).pingLabel(kind.name);
String nousNoteSent(String lang, PingKind kind, {String? text}) =>
    l10nFor(lang).nousNoteSent(pingLabel(lang, kind, text: text));
String nousNoteCooldown(String lang) => l10nFor(lang).nousNoteCooldown;
String nousNoteFailed(String lang) => l10nFor(lang).nousNoteFailed;

/// What to say after sending [kind]: sent, wait a moment, or it failed.
String pingResultMessage(
  String lang,
  PingKind kind,
  Failure? failure, {
  String? text,
}) => switch (failure) {
  null => nousNoteSent(lang, kind, text: text),
  PingFailure(problem: PingProblem.cooldown) => nousNoteCooldown(lang),
  _ => nousNoteFailed(lang),
};

/// "Camille : Je pense à toi, il y a 12 min" /
/// "Camille: Thinking of you, 12 min ago".
String nousReceivedLine(
  String lang,
  String name,
  PingKind kind,
  DateTime sentAt,
  DateTime now, {
  String? text,
}) {
  final l = l10nFor(lang);
  final ago = now.difference(sentAt);
  final String when;
  if (ago.inMinutes < 1) {
    when = l.timeAgoJustNow;
  } else if (ago.inMinutes < 60) {
    when = l.timeAgoMinutes(ago.inMinutes);
  } else if (ago.inHours < 24) {
    when = l.timeAgoHours(ago.inHours);
  } else {
    when = l.timeAgoOnDay(
      DateFormat.MMMd(AppLanguages.dateLocale(lang)).format(sentAt.toLocal()),
    );
  }
  return l.nousReceivedLine(name, pingLabel(lang, kind, text: text), when);
}

/// The full-screen moment and the push body when a note arrives. A note of
/// one's own is its [text] alone: [pingSignature] says who wrote it.
String pingReceivedTitle(
  String lang,
  PingKind kind,
  String name, {
  String? text,
}) => kind == PingKind.custom
    ? text ?? ''
    : l10nFor(lang).pingReceivedTitle(kind.name, name);

/// Under a note of one's own, like a signature: "Camille · À l'instant".
String pingSignature(String lang, String name) =>
    '$name · ${pingJustNow(lang)}';
String pingWriteBack(String lang) => l10nFor(lang).pingWriteBack;

// Writing a note of one's own.
String nousWrite(String lang) => l10nFor(lang).nousWrite;
String nousMyWords(String lang) => l10nFor(lang).nousMyWords;
String nousWriteTo(String lang, String name) => l10nFor(lang).nousWriteTo(name);
String nousWriteHint(String lang) => l10nFor(lang).nousWriteHint;
String nousWriteReplaces(String lang) => l10nFor(lang).nousWriteReplaces;
String nousKeepWord(String lang) => l10nFor(lang).nousKeepWord;
String nousSend(String lang) => l10nFor(lang).nousSend;

// The notes shown on Nous, chosen in "Mes mots".
String myWordsTitle(String lang) => l10nFor(lang).myWordsTitle;
String myWordsHelp(String lang) => l10nFor(lang).myWordsHelp;
String myWordsAddHint(String lang) => l10nFor(lang).myWordsAddHint;
String myWordsAdd(String lang) => l10nFor(lang).myWordsAdd;
String myWordsRemove(String lang, String word) =>
    l10nFor(lang).myWordsRemove(word);
String myWordsMove(String lang, String word) => l10nFor(lang).myWordsMove(word);
String myWordsFull(String lang) => l10nFor(lang).myWordsFull;
String myWordsAlready(String lang) => l10nFor(lang).myWordsAlready;
String myWordsDrag(String lang) => l10nFor(lang).myWordsDrag;
String pingJustNow(String lang) => l10nFor(lang).pingJustNow;
String pingReplyMeToo(String lang) => l10nFor(lang).pingReplyMeToo;
String pingTapToClose(String lang) => l10nFor(lang).pingTapToClose;
String nousPartnerFallback(String lang) => l10nFor(lang).nousPartnerFallback;

String nousNextPlan(String lang) => l10nFor(lang).nousNextPlan;
String nousInDays(String lang, int n) => l10nFor(lang).nousInDays(n);
String nousNoCountdown(String lang) => l10nFor(lang).nousNoCountdown;
String nousNoCountdownHint(String lang) => l10nFor(lang).nousNoCountdownHint;
String nousAnniversary(String lang) => l10nFor(lang).nousAnniversary;
String nousYearsTogether(String lang, int years) =>
    l10nFor(lang).nousYearsTogether(years);

String nousNoPartnerTitle(String lang) => l10nFor(lang).nousNoPartnerTitle;
String nousNoPartnerBody(String lang) => l10nFor(lang).nousNoPartnerBody;
String nousInvite(String lang) => l10nFor(lang).nousInvite;
