// Settings and app info strings. Use lang 'fr' or 'en'.

/// Bottom nav labels (used in MainShellScreen).
String mainNavCalendar(String lang) => lang == 'fr' ? 'Calendrier' : 'Calendar';
String mainNavPeriod(String lang) => lang == 'fr' ? 'Règles' : 'Period';
String mainNavPosition(String lang) => lang == 'fr' ? 'Position' : 'Location';

String settingsTitle(String lang) => lang == 'fr' ? 'Paramètres' : 'Settings';
String settingsAboutApp(String lang) => lang == 'fr' ? 'À propos' : 'About';
String settingsUsername(String lang) =>
    lang == 'fr' ? 'Prénom ou surnom' : 'Name or nickname';
String settingsProfilePhoto(String lang) => lang == 'fr' ? 'Photo de profil' : 'Profile photo';
String settingsChangePhoto(String lang) => lang == 'fr' ? 'Changer la photo' : 'Change photo';
String settingsPermissions(String lang) => lang == 'fr' ? 'Autorisations' : 'Permissions';
String settingsOpenAppSettings(String lang) => lang == 'fr' ? 'Ouvrir les réglages' : 'Open app settings';
String settingsNotifications(String lang) => lang == 'fr' ? 'Notifications' : 'Notifications';
String settingsPeriodReminder(String lang) => lang == 'fr'
    ? 'Prévenir la veille des règles de votre partenaire'
    : "Remind me the day before my partner's period";
String settingsCalendarReminders(String lang) => lang == 'fr' ? 'Rappels calendrier' : 'Calendar reminders';
String settingsCalendarRemindersSubtitle(String lang) =>
    lang == 'fr' ? 'Bientôt disponible' : 'Coming soon';
String settingsPermissionGranted(String lang) => lang == 'fr' ? 'Autorisé' : 'Granted';
String settingsPermissionDenied(String lang) => lang == 'fr' ? 'Refusé' : 'Denied';
String settingsPermissionRestricted(String lang) => lang == 'fr' ? 'Restreint' : 'Restricted';
String settingsPermissionPermanentDenied(String lang) =>
    lang == 'fr' ? 'Bloqué' : 'Blocked';
String settingsCalendars(String lang) => lang == 'fr' ? 'Calendrier' : 'Calendar';
String settingsNotificationsPerm(String lang) => lang == 'fr' ? 'Notifications' : 'Notifications';
String settingsLocation(String lang) => lang == 'fr' ? 'Position' : 'Location';
String settingsPermissionsReloadTooltip(String lang) =>
    lang == 'fr' ? 'Actualiser les autorisations' : 'Refresh permissions';
String settingsPermissionsReloadDone(String lang) =>
    lang == 'fr' ? 'Autorisations actualisées' : 'Permissions updated';
String settingsShareMyLocation(String lang) =>
    lang == 'fr' ? 'Partager ma position' : 'Share my location';
String settingsShareMyLocationSubtitle(String lang) =>
    lang == 'fr'
        ? "Votre partenaire voit où vous êtes sur la carte. Aucun historique n'est gardé."
        : 'Your partner sees where you are on the map. No history is kept.';
String settingsLocationRequiredForSharing(String lang) =>
    lang == 'fr'
        ? "Autorisez l'accès à la position pour la partager."
        : 'Allow location access to share where you are.';
String settingsCamera(String lang) => lang == 'fr' ? 'Appareil photo' : 'Camera';

// Leave couple
String settingsCoupleGroup(String lang) => lang == 'fr' ? 'Couple' : 'Couple';
String settingsLeaveCouple(String lang) => lang == 'fr' ? 'Quitter le couple' : 'Leave couple';
String settingsLeaveCoupleSubtitle(String lang) =>
    lang == 'fr'
        ? 'Coupe le lien avec votre partenaire et supprime ce que vous partagez : calendrier, cycle, position, listes et petits mots.'
        : 'Unlinks you from your partner and deletes what you share: calendar, cycle, location, lists and little notes.';
String settingsLeaveCoupleConfirmTitle(String lang) =>
    lang == 'fr' ? 'Quitter le couple ?' : 'Leave the couple?';
String settingsLeaveCoupleConfirmMessage(String lang) =>
    lang == 'fr'
        ? 'Le calendrier, le cycle, la position, les listes et les petits mots seront supprimés pour vous deux. Impossible de revenir en arrière.'
        : "Your calendar, cycle, location, lists and little notes will be deleted for both of you. This can't be undone.";
