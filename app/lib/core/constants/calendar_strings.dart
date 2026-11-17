import 'package:intl/intl.dart';

import 'package:nousdeux/core/l10n/app_languages.dart';

/// Calendar screen strings. Use lang 'fr' or 'en'.
String calendarTitle(String lang) =>
    lang == 'fr' ? 'Calendrier' : 'Calendar';
String calendarToday(String lang) =>
    lang == 'fr' ? "Aujourd'hui" : 'Today';
String calendarAdd(String lang) => lang == 'fr' ? 'Ajouter' : 'Add';
String calendarPartner(String lang) =>
    lang == 'fr' ? 'Partenaire' : 'Partner';
String calendarMe(String lang) => lang == 'fr' ? 'Moi' : 'Me';
String calendarDeleteEventTitle(String lang) =>
    lang == 'fr' ? 'Supprimer l\'événement ?' : 'Delete event?';
String calendarDeleteEventConfirm(String lang, String title) => lang == 'fr'
    ? '« $title » sera supprimé pour vous deux.'
    : '"$title" will be deleted for both of you.';
String calendarCancel(String lang) => lang == 'fr' ? 'Annuler' : 'Cancel';
String calendarDelete(String lang) => lang == 'fr' ? 'Supprimer' : 'Delete';
String calendarNothingInMonth(String lang, String month) =>
    lang == 'fr' ? 'Rien de prévu en $month' : 'Nothing planned in $month';
String calendarCreateEvent(String lang) =>
    lang == 'fr' ? 'Ajouter un événement' : 'Add an event';
String calendarPreviousMonth(String lang) =>
    lang == 'fr' ? 'Mois précédent' : 'Previous month';
String calendarNextMonth(String lang) =>
    lang == 'fr' ? 'Mois suivant' : 'Next month';

// Calendar access, asked on the follow screen
String calendarImportAllowAccess(String lang) =>
    lang == 'fr' ? 'Autoriser l\'accès au calendrier' : 'Allow calendar access';
String calendarImportOpenSettings(String lang) =>
    lang == 'fr' ? 'Ouvrir les réglages' : 'Open settings';
// Event form
String calendarEventEdit(String lang) =>
    lang == 'fr' ? 'Modifier l\'événement' : 'Edit event';
String calendarEventNew(String lang) =>
    lang == 'fr' ? 'Nouvel événement' : 'New event';
String calendarEventTitleLabel(String lang) =>
    lang == 'fr' ? 'Titre' : 'Title';
String calendarEventTitleRequired(String lang) =>
    lang == 'fr' ? 'Ajoutez un titre.' : 'Add a title.';
String calendarEventDescriptionLabel(String lang) =>
    lang == 'fr' ? 'Description (optionnel)' : 'Description (optional)';
String calendarEventStart(String lang) => lang == 'fr' ? 'Début' : 'Start';
String calendarEventEnd(String lang) => lang == 'fr' ? 'Fin' : 'End';
String calendarEventSave(String lang) =>
    lang == 'fr' ? 'Enregistrer' : 'Save';
String calendarEventCountdown(String lang) =>
    lang == 'fr' ? 'Compte à rebours' : 'Countdown';
String calendarEventCountdownHint(String lang) => lang == 'fr'
    ? "Affiché dans l'onglet Nous jusqu'au jour J."
    : 'Shown on the Nous tab until the day comes.';
String calendarEventEndBeforeStart(String lang) => lang == 'fr'
    ? 'La fin doit venir après le début.'
    : 'The end has to come after the start.';

// Phone calendar: following it (docs/CALENDAR_SYNC.md).
String calendarFollowLabel(String lang) =>
    lang == 'fr' ? 'Agenda du téléphone' : 'Phone calendar';
String calendarFollowTitle(String lang) =>
    lang == 'fr' ? 'Vos agendas suivis' : 'Calendars you follow';
String calendarFollowIntro(String lang, String partnerName) => lang == 'fr'
    ? 'Leurs titres et horaires sont copiés dans Nous Deux et restent à jour : $partnerName les voit. Rien d\'autre ne quitte votre téléphone.'
    : 'Their titles and times are copied into Nous Deux and kept up to date: $partnerName sees them. Nothing else leaves your phone.';
