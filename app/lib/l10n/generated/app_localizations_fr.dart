// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get splashTagline => 'Là où les histoires se rejoignent';

  @override
  String get mainNoPartnerBubble =>
      'Votre partenaire n\'est pas encore là. Envoyez-lui une invitation.';

  @override
  String get pairingCelebrationTitle => 'Vous voilà deux.';

  @override
  String get pairingCelebrationBody =>
      'Votre partenaire vous a rejoint. Ce que vous ajoutez ici, vous le partagez à deux.';

  @override
  String get appSupabaseConfigMessage =>
      'Configurez Supabase : définissez SUPABASE_URL et SUPABASE_ANON_KEY via --dart-define.';

  @override
  String get authTitle => 'Nous Deux';

  @override
  String get authSubtitle => 'Un espace rien qu\'à vous deux.';

  @override
  String get authOr => 'ou';

  @override
  String get authPhoneLabel => 'Numéro de téléphone';

  @override
  String get authPhoneHint => '06 12 34 56 78';

  @override
  String get authSendCode => 'Recevoir un code par SMS';

  @override
  String get authContinueWithGoogle => 'Continuer avec Google';

  @override
  String get authContinueWithApple => 'Continuer avec Apple';

  @override
  String get authWithEmail => 'Se connecter avec un e-mail';

  @override
  String get authErrorEnterPhone => 'Indiquez votre numéro de téléphone.';

  @override
  String get authErrorGeneric => 'La connexion n\'a pas abouti. Réessayez.';

  @override
  String get authVerifyTitle => 'Code reçu par SMS';

  @override
  String authVerifyInstructions(String phone) {
    return 'Saisissez le code à 6 chiffres envoyé au $phone.';
  }

  @override
  String get authVerifyButton => 'Valider';

  @override
  String get authVerifyErrorEnterCode => 'Saisissez le code reçu par SMS.';

  @override
  String get authVerifyErrorInvalid =>
      'Ce code ne fonctionne pas. Vérifiez-le, ou revenez en arrière pour en recevoir un autre.';

  @override
  String get authEmailTitle => 'Connexion par e-mail';

  @override
  String get authEmailIntro =>
      'Pour les comptes que Nous Deux vous a créés, par exemple pour tester l\'application.';

  @override
  String get authEmailLabel => 'Adresse e-mail';

  @override
  String get authPasswordLabel => 'Mot de passe';

  @override
  String get authEmailButton => 'Se connecter';

  @override
  String get authEmailErrorEmpty =>
      'Saisissez votre adresse e-mail et votre mot de passe.';

  @override
  String get authEmailErrorWrong => 'Adresse e-mail ou mot de passe incorrect.';

  @override
  String get calendarTitle => 'Calendrier';

  @override
  String get calendarToday => 'Aujourd\'hui';

  @override
  String get calendarAdd => 'Ajouter';

  @override
  String get calendarPartner => 'Partenaire';

  @override
  String get calendarMe => 'Moi';

  @override
  String get calendarDeleteEventTitle => 'Supprimer l\'événement ?';

  @override
  String calendarDeleteEventConfirm(String title) {
    return '« $title » sera supprimé pour vous deux.';
  }

  @override
  String get calendarCancel => 'Annuler';

  @override
  String get calendarDelete => 'Supprimer';

  @override
  String calendarNothingInMonth(String month) {
    return 'Rien de prévu en $month';
  }

  @override
  String get calendarCreateEvent => 'Ajouter un événement';

  @override
  String get calendarPreviousMonth => 'Mois précédent';

  @override
  String get calendarNextMonth => 'Mois suivant';

  @override
  String get calendarImportAllowAccess => 'Autoriser l\'accès au calendrier';

  @override
  String get calendarImportOpenSettings => 'Ouvrir les réglages';

  @override
  String get calendarEventEdit => 'Modifier l\'événement';

  @override
  String get calendarEventNew => 'Nouvel événement';

  @override
  String get calendarEventTitleLabel => 'Titre';

  @override
  String get calendarEventTitleRequired => 'Ajoutez un titre.';

  @override
  String get calendarEventDescriptionLabel => 'Description (optionnel)';

  @override
  String get calendarEventStart => 'Début';

  @override
  String get calendarEventEnd => 'Fin';

  @override
  String get calendarEventSave => 'Enregistrer';

  @override
  String get calendarEventCountdown => 'Compte à rebours';

  @override
  String get calendarEventCountdownHint =>
      'Affiché dans l\'onglet Nous jusqu\'au jour J.';

  @override
  String get calendarEventEndBeforeStart => 'La fin doit venir après le début.';

  @override
  String get calendarFollowLabel => 'Agenda du téléphone';

  @override
  String get calendarFollowTitle => 'Vos agendas suivis';

  @override
  String calendarFollowIntro(String partnerName) {
    return 'Leurs titres et horaires sont copiés dans Nous Deux et restent à jour : $partnerName les voit. Rien d\'autre ne quitte votre téléphone.';
  }

  @override
  String get calendarFollowTip =>
      'Le plus simple : un agenda « Nous » sur votre téléphone, pour ce qui vous concerne tous les deux. Le reste de votre agenda reste à vous.';

  @override
  String get calendarFollowLastSync => 'Dernière mise à jour';

  @override
  String get calendarFollowFootnote =>
      'Du mois dernier aux six prochains mois. Les événements se modifient dans votre agenda ; ne plus suivre un agenda retire ses copies de cette période, tout arrêter les retire toutes.';

  @override
  String get calendarFollowOtherPhone =>
      'Vos agendas sont suivis depuis un autre téléphone. En suivre un ici prend le relais.';

  @override
  String get calendarFollowGone =>
      'Un agenda suivi n\'est plus sur ce téléphone, rien n\'est mis à jour.';

  @override
  String get calendarFollowDropGone => 'Ne plus le suivre';

  @override
  String get calendarFollowFailed =>
      'La mise à jour n\'a pas abouti. Réessayez plus tard.';

  @override
  String get calendarFollowNone => 'Aucun agenda sur ce téléphone.';

  @override
  String get calendarFollowPermission =>
      'Nous Deux a besoin d\'accéder à vos agendas pour les suivre. Si la demande ne s\'affiche pas, autorisez l\'accès dans les réglages.';

  @override
  String get calendarAllDay => 'Toute la journée';

  @override
  String get cycleAskTitle => 'Suivez-vous votre cycle dans l\'app ?';

  @override
  String get cycleAskBody =>
      'Si oui, cet onglet devient votre suivi. Sinon, il vous montre le cycle de votre partenaire quand il est partagé.';

  @override
  String get cycleConsent =>
      'En suivant votre cycle, vous acceptez que l\'app enregistre vos dates de règles, votre ressenti du jour et vos notes sur nos serveurs en Allemagne. Ce sont des données de santé. Votre partenaire voit vos dates et votre ressenti tant que vous les partagez ; vos notes restent privées. Vous pouvez arrêter et tout supprimer à tout moment dans les paramètres.';

  @override
  String get cycleConsentTitle => 'Suivre votre cycle dans l\'app ?';

  @override
  String get cycleConsentAccept => 'J\'accepte';

  @override
  String get cyclePrivacyPolicy => 'Politique de confidentialité';

  @override
  String get cycleStopTitle => 'Arrêter le suivi de votre cycle ?';

  @override
  String get cycleStopBody =>
      'Vous pouvez garder vos données de cycle au cas où vous reprendriez, ou les supprimer maintenant : dates, ressenti et notes. La suppression est définitive.';

  @override
  String get cycleStopKeep => 'Garder mes données';

  @override
  String get cycleStopDelete => 'Tout supprimer';

  @override
  String get cycleDataDeleted => 'Vos données de cycle sont supprimées.';

  @override
  String get cycleAskYes => 'Oui, je le suis';

  @override
  String get cycleAskNo => 'Non';

  @override
  String get settingsTracksCycle => 'Je suis mon cycle dans l\'app';

  @override
  String get cycleDayWord => 'jour';

  @override
  String cycleOfAbout(int length) {
    return 'sur ~$length';
  }

  @override
  String cycleRingLabel(int day, int length) {
    return 'Cycle d\'environ $length jours, aujourd\'hui jour $day';
  }

  @override
  String get cycleNoDataTitle => 'Notez vos prochaines règles';

  @override
  String get cycleNoDataBody =>
      'L\'app apprend votre rythme cycle après cycle.';

  @override
  String get cycleStarted => 'Mes règles ont commencé';

  @override
  String get cycleEnded => 'Elles sont finies';

  @override
  String get cycleOtherDay => 'C\'était un autre jour';

  @override
  String get cycleToday => 'Aujourd\'hui';

  @override
  String cycleSeenBy(String name) {
    return '$name le voit';
  }

  @override
  String get cycleSeenByNobody => 'Rien n\'est partagé';

  @override
  String get cycleNoteLabel => 'Note pour vous';

  @override
  String get cycleNoteHint => 'Seulement pour vous, jamais partagée';

  @override
  String get cycleNoteSaved => 'Note enregistrée.';

  @override
  String get cycleThisWeek => 'À savoir cette semaine';

  @override
  String cycleReadChapter(String title) {
    return 'Lire : $title';
  }

  @override
  String get cycleHistoryLink => 'Vos cycles';

  @override
  String cycleSharingLink(String name) {
    return 'Ce que $name voit';
  }

  @override
  String cyclePartnerLink(String name) {
    return 'Le cycle de $name';
  }

  @override
  String get cycleUndo => 'Annuler';

  @override
  String get cycleOtherState => '+ Autre';

  @override
  String get cycleNewStateHint => 'Votre ressenti';

  @override
  String get cycleAddState => 'Ajouter';

  @override
  String get cycleOwnStateHint => 'retirer de vos ressentis';

  @override
  String cycleStateRemoved(String state) {
    return '« $state » ne sera plus proposé.';
  }

  @override
  String get cycleTooManyStates => 'Douze ressentis au plus par jour.';

  @override
  String get cycleSaveFailed => 'Ça n\'a pas été enregistré. Réessayez.';

  @override
  String get cycleNeedsCouple =>
      'Le suivi s\'enregistre dans votre couple : invitez d\'abord votre partenaire.';

  @override
  String get cycleSheetStarted => 'Règles commencées';

  @override
  String get cycleSheetEnded => 'Règles terminées';

  @override
  String get cycleSheetWhen => 'Quand ?';

  @override
  String get cycleYesterday => 'Hier';

  @override
  String get cycleAnotherDay => 'Autre jour…';

  @override
  String get cycleSave => 'Enregistrer';

  @override
  String get cycleSheetFootnote =>
      'Le jour où elles s\'arrêtent, le bouton devient « Elles sont finies ».';

  @override
  String get cycleHistoryTitle => 'Vos cycles';

  @override
  String get cycleAverage => 'Cycle moyen';

  @override
  String get cyclePeriod => 'Règles';

  @override
  String get cycleDaysWord => 'jours';

  @override
  String get cycleNeedTwo =>
      'Il faut deux cycles complets pour une moyenne ; d\'ici là, l\'app compte 28 jours.';

  @override
  String cycleCurrentRow(int day) {
    return 'en cours · jour $day';
  }

  @override
  String get cycleRestOfCycle => 'Reste du cycle';

  @override
  String get cycleHistoryHint =>
      'Touchez un cycle pour le corriger, restez appuyé pour l\'effacer.';

  @override
  String get cycleHistoryEmpty =>
      'Vos cycles apparaîtront ici au fil des mois.';

  @override
  String cyclePartnerLabel(String name) {
    return 'Règles · $name';
  }

  @override
  String cyclePartnerNotShared(String name) {
    return '$name ne partage pas son cycle pour l\'instant.';
  }

  @override
  String cyclePartnerNothingYet(String name) {
    return '$name n\'a encore rien noté.';
  }

  @override
  String cyclePartnerNotTracking(String name) {
    return '$name ne suit pas de cycle dans l\'app.';
  }

  @override
  String get cycleNoPartner =>
      'Ici, vous suivrez le cycle de votre partenaire quand il sera partagé, avec des idées pour être là au bon moment.';

  @override
  String get cycleWhatHelps => 'Ce qui peut aider cette semaine';

  @override
  String cyclePartnerNoted(String name) {
    return '$name a noté aujourd\'hui';
  }

  @override
  String get cycleLittleNote => 'Un petit mot ?';

  @override
  String get cycleRemindMe => 'Me prévenir la veille';

  @override
  String get cycleRemindNoDate => 'Dès qu\'une date est prévue';

  @override
  String cycleSharingTitle(String name) {
    return 'Ce que $name voit';
  }

  @override
  String get cycleSharingIntro =>
      'Vous choisissez ce que votre partenaire voit. Ça change tout de suite sur son téléphone.';

  @override
  String get cycleShareCycle => 'Mon cycle';

  @override
  String get cycleShareCycleHint =>
      'Jour, phase, date prévue et rappel la veille';

  @override
  String get cycleShareCheckins => 'Mon ressenti du jour';

  @override
  String get cycleShareCheckinsHint => 'Ce que vous cochez chaque jour';

  @override
  String get cycleNotesRow => 'Vos notes';

  @override
  String get cycleNotesAlwaysPrivate => 'Toujours privées';

  @override
  String get cycleStopSharing => 'Ne plus rien partager';

  @override
  String get guideLabel => 'Guide';

  @override
  String get guideTitle => 'Comprendre le cycle';

  @override
  String guideForYouNow(int day) {
    return 'Pour vous maintenant · jour $day';
  }

  @override
  String guideForPartnerNow(String name, int day) {
    return 'Pour $name maintenant · jour $day';
  }

  @override
  String guideChapter(int n) {
    return 'Chapitre $n';
  }

  @override
  String get guideRead => 'lu';

  @override
  String get guideFootnote =>
      'Écrit à partir de sources de santé publique. Ne remplace pas un avis médical.';

  @override
  String get guideContents => 'Sommaire';

  @override
  String guideNext(String title) {
    return 'Suivant : $title';
  }

  @override
  String get guideSearch => 'Chercher dans le guide';

  @override
  String guideNoMatch(String query) {
    return 'Aucun chapitre ne parle de « $query ».';
  }

  @override
  String get guideBody => 'Dans le corps';

  @override
  String get guideMood => 'Côté humeur';

  @override
  String get guideWhatHelps => 'Ce qui aide';

  @override
  String get guideYouAreHere => 'vous êtes ici';

  @override
  String guidePartnerIsHere(String name) {
    return '$name est ici';
  }

  @override
  String get guideSources => 'Sources';

  @override
  String guideDaysShort(String range) {
    return 'j$range';
  }

  @override
  String get listsTitle => 'Listes';

  @override
  String listsSubtitle(String partnerName) {
    return 'Partagées avec $partnerName, en direct.';
  }

  @override
  String get listsSeeAll => 'Tout voir';

  @override
  String get listsNew => 'Nouvelle liste';

  @override
  String get listsEmptyTitle => 'Pas encore de liste';

  @override
  String get listsEmptyBody =>
      'Courses, choses à faire, idées de week-end : ce que vous ajoutez apparaît aussi chez votre partenaire.';

  @override
  String get listsNameLabel => 'Nom de la liste';

  @override
  String get listsNameHint => 'Courses';

  @override
  String get listsIconLabel => 'Icône';

  @override
  String get listsCreate => 'Créer';

  @override
  String get listsRename => 'Renommer';

  @override
  String get listsDelete => 'Supprimer la liste';

  @override
  String listsDeleteConfirm(String name) {
    return '« $name » et tous ses éléments seront supprimés pour vous deux.';
  }

  @override
  String get listsCancel => 'Annuler';

  @override
  String get listsSave => 'Enregistrer';

  @override
  String get listsOptions => 'Options de la liste';

  @override
  String get listsBack => 'Retour';

  @override
  String get listsAddLabel => 'Ajouter un élément';

  @override
  String get listsAddHint => 'Lait d\'avoine, pain…';

  @override
  String get listsAddButton => 'Ajouter';

  @override
  String listsChecked(int n) {
    return 'Cochés ($n)';
  }

  @override
  String get listsClearChecked => 'Tout effacer';

  @override
  String get listsAddedByMe => 'Ajouté par vous';

  @override
  String listsAddedBy(String name) {
    return 'Ajouté par $name';
  }

  @override
  String listsItemDeleted(String text) {
    return '« $text » supprimé.';
  }

  @override
  String get listsUndo => 'Annuler';

  @override
  String get listsDeleteItem => 'Supprimer';

  @override
  String get listsGoneTitle => 'Cette liste n\'existe plus';

  @override
  String get listsGoneBody =>
      'Elle a sans doute été supprimée sur l\'autre téléphone.';

  @override
  String get listsAll => 'Toutes les listes';

  @override
  String get listsEmptyListBody => 'Ajoutez le premier élément ci-dessus.';

  @override
  String get listsError => 'Ça n\'a pas marché. Réessayez.';

  @override
  String get nousTitle => 'Nous';

  @override
  String get nousSettingsTooltip => 'Réglages';

  @override
  String get nousTogetherSince => 'Ensemble depuis';

  @override
  String get nousEdit => 'Modifier';

  @override
  String get nousPickStartHelp => 'Le jour où tout a commencé';

  @override
  String get nousStartSaved => 'Date mise à jour.';

  @override
  String get nousSendNote => 'Envoyer un petit mot';

  @override
  String get nousNoteCooldown =>
      'Un petit mot toutes les 30 secondes au plus. Réessayez dans un instant.';

  @override
  String get nousNoteFailed => 'Le petit mot n\'est pas parti. Réessayez.';

  @override
  String get pingWriteBack => 'Répondre par un mot';

  @override
  String get nousWrite => 'Écrire…';

  @override
  String get nousMyWords => 'Mes mots';

  @override
  String nousWriteTo(String name) {
    return 'Un petit mot pour $name';
  }

  @override
  String get nousWriteHint => 'Votre petit mot';

  @override
  String get nousWriteReplaces =>
      'Il remplace votre dernier mot, comme les autres.';

  @override
  String get nousKeepWord => 'Le garder dans mes mots';

  @override
  String get nousSend => 'Envoyer';

  @override
  String get myWordsTitle => 'Mes petits mots';

  @override
  String get myWordsHelp =>
      'Ceux qui sont cochés s\'affichent sur Nous, dans cet ordre. Six au plus.';

  @override
  String get myWordsAddHint => 'Ajouter un mot…';

  @override
  String get myWordsAdd => 'Ajouter';

  @override
  String myWordsRemove(String word) {
    return 'Retirer « $word »';
  }

  @override
  String myWordsMove(String word) {
    return 'Déplacer « $word »';
  }

  @override
  String get myWordsFull =>
      'Six mots au plus sur Nous. Décochez-en un d\'abord.';

  @override
  String get myWordsAlready => 'Ce mot est déjà dans la liste.';

  @override
  String get myWordsDrag =>
      'Glissez la poignée à droite pour changer l\'ordre.';

  @override
  String get pingJustNow => 'À l\'instant';

  @override
  String get pingReplyMeToo => 'Moi aussi';

  @override
  String get pingTapToClose => 'Toucher pour fermer';

  @override
  String get nousPartnerFallback => 'Votre partenaire';

  @override
  String get nousNextPlan => 'Prochain rendez-vous';

  @override
  String get nousNoCountdown => 'Rien de prévu';

  @override
  String get nousNoCountdownHint =>
      'Activez « Compte à rebours » sur un événement.';

  @override
  String get nousAnniversary => 'Anniversaire';

  @override
  String get nousNoPartnerTitle => 'Invitez votre partenaire';

  @override
  String get nousNoPartnerBody =>
      'Le compteur démarre le jour où vous êtes deux.';

  @override
  String get nousInvite => 'Inviter';

  @override
  String get onboardingTitle => 'Présentez-vous';

  @override
  String get onboardingSubtitle =>
      'Votre partenaire verra ce prénom. Vous pourrez le changer plus tard dans les réglages.';

  @override
  String get onboardingDisplayNameLabel => 'Prénom ou surnom';

  @override
  String get onboardingDisplayNameHint => 'Camille';

  @override
  String get onboardingLanguageLabel => 'Langue';

  @override
  String get onboardingContinue => 'Continuer';

  @override
  String get onboardingErrorDisplayName =>
      'Indiquez le prénom que votre partenaire verra.';

  @override
  String get onboardingErrorGeneric =>
      'L\'enregistrement n\'a pas abouti. Réessayez.';

  @override
  String get pairingInviteTitle => 'Inviter votre partenaire';

  @override
  String get pairingIntro =>
      'Générez un code et montrez-le à votre partenaire, qui pourra scanner le QR code ou taper les 6 caractères.';

  @override
  String get pairingGenerateCode => 'Générer un code';

  @override
  String get pairingScanQrPrompt =>
      'À scanner avec le téléphone de votre partenaire :';

  @override
  String get pairingOrEnterCode => 'Ou tapez ce code :';

  @override
  String get pairingAlreadyHaveCode => 'Votre partenaire vous a déjà invité ?';

  @override
  String get pairingJoinWithCode => 'J\'ai un code';

  @override
  String get pairingScanQr => 'Scanner un QR code';

  @override
  String get pairingAlreadyPaired =>
      'Vous êtes déjà en couple dans l\'app. Retour à l\'accueil…';

  @override
  String get pairingError => 'Ça n\'a pas marché. Réessayez.';

  @override
  String get pairingJoinTitle => 'Rejoindre votre partenaire';

  @override
  String get pairingJoinInstructions =>
      'Tapez le code à 6 caractères affiché sur le téléphone de votre partenaire.';

  @override
  String get pairingJoinCodeLabel => 'Code';

  @override
  String get pairingJoinButton => 'Rejoindre';

  @override
  String get pairingJoinErrorCode => 'Tapez le code de votre partenaire.';

  @override
  String get pairingJoinErrorUsed =>
      'Ce code a déjà servi. Demandez-en un nouveau à votre partenaire.';

  @override
  String get pairingJoinErrorOwnCode =>
      'C\'est votre propre code : c\'est à votre partenaire de le saisir.';

  @override
  String get pairingJoinErrorInvalid =>
      'Ce code ne correspond à aucune invitation. Vérifiez-le avec votre partenaire.';

  @override
  String get pairingJoinErrorAlreadyPaired =>
      'Vous êtes déjà en couple dans l\'app. Quittez ce couple dans Réglages avant d\'en rejoindre un autre.';

  @override
  String get pairingJoinErrorTooManyAttempts =>
      'Trop de codes erronés. Réessayez dans 10 minutes.';

  @override
  String get pairingScanTitle => 'Scanner le QR code';

  @override
  String get pairingScanConnecting => 'Connexion…';

  @override
  String get periodLearnMore => 'En savoir plus';

  @override
  String get periodCouldNotOpenLink => 'Impossible d\'ouvrir le lien';

  @override
  String get mainNavCalendar => 'Calendrier';

  @override
  String get mainNavPeriod => 'Règles';

  @override
  String get mainNavPosition => 'Position';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get settingsAboutApp => 'À propos';

  @override
  String get settingsUsername => 'Prénom ou surnom';

  @override
  String get settingsProfilePhoto => 'Photo de profil';

  @override
  String get settingsChangePhoto => 'Changer la photo';

  @override
  String get settingsPermissions => 'Autorisations';

  @override
  String get settingsOpenAppSettings => 'Ouvrir les réglages';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsPeriodReminder =>
      'Prévenir la veille des règles de votre partenaire';

  @override
  String get settingsCalendarReminders => 'Rappels calendrier';

  @override
  String get settingsCalendarRemindersSubtitle => 'Bientôt disponible';

  @override
  String get settingsPermissionGranted => 'Autorisé';

  @override
  String get settingsPermissionDenied => 'Refusé';

  @override
  String get settingsPermissionRestricted => 'Restreint';

  @override
  String get settingsPermissionPermanentDenied => 'Bloqué';

  @override
  String get settingsCalendars => 'Calendrier';

  @override
  String get settingsNotificationsPerm => 'Notifications';

  @override
  String get settingsLocation => 'Position';

  @override
  String get settingsPermissionsReloadTooltip => 'Actualiser les autorisations';

  @override
  String get settingsPermissionsReloadDone => 'Autorisations actualisées';

  @override
  String get settingsShareMyLocation => 'Partager ma position';

  @override
  String get settingsShareMyLocationSubtitle =>
      'Votre partenaire voit où vous êtes sur la carte. Aucun historique n\'est gardé.';

  @override
  String get settingsLocationRequiredForSharing =>
      'Autorisez l\'accès à la position pour la partager.';

  @override
  String get settingsCamera => 'Appareil photo';

  @override
  String get settingsCoupleGroup => 'Couple';

  @override
  String get settingsLeaveCouple => 'Quitter le couple';

  @override
  String get settingsLeaveCoupleSubtitle =>
      'Coupe le lien avec votre partenaire et supprime ce que vous partagez : calendrier, cycle, position, listes et petits mots.';

  @override
  String get settingsLeaveCoupleConfirmTitle => 'Quitter le couple ?';

  @override
  String get settingsLeaveCoupleConfirmMessage =>
      'Le calendrier, le cycle, la position, les listes et les petits mots seront supprimés pour vous deux. Impossible de revenir en arrière.';

  @override
  String get settingsLeaveCoupleConfirm => 'Quitter';

  @override
  String get settingsLeaveCoupleSuccess => 'Vous avez quitté le couple.';

  @override
  String get settingsAccountGroup => 'Compte';

  @override
  String get settingsSignOut => 'Se déconnecter';

  @override
  String get settingsSignOutConfirmTitle => 'Se déconnecter ?';

  @override
  String get settingsSignOutConfirmMessage =>
      'Votre couple et ce que vous partagez restent en place. Reconnectez-vous avec le même compte pour les retrouver.';

  @override
  String get settingsDeleteAccount => 'Supprimer mon compte';

  @override
  String get settingsDeleteAccountConfirmTitle => 'Supprimer votre compte ?';

  @override
  String get settingsDeleteAccountConfirm => 'Supprimer';

  @override
  String get settingsDeleteAccountDone => 'Votre compte a été supprimé.';

  @override
  String get settingsDeleteAccountFailed =>
      'Le compte n\'a pas pu être supprimé. Vérifiez votre connexion et réessayez.';

  @override
  String get appInfoTitle => 'À propos de l\'app';

  @override
  String get appInfoDescription =>
      'Nous Deux est une application pour les couples, pensée pour la vie privée : un calendrier commun, le suivi du cycle et, si vous le voulez, le partage de position.';

  @override
  String get appInfoFree =>
      'Le projet est gratuit et le restera. Il n\'y aura jamais de publicité.';

  @override
  String get appInfoSource => 'Code source';

  @override
  String get appInfoContributors => 'Contributeurs';

  @override
  String get appInfoThomasMoser => 'Développement';

  @override
  String get appInfoEvahBaumlin =>
      'Contenu, explications scientifiques et regard féminin';

  @override
  String get appInfoFriends => 'Soutien tout au long du projet';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get settingsLanguageUpdated => 'Langue mise à jour';

  @override
  String get settingsEditUsername => 'Modifier le nom';

  @override
  String get settingsSave => 'Enregistrer';

  @override
  String get settingsCancel => 'Annuler';

  @override
  String get timeAgoJustNow => 'à l\'instant';

  @override
  String timeAgoMinutes(int minutes) {
    return 'il y a $minutes min';
  }

  @override
  String timeAgoHours(int hours) {
    return 'il y a $hours h';
  }

  @override
  String timeAgoOnDay(String day) {
    return 'le $day';
  }

  @override
  String get calendarSyncedFromMine => 'Depuis votre agenda';

  @override
  String calendarSyncedFrom(String name, String nameStart) {
    String _temp0 = intl.Intl.selectLogic(nameStart, {
      'vowel': 'Depuis l\'agenda d\'$name',
      'other': 'Depuis l\'agenda de $name',
    });
    return '$_temp0';
  }

  @override
  String get calendarSyncedReadOnlyMine =>
      'Cet événement suit l\'agenda de votre téléphone : modifiez-le ou supprimez-le là-bas.';

  @override
  String calendarSyncedReadOnly(String name) {
    return 'Cet événement suit l\'agenda du téléphone de $name : il se modifie ou se supprime là-bas.';
  }

  @override
  String get cyclePartnerFallback => 'Votre partenaire';

  @override
  String cyclePhaseLabel(String phase) {
    String _temp0 = intl.Intl.selectLogic(phase, {
      'menstrual': 'Règles',
      'follicular': 'Phase folliculaire',
      'ovulation': 'Ovulation',
      'luteal': 'Phase lutéale',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String cycleHeadlineOngoing(int day) {
    return 'Règles en cours, jour $day';
  }

  @override
  String cycleHeadlineIn(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Règles dans ~$days jours',
      one: 'Règles prévues demain',
      zero: 'Règles prévues aujourd\'hui',
    );
    return '$_temp0';
  }

  @override
  String cycleHeadlineLate(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Règles attendues depuis $days jours',
      one: 'Règles attendues depuis $days jour',
    );
    return '$_temp0';
  }

  @override
  String cycleBasis(String date, int cyclesUsed) {
    String _temp0 = intl.Intl.pluralLogic(
      cyclesUsed,
      locale: localeName,
      other: 'vers le $date, d\'après vos $cyclesUsed derniers cycles',
      one: 'vers le $date, d\'après votre dernier cycle',
      zero: 'vers le $date, sur 28 jours en attendant d\'en savoir plus',
    );
    return '$_temp0';
  }

  @override
  String cycleLoggedStart(String date) {
    return 'Début noté : $date';
  }

  @override
  String cycleLoggedEnd(String date) {
    return 'Fin notée : $date';
  }

  @override
  String cycleSelfTip(String phase) {
    String _temp0 = intl.Intl.selectLogic(phase, {
      'menstrual':
          'Chaleur, repos et eau aident souvent pendant les règles. Des douleurs qui vous empêchent de vivre normalement méritent un avis médical.',
      'follicular':
          'L\'énergie remonte souvent après les règles : un bon moment pour ce qui demande de l\'élan.',
      'ovulation':
          'Autour de l\'ovulation, beaucoup se sentent en forme. Une petite gêne d\'un côté du ventre peut aussi arriver.',
      'luteal':
          'En fin de cycle, sommeil plus léger et énergie plus basse sont fréquents. Rien d\'anormal.',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String cycleRegularitySame(int count, int days) {
    return 'Vos $count derniers cycles ont tous duré $days jours.';
  }

  @override
  String cycleRegularityRange(int count, int shortest, int longest) {
    return 'Vos $count derniers cycles ont duré entre $shortest et $longest jours.';
  }

  @override
  String cycleSpanRow(int length) {
    return '$length j';
  }

  @override
  String cycleSpanRowWithPeriod(int length, int periodDays) {
    return '$length j · règles $periodDays j';
  }

  @override
  String cyclePartnerHeadlineOngoing(String name, int day) {
    return '$name a ses règles, jour $day';
  }

  @override
  String cyclePartnerHeadlineDay(String name, int day) {
    return '$name est au jour $day';
  }

  @override
  String cyclePartnerNextLate(String date) {
    return 'Les règles étaient attendues vers le $date.';
  }

  @override
  String cyclePartnerNext(String date) {
    return 'Prochaines règles vers le $date.';
  }

  @override
  String cycleRemindOn(String date) {
    return 'le $date au soir';
  }

  @override
  String cyclePartnerTip1(String phase) {
    String _temp0 = intl.Intl.selectLogic(phase, {
      'menstrual':
          'Proposer la bouillotte ou une tisane, sans attendre qu\'on la demande.',
      'follicular':
          'L\'énergie revient souvent : bon moment pour une sortie à deux.',
      'ovulation':
          'Beaucoup se sentent en forme ces jours-là : profitez-en ensemble.',
      'luteal': 'Garder les soirées calmes si la fatigue se fait sentir.',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String cyclePartnerTip2(String phase) {
    String _temp0 = intl.Intl.selectLogic(phase, {
      'menstrual': 'Alléger la journée : prendre les courses ou le dîner.',
      'follicular': 'Proposer un projet que vous repoussez depuis un moment.',
      'ovulation':
          'Une petite gêne au bas du ventre peut arriver ; demandez simplement comment ça va.',
      'luteal': 'Proposer plutôt que demander : « Je m\'occupe du dîner ? »',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String cyclePartnerTip3(String phase) {
    String _temp0 = intl.Intl.selectLogic(phase, {
      'menstrual': 'Demander « De quoi tu as besoin ? » plutôt que deviner.',
      'follicular': 'Suivre son rythme, sans le pousser.',
      'ovulation': 'Rester à l\'écoute : chaque cycle est différent.',
      'luteal':
          'Ne pas tout mettre sur le compte des hormones : écouter ce qui est dit.',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String guideNowTitle(String phase) {
    return '$phase : ce qui se passe, ce qui aide';
  }

  @override
  String get listsCountsEmpty => 'Vide';

  @override
  String get listsCountsAllDone => 'Tout est fait';

  @override
  String listsCounts(int open, int total) {
    return '$open à faire sur $total';
  }

  @override
  String listsIconName(String icon) {
    String _temp0 = intl.Intl.selectLogic(icon, {
      'list': 'Liste',
      'cart': 'Courses',
      'star': 'Envies',
      'home': 'Maison',
      'gift': 'Cadeaux',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String nousDaysUnit(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'jours',
      one: 'jour',
    );
    return '$_temp0';
  }

  @override
  String nousSinceDate(String date) {
    return 'Depuis le $date';
  }

  @override
  String pingLabel(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'thinkingOfYou': 'Je pense à toi',
      'goodNight': 'Bonne nuit',
      'onMyWay': 'J\'arrive',
      'missYou': 'Tu me manques',
      'kiss': 'Bisou',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String nousNoteSent(String note) {
    return 'Envoyé : $note';
  }

  @override
  String pingReceivedTitle(String kind, String name) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'thinkingOfYou': '$name pense à toi.',
      'goodNight': '$name te souhaite bonne nuit.',
      'onMyWay': '$name arrive.',
      'missYou': '$name : tu me manques.',
      'kiss': '$name t\'envoie un bisou.',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String nousReceivedLine(String name, String note, String when) {
    return '$name : $note, $when';
  }

  @override
  String nousInDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'dans $days j',
      one: 'demain',
      zero: 'aujourd\'hui',
    );
    return '$_temp0';
  }

  @override
  String nousYearsTogether(int years) {
    String _temp0 = intl.Intl.pluralLogic(
      years,
      locale: localeName,
      other: '$years ans ensemble',
      one: '$years an ensemble',
    );
    return '$_temp0';
  }

  @override
  String get settingsDeleteAccountConfirmPaired =>
      'Votre compte, votre profil, votre photo et vos notes de cycle seront supprimés. Vous quitterez aussi le couple : le calendrier, le cycle, la position, les listes et les petits mots seront supprimés pour vous deux. Impossible de revenir en arrière.';

  @override
  String get settingsDeleteAccountConfirmSolo =>
      'Votre compte, votre profil, votre photo et vos notes de cycle seront supprimés. Impossible de revenir en arrière.';

  @override
  String get periodScreenTitle => 'Règles';

  @override
  String get periodLogNew => 'Nouvel enregistrement';

  @override
  String get periodLogEdit => 'Modifier l\'enregistrement';

  @override
  String get periodDeleteConfirmTitle => 'Supprimer cet enregistrement ?';

  @override
  String get periodCancel => 'Annuler';

  @override
  String get periodDelete => 'Supprimer';

  @override
  String get periodSave => 'Enregistrer';

  @override
  String get periodStartDate => 'Date de début';

  @override
  String get periodEndDate => 'Date de fin (optionnel)';

  @override
  String get periodReminderNotificationTitle => 'Règles prévues demain';

  @override
  String get periodReminderNotificationBody =>
      'D\'après son cycle, les règles de votre partenaire devraient commencer demain.';

  @override
  String periodMoodLabel(String value) {
    String _temp0 = intl.Intl.selectLogic(value, {
      'good': 'Bien',
      'tired': 'Fatigué(e)',
      'anxious': 'Anxieux(se)',
      'irritable': 'Irrité(e)',
      'other': '$value',
    });
    return '$_temp0';
  }

  @override
  String periodSymptomLabel(String value) {
    String _temp0 = intl.Intl.selectLogic(value, {
      'cramps': 'Crampes',
      'headache': 'Maux de tête',
      'acne': 'Acné',
      'pain': 'Douleurs',
      'bloating': 'Ballonnements',
      'other': '$value',
    });
    return '$_temp0';
  }

  @override
  String guideLabelPrefix(String label) {
    return '$label : ';
  }

  @override
  String get positionTitle => 'Position';

  @override
  String get positionNoPartnerMessage => 'Invitez votre partenaire';

  @override
  String get positionNoPartnerSecondary =>
      'Une fois à deux, vous vous verrez sur la carte.';

  @override
  String get positionInvitePartner => 'Inviter';

  @override
  String get positionEnableSharingMessage => 'Activez la position';

  @override
  String get positionEnableSharingSecondary =>
      'Autorisez l\'accès à la position dans les réglages de votre téléphone.';

  @override
  String get positionOpenSettings => 'Ouvrir les réglages';

  @override
  String get positionReloadTooltip => 'Actualiser';

  @override
  String get positionReloadDone => 'À jour';

  @override
  String get positionMapPhoneOnly => 'La carte s\'affiche sur téléphone.';

  @override
  String get positionTogether => 'Ensemble ❤️';

  @override
  String get positionTogetherTitle => 'Nous Deux';

  @override
  String get positionMe => 'Moi';

  @override
  String get positionSeeAll => 'Voir tout';

  @override
  String get positionPartnerFallback => 'Partenaire';

  @override
  String get appInfoFriendsName => 'Les amis';

  @override
  String get profileUnavailableTitle => 'Connexion impossible';

  @override
  String get profileUnavailableBody =>
      'Nous Deux n\'arrive pas à joindre son serveur. Vérifiez votre connexion, puis réessayez.';

  @override
  String get profileUnavailableRetry => 'Réessayer';

  @override
  String get newsTitle => 'Nouveautés';

  @override
  String get newsSignature => 'L\'équipe Nous Deux';

  @override
  String newsUnread(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count non lues',
      one: '$count non lue',
    );
    return '$_temp0';
  }

  @override
  String get newsEmpty => 'Rien de nouveau pour l\'instant.';

  @override
  String get newsLoadFailed =>
      'Impossible de charger les nouveautés. Vérifiez votre connexion, puis réessayez.';

  @override
  String get settingsNewsPush => 'Nouveautés de l\'app';

  @override
  String get settingsNewsPushSubtitle =>
      'Les nouvelles fonctions et les messages de l\'équipe Nous Deux.';

  @override
  String newsAvatarUnread(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Réglages, $count nouveautés',
      one: 'Réglages, $count nouveauté',
    );
    return '$_temp0';
  }

  @override
  String get settingsFeedback => 'Envoyer un retour';

  @override
  String feedbackSubject(String build, String device) {
    return 'Nous Deux · build $build · $device';
  }

  @override
  String settingsFeedbackNoMail(String email) {
    return 'Aucune app de mail trouvée. Écrivez à $email.';
  }

  @override
  String pillReminderTitle(String style) {
    String _temp0 = intl.Intl.selectLogic(style, {
      'clear': 'Pilule',
      'other': 'Petit rappel',
    });
    return '$_temp0';
  }

  @override
  String pillReminderBodyClear(int number) {
    return 'C\'est l\'heure de votre pilule. Comprimé $number.';
  }

  @override
  String pillReminderBodyDiscreet(String time) {
    return 'Votre rappel de $time.';
  }

  @override
  String get pillReminderLaterClear =>
      'Pas encore cochée : c\'est l\'heure de votre pilule.';

  @override
  String pillReminderLaterDiscreet(String time) {
    return 'Toujours là : votre rappel de $time.';
  }

  @override
  String pillActionTaken(String style) {
    String _temp0 = intl.Intl.selectLogic(style, {
      'clear': 'Prise',
      'other': 'C\'est fait',
    });
    return '$_temp0';
  }

  @override
  String get pillActionSnooze => 'Dans 30 min';
}
