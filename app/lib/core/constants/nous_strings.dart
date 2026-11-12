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
String pingLabel(String lang, PingKind kind) => switch (kind) {
  PingKind.thinkingOfYou => lang == 'fr' ? 'Je pense à toi' : 'Thinking of you',
  PingKind.goodNight => lang == 'fr' ? 'Bonne nuit' : 'Good night',
  PingKind.onMyWay => lang == 'fr' ? "J'arrive" : 'On my way',
  PingKind.missYou => lang == 'fr' ? 'Tu me manques' : 'Miss you',
  PingKind.kiss => lang == 'fr' ? 'Bisou' : 'Kiss',
};
String nousNoteSent(String lang, PingKind kind) => lang == 'fr'
    ? 'Envoyé : ${pingLabel(lang, kind)}'
    : 'Sent: ${pingLabel(lang, kind)}';
String nousNoteCooldown(String lang) => lang == 'fr'
    ? 'Un petit mot toutes les 30 secondes au plus. Réessayez dans un instant.'
    : 'One little note every 30 seconds at most. Try again in a moment.';
String nousNoteFailed(String lang) => lang == 'fr'
    ? "Le petit mot n'est pas parti. Réessayez."
    : "The note didn't go through. Try again.";

/// What to say after sending [kind]: sent, wait a moment, or it failed.
String pingResultMessage(String lang, PingKind kind, Failure? failure) =>
    switch (failure) {
      null => nousNoteSent(lang, kind),
      PingFailure(problem: PingProblem.cooldown) => nousNoteCooldown(lang),
      _ => nousNoteFailed(lang),
    };

/// "Camille, il y a 12 min" / "Camille, 12 min ago".
String nousReceivedLine(
  String lang,
  String name,
  DateTime sentAt,
  DateTime now,
) {
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
  return '$name, $when';
}

/// The full-screen moment and the push body when a note arrives.
String pingReceivedTitle(
  String lang,
  PingKind kind,
  String name,
) => switch (kind) {
  PingKind.thinkingOfYou =>
    lang == 'fr' ? '$name pense à toi.' : '$name is thinking of you.',
  PingKind.goodNight =>
    lang == 'fr' ? '$name te souhaite bonne nuit.' : '$name says good night.',
  PingKind.onMyWay => lang == 'fr' ? '$name arrive.' : '$name is on the way.',
  PingKind.missYou =>
    lang == 'fr' ? '$name : tu me manques.' : '$name misses you.',
  PingKind.kiss =>
    lang == 'fr' ? "$name t'envoie un bisou." : '$name sends you a kiss.',
};
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
