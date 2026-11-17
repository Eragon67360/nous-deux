// Nous tab strings (days together, countdowns, little notes).
// Keep the received-note wording in sync with
// supabase/functions/notify-partner-ping/index.ts.

import 'package:intl/intl.dart';

import 'package:nousdeux/core/errors/failures.dart';
import 'package:nousdeux/domain/entities/ping_entity.dart';

String nousTitle(String lang) => lang == 'fr' ? 'Nous' : 'Us';
String nousSettingsTooltip(String lang) =>
    lang == 'fr' ? 'Réglages' : 'Settings';

String nousTogetherSince(String lang) =>
    lang == 'fr' ? 'Ensemble depuis' : 'Together for';
String nousDaysUnit(String lang, int n) =>
    lang == 'fr' ? (n > 1 ? 'jours' : 'jour') : (n == 1 ? 'day' : 'days');
String nousSinceDate(String lang, DateTime day) => lang == 'fr'
    ? 'Depuis le ${DateFormat('d MMMM y', 'fr_FR').format(day)}'
    : 'Since ${DateFormat('MMMM d, y', 'en_US').format(day)}';
String nousEdit(String lang) => lang == 'fr' ? 'Modifier' : 'Edit';
String nousPickStartHelp(String lang) =>
    lang == 'fr' ? 'Le jour où tout a commencé' : 'The day it all started';
String nousStartSaved(String lang) =>
    lang == 'fr' ? 'Date mise à jour.' : 'Date updated.';

String nousSendNote(String lang) =>
    lang == 'fr' ? 'Envoyer un petit mot' : 'Send a little note';

/// The words of a note: a preset's, or the [text] of one's own.
String pingLabel(String lang, PingKind kind, {String? text}) => switch (kind) {
  PingKind.thinkingOfYou => lang == 'fr' ? 'Je pense à toi' : 'Thinking of you',
  PingKind.goodNight => lang == 'fr' ? 'Bonne nuit' : 'Good night',
  PingKind.onMyWay => lang == 'fr' ? "J'arrive" : 'On my way',
  PingKind.missYou => lang == 'fr' ? 'Tu me manques' : 'Miss you',
  PingKind.kiss => lang == 'fr' ? 'Bisou' : 'Kiss',
  PingKind.custom => text ?? '',
};
String nousNoteSent(String lang, PingKind kind, {String? text}) => lang == 'fr'
    ? 'Envoyé : ${pingLabel(lang, kind, text: text)}'
    : 'Sent: ${pingLabel(lang, kind, text: text)}';
String nousNoteCooldown(String lang) => lang == 'fr'
    ? 'Un petit mot toutes les 30 secondes au plus. Réessayez dans un instant.'
    : 'One little note every 30 seconds at most. Try again in a moment.';
String nousNoteFailed(String lang) => lang == 'fr'
    ? "Le petit mot n'est pas parti. Réessayez."
    : "The note didn't go through. Try again.";

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
  final ago = now.difference(sentAt);
  final String when;
  if (ago.inMinutes < 1) {
    when = lang == 'fr' ? "à l'instant" : 'just now';
  } else if (ago.inMinutes < 60) {
    when = lang == 'fr'
        ? 'il y a ${ago.inMinutes} min'
        : '${ago.inMinutes} min ago';
  } else if (ago.inHours < 24) {
    when = lang == 'fr' ? 'il y a ${ago.inHours} h' : '${ago.inHours} h ago';
  } else {
    when = lang == 'fr'
        ? 'le ${DateFormat('d MMM', 'fr_FR').format(sentAt.toLocal())}'
        : 'on ${DateFormat('MMM d', 'en_US').format(sentAt.toLocal())}';
  }
  // French puts a (non-breaking) space before the colon.
  final note = pingLabel(lang, kind, text: text);
  return lang == 'fr' ? '$name : $note, $when' : '$name: $note, $when';
}

/// The full-screen moment and the push body when a note arrives. A note of
/// one's own is its [text] alone: [pingSignature] says who wrote it.
String pingReceivedTitle(
  String lang,
  PingKind kind,
  String name, {
  String? text,
}) => switch (kind) {
  PingKind.thinkingOfYou =>
    lang == 'fr' ? '$name pense à toi.' : '$name is thinking of you.',
  PingKind.goodNight =>
    lang == 'fr' ? '$name te souhaite bonne nuit.' : '$name says good night.',
  PingKind.onMyWay => lang == 'fr' ? '$name arrive.' : '$name is on the way.',
  PingKind.missYou =>
    lang == 'fr' ? '$name : tu me manques.' : '$name misses you.',
  PingKind.kiss =>
    lang == 'fr' ? "$name t'envoie un bisou." : '$name sends you a kiss.',
  PingKind.custom => text ?? '',
};

