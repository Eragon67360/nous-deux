import 'package:intl/intl.dart';

import 'package:nousdeux/core/constants/period_education.dart' show CyclePhase;

/// Strings for the Règles tab (cycle page, partner page, sharing, guide).
/// Use lang 'fr' or 'en'. Names are the partner's display name.

String _date(String lang, DateTime d) => DateFormat(
  lang == 'fr' ? 'EEE d MMM' : 'EEE, MMM d',
  lang == 'fr' ? 'fr_FR' : 'en_US',
).format(d);

/// The partner's name, or a stand-in while they have none.
String cyclePartnerName(String lang, String? username) {
  final name = username?.trim();
  if (name != null && name.isNotEmpty) return name;
  return lang == 'fr' ? 'Votre partenaire' : 'Your partner';
}

// --- Who tracks ---
String cycleAskTitle(String lang) => lang == 'fr'
    ? 'Suivez-vous votre cycle dans l\'app ?'
    : 'Do you track your cycle in the app?';
String cycleAskBody(String lang) => lang == 'fr'
    ? 'Si oui, cet onglet devient votre suivi. Sinon, il vous montre le cycle de votre partenaire quand il est partagé.'
    : 'If you do, this tab becomes your tracker. If not, it shows your partner\'s cycle when they share it.';

// --- Consent (cycle data is health data) ---
String cycleConsent(String lang) => lang == 'fr'
    ? 'En suivant votre cycle, vous acceptez que l\'app enregistre vos dates de règles, votre ressenti du jour et vos notes sur nos serveurs en Allemagne. Ce sont des données de santé. Votre partenaire voit vos dates et votre ressenti tant que vous les partagez ; vos notes restent privées. Vous pouvez arrêter et tout supprimer à tout moment dans les paramètres.'
    : 'By tracking your cycle, you agree that the app stores your period dates, how you feel each day and your notes on our servers in Germany. This is health data. Your partner sees your dates and how you feel while you share them; your notes stay private. You can stop and delete everything at any time in Settings.';
String cycleConsentTitle(String lang) => lang == 'fr'
    ? 'Suivre votre cycle dans l\'app ?'
    : 'Track your cycle in the app?';
String cycleConsentAccept(String lang) =>
    lang == 'fr' ? 'J\'accepte' : 'I agree';
String cyclePrivacyPolicy(String lang) =>
    lang == 'fr' ? 'Politique de confidentialité' : 'Privacy policy';
String cyclePrivacyUrl(String lang) =>
    'https://nous-deux.app/${lang == 'fr' ? 'fr' : 'en'}/politique-de-confidentialite';
String cycleStopTitle(String lang) => lang == 'fr'
    ? 'Arrêter le suivi de votre cycle ?'
    : 'Stop tracking your cycle?';
String cycleStopBody(String lang) => lang == 'fr'
    ? 'Vous pouvez garder vos données de cycle au cas où vous reprendriez, ou les supprimer maintenant : dates, ressenti et notes. La suppression est définitive.'
    : 'You can keep your cycle data in case you start again, or delete it now: dates, check-ins and notes. Deleting can\'t be undone.';
String cycleStopKeep(String lang) =>
    lang == 'fr' ? 'Garder mes données' : 'Keep my data';
String cycleStopDelete(String lang) =>
    lang == 'fr' ? 'Tout supprimer' : 'Delete everything';
String cycleDataDeleted(String lang) => lang == 'fr'
    ? 'Vos données de cycle sont supprimées.'
    : 'Your cycle data is deleted.';
String cycleAskYes(String lang) =>
    lang == 'fr' ? 'Oui, je le suis' : 'Yes, I do';
String cycleAskNo(String lang) => lang == 'fr' ? 'Non' : 'No';
String settingsTracksCycle(String lang) => lang == 'fr'
    ? 'Je suis mon cycle dans l\'app'
    : 'I track my cycle in the app';

// --- Phases ---
String cyclePhaseLabel(String lang, CyclePhase phase) => switch (phase) {
  CyclePhase.menstrual => lang == 'fr' ? 'Règles' : 'Period',
  CyclePhase.follicular =>
    lang == 'fr' ? 'Phase folliculaire' : 'Follicular phase',
  CyclePhase.ovulation => lang == 'fr' ? 'Ovulation' : 'Ovulation',
  CyclePhase.luteal => lang == 'fr' ? 'Phase lutéale' : 'Luteal phase',
};

