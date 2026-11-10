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
String calendarNothingToday(String lang) =>
    lang == 'fr' ? 'Rien de prévu aujourd\'hui' : 'Nothing planned for today';
String calendarNoEventsOn(String lang, String dateStr) =>
    lang == 'fr' ? 'Rien de prévu le $dateStr' : 'Nothing planned on $dateStr';
String calendarCreateEvent(String lang) =>
    lang == 'fr' ? 'Ajouter un événement' : 'Add an event';
String calendarImportTooltip(String lang) =>
    lang == 'fr' ? 'Importer' : 'Import';

// TableCalendar format labels
String calendarFormatMonth(String lang) =>
    lang == 'fr' ? 'Mois' : 'Month';
String calendarFormatTwoWeeks(String lang) =>
    lang == 'fr' ? '2 sem.' : '2 wks';
String calendarFormatWeek(String lang) =>
    lang == 'fr' ? 'Semaine' : 'Week';

// Import screen
String calendarImportTitle(String lang) =>
    lang == 'fr' ? 'Importer depuis l\'agenda' : 'Import from calendar';
String calendarImportLoading(String lang) =>
    lang == 'fr' ? 'Chargement des agendas…' : 'Loading calendars…';
String calendarImportIntro(String lang) =>
    lang == 'fr'
        ? 'Choisissez un agenda et une période : les événements seront copiés dans Nous Deux.'
        : 'Pick a calendar and a date range. The events will be copied into Nous Deux.';
String calendarImportPermissionMessage(String lang) =>
    lang == 'fr'
        ? "Nous Deux a besoin d'accéder à votre calendrier pour importer des événements. Si la demande ne s'affiche pas, autorisez l'accès dans les réglages."
        : 'Nous Deux needs access to your calendar to import events. If no prompt appears, allow access in Settings.';
String calendarImportVerifying(String lang) =>
    lang == 'fr' ? 'Vérification…' : 'Verifying…';
String calendarImportAllowAccess(String lang) =>
    lang == 'fr' ? 'Autoriser l\'accès au calendrier' : 'Allow calendar access';
String calendarImportOpenSettings(String lang) =>
    lang == 'fr' ? 'Ouvrir les réglages' : 'Open settings';
String calendarImportNoCalendars(String lang) =>
    lang == 'fr'
        ? 'Aucun calendrier trouvé sur cet appareil.'
        : 'No calendars found on this device.';
String calendarImportCalendarLabel(String lang) =>
    lang == 'fr' ? 'Agenda' : 'Calendar';
String calendarImportFrom(String lang) => lang == 'fr' ? 'Du' : 'From';
String calendarImportTo(String lang) => lang == 'fr' ? 'Au' : 'To';
String calendarImportImporting(String lang) =>
    lang == 'fr' ? 'Importation…' : 'Importing…';
String calendarImportButton(String lang) =>
    lang == 'fr' ? 'Importer' : 'Import';
String calendarImportRestartMessage(String lang) =>
    lang == 'fr'
        ? 'Redémarrez complètement l\'app (arrêt puis relance) pour que le bouton Réglages fonctionne.'
        : 'Fully restart the app (quit then relaunch) for the Settings button to work.';

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