/// Under a note of one's own, like a signature: "Camille · À l'instant".
String pingSignature(String lang, String name) =>
    '$name · ${pingJustNow(lang)}';
String pingWriteBack(String lang) =>
    lang == 'fr' ? 'Répondre par un mot' : 'Reply with a note';

// Writing a note of one's own.
String nousWrite(String lang) => lang == 'fr' ? 'Écrire…' : 'Write…';
String nousMyWords(String lang) => lang == 'fr' ? 'Mes mots' : 'My notes';
String nousWriteTo(String lang, String name) =>
    lang == 'fr' ? 'Un petit mot pour $name' : 'A little note for $name';
String nousWriteHint(String lang) =>
    lang == 'fr' ? 'Votre petit mot' : 'Your little note';
String nousWriteReplaces(String lang) => lang == 'fr'
    ? 'Il remplace votre dernier mot, comme les autres.'
    : 'It replaces your last note, like the others.';
String nousKeepWord(String lang) =>
    lang == 'fr' ? 'Le garder dans mes mots' : 'Keep it in my notes';
String nousSend(String lang) => lang == 'fr' ? 'Envoyer' : 'Send';

// The notes shown on Nous, chosen in "Mes mots".
String myWordsTitle(String lang) =>
    lang == 'fr' ? 'Mes petits mots' : 'My little notes';
String myWordsHelp(String lang) => lang == 'fr'
    ? "Ceux qui sont cochés s'affichent sur Nous, dans cet ordre. "
          'Six au plus.'
    : 'The ticked ones show on Nous, in this order. Six at most.';
String myWordsAddHint(String lang) =>
    lang == 'fr' ? 'Ajouter un mot…' : 'Add a note…';
String myWordsAdd(String lang) => lang == 'fr' ? 'Ajouter' : 'Add';
String myWordsRemove(String lang, String word) =>
    lang == 'fr' ? 'Retirer « $word »' : 'Remove "$word"';
String myWordsMove(String lang, String word) =>
    lang == 'fr' ? 'Déplacer « $word »' : 'Move "$word"';
String myWordsFull(String lang) => lang == 'fr'
    ? "Six mots au plus sur Nous. Décochez-en un d'abord."
    : 'Six notes at most on Nous. Untick one first.';
String myWordsAlready(String lang) => lang == 'fr'
    ? 'Ce mot est déjà dans la liste.'
    : 'That note is already there.';
String myWordsDrag(String lang) => lang == 'fr'
    ? "Glissez la poignée à droite pour changer l'ordre."
    : 'Drag the handle on the right to change the order.';
String pingJustNow(String lang) => lang == 'fr' ? "À l'instant" : 'Just now';
String pingReplyMeToo(String lang) => lang == 'fr' ? 'Moi aussi' : 'Me too';
String pingTapToClose(String lang) =>
    lang == 'fr' ? 'Toucher pour fermer' : 'Tap to close';
String nousPartnerFallback(String lang) =>
    lang == 'fr' ? 'Votre partenaire' : 'Your partner';

String nousNextPlan(String lang) =>
    lang == 'fr' ? 'Prochain rendez-vous' : 'Next plan';
String nousInDays(String lang, int n) => switch (n) {
  0 => lang == 'fr' ? "aujourd'hui" : 'today',
  1 => lang == 'fr' ? 'demain' : 'tomorrow',
  _ => lang == 'fr' ? 'dans $n j' : 'in $n d',
};
String nousNoCountdown(String lang) =>
    lang == 'fr' ? 'Rien de prévu' : 'Nothing planned';
String nousNoCountdownHint(String lang) => lang == 'fr'
    ? 'Activez « Compte à rebours » sur un événement.'
    : 'Turn on Countdown for an event.';
String nousAnniversary(String lang) =>
    lang == 'fr' ? 'Anniversaire' : 'Anniversary';
String nousYearsTogether(String lang, int years) => lang == 'fr'
    ? '$years ${years > 1 ? 'ans' : 'an'} ensemble'
    : '$years ${years == 1 ? 'year' : 'years'} together';

String nousNoPartnerTitle(String lang) =>
    lang == 'fr' ? 'Invitez votre partenaire' : 'Invite your partner';
String nousNoPartnerBody(String lang) => lang == 'fr'
    ? 'Le compteur démarre le jour où vous êtes deux.'
    : 'The counter starts on the day there are two of you.';
String nousInvite(String lang) => lang == 'fr' ? 'Inviter' : 'Invite';