// --- My cycle (R1) ---
String cycleDayWord(String lang) => lang == 'fr' ? 'jour' : 'day';
String cycleOfAbout(String lang, int length) =>
    lang == 'fr' ? 'sur ~$length' : 'of ~$length';
String cycleRingLabel(String lang, int day, int length) => lang == 'fr'
    ? 'Cycle d\'environ $length jours, aujourd\'hui jour $day'
    : 'Cycle of about $length days, today day $day';

/// The big line under the ring.
String cycleHeadline(
  String lang, {
  required bool ongoing,
  required int dayOfCycle,
  required int? daysUntil,
}) {
  if (ongoing) {
    return lang == 'fr'
        ? 'Règles en cours, jour $dayOfCycle'
        : 'Period, day $dayOfCycle';
  }
  final d = daysUntil;
  if (d == null) return '';
  if (d > 1) {
    return lang == 'fr' ? 'Règles dans ~$d jours' : 'Period in ~$d days';
  }
  if (d == 1) {
    return lang == 'fr' ? 'Règles prévues demain' : 'Period expected tomorrow';
  }
  if (d == 0) {
    return lang == 'fr'
        ? 'Règles prévues aujourd\'hui'
        : 'Period expected today';
  }
  final late = -d;
  return lang == 'fr'
      ? 'Règles attendues depuis $late ${late > 1 ? 'jours' : 'jour'}'
      : 'Period expected $late ${late > 1 ? 'days' : 'day'} ago';
}

/// Where the expected date comes from.
String cycleBasis(String lang, DateTime next, int cyclesUsed) {
  final date = _date(lang, next);
  if (cyclesUsed == 0) {
    return lang == 'fr'
        ? 'vers le $date, sur 28 jours en attendant d\'en savoir plus'
        : 'around $date, assuming 28 days until there is more to go on';
  }
  if (cyclesUsed == 1) {
    return lang == 'fr'
        ? 'vers le $date, d\'après votre dernier cycle'
        : 'around $date, based on your last cycle';
  }
  return lang == 'fr'
      ? 'vers le $date, d\'après vos $cyclesUsed derniers cycles'
      : 'around $date, based on your last $cyclesUsed cycles';
}

String cycleNoDataTitle(String lang) =>
    lang == 'fr' ? 'Notez vos prochaines règles' : 'Log your next period';
String cycleNoDataBody(String lang) => lang == 'fr'
    ? 'L\'app apprend votre rythme cycle après cycle.'
    : 'The app learns your rhythm cycle after cycle.';
String cycleStarted(String lang) =>
    lang == 'fr' ? 'Mes règles ont commencé' : 'My period started';
String cycleEnded(String lang) =>
    lang == 'fr' ? 'Elles sont finies' : 'My period ended';
String cycleOtherDay(String lang) =>
    lang == 'fr' ? 'C\'était un autre jour' : 'It was another day';
String cycleToday(String lang) => lang == 'fr' ? 'Aujourd\'hui' : 'Today';
String cycleSeenBy(String lang, String name) =>
    lang == 'fr' ? '$name le voit' : '$name can see this';
String cycleSeenByNobody(String lang) =>
    lang == 'fr' ? 'Rien n\'est partagé' : 'Not shared';
String cycleNoteLabel(String lang) =>
    lang == 'fr' ? 'Note pour vous' : 'A note for you';
String cycleNoteHint(String lang) => lang == 'fr'
    ? 'Seulement pour vous, jamais partagée'
    : 'Only for you, never shared';
String cycleNoteSaved(String lang) =>
    lang == 'fr' ? 'Note enregistrée.' : 'Note saved.';
String cycleThisWeek(String lang) =>
    lang == 'fr' ? 'À savoir cette semaine' : 'Good to know this week';
String cycleReadChapter(String lang, String title) =>
    lang == 'fr' ? 'Lire : $title' : 'Read: $title';
String cycleHistoryLink(String lang) =>
    lang == 'fr' ? 'Vos cycles' : 'Your cycles';
String cycleSharingLink(String lang, String name) =>
    lang == 'fr' ? 'Ce que $name voit' : 'What $name sees';
String cyclePartnerLink(String lang, String name) =>
    lang == 'fr' ? 'Le cycle de $name' : '$name\'s cycle';
String cycleLoggedStart(String lang, DateTime day) => lang == 'fr'
    ? 'Début noté : ${_date(lang, day)}'
    : 'Start logged: ${_date(lang, day)}';
String cycleLoggedEnd(String lang, DateTime day) => lang == 'fr'
    ? 'Fin notée : ${_date(lang, day)}'
    : 'End logged: ${_date(lang, day)}';