String settingsLeaveCoupleConfirm(String lang) => lang == 'fr' ? 'Quitter' : 'Leave';
String settingsLeaveCoupleSuccess(String lang) =>
    lang == 'fr' ? 'Vous avez quitté le couple.' : "You've left the couple.";

// Sign out
String settingsAccountGroup(String lang) => lang == 'fr' ? 'Compte' : 'Account';
String settingsSignOut(String lang) => lang == 'fr' ? 'Se déconnecter' : 'Sign out';
String settingsSignOutConfirmTitle(String lang) =>
    lang == 'fr' ? 'Se déconnecter ?' : 'Sign out?';
String settingsSignOutConfirmMessage(String lang) =>
    lang == 'fr'
        ? 'Votre couple et ce que vous partagez restent en place. Reconnectez-vous avec le même compte pour les retrouver.'
        : 'Your couple and what you share stay as they are. Sign in with the same account to find them again.';

// Delete account
String settingsDeleteAccount(String lang) =>
    lang == 'fr' ? 'Supprimer mon compte' : 'Delete my account';
String settingsDeleteAccountConfirmTitle(String lang) =>
    lang == 'fr' ? 'Supprimer votre compte ?' : 'Delete your account?';
String settingsDeleteAccountConfirmMessage(
  String lang, {
  required bool paired,
}) {
  if (lang == 'fr') {
    return paired
        ? "Votre compte, votre profil, votre photo et vos notes de cycle seront supprimés. Vous quitterez aussi le couple : le calendrier, le cycle, la position, les listes et les petits mots seront supprimés pour vous deux. Impossible de revenir en arrière."
        : 'Votre compte, votre profil, votre photo et vos notes de cycle seront supprimés. Impossible de revenir en arrière.';
  }
  return paired
      ? "Your account, profile, photo and cycle notes will be deleted. You'll also leave the couple: your calendar, cycle, location, lists and little notes will be deleted for both of you. This can't be undone."
      : "Your account, profile, photo and cycle notes will be deleted. This can't be undone.";
}

String settingsDeleteAccountConfirm(String lang) =>
    lang == 'fr' ? 'Supprimer' : 'Delete';
String settingsDeleteAccountDone(String lang) => lang == 'fr'
    ? 'Votre compte a été supprimé.'
    : 'Your account has been deleted.';
String settingsDeleteAccountFailed(String lang) => lang == 'fr'
    ? "Le compte n'a pas pu être supprimé. Vérifiez votre connexion et réessayez."
    : "Your account couldn't be deleted. Check your connection and try again.";

// App info
String appInfoTitle(String lang) => lang == 'fr' ? 'À propos de l\'app' : 'About the app';
String appInfoDescription(String lang) =>
    lang == 'fr'
        ? 'Nous Deux est une application pour les couples, pensée pour la vie privée : un calendrier commun, le suivi du cycle et, si vous le voulez, le partage de position.'
        : 'Nous Deux is a private app for couples: a shared calendar, cycle tracking and, if you want it, location sharing.';
String appInfoFree(String lang) =>
    lang == 'fr'
        ? "Le projet est gratuit et le restera. Il n'y aura jamais de publicité."
        : 'The project is free and will stay free. There will never be ads.';
String appInfoSource(String lang) => lang == 'fr' ? 'Code source' : 'Source code';
String appInfoContributors(String lang) => lang == 'fr' ? 'Contributeurs' : 'Contributors';
String appInfoThomasMoser(String lang) => lang == 'fr' ? 'Développement' : 'Development';
String appInfoEvahBaumlin(String lang) =>
    lang == 'fr'
        ? 'Contenu, explications scientifiques et regard féminin'
        : "Content, scientific explanations and a woman's perspective";
String appInfoFriends(String lang) => lang == 'fr' ? 'Soutien tout au long du projet' : 'Support along the way';

// Language
String settingsLanguage(String lang) => lang == 'fr' ? 'Langue' : 'Language';
String settingsLanguageFrench(String lang) => lang == 'fr' ? 'Français' : 'French';
String settingsLanguageEnglish(String lang) => lang == 'fr' ? 'Anglais' : 'English';
String settingsLanguageUpdated(String lang) =>
    lang == 'fr' ? 'Langue mise à jour' : 'Language updated';

// Username edit
String settingsEditUsername(String lang) => lang == 'fr' ? 'Modifier le nom' : 'Edit name';
String settingsSave(String lang) => lang == 'fr' ? 'Enregistrer' : 'Save';
String settingsCancel(String lang) => lang == 'fr' ? 'Annuler' : 'Cancel';
