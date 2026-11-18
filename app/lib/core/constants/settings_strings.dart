import 'package:nousdeux/core/l10n/l10n.dart';
// Settings and app info strings. Use lang 'fr' or 'en'.

/// Bottom nav labels (used in MainShellScreen).
String mainNavCalendar(String lang) => l10nFor(lang).mainNavCalendar;
String mainNavPeriod(String lang) => l10nFor(lang).mainNavPeriod;
String mainNavPosition(String lang) => l10nFor(lang).mainNavPosition;

String settingsTitle(String lang) => l10nFor(lang).settingsTitle;
String settingsAboutApp(String lang) => l10nFor(lang).settingsAboutApp;
String settingsUsername(String lang) => l10nFor(lang).settingsUsername;
String settingsProfilePhoto(String lang) => l10nFor(lang).settingsProfilePhoto;
String settingsChangePhoto(String lang) => l10nFor(lang).settingsChangePhoto;
String settingsPermissions(String lang) => l10nFor(lang).settingsPermissions;
String settingsOpenAppSettings(String lang) =>
    l10nFor(lang).settingsOpenAppSettings;
String settingsNotifications(String lang) =>
    l10nFor(lang).settingsNotifications;
String settingsPeriodReminder(String lang) =>
    l10nFor(lang).settingsPeriodReminder;
String settingsCalendarReminders(String lang) =>
    l10nFor(lang).settingsCalendarReminders;
String settingsCalendarRemindersSubtitle(String lang) =>
    l10nFor(lang).settingsCalendarRemindersSubtitle;
String settingsPermissionGranted(String lang) =>
    l10nFor(lang).settingsPermissionGranted;
String settingsPermissionDenied(String lang) =>
    l10nFor(lang).settingsPermissionDenied;
String settingsPermissionRestricted(String lang) =>
    l10nFor(lang).settingsPermissionRestricted;
String settingsPermissionPermanentDenied(String lang) =>
    l10nFor(lang).settingsPermissionPermanentDenied;
String settingsCalendars(String lang) => l10nFor(lang).settingsCalendars;
String settingsNotificationsPerm(String lang) =>
    l10nFor(lang).settingsNotificationsPerm;
String settingsLocation(String lang) => l10nFor(lang).settingsLocation;
String settingsPermissionsReloadTooltip(String lang) =>
    l10nFor(lang).settingsPermissionsReloadTooltip;
String settingsPermissionsReloadDone(String lang) =>
    l10nFor(lang).settingsPermissionsReloadDone;
String settingsShareMyLocation(String lang) =>
    l10nFor(lang).settingsShareMyLocation;
String settingsShareMyLocationSubtitle(String lang) =>
    l10nFor(lang).settingsShareMyLocationSubtitle;
String settingsLocationRequiredForSharing(String lang) =>
    l10nFor(lang).settingsLocationRequiredForSharing;
String settingsCamera(String lang) => l10nFor(lang).settingsCamera;

// Leave couple
String settingsCoupleGroup(String lang) => l10nFor(lang).settingsCoupleGroup;
String settingsLeaveCouple(String lang) => l10nFor(lang).settingsLeaveCouple;
String settingsLeaveCoupleSubtitle(String lang) =>
    l10nFor(lang).settingsLeaveCoupleSubtitle;
String settingsLeaveCoupleConfirmTitle(String lang) =>
    l10nFor(lang).settingsLeaveCoupleConfirmTitle;
String settingsLeaveCoupleConfirmMessage(String lang) =>
    l10nFor(lang).settingsLeaveCoupleConfirmMessage;
String settingsLeaveCoupleConfirm(String lang) =>
    l10nFor(lang).settingsLeaveCoupleConfirm;
String settingsLeaveCoupleSuccess(String lang) =>
    l10nFor(lang).settingsLeaveCoupleSuccess;

// Sign out
String settingsAccountGroup(String lang) => l10nFor(lang).settingsAccountGroup;
String settingsSignOut(String lang) => l10nFor(lang).settingsSignOut;
String settingsSignOutConfirmTitle(String lang) =>
    l10nFor(lang).settingsSignOutConfirmTitle;
String settingsSignOutConfirmMessage(String lang) =>
    l10nFor(lang).settingsSignOutConfirmMessage;

// Delete account
String settingsDeleteAccount(String lang) =>
    l10nFor(lang).settingsDeleteAccount;
String settingsDeleteAccountConfirmTitle(String lang) =>
    l10nFor(lang).settingsDeleteAccountConfirmTitle;
String settingsDeleteAccountConfirmMessage(
  String lang, {
  required bool paired,
}) => paired
    ? l10nFor(lang).settingsDeleteAccountConfirmPaired
    : l10nFor(lang).settingsDeleteAccountConfirmSolo;

String settingsDeleteAccountConfirm(String lang) =>
    l10nFor(lang).settingsDeleteAccountConfirm;
String settingsDeleteAccountDone(String lang) =>
    l10nFor(lang).settingsDeleteAccountDone;
String settingsDeleteAccountFailed(String lang) =>
    l10nFor(lang).settingsDeleteAccountFailed;

// App info
String appInfoTitle(String lang) => l10nFor(lang).appInfoTitle;
String appInfoDescription(String lang) => l10nFor(lang).appInfoDescription;
String appInfoFree(String lang) => l10nFor(lang).appInfoFree;
String appInfoSource(String lang) => l10nFor(lang).appInfoSource;
String appInfoContributors(String lang) => l10nFor(lang).appInfoContributors;
String appInfoThomasMoser(String lang) => l10nFor(lang).appInfoThomasMoser;
String appInfoEvahBaumlin(String lang) => l10nFor(lang).appInfoEvahBaumlin;
String appInfoFriends(String lang) => l10nFor(lang).appInfoFriends;

// Language
String settingsLanguage(String lang) => l10nFor(lang).settingsLanguage;
String settingsLanguageUpdated(String lang) =>
    l10nFor(lang).settingsLanguageUpdated;

// Username edit
String settingsEditUsername(String lang) => l10nFor(lang).settingsEditUsername;
String settingsSave(String lang) => l10nFor(lang).settingsSave;
String settingsCancel(String lang) => l10nFor(lang).settingsCancel;
String appInfoFriendsName(String lang) => l10nFor(lang).appInfoFriendsName;

/// « Envoyer un retour »: opens the phone's mail app (core/services/feedback_mail.dart).
String settingsFeedback(String lang) => l10nFor(lang).settingsFeedback;
String settingsFeedbackNoMail(String lang, String email) =>
    l10nFor(lang).settingsFeedbackNoMail(email);