String cycleUndo(String lang) => lang == 'fr' ? 'Annuler' : 'Undo';
String cycleShortDate(String lang, DateTime day) => DateFormat(
  lang == 'fr' ? 'd MMM' : 'MMM d',
  lang == 'fr' ? 'fr_FR' : 'en_US',
).format(day);
String cycleSaveFailed(String lang) => lang == 'fr'
    ? 'Ça n\'a pas été enregistré. Réessayez.'
    : 'That wasn\'t saved. Try again.';
String cycleNeedsCouple(String lang) => lang == 'fr'
    ? 'Le suivi s\'enregistre dans votre couple : invitez d\'abord votre partenaire.'
    : 'Tracking is saved in your couple: invite your partner first.';

/// What the person who tracks may like to know, per phase.
String cycleSelfTip(String lang, CyclePhase phase) => switch (phase) {
  CyclePhase.menstrual =>
    lang == 'fr'
        ? 'Chaleur, repos et eau aident souvent pendant les règles. Des douleurs qui vous empêchent de vivre normalement méritent un avis médical.'
        : 'Heat, rest and water often help during your period. Pain that stops you from living normally is worth a doctor\'s opinion.',
  CyclePhase.follicular =>
    lang == 'fr'
        ? 'L\'énergie remonte souvent après les règles : un bon moment pour ce qui demande de l\'élan.'
        : 'Energy often rises after your period: a good time for things that need drive.',
  CyclePhase.ovulation =>
    lang == 'fr'
        ? 'Autour de l\'ovulation, beaucoup se sentent en forme. Une petite gêne d\'un côté du ventre peut aussi arriver.'
        : 'Around ovulation many feel at their best. Slight discomfort on one side of the belly can happen too.',
  CyclePhase.luteal =>
    lang == 'fr'
        ? 'En fin de cycle, sommeil plus léger et énergie plus basse sont fréquents. Rien d\'anormal.'
        : 'Late in the cycle, lighter sleep and lower energy are common. Nothing unusual.',
};

// --- Log sheet ---
String cycleSheetStarted(String lang) =>
    lang == 'fr' ? 'Règles commencées' : 'Period started';
String cycleSheetEnded(String lang) =>
    lang == 'fr' ? 'Règles terminées' : 'Period ended';
String cycleSheetWhen(String lang) => lang == 'fr' ? 'Quand ?' : 'When?';
String cycleYesterday(String lang) => lang == 'fr' ? 'Hier' : 'Yesterday';
String cycleAnotherDay(String lang) =>
    lang == 'fr' ? 'Autre jour…' : 'Another day…';
String cycleSave(String lang) => lang == 'fr' ? 'Enregistrer' : 'Save';
String cycleSheetFootnote(String lang) => lang == 'fr'
    ? 'Le jour où elles s\'arrêtent, le bouton devient « Elles sont finies ».'
    : 'When it stops, the button becomes "My period ended".';

// --- History ---
String cycleHistoryTitle(String lang) =>
    lang == 'fr' ? 'Vos cycles' : 'Your cycles';
String cycleAverage(String lang) =>
    lang == 'fr' ? 'Cycle moyen' : 'Average cycle';
String cyclePeriod(String lang) => lang == 'fr' ? 'Règles' : 'Period';
String cycleDaysWord(String lang) => lang == 'fr' ? 'jours' : 'days';
String cycleRegularity(String lang, int count, int shortest, int longest) =>
    shortest == longest
    ? (lang == 'fr'
          ? 'Vos $count derniers cycles ont tous duré $shortest jours.'
          : 'Your last $count cycles all lasted $shortest days.')
    : (lang == 'fr'
          ? 'Vos $count derniers cycles ont duré entre $shortest et $longest jours.'
          : 'Your last $count cycles lasted $shortest to $longest days.');
String cycleNeedTwo(String lang) => lang == 'fr'
    ? 'Il faut deux cycles complets pour une moyenne ; d\'ici là, l\'app compte 28 jours.'
    : 'Two full cycles are needed for an average; until then the app counts 28 days.';
String cycleCurrentRow(String lang, int day) =>
    lang == 'fr' ? 'en cours · jour $day' : 'now · day $day';
String cycleSpanRow(String lang, int length, int? periodDays) {
  final period = periodDays == null
      ? ''
      : (lang == 'fr' ? ' · règles $periodDays j' : ' · period $periodDays d');
  return lang == 'fr' ? '$length j$period' : '$length d$period';
}

String cycleRestOfCycle(String lang) =>
    lang == 'fr' ? 'Reste du cycle' : 'Rest of the cycle';