String calendarFollowTip(String lang) => lang == 'fr'
    ? 'Le plus simple : un agenda « Nous » sur votre téléphone, pour ce qui vous concerne tous les deux. Le reste de votre agenda reste à vous.'
    : 'Simplest: an “Us” calendar on your phone, for what concerns you both. The rest of your calendar stays yours.';
String calendarFollowLastSync(String lang) =>
    lang == 'fr' ? 'Dernière mise à jour' : 'Last updated';
String calendarFollowFootnote(String lang) => lang == 'fr'
    ? 'Du mois dernier aux six prochains mois. Les événements se modifient dans votre agenda ; ne plus suivre un agenda retire ses copies de cette période, tout arrêter les retire toutes.'
    : 'From last month to six months ahead. Events are changed in your calendar; unfollowing a calendar removes its copies from that period, turning them all off removes every copy.';
String calendarFollowOtherPhone(String lang) => lang == 'fr'
    ? 'Vos agendas sont suivis depuis un autre téléphone. En suivre un ici prend le relais.'
    : 'Your calendars are followed from another phone. Following one here takes over.';
String calendarFollowGone(String lang) => lang == 'fr'
    ? 'Un agenda suivi n\'est plus sur ce téléphone, rien n\'est mis à jour.'
    : 'A followed calendar is no longer on this phone, so nothing is updated.';
String calendarFollowDropGone(String lang) =>
    lang == 'fr' ? 'Ne plus le suivre' : 'Stop following it';
String calendarFollowFailed(String lang) => lang == 'fr'
    ? 'La mise à jour n\'a pas abouti. Réessayez plus tard.'
    : 'The update didn\'t go through. Try again later.';
String calendarFollowNone(String lang) => lang == 'fr'
    ? 'Aucun agenda sur ce téléphone.'
    : 'No calendar on this phone.';
String calendarFollowPermission(String lang) => lang == 'fr'
    ? 'Nous Deux a besoin d\'accéder à vos agendas pour les suivre. Si la demande ne s\'affiche pas, autorisez l\'accès dans les réglages.'
    : 'Nous Deux needs access to your calendars to follow them. If no prompt appears, allow access in Settings.';

/// "Il y a 5 min", "5 min ago": how long ago [at] was, at [now].
String calendarAgo(String lang, DateTime at, DateTime now) {
  final ago = now.difference(at);
  if (ago.inMinutes < 1) return lang == 'fr' ? 'à l\'instant' : 'just now';
  if (ago.inHours < 1) {
    return lang == 'fr'
        ? 'il y a ${ago.inMinutes} min'
        : '${ago.inMinutes} min ago';
  }
  if (ago.inHours < 24) {
    return lang == 'fr' ? 'il y a ${ago.inHours} h' : '${ago.inHours} h ago';
  }
  final day = DateFormat.MMMd(AppLanguages.dateLocale(lang)).format(at);
  return lang == 'fr' ? 'le $day' : 'on $day';
}

/// The partner's calendar freshness in the header ("Alex · il y a 5 min").
String calendarPartnerFresh(String lang, String name, String ago) =>
    '$name · $ago';

/// Where a synced event comes from. French elides "de" before a vowel.
String calendarSyncedFrom(String lang, String name, {required bool mine}) {
  if (lang != 'fr') {
    return mine ? 'From your calendar' : 'From $name\'s calendar';
  }
  if (mine) return 'Depuis votre agenda';
  final elided = RegExp(
    r'^[aeiouyhàâäéèêëîïôöùûüAEIOUYHÀÂÄÉÈÊËÎÏÔÖÙÛÜ]',
  ).hasMatch(name);
  return elided ? 'Depuis l\'agenda d\'$name' : 'Depuis l\'agenda de $name';
}

String calendarSyncedReadOnly(String lang, String name, {required bool mine}) {
  if (lang == 'fr') {
    return mine
        ? 'Cet événement suit l\'agenda de votre téléphone : modifiez-le ou supprimez-le là-bas.'
        : 'Cet événement suit l\'agenda du téléphone de $name : il se modifie ou se supprime là-bas.';
  }
  return mine
      ? 'This event follows your phone\'s calendar: change or delete it there.'
      : 'This event follows $name\'s phone calendar: it is changed or deleted there.';
}

String calendarAllDay(String lang) =>
    lang == 'fr' ? 'Toute la journée' : 'All day';
