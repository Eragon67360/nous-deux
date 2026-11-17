import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @splashTagline.
  ///
  /// In en, this message translates to:
  /// **'Where stories meet'**
  String get splashTagline;

  /// No description provided for @mainNoPartnerBubble.
  ///
  /// In en, this message translates to:
  /// **'Your partner isn\'t here yet. Send them an invite.'**
  String get mainNoPartnerBubble;

  /// No description provided for @pairingCelebrationTitle.
  ///
  /// In en, this message translates to:
  /// **'It\'s the two of you now.'**
  String get pairingCelebrationTitle;

  /// No description provided for @pairingCelebrationBody.
  ///
  /// In en, this message translates to:
  /// **'Your partner is in. Whatever you add here, you now share.'**
  String get pairingCelebrationBody;

  /// No description provided for @appSupabaseConfigMessage.
  ///
  /// In en, this message translates to:
  /// **'Configure Supabase: set SUPABASE_URL and SUPABASE_ANON_KEY via --dart-define.'**
  String get appSupabaseConfigMessage;

  /// No description provided for @authTitle.
  ///
  /// In en, this message translates to:
  /// **'Nous Deux'**
  String get authTitle;

  /// No description provided for @authSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A space for just the two of you.'**
  String get authSubtitle;

  /// No description provided for @authOr.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get authOr;

  /// No description provided for @authPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get authPhoneLabel;

  /// No description provided for @authPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'+1 234 567 8900'**
  String get authPhoneHint;

  /// No description provided for @authSendCode.
  ///
  /// In en, this message translates to:
  /// **'Text me a code'**
  String get authSendCode;

  /// No description provided for @authContinueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get authContinueWithGoogle;

  /// No description provided for @authContinueWithApple.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get authContinueWithApple;

  /// No description provided for @authWithEmail.
  ///
  /// In en, this message translates to:
  /// **'Sign in with email'**
  String get authWithEmail;

  /// No description provided for @authErrorEnterPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number.'**
  String get authErrorEnterPhone;

  /// No description provided for @authErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t sign you in. Try again.'**
  String get authErrorGeneric;

  /// No description provided for @authVerifyTitle.
  ///
  /// In en, this message translates to:
  /// **'Check your texts'**
  String get authVerifyTitle;

  /// No description provided for @authVerifyInstructions.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code we sent to {phone}.'**
  String authVerifyInstructions(String phone);

  /// No description provided for @authVerifyButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get authVerifyButton;

  /// No description provided for @authVerifyErrorEnterCode.
  ///
  /// In en, this message translates to:
  /// **'Enter the code from the text message.'**
  String get authVerifyErrorEnterCode;

  /// No description provided for @authVerifyErrorInvalid.
  ///
  /// In en, this message translates to:
  /// **'That code didn\'t work. Check it, or go back to get a new one.'**
  String get authVerifyErrorInvalid;

  /// No description provided for @authEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with email'**
  String get authEmailTitle;

  /// No description provided for @authEmailIntro.
  ///
  /// In en, this message translates to:
  /// **'For accounts Nous Deux set up for you, for example to test the app.'**
  String get authEmailIntro;

  /// No description provided for @authEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get authEmailLabel;

  /// No description provided for @authPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPasswordLabel;

  /// No description provided for @authEmailButton.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authEmailButton;

  /// No description provided for @authEmailErrorEmpty.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address and password.'**
  String get authEmailErrorEmpty;

  /// No description provided for @authEmailErrorWrong.
  ///
  /// In en, this message translates to:
  /// **'Wrong email address or password.'**
  String get authEmailErrorWrong;

  /// No description provided for @calendarTitle.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendarTitle;

  /// No description provided for @calendarToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get calendarToday;

  /// No description provided for @calendarAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get calendarAdd;

  /// No description provided for @calendarPartner.
  ///
  /// In en, this message translates to:
  /// **'Partner'**
  String get calendarPartner;

  /// No description provided for @calendarMe.
  ///
  /// In en, this message translates to:
  /// **'Me'**
  String get calendarMe;

  /// No description provided for @calendarDeleteEventTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete event?'**
  String get calendarDeleteEventTitle;

  /// No description provided for @calendarDeleteEventConfirm.
  ///
  /// In en, this message translates to:
  /// **'\"{title}\" will be deleted for both of you.'**
  String calendarDeleteEventConfirm(String title);

  /// No description provided for @calendarCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get calendarCancel;

  /// No description provided for @calendarDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get calendarDelete;

  /// No description provided for @calendarNothingInMonth.
  ///
  /// In en, this message translates to:
  /// **'Nothing planned in {month}'**
  String calendarNothingInMonth(String month);

  /// No description provided for @calendarCreateEvent.
  ///
  /// In en, this message translates to:
  /// **'Add an event'**
  String get calendarCreateEvent;

  /// No description provided for @calendarPreviousMonth.
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get calendarPreviousMonth;

  /// No description provided for @calendarNextMonth.
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get calendarNextMonth;

  /// No description provided for @calendarImportAllowAccess.
  ///
  /// In en, this message translates to:
  /// **'Allow calendar access'**
  String get calendarImportAllowAccess;

  /// No description provided for @calendarImportOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get calendarImportOpenSettings;

  /// No description provided for @calendarEventEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit event'**
  String get calendarEventEdit;

  /// No description provided for @calendarEventNew.
  ///
  /// In en, this message translates to:
  /// **'New event'**
  String get calendarEventNew;

  /// No description provided for @calendarEventTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get calendarEventTitleLabel;

  /// No description provided for @calendarEventTitleRequired.
  ///
  /// In en, this message translates to:
  /// **'Add a title.'**
  String get calendarEventTitleRequired;

  /// No description provided for @calendarEventDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get calendarEventDescriptionLabel;

  /// No description provided for @calendarEventStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get calendarEventStart;

  /// No description provided for @calendarEventEnd.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get calendarEventEnd;

  /// No description provided for @calendarEventSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get calendarEventSave;

  /// No description provided for @calendarEventCountdown.
  ///
  /// In en, this message translates to:
  /// **'Countdown'**
  String get calendarEventCountdown;

  /// No description provided for @calendarEventCountdownHint.
  ///
  /// In en, this message translates to:
  /// **'Shown on the Nous tab until the day comes.'**
  String get calendarEventCountdownHint;

  /// No description provided for @calendarEventEndBeforeStart.
  ///
  /// In en, this message translates to:
  /// **'The end has to come after the start.'**
  String get calendarEventEndBeforeStart;

  /// No description provided for @calendarFollowLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone calendar'**
  String get calendarFollowLabel;

  /// No description provided for @calendarFollowTitle.
  ///
  /// In en, this message translates to:
  /// **'Calendars you follow'**
  String get calendarFollowTitle;

  /// No description provided for @calendarFollowIntro.
  ///
  /// In en, this message translates to:
  /// **'Their titles and times are copied into Nous Deux and kept up to date: {partnerName} sees them. Nothing else leaves your phone.'**
  String calendarFollowIntro(String partnerName);

  /// No description provided for @calendarFollowTip.
  ///
  /// In en, this message translates to:
  /// **'Simplest: an “Us” calendar on your phone, for what concerns you both. The rest of your calendar stays yours.'**
  String get calendarFollowTip;

  /// No description provided for @calendarFollowLastSync.
  ///
  /// In en, this message translates to:
  /// **'Last updated'**
  String get calendarFollowLastSync;

  /// No description provided for @calendarFollowFootnote.
  ///
  /// In en, this message translates to:
  /// **'From last month to six months ahead. Events are changed in your calendar; unfollowing a calendar removes its copies from that period, turning them all off removes every copy.'**
  String get calendarFollowFootnote;

  /// No description provided for @calendarFollowOtherPhone.
  ///
  /// In en, this message translates to:
  /// **'Your calendars are followed from another phone. Following one here takes over.'**
  String get calendarFollowOtherPhone;

  /// No description provided for @calendarFollowGone.
  ///
  /// In en, this message translates to:
  /// **'A followed calendar is no longer on this phone, so nothing is updated.'**
  String get calendarFollowGone;

  /// No description provided for @calendarFollowDropGone.
  ///
  /// In en, this message translates to:
  /// **'Stop following it'**
  String get calendarFollowDropGone;

  /// No description provided for @calendarFollowFailed.
  ///
  /// In en, this message translates to:
  /// **'The update didn\'t go through. Try again later.'**
  String get calendarFollowFailed;

  /// No description provided for @calendarFollowNone.
  ///
  /// In en, this message translates to:
  /// **'No calendar on this phone.'**
  String get calendarFollowNone;

  /// No description provided for @calendarFollowPermission.
  ///
  /// In en, this message translates to:
  /// **'Nous Deux needs access to your calendars to follow them. If no prompt appears, allow access in Settings.'**
  String get calendarFollowPermission;

  /// No description provided for @calendarAllDay.
  ///
  /// In en, this message translates to:
  /// **'All day'**
  String get calendarAllDay;

  /// No description provided for @cycleAskTitle.
  ///
  /// In en, this message translates to:
  /// **'Do you track your cycle in the app?'**
  String get cycleAskTitle;

  /// No description provided for @cycleAskBody.
  ///
  /// In en, this message translates to:
  /// **'If you do, this tab becomes your tracker. If not, it shows your partner\'s cycle when they share it.'**
  String get cycleAskBody;

  /// No description provided for @cycleConsent.
  ///
  /// In en, this message translates to:
  /// **'By tracking your cycle, you agree that the app stores your period dates, how you feel each day and your notes on our servers in Germany. This is health data. Your partner sees your dates and how you feel while you share them; your notes stay private. You can stop and delete everything at any time in Settings.'**
  String get cycleConsent;

  /// No description provided for @cycleConsentTitle.
  ///
  /// In en, this message translates to:
  /// **'Track your cycle in the app?'**
  String get cycleConsentTitle;

  /// No description provided for @cycleConsentAccept.
  ///
  /// In en, this message translates to:
  /// **'I agree'**
  String get cycleConsentAccept;

  /// No description provided for @cyclePrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get cyclePrivacyPolicy;

  /// No description provided for @cycleStopTitle.
  ///
  /// In en, this message translates to:
  /// **'Stop tracking your cycle?'**
  String get cycleStopTitle;

  /// No description provided for @cycleStopBody.
  ///
  /// In en, this message translates to:
  /// **'You can keep your cycle data in case you start again, or delete it now: dates, check-ins and notes. Deleting can\'t be undone.'**
  String get cycleStopBody;

  /// No description provided for @cycleStopKeep.
  ///
  /// In en, this message translates to:
  /// **'Keep my data'**
  String get cycleStopKeep;

  /// No description provided for @cycleStopDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete everything'**
  String get cycleStopDelete;

  /// No description provided for @cycleDataDeleted.
  ///
  /// In en, this message translates to:
  /// **'Your cycle data is deleted.'**
  String get cycleDataDeleted;

  /// No description provided for @cycleAskYes.
  ///
  /// In en, this message translates to:
  /// **'Yes, I do'**
  String get cycleAskYes;

  /// No description provided for @cycleAskNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get cycleAskNo;

  /// No description provided for @settingsTracksCycle.
  ///
  /// In en, this message translates to:
  /// **'I track my cycle in the app'**
  String get settingsTracksCycle;

  /// No description provided for @cycleDayWord.
  ///
  /// In en, this message translates to:
  /// **'day'**
  String get cycleDayWord;

  /// No description provided for @cycleOfAbout.
  ///
  /// In en, this message translates to:
  /// **'of ~{length}'**
  String cycleOfAbout(int length);

  /// No description provided for @cycleRingLabel.
  ///
  /// In en, this message translates to:
  /// **'Cycle of about {length} days, today day {day}'**
  String cycleRingLabel(int day, int length);

  /// No description provided for @cycleNoDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Log your next period'**
  String get cycleNoDataTitle;

  /// No description provided for @cycleNoDataBody.
  ///
  /// In en, this message translates to:
  /// **'The app learns your rhythm cycle after cycle.'**
  String get cycleNoDataBody;

  /// No description provided for @cycleStarted.
  ///
  /// In en, this message translates to:
  /// **'My period started'**
  String get cycleStarted;

  /// No description provided for @cycleEnded.
  ///
  /// In en, this message translates to:
  /// **'My period ended'**
  String get cycleEnded;

  /// No description provided for @cycleOtherDay.
  ///
  /// In en, this message translates to:
  /// **'It was another day'**
  String get cycleOtherDay;

  /// No description provided for @cycleToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get cycleToday;

  /// No description provided for @cycleSeenBy.
  ///
  /// In en, this message translates to:
  /// **'{name} can see this'**
  String cycleSeenBy(String name);

  /// No description provided for @cycleSeenByNobody.
  ///
  /// In en, this message translates to:
  /// **'Not shared'**
  String get cycleSeenByNobody;

  /// No description provided for @cycleNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'A note for you'**
  String get cycleNoteLabel;

  /// No description provided for @cycleNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Only for you, never shared'**
  String get cycleNoteHint;

  /// No description provided for @cycleNoteSaved.
  ///
  /// In en, this message translates to:
  /// **'Note saved.'**
  String get cycleNoteSaved;

  /// No description provided for @cycleThisWeek.
  ///
  /// In en, this message translates to:
  /// **'Good to know this week'**
  String get cycleThisWeek;

  /// No description provided for @cycleReadChapter.
  ///
  /// In en, this message translates to:
  /// **'Read: {title}'**
  String cycleReadChapter(String title);

  /// No description provided for @cycleHistoryLink.
  ///
  /// In en, this message translates to:
  /// **'Your cycles'**
  String get cycleHistoryLink;

  /// No description provided for @cycleSharingLink.
  ///
  /// In en, this message translates to:
  /// **'What {name} sees'**
  String cycleSharingLink(String name);

  /// No description provided for @cyclePartnerLink.
  ///
  /// In en, this message translates to:
  /// **'{name}\'s cycle'**
  String cyclePartnerLink(String name);

  /// No description provided for @cycleUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get cycleUndo;

  /// No description provided for @cycleOtherState.
  ///
  /// In en, this message translates to:
  /// **'+ Other'**
  String get cycleOtherState;

  /// No description provided for @cycleNewStateHint.
  ///
  /// In en, this message translates to:
  /// **'How you feel'**
  String get cycleNewStateHint;

  /// No description provided for @cycleAddState.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get cycleAddState;

  /// No description provided for @cycleOwnStateHint.
  ///
  /// In en, this message translates to:
  /// **'remove from your list'**
  String get cycleOwnStateHint;

  /// No description provided for @cycleStateRemoved.
  ///
  /// In en, this message translates to:
  /// **'\"{state}\" won\'t be offered any more.'**
  String cycleStateRemoved(String state);

  /// No description provided for @cycleTooManyStates.
  ///
  /// In en, this message translates to:
  /// **'Twelve at most a day.'**
  String get cycleTooManyStates;

  /// No description provided for @cycleSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'That wasn\'t saved. Try again.'**
  String get cycleSaveFailed;

  /// No description provided for @cycleNeedsCouple.
  ///
  /// In en, this message translates to:
  /// **'Tracking is saved in your couple: invite your partner first.'**
  String get cycleNeedsCouple;

  /// No description provided for @cycleSheetStarted.
  ///
  /// In en, this message translates to:
  /// **'Period started'**
  String get cycleSheetStarted;

  /// No description provided for @cycleSheetEnded.
  ///
  /// In en, this message translates to:
  /// **'Period ended'**
  String get cycleSheetEnded;

  /// No description provided for @cycleSheetWhen.
  ///
  /// In en, this message translates to:
  /// **'When?'**
  String get cycleSheetWhen;

  /// No description provided for @cycleYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get cycleYesterday;

  /// No description provided for @cycleAnotherDay.
  ///
  /// In en, this message translates to:
  /// **'Another day…'**
  String get cycleAnotherDay;

  /// No description provided for @cycleSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get cycleSave;

  /// No description provided for @cycleSheetFootnote.
  ///
  /// In en, this message translates to:
  /// **'When it stops, the button becomes \"My period ended\".'**
  String get cycleSheetFootnote;

  /// No description provided for @cycleHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Your cycles'**
  String get cycleHistoryTitle;

  /// No description provided for @cycleAverage.
  ///
  /// In en, this message translates to:
  /// **'Average cycle'**
  String get cycleAverage;

  /// No description provided for @cyclePeriod.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get cyclePeriod;

  /// No description provided for @cycleDaysWord.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get cycleDaysWord;

  /// No description provided for @cycleNeedTwo.
  ///
  /// In en, this message translates to:
  /// **'Two full cycles are needed for an average; until then the app counts 28 days.'**
  String get cycleNeedTwo;

  /// No description provided for @cycleCurrentRow.
  ///
  /// In en, this message translates to:
  /// **'now · day {day}'**
  String cycleCurrentRow(int day);

  /// No description provided for @cycleRestOfCycle.
  ///
  /// In en, this message translates to:
  /// **'Rest of the cycle'**
  String get cycleRestOfCycle;

  /// No description provided for @cycleHistoryHint.
  ///
  /// In en, this message translates to:
  /// **'Tap a cycle to fix it, long-press to delete it.'**
  String get cycleHistoryHint;

  /// No description provided for @cycleHistoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your cycles will appear here month after month.'**
  String get cycleHistoryEmpty;

  /// No description provided for @cyclePartnerLabel.
  ///
  /// In en, this message translates to:
  /// **'Period · {name}'**
  String cyclePartnerLabel(String name);

  /// No description provided for @cyclePartnerNotShared.
  ///
  /// In en, this message translates to:
  /// **'{name} isn\'t sharing their cycle right now.'**
  String cyclePartnerNotShared(String name);

  /// No description provided for @cyclePartnerNothingYet.
  ///
  /// In en, this message translates to:
  /// **'{name} hasn\'t logged anything yet.'**
  String cyclePartnerNothingYet(String name);

  /// No description provided for @cyclePartnerNotTracking.
  ///
  /// In en, this message translates to:
  /// **'{name} doesn\'t track a cycle in the app.'**
  String cyclePartnerNotTracking(String name);

  /// No description provided for @cycleNoPartner.
  ///
  /// In en, this message translates to:
  /// **'Here you\'ll follow your partner\'s cycle, if they share it, with ideas for being there at the right time.'**
  String get cycleNoPartner;

  /// No description provided for @cycleWhatHelps.
  ///
  /// In en, this message translates to:
  /// **'What tends to help this week'**
  String get cycleWhatHelps;

  /// No description provided for @cyclePartnerNoted.
  ///
  /// In en, this message translates to:
  /// **'{name} noted today'**
  String cyclePartnerNoted(String name);

  /// No description provided for @cycleLittleNote.
  ///
  /// In en, this message translates to:
  /// **'A little note?'**
  String get cycleLittleNote;

  /// No description provided for @cycleRemindMe.
  ///
  /// In en, this message translates to:
  /// **'Remind me the day before'**
  String get cycleRemindMe;

  /// No description provided for @cycleRemindNoDate.
  ///
  /// In en, this message translates to:
  /// **'As soon as a date is expected'**
  String get cycleRemindNoDate;

  /// No description provided for @cycleSharingTitle.
  ///
  /// In en, this message translates to:
  /// **'What {name} sees'**
  String cycleSharingTitle(String name);

  /// No description provided for @cycleSharingIntro.
  ///
  /// In en, this message translates to:
  /// **'You choose what your partner sees. It changes on their phone right away.'**
  String get cycleSharingIntro;

  /// No description provided for @cycleShareCycle.
  ///
  /// In en, this message translates to:
  /// **'My cycle'**
  String get cycleShareCycle;

  /// No description provided for @cycleShareCycleHint.
  ///
  /// In en, this message translates to:
  /// **'Day, phase, expected date and the reminder'**
  String get cycleShareCycleHint;

  /// No description provided for @cycleShareCheckins.
  ///
  /// In en, this message translates to:
  /// **'How I feel each day'**
  String get cycleShareCheckins;

  /// No description provided for @cycleShareCheckinsHint.
  ///
  /// In en, this message translates to:
  /// **'What you check each day'**
  String get cycleShareCheckinsHint;

  /// No description provided for @cycleNotesRow.
  ///
  /// In en, this message translates to:
  /// **'Your notes'**
  String get cycleNotesRow;

  /// No description provided for @cycleNotesAlwaysPrivate.
  ///
  /// In en, this message translates to:
  /// **'Always private'**
  String get cycleNotesAlwaysPrivate;

  /// No description provided for @cycleStopSharing.
  ///
  /// In en, this message translates to:
  /// **'Stop sharing everything'**
  String get cycleStopSharing;

  /// No description provided for @guideLabel.
  ///
  /// In en, this message translates to:
  /// **'Guide'**
  String get guideLabel;

  /// No description provided for @guideTitle.
  ///
  /// In en, this message translates to:
  /// **'Understanding the cycle'**
  String get guideTitle;

  /// No description provided for @guideForYouNow.
  ///
  /// In en, this message translates to:
  /// **'For you now · day {day}'**
  String guideForYouNow(int day);

  /// No description provided for @guideForPartnerNow.
  ///
  /// In en, this message translates to:
  /// **'For {name} now · day {day}'**
  String guideForPartnerNow(String name, int day);

  /// No description provided for @guideChapter.
  ///
  /// In en, this message translates to:
  /// **'Chapter {n}'**
  String guideChapter(int n);

  /// No description provided for @guideRead.
  ///
  /// In en, this message translates to:
  /// **'read'**
  String get guideRead;

  /// No description provided for @guideFootnote.
  ///
  /// In en, this message translates to:
  /// **'Based on public health sources. Not medical advice.'**
  String get guideFootnote;

  /// No description provided for @guideContents.
  ///
  /// In en, this message translates to:
  /// **'Contents'**
  String get guideContents;

  /// No description provided for @guideNext.
  ///
  /// In en, this message translates to:
  /// **'Next: {title}'**
  String guideNext(String title);

  /// No description provided for @guideSearch.
  ///
  /// In en, this message translates to:
  /// **'Search the guide'**
  String get guideSearch;

  /// No description provided for @guideNoMatch.
  ///
  /// In en, this message translates to:
  /// **'No chapter mentions \"{query}\".'**
  String guideNoMatch(String query);

  /// No description provided for @guideBody.
  ///
  /// In en, this message translates to:
  /// **'In the body'**
  String get guideBody;

  /// No description provided for @guideMood.
  ///
  /// In en, this message translates to:
  /// **'Mood'**
  String get guideMood;

  /// No description provided for @guideWhatHelps.
  ///
  /// In en, this message translates to:
  /// **'What helps'**
  String get guideWhatHelps;

  /// No description provided for @guideYouAreHere.
  ///
  /// In en, this message translates to:
  /// **'you are here'**
  String get guideYouAreHere;

  /// No description provided for @guidePartnerIsHere.
  ///
  /// In en, this message translates to:
  /// **'{name} is here'**
  String guidePartnerIsHere(String name);

  /// No description provided for @guideSources.
  ///
  /// In en, this message translates to:
  /// **'Sources'**
  String get guideSources;

  /// No description provided for @guideDaysShort.
  ///
  /// In en, this message translates to:
  /// **'days {range}'**
  String guideDaysShort(String range);

  /// No description provided for @listsTitle.
  ///
  /// In en, this message translates to:
  /// **'Lists'**
  String get listsTitle;

  /// No description provided for @listsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Shared with {partnerName}, live.'**
  String listsSubtitle(String partnerName);

  /// No description provided for @listsSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get listsSeeAll;

  /// No description provided for @listsNew.
  ///
  /// In en, this message translates to:
  /// **'New list'**
  String get listsNew;

  /// No description provided for @listsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No lists yet'**
  String get listsEmptyTitle;

  /// No description provided for @listsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Groceries, to-dos, weekend ideas: whatever you add shows up on your partner\'s phone too.'**
  String get listsEmptyBody;

  /// No description provided for @listsNameLabel.
  ///
  /// In en, this message translates to:
  /// **'List name'**
  String get listsNameLabel;

  /// No description provided for @listsNameHint.
  ///
  /// In en, this message translates to:
  /// **'Groceries'**
  String get listsNameHint;

  /// No description provided for @listsIconLabel.
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get listsIconLabel;

  /// No description provided for @listsCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get listsCreate;

  /// No description provided for @listsRename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get listsRename;

  /// No description provided for @listsDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete list'**
  String get listsDelete;

  /// No description provided for @listsDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" and all its items will be deleted for both of you.'**
  String listsDeleteConfirm(String name);

  /// No description provided for @listsCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get listsCancel;

  /// No description provided for @listsSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get listsSave;

  /// No description provided for @listsOptions.
  ///
  /// In en, this message translates to:
  /// **'List options'**
  String get listsOptions;

  /// No description provided for @listsBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get listsBack;

  /// No description provided for @listsAddLabel.
  ///
  /// In en, this message translates to:
  /// **'Add an item'**
  String get listsAddLabel;

  /// No description provided for @listsAddHint.
  ///
  /// In en, this message translates to:
  /// **'Oat milk, bread…'**
  String get listsAddHint;

  /// No description provided for @listsAddButton.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get listsAddButton;

  /// No description provided for @listsChecked.
  ///
  /// In en, this message translates to:
  /// **'Ticked ({n})'**
  String listsChecked(int n);

  /// No description provided for @listsClearChecked.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get listsClearChecked;

  /// No description provided for @listsAddedByMe.
  ///
  /// In en, this message translates to:
  /// **'Added by you'**
  String get listsAddedByMe;

  /// No description provided for @listsAddedBy.
  ///
  /// In en, this message translates to:
  /// **'Added by {name}'**
  String listsAddedBy(String name);

  /// No description provided for @listsItemDeleted.
  ///
  /// In en, this message translates to:
  /// **'\"{text}\" deleted.'**
  String listsItemDeleted(String text);

  /// No description provided for @listsUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get listsUndo;

  /// No description provided for @listsDeleteItem.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get listsDeleteItem;

  /// No description provided for @listsGoneTitle.
  ///
  /// In en, this message translates to:
  /// **'This list is gone'**
  String get listsGoneTitle;

  /// No description provided for @listsGoneBody.
  ///
  /// In en, this message translates to:
  /// **'It was probably deleted on the other phone.'**
  String get listsGoneBody;

  /// No description provided for @listsAll.
  ///
  /// In en, this message translates to:
  /// **'All lists'**
  String get listsAll;

  /// No description provided for @listsEmptyListBody.
  ///
  /// In en, this message translates to:
  /// **'Add the first item above.'**
  String get listsEmptyListBody;

  /// No description provided for @listsError.
  ///
  /// In en, this message translates to:
  /// **'That didn\'t work. Try again.'**
  String get listsError;

  /// No description provided for @nousTitle.
  ///
  /// In en, this message translates to:
  /// **'Us'**
  String get nousTitle;

  /// No description provided for @nousSettingsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get nousSettingsTooltip;

  /// No description provided for @nousTogetherSince.
  ///
  /// In en, this message translates to:
  /// **'Together for'**
  String get nousTogetherSince;

  /// No description provided for @nousEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get nousEdit;

  /// No description provided for @nousPickStartHelp.
  ///
  /// In en, this message translates to:
  /// **'The day it all started'**
  String get nousPickStartHelp;

  /// No description provided for @nousStartSaved.
  ///
  /// In en, this message translates to:
  /// **'Date updated.'**
  String get nousStartSaved;

  /// No description provided for @nousSendNote.
  ///
  /// In en, this message translates to:
  /// **'Send a little note'**
  String get nousSendNote;

  /// No description provided for @nousNoteCooldown.
  ///
  /// In en, this message translates to:
  /// **'One little note every 30 seconds at most. Try again in a moment.'**
  String get nousNoteCooldown;

  /// No description provided for @nousNoteFailed.
  ///
  /// In en, this message translates to:
  /// **'The note didn\'t go through. Try again.'**
  String get nousNoteFailed;

  /// No description provided for @pingWriteBack.
  ///
  /// In en, this message translates to:
  /// **'Reply with a note'**
  String get pingWriteBack;

  /// No description provided for @nousWrite.
  ///
  /// In en, this message translates to:
  /// **'Write…'**
  String get nousWrite;

  /// No description provided for @nousMyWords.
  ///
  /// In en, this message translates to:
  /// **'My notes'**
  String get nousMyWords;

  /// No description provided for @nousWriteTo.
  ///
  /// In en, this message translates to:
  /// **'A little note for {name}'**
  String nousWriteTo(String name);

  /// No description provided for @nousWriteHint.
  ///
  /// In en, this message translates to:
  /// **'Your little note'**
  String get nousWriteHint;

  /// No description provided for @nousWriteReplaces.
  ///
  /// In en, this message translates to:
  /// **'It replaces your last note, like the others.'**
  String get nousWriteReplaces;

  /// No description provided for @nousKeepWord.
  ///
  /// In en, this message translates to:
  /// **'Keep it in my notes'**
  String get nousKeepWord;

  /// No description provided for @nousSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get nousSend;

  /// No description provided for @myWordsTitle.
  ///
  /// In en, this message translates to:
  /// **'My little notes'**
  String get myWordsTitle;

  /// No description provided for @myWordsHelp.
  ///
  /// In en, this message translates to:
  /// **'The ticked ones show on Nous, in this order. Six at most.'**
  String get myWordsHelp;

  /// No description provided for @myWordsAddHint.
  ///
  /// In en, this message translates to:
  /// **'Add a note…'**
  String get myWordsAddHint;

  /// No description provided for @myWordsAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get myWordsAdd;

  /// No description provided for @myWordsRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove \"{word}\"'**
  String myWordsRemove(String word);

  /// No description provided for @myWordsMove.
  ///
  /// In en, this message translates to:
  /// **'Move \"{word}\"'**
  String myWordsMove(String word);

  /// No description provided for @myWordsFull.
  ///
  /// In en, this message translates to:
  /// **'Six notes at most on Nous. Untick one first.'**
  String get myWordsFull;

  /// No description provided for @myWordsAlready.
  ///
  /// In en, this message translates to:
  /// **'That note is already there.'**
  String get myWordsAlready;

  /// No description provided for @myWordsDrag.
  ///
  /// In en, this message translates to:
  /// **'Drag the handle on the right to change the order.'**
  String get myWordsDrag;

  /// No description provided for @pingJustNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get pingJustNow;

  /// No description provided for @pingReplyMeToo.
  ///
  /// In en, this message translates to:
  /// **'Me too'**
  String get pingReplyMeToo;

  /// No description provided for @pingTapToClose.
  ///
  /// In en, this message translates to:
  /// **'Tap to close'**
  String get pingTapToClose;

  /// No description provided for @nousPartnerFallback.
  ///
  /// In en, this message translates to:
  /// **'Your partner'**
  String get nousPartnerFallback;

  /// No description provided for @nousNextPlan.
  ///
  /// In en, this message translates to:
  /// **'Next plan'**
  String get nousNextPlan;

  /// No description provided for @nousNoCountdown.
  ///
  /// In en, this message translates to:
  /// **'Nothing planned'**
  String get nousNoCountdown;

  /// No description provided for @nousNoCountdownHint.
  ///
  /// In en, this message translates to:
  /// **'Turn on Countdown for an event.'**
  String get nousNoCountdownHint;

  /// No description provided for @nousAnniversary.
  ///
  /// In en, this message translates to:
  /// **'Anniversary'**
  String get nousAnniversary;

  /// No description provided for @nousNoPartnerTitle.
  ///
  /// In en, this message translates to:
  /// **'Invite your partner'**
  String get nousNoPartnerTitle;

  /// No description provided for @nousNoPartnerBody.
  ///
  /// In en, this message translates to:
  /// **'The counter starts on the day there are two of you.'**
  String get nousNoPartnerBody;

  /// No description provided for @nousInvite.
  ///
  /// In en, this message translates to:
  /// **'Invite'**
  String get nousInvite;

  /// No description provided for @onboardingTitle.
  ///
  /// In en, this message translates to:
  /// **'Introduce yourself'**
  String get onboardingTitle;

  /// No description provided for @onboardingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your partner will see this name. You can change it later in Settings.'**
  String get onboardingSubtitle;

  /// No description provided for @onboardingDisplayNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name or nickname'**
  String get onboardingDisplayNameLabel;

  /// No description provided for @onboardingDisplayNameHint.
  ///
  /// In en, this message translates to:
  /// **'Alex'**
  String get onboardingDisplayNameHint;

  /// No description provided for @onboardingLanguageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get onboardingLanguageLabel;

  /// No description provided for @onboardingContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get onboardingContinue;

  /// No description provided for @onboardingErrorDisplayName.
  ///
  /// In en, this message translates to:
  /// **'Add the name your partner will see.'**
  String get onboardingErrorDisplayName;

  /// No description provided for @onboardingErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save that. Try again.'**
  String get onboardingErrorGeneric;

  /// No description provided for @pairingInviteTitle.
  ///
  /// In en, this message translates to:
  /// **'Invite your partner'**
  String get pairingInviteTitle;

  /// No description provided for @pairingIntro.
  ///
  /// In en, this message translates to:
  /// **'Generate a code and show it to your partner. They can scan the QR code or type the 6 characters.'**
  String get pairingIntro;

  /// No description provided for @pairingGenerateCode.
  ///
  /// In en, this message translates to:
  /// **'Generate a code'**
  String get pairingGenerateCode;

  /// No description provided for @pairingScanQrPrompt.
  ///
  /// In en, this message translates to:
  /// **'Scan this with your partner\'s phone:'**
  String get pairingScanQrPrompt;

  /// No description provided for @pairingOrEnterCode.
  ///
  /// In en, this message translates to:
  /// **'Or type this code:'**
  String get pairingOrEnterCode;

  /// No description provided for @pairingAlreadyHaveCode.
  ///
  /// In en, this message translates to:
  /// **'Already invited by your partner?'**
  String get pairingAlreadyHaveCode;

  /// No description provided for @pairingJoinWithCode.
  ///
  /// In en, this message translates to:
  /// **'I have a code'**
  String get pairingJoinWithCode;

  /// No description provided for @pairingScanQr.
  ///
  /// In en, this message translates to:
  /// **'Scan a QR code'**
  String get pairingScanQr;

  /// No description provided for @pairingAlreadyPaired.
  ///
  /// In en, this message translates to:
  /// **'You\'re already paired. Taking you back…'**
  String get pairingAlreadyPaired;

  /// No description provided for @pairingError.
  ///
  /// In en, this message translates to:
  /// **'That didn\'t work. Try again.'**
  String get pairingError;

  /// No description provided for @pairingJoinTitle.
  ///
  /// In en, this message translates to:
  /// **'Join your partner'**
  String get pairingJoinTitle;

  /// No description provided for @pairingJoinInstructions.
  ///
  /// In en, this message translates to:
  /// **'Type the 6-character code shown on your partner\'s phone.'**
  String get pairingJoinInstructions;

  /// No description provided for @pairingJoinCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get pairingJoinCodeLabel;

  /// No description provided for @pairingJoinButton.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get pairingJoinButton;

  /// No description provided for @pairingJoinErrorCode.
  ///
  /// In en, this message translates to:
  /// **'Type your partner\'s code.'**
  String get pairingJoinErrorCode;

  /// No description provided for @pairingJoinErrorUsed.
  ///
  /// In en, this message translates to:
  /// **'This code has already been used. Ask your partner for a new one.'**
  String get pairingJoinErrorUsed;

  /// No description provided for @pairingJoinErrorOwnCode.
  ///
  /// In en, this message translates to:
  /// **'That\'s your own code. Your partner needs to enter it.'**
  String get pairingJoinErrorOwnCode;

  /// No description provided for @pairingJoinErrorInvalid.
  ///
  /// In en, this message translates to:
  /// **'That code doesn\'t match an invite. Check it with your partner.'**
  String get pairingJoinErrorInvalid;

  /// No description provided for @pairingJoinErrorAlreadyPaired.
  ///
  /// In en, this message translates to:
  /// **'You\'re already in a couple in the app. Leave it in Settings before joining another.'**
  String get pairingJoinErrorAlreadyPaired;

  /// No description provided for @pairingJoinErrorTooManyAttempts.
  ///
  /// In en, this message translates to:
  /// **'Too many wrong codes. Try again in 10 minutes.'**
  String get pairingJoinErrorTooManyAttempts;

  /// No description provided for @pairingScanTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan the QR code'**
  String get pairingScanTitle;

  /// No description provided for @pairingScanConnecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting…'**
  String get pairingScanConnecting;

  /// No description provided for @periodLearnMore.
  ///
  /// In en, this message translates to:
  /// **'Learn more'**
  String get periodLearnMore;

  /// No description provided for @periodCouldNotOpenLink.
  ///
  /// In en, this message translates to:
  /// **'Could not open link'**
  String get periodCouldNotOpenLink;

  /// No description provided for @mainNavCalendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get mainNavCalendar;

  /// No description provided for @mainNavPeriod.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get mainNavPeriod;

  /// No description provided for @mainNavPosition.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get mainNavPosition;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsAboutApp.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAboutApp;

  /// No description provided for @settingsUsername.
  ///
  /// In en, this message translates to:
  /// **'Name or nickname'**
  String get settingsUsername;

  /// No description provided for @settingsProfilePhoto.
  ///
  /// In en, this message translates to:
  /// **'Profile photo'**
  String get settingsProfilePhoto;

  /// No description provided for @settingsChangePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change photo'**
  String get settingsChangePhoto;

  /// No description provided for @settingsPermissions.
  ///
  /// In en, this message translates to:
  /// **'Permissions'**
  String get settingsPermissions;

  /// No description provided for @settingsOpenAppSettings.
  ///
  /// In en, this message translates to:
  /// **'Open app settings'**
  String get settingsOpenAppSettings;

  /// No description provided for @settingsNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// No description provided for @settingsPeriodReminder.
  ///
  /// In en, this message translates to:
  /// **'Remind me the day before my partner\'s period'**
  String get settingsPeriodReminder;

  /// No description provided for @settingsCalendarReminders.
  ///
  /// In en, this message translates to:
  /// **'Calendar reminders'**
  String get settingsCalendarReminders;

  /// No description provided for @settingsCalendarRemindersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get settingsCalendarRemindersSubtitle;

  /// No description provided for @settingsPermissionGranted.
  ///
  /// In en, this message translates to:
  /// **'Granted'**
  String get settingsPermissionGranted;

  /// No description provided for @settingsPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Denied'**
  String get settingsPermissionDenied;

  /// No description provided for @settingsPermissionRestricted.
  ///
  /// In en, this message translates to:
  /// **'Restricted'**
  String get settingsPermissionRestricted;

  /// No description provided for @settingsPermissionPermanentDenied.
  ///
  /// In en, this message translates to:
  /// **'Blocked'**
  String get settingsPermissionPermanentDenied;

  /// No description provided for @settingsCalendars.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get settingsCalendars;

  /// No description provided for @settingsNotificationsPerm.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotificationsPerm;

  /// No description provided for @settingsLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get settingsLocation;

  /// No description provided for @settingsPermissionsReloadTooltip.
  ///
  /// In en, this message translates to:
  /// **'Refresh permissions'**
  String get settingsPermissionsReloadTooltip;

  /// No description provided for @settingsPermissionsReloadDone.
  ///
  /// In en, this message translates to:
  /// **'Permissions updated'**
  String get settingsPermissionsReloadDone;

  /// No description provided for @settingsShareMyLocation.
  ///
  /// In en, this message translates to:
  /// **'Share my location'**
  String get settingsShareMyLocation;

  /// No description provided for @settingsShareMyLocationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your partner sees where you are on the map. No history is kept.'**
  String get settingsShareMyLocationSubtitle;

  /// No description provided for @settingsLocationRequiredForSharing.
  ///
  /// In en, this message translates to:
  /// **'Allow location access to share where you are.'**
  String get settingsLocationRequiredForSharing;

  /// No description provided for @settingsCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get settingsCamera;

  /// No description provided for @settingsCoupleGroup.
  ///
  /// In en, this message translates to:
  /// **'Couple'**
  String get settingsCoupleGroup;

  /// No description provided for @settingsLeaveCouple.
  ///
  /// In en, this message translates to:
  /// **'Leave couple'**
  String get settingsLeaveCouple;

  /// No description provided for @settingsLeaveCoupleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Unlinks you from your partner and deletes what you share: calendar, cycle, location, lists and little notes.'**
  String get settingsLeaveCoupleSubtitle;

  /// No description provided for @settingsLeaveCoupleConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave the couple?'**
  String get settingsLeaveCoupleConfirmTitle;

  /// No description provided for @settingsLeaveCoupleConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Your calendar, cycle, location, lists and little notes will be deleted for both of you. This can\'t be undone.'**
  String get settingsLeaveCoupleConfirmMessage;

  /// No description provided for @settingsLeaveCoupleConfirm.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get settingsLeaveCoupleConfirm;

  /// No description provided for @settingsLeaveCoupleSuccess.
  ///
  /// In en, this message translates to:
  /// **'You\'ve left the couple.'**
  String get settingsLeaveCoupleSuccess;

  /// No description provided for @settingsAccountGroup.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settingsAccountGroup;

  /// No description provided for @settingsSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get settingsSignOut;

  /// No description provided for @settingsSignOutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out?'**
  String get settingsSignOutConfirmTitle;

  /// No description provided for @settingsSignOutConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Your couple and what you share stay as they are. Sign in with the same account to find them again.'**
  String get settingsSignOutConfirmMessage;

  /// No description provided for @settingsDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete my account'**
  String get settingsDeleteAccount;

  /// No description provided for @settingsDeleteAccountConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete your account?'**
  String get settingsDeleteAccountConfirmTitle;

  /// No description provided for @settingsDeleteAccountConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get settingsDeleteAccountConfirm;

  /// No description provided for @settingsDeleteAccountDone.
  ///
  /// In en, this message translates to:
  /// **'Your account has been deleted.'**
  String get settingsDeleteAccountDone;

  /// No description provided for @settingsDeleteAccountFailed.
  ///
  /// In en, this message translates to:
  /// **'Your account couldn\'t be deleted. Check your connection and try again.'**
  String get settingsDeleteAccountFailed;

  /// No description provided for @appInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'About the app'**
  String get appInfoTitle;

  /// No description provided for @appInfoDescription.
  ///
  /// In en, this message translates to:
  /// **'Nous Deux is a private app for couples: a shared calendar, cycle tracking and, if you want it, location sharing.'**
  String get appInfoDescription;

  /// No description provided for @appInfoFree.
  ///
  /// In en, this message translates to:
  /// **'The project is free and will stay free. There will never be ads.'**
  String get appInfoFree;

  /// No description provided for @appInfoSource.
  ///
  /// In en, this message translates to:
  /// **'Source code'**
  String get appInfoSource;

  /// No description provided for @appInfoContributors.
  ///
  /// In en, this message translates to:
  /// **'Contributors'**
  String get appInfoContributors;

  /// No description provided for @appInfoThomasMoser.
  ///
  /// In en, this message translates to:
  /// **'Development'**
  String get appInfoThomasMoser;

  /// No description provided for @appInfoEvahBaumlin.
  ///
  /// In en, this message translates to:
  /// **'Content, scientific explanations and a woman\'s perspective'**
  String get appInfoEvahBaumlin;

  /// No description provided for @appInfoFriends.
  ///
  /// In en, this message translates to:
  /// **'Support along the way'**
  String get appInfoFriends;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageUpdated.
  ///
  /// In en, this message translates to:
  /// **'Language updated'**
  String get settingsLanguageUpdated;

  /// No description provided for @settingsEditUsername.
  ///
  /// In en, this message translates to:
  /// **'Edit name'**
  String get settingsEditUsername;

  /// No description provided for @settingsSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get settingsSave;

  /// No description provided for @settingsCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get settingsCancel;

  /// No description provided for @timeAgoJustNow.
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get timeAgoJustNow;

  /// No description provided for @timeAgoMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min ago'**
  String timeAgoMinutes(int minutes);

  /// No description provided for @timeAgoHours.
  ///
  /// In en, this message translates to:
  /// **'{hours} h ago'**
  String timeAgoHours(int hours);

  /// {day} is a short date, like "Mar 1".
  ///
  /// In en, this message translates to:
  /// **'on {day}'**
  String timeAgoOnDay(String day);

  /// No description provided for @calendarSyncedFromMine.
  ///
  /// In en, this message translates to:
  /// **'From your calendar'**
  String get calendarSyncedFromMine;

  /// nameStart is "vowel" when the name starts with a vowel or h, for French elision.
  ///
  /// In en, this message translates to:
  /// **'{nameStart, select, other{From {name}\'s calendar}}'**
  String calendarSyncedFrom(String name, String nameStart);

  /// No description provided for @calendarSyncedReadOnlyMine.
  ///
  /// In en, this message translates to:
  /// **'This event follows your phone\'s calendar: change or delete it there.'**
  String get calendarSyncedReadOnlyMine;

  /// No description provided for @calendarSyncedReadOnly.
  ///
  /// In en, this message translates to:
  /// **'This event follows {name}\'s phone calendar: it is changed or deleted there.'**
  String calendarSyncedReadOnly(String name);

  /// No description provided for @cyclePartnerFallback.
  ///
  /// In en, this message translates to:
  /// **'Your partner'**
  String get cyclePartnerFallback;

  /// No description provided for @cyclePhaseLabel.
  ///
  /// In en, this message translates to:
  /// **'{phase, select, menstrual{Period} follicular{Follicular phase} ovulation{Ovulation} luteal{Luteal phase} other{}}'**
  String cyclePhaseLabel(String phase);

  /// No description provided for @cycleHeadlineOngoing.
  ///
  /// In en, this message translates to:
  /// **'Period, day {day}'**
  String cycleHeadlineOngoing(int day);

  /// No description provided for @cycleHeadlineIn.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =0{Period expected today} =1{Period expected tomorrow} other{Period in ~{days} days}}'**
  String cycleHeadlineIn(int days);

  /// No description provided for @cycleHeadlineLate.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, one{Period expected {days} day ago} other{Period expected {days} days ago}}'**
  String cycleHeadlineLate(int days);

  /// No description provided for @cycleBasis.
  ///
  /// In en, this message translates to:
  /// **'{cyclesUsed, plural, =0{around {date}, assuming 28 days until there is more to go on} =1{around {date}, based on your last cycle} other{around {date}, based on your last {cyclesUsed} cycles}}'**
  String cycleBasis(String date, int cyclesUsed);

  /// No description provided for @cycleLoggedStart.
  ///
  /// In en, this message translates to:
  /// **'Start logged: {date}'**
  String cycleLoggedStart(String date);

  /// No description provided for @cycleLoggedEnd.
  ///
  /// In en, this message translates to:
  /// **'End logged: {date}'**
  String cycleLoggedEnd(String date);

  /// No description provided for @cycleSelfTip.
  ///
  /// In en, this message translates to:
  /// **'{phase, select, menstrual{Heat, rest and water often help during your period. Pain that stops you from living normally is worth a doctor\'s opinion.} follicular{Energy often rises after your period: a good time for things that need drive.} ovulation{Around ovulation many feel at their best. Slight discomfort on one side of the belly can happen too.} luteal{Late in the cycle, lighter sleep and lower energy are common. Nothing unusual.} other{}}'**
  String cycleSelfTip(String phase);

  /// No description provided for @cycleRegularitySame.
  ///
  /// In en, this message translates to:
  /// **'Your last {count} cycles all lasted {days} days.'**
  String cycleRegularitySame(int count, int days);

  /// No description provided for @cycleRegularityRange.
  ///
  /// In en, this message translates to:
  /// **'Your last {count} cycles lasted {shortest} to {longest} days.'**
  String cycleRegularityRange(int count, int shortest, int longest);

  /// A past cycle's length in days, abbreviated.
  ///
  /// In en, this message translates to:
  /// **'{length} d'**
  String cycleSpanRow(int length);

  /// No description provided for @cycleSpanRowWithPeriod.
  ///
  /// In en, this message translates to:
  /// **'{length} d · period {periodDays} d'**
  String cycleSpanRowWithPeriod(int length, int periodDays);

  /// No description provided for @cyclePartnerHeadlineOngoing.
  ///
  /// In en, this message translates to:
  /// **'{name} has their period, day {day}'**
  String cyclePartnerHeadlineOngoing(String name, int day);

  /// No description provided for @cyclePartnerHeadlineDay.
  ///
  /// In en, this message translates to:
  /// **'{name} is on day {day}'**
  String cyclePartnerHeadlineDay(String name, int day);

  /// No description provided for @cyclePartnerNextLate.
  ///
  /// In en, this message translates to:
  /// **'The period was expected around {date}.'**
  String cyclePartnerNextLate(String date);

  /// No description provided for @cyclePartnerNext.
  ///
  /// In en, this message translates to:
  /// **'Next period around {date}.'**
  String cyclePartnerNext(String date);

  /// No description provided for @cycleRemindOn.
  ///
  /// In en, this message translates to:
  /// **'on the evening of {date}'**
  String cycleRemindOn(String date);

  /// No description provided for @cyclePartnerTip1.
  ///
  /// In en, this message translates to:
  /// **'{phase, select, menstrual{Offer a heat pack or a hot drink without waiting to be asked.} follicular{Energy often comes back: a good time for a plan together.} ovulation{Many feel at their best these days: enjoy it together.} luteal{Keep evenings calm if tiredness shows.} other{}}'**
  String cyclePartnerTip1(String phase);

  /// No description provided for @cyclePartnerTip2.
  ///
  /// In en, this message translates to:
  /// **'{phase, select, menstrual{Lighten the day: take on the shopping or dinner.} follicular{Suggest something you\'ve been putting off.} ovulation{A little lower-belly discomfort can happen; just ask how they feel.} luteal{Offer rather than ask: \"Shall I make dinner?\"} other{}}'**
  String cyclePartnerTip2(String phase);

  /// No description provided for @cyclePartnerTip3.
  ///
  /// In en, this message translates to:
  /// **'{phase, select, menstrual{Ask \"What do you need?\" rather than guess.} follicular{Follow their pace without pushing it.} ovulation{Keep listening: every cycle is different.} luteal{Don\'t put everything down to hormones: listen to what is said.} other{}}'**
  String cyclePartnerTip3(String phase);

  /// {phase} is a cycle phase name, like "Luteal phase".
  ///
  /// In en, this message translates to:
  /// **'{phase}: what happens, what helps'**
  String guideNowTitle(String phase);

  /// No description provided for @listsCountsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Empty'**
  String get listsCountsEmpty;

  /// No description provided for @listsCountsAllDone.
  ///
  /// In en, this message translates to:
  /// **'All done'**
  String get listsCountsAllDone;

  /// No description provided for @listsCounts.
  ///
  /// In en, this message translates to:
  /// **'{open} left of {total}'**
  String listsCounts(int open, int total);

  /// No description provided for @listsIconName.
  ///
  /// In en, this message translates to:
  /// **'{icon, select, list{List} cart{Shopping} star{Wishes} home{Home} gift{Gifts} other{}}'**
  String listsIconName(String icon);

  /// The unit after a number of days, without the number.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, one{day} other{days}}'**
  String nousDaysUnit(int days);

  /// No description provided for @nousSinceDate.
  ///
  /// In en, this message translates to:
  /// **'Since {date}'**
  String nousSinceDate(String date);

  /// A ready-made little note.
  ///
  /// In en, this message translates to:
  /// **'{kind, select, thinkingOfYou{Thinking of you} goodNight{Good night} onMyWay{On my way} missYou{Miss you} kiss{Kiss} other{}}'**
  String pingLabel(String kind);

  /// No description provided for @nousNoteSent.
  ///
  /// In en, this message translates to:
  /// **'Sent: {note}'**
  String nousNoteSent(String note);

  /// No description provided for @pingReceivedTitle.
  ///
  /// In en, this message translates to:
  /// **'{kind, select, thinkingOfYou{{name} is thinking of you.} goodNight{{name} says good night.} onMyWay{{name} is on the way.} missYou{{name} misses you.} kiss{{name} sends you a kiss.} other{}}'**
  String pingReceivedTitle(String kind, String name);

  /// French puts a non-breaking space before the colon.
  ///
  /// In en, this message translates to:
  /// **'{name}: {note}, {when}'**
  String nousReceivedLine(String name, String note, String when);

  /// No description provided for @nousInDays.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =0{today} =1{tomorrow} other{in {days} d}}'**
  String nousInDays(int days);

  /// No description provided for @nousYearsTogether.
  ///
  /// In en, this message translates to:
  /// **'{years, plural, one{{years} year together} other{{years} years together}}'**
  String nousYearsTogether(int years);

  /// No description provided for @settingsDeleteAccountConfirmPaired.
  ///
  /// In en, this message translates to:
  /// **'Your account, profile, photo and cycle notes will be deleted. You\'ll also leave the couple: your calendar, cycle, location, lists and little notes will be deleted for both of you. This can\'t be undone.'**
  String get settingsDeleteAccountConfirmPaired;

  /// No description provided for @settingsDeleteAccountConfirmSolo.
  ///
  /// In en, this message translates to:
  /// **'Your account, profile, photo and cycle notes will be deleted. This can\'t be undone.'**
  String get settingsDeleteAccountConfirmSolo;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