String cycleHistoryHint(String lang) => lang == 'fr'
    ? 'Touchez un cycle pour le corriger, restez appuyé pour l\'effacer.'
    : 'Tap a cycle to fix it, long-press to delete it.';
String cycleHistoryEmpty(String lang) => lang == 'fr'
    ? 'Vos cycles apparaîtront ici au fil des mois.'
    : 'Your cycles will appear here month after month.';

// --- Partner's cycle (R3) ---
String cyclePartnerLabel(String lang, String name) =>
    lang == 'fr' ? 'Règles · $name' : 'Period · $name';
String cyclePartnerHeadline(
  String lang,
  String name, {
  required bool ongoing,
  required int day,
}) => ongoing
    ? (lang == 'fr'
          ? '$name a ses règles, jour $day'
          : '$name has their period, day $day')
    : (lang == 'fr' ? '$name est au jour $day' : '$name is on day $day');
String cyclePartnerNext(String lang, DateTime next, int? daysUntil) {
  final date = _date(lang, next);
  if (daysUntil != null && daysUntil < 0) {
    return lang == 'fr'
        ? 'Les règles étaient attendues vers le $date.'
        : 'The period was expected around $date.';
  }
  return lang == 'fr'
      ? 'Prochaines règles vers le $date.'
      : 'Next period around $date.';
}

String cyclePartnerNotShared(String lang, String name) => lang == 'fr'
    ? '$name ne partage pas son cycle pour l\'instant.'
    : '$name isn\'t sharing their cycle right now.';
String cyclePartnerNothingYet(String lang, String name) => lang == 'fr'
    ? '$name n\'a encore rien noté.'
    : '$name hasn\'t logged anything yet.';
String cyclePartnerNotTracking(String lang, String name) => lang == 'fr'
    ? '$name ne suit pas de cycle dans l\'app.'
    : '$name doesn\'t track a cycle in the app.';
String cycleNoPartner(String lang) => lang == 'fr'
    ? 'Ici, vous suivrez le cycle de votre partenaire, s\'il le partage, avec des idées pour être là au bon moment.'
    : 'Here you\'ll follow your partner\'s cycle, if they share it, with ideas for being there at the right time.';
String cycleWhatHelps(String lang) => lang == 'fr'
    ? 'Ce qui peut aider cette semaine'
    : 'What tends to help this week';
String cyclePartnerNoted(String lang, String name) =>
    lang == 'fr' ? '$name a noté aujourd\'hui' : '$name noted today';
String cycleLittleNote(String lang) =>
    lang == 'fr' ? 'Un petit mot ?' : 'A little note?';
String cycleRemindMe(String lang) =>
    lang == 'fr' ? 'Me prévenir la veille' : 'Remind me the day before';
String cycleRemindOn(String lang, DateTime day) => lang == 'fr'
    ? 'le ${_date(lang, day)} au soir'
    : 'on the evening of ${_date(lang, day)}';
String cycleRemindNoDate(String lang) => lang == 'fr'
    ? 'Dès qu\'une date est prévue'
    : 'As soon as a date is expected';

/// Three things that tend to help, per phase, for the partner.
List<String> cyclePartnerTips(String lang, CyclePhase phase) => switch (phase) {
  CyclePhase.menstrual =>
    lang == 'fr'
        ? [
            'Proposer la bouillotte ou une tisane, sans attendre qu\'on la demande.',
            'Alléger la journée : prendre les courses ou le dîner.',
            'Demander « De quoi tu as besoin ? » plutôt que deviner.',
          ]
        : [
            'Offer a heat pack or a hot drink without waiting to be asked.',
            'Lighten the day: take on the shopping or dinner.',
            'Ask "What do you need?" rather than guess.',
          ],
  CyclePhase.follicular =>
    lang == 'fr'
        ? [
            'L\'énergie revient souvent : bon moment pour une sortie à deux.',
            'Proposer un projet que vous repoussez depuis un moment.',
            'Suivre son rythme, sans le pousser.',
          ]
        : [
            'Energy often comes back: a good time for a plan together.',
            'Suggest something you\'ve been putting off.',
            'Follow their pace without pushing it.',
          ],
  CyclePhase.ovulation =>
    lang == 'fr'
        ? [
            'Beaucoup se sentent en forme ces jours-là : profitez-en ensemble.',
            'Une petite gêne au bas du ventre peut arriver ; demandez simplement comment ça va.',
            'Rester à l\'écoute : chaque cycle est différent.',
          ]
        : [
            'Many feel at their best these days: enjoy it together.',
            'A little lower-belly discomfort can happen; just ask how they feel.',
            'Keep listening: every cycle is different.',
          ],
  CyclePhase.luteal =>
    lang == 'fr'
        ? [
            'Garder les soirées calmes si la fatigue se fait sentir.',
            'Proposer plutôt que demander : « Je m\'occupe du dîner ? »',
            'Ne pas tout mettre sur le compte des hormones : écouter ce qui est dit.',
          ]
        : [
            'Keep evenings calm if tiredness shows.',
            'Offer rather than ask: "Shall I make dinner?"',
            'Don\'t put everything down to hormones: listen to what is said.',
          ],
};

// --- Sharing (R3) ---
String cycleSharingTitle(String lang, String name) =>
    lang == 'fr' ? 'Ce que $name voit' : 'What $name sees';
String cycleSharingIntro(String lang) => lang == 'fr'
    ? 'Vous choisissez ce que votre partenaire voit. Ça change tout de suite sur son téléphone.'
    : 'You choose what your partner sees. It changes on their phone right away.';
String cycleShareCycle(String lang) => lang == 'fr' ? 'Mon cycle' : 'My cycle';
String cycleShareCycleHint(String lang) => lang == 'fr'
    ? 'Jour, phase, date prévue et rappel la veille'
    : 'Day, phase, expected date and the reminder';
String cycleShareCheckins(String lang) =>
    lang == 'fr' ? 'Mon ressenti du jour' : 'How I feel each day';
String cycleShareCheckinsHint(String lang) =>
    lang == 'fr' ? 'Ce que vous cochez chaque jour' : 'What you check each day';
String cycleNotesRow(String lang) => lang == 'fr' ? 'Vos notes' : 'Your notes';
String cycleNotesAlwaysPrivate(String lang) =>
    lang == 'fr' ? 'Toujours privées' : 'Always private';
String cycleStopSharing(String lang) =>
    lang == 'fr' ? 'Ne plus rien partager' : 'Stop sharing everything';

// --- Guide (R4) ---
String guideLabel(String lang) => lang == 'fr' ? 'Guide' : 'Guide';
String guideTitle(String lang) =>
    lang == 'fr' ? 'Comprendre le cycle' : 'Understanding the cycle';
String guideForYouNow(String lang, int day) => lang == 'fr'
    ? 'Pour vous maintenant · jour $day'
    : 'For you now · day $day';
String guideForPartnerNow(String lang, String name, int day) => lang == 'fr'
    ? 'Pour $name maintenant · jour $day'
    : 'For $name now · day $day';
String guideNowTitle(String lang, CyclePhase phase) => lang == 'fr'
    ? '${cyclePhaseLabel(lang, phase)} : ce qui se passe, ce qui aide'
    : '${cyclePhaseLabel(lang, phase)}: what happens, what helps';
String guideChapter(String lang, int n) =>
    lang == 'fr' ? 'Chapitre $n' : 'Chapter $n';
String guideRead(String lang) => lang == 'fr' ? 'lu' : 'read';
String guideFootnote(String lang) => lang == 'fr'
    ? 'Écrit à partir de sources de santé publique. Ne remplace pas un avis médical.'
    : 'Based on public health sources. Not medical advice.';
String guideContents(String lang) => lang == 'fr' ? 'Sommaire' : 'Contents';
String guideNext(String lang, String title) =>
    lang == 'fr' ? 'Suivant : $title' : 'Next: $title';
String guideSearch(String lang) =>
    lang == 'fr' ? 'Chercher dans le guide' : 'Search the guide';
String guideNoMatch(String lang, String query) => lang == 'fr'
    ? 'Aucun chapitre ne parle de « $query ».'
    : 'No chapter mentions "$query".';
String guideBody(String lang) => lang == 'fr' ? 'Dans le corps' : 'In the body';
String guideMood(String lang) => lang == 'fr' ? 'Côté humeur' : 'Mood';
String guideWhatHelps(String lang) =>
    lang == 'fr' ? 'Ce qui aide' : 'What helps';
String guideYouAreHere(String lang) =>
    lang == 'fr' ? 'vous êtes ici' : 'you are here';
String guidePartnerIsHere(String lang, String name) =>
    lang == 'fr' ? '$name est ici' : '$name is here';
String guideSources(String lang) => lang == 'fr' ? 'Sources' : 'Sources';
String guideDaysShort(String lang, String range) =>
    lang == 'fr' ? 'j$range' : 'days $range';
