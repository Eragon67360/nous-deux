// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get splashTagline => 'Where stories meet';

  @override
  String get mainNoPartnerBubble =>
      'Your partner isn\'t here yet. Send them an invite.';

  @override
  String get pairingCelebrationTitle => 'It\'s the two of you now.';

  @override
  String get pairingCelebrationBody =>
      'Your partner is in. Whatever you add here, you now share.';

  @override
  String get appSupabaseConfigMessage =>
      'Configure Supabase: set SUPABASE_URL and SUPABASE_ANON_KEY via --dart-define.';

  @override
  String get authTitle => 'Nous Deux';

  @override
  String get authSubtitle => 'A space for just the two of you.';

  @override
  String get authOr => 'or';

  @override
  String get authPhoneLabel => 'Phone number';

  @override
  String get authPhoneHint => '+1 234 567 8900';

  @override
  String get authSendCode => 'Text me a code';

  @override
  String get authContinueWithGoogle => 'Continue with Google';

  @override
  String get authContinueWithApple => 'Continue with Apple';

  @override
  String get authWithEmail => 'Sign in with email';

  @override
  String get authErrorEnterPhone => 'Enter your phone number.';

  @override
  String get authErrorGeneric => 'Couldn\'t sign you in. Try again.';

  @override
  String get authVerifyTitle => 'Check your texts';

  @override
  String authVerifyInstructions(String phone) {
    return 'Enter the 6-digit code we sent to $phone.';
  }

  @override
  String get authVerifyButton => 'Confirm';

  @override
  String get authVerifyErrorEnterCode =>
      'Enter the code from the text message.';

  @override
  String get authVerifyErrorInvalid =>
      'That code didn\'t work. Check it, or go back to get a new one.';

  @override
  String get authEmailTitle => 'Sign in with email';

  @override
  String get authEmailIntro =>
      'For accounts Nous Deux set up for you, for example to test the app.';

  @override
  String get authEmailLabel => 'Email address';

  @override
  String get authPasswordLabel => 'Password';

  @override
  String get authEmailButton => 'Sign in';

  @override
  String get authEmailErrorEmpty => 'Enter your email address and password.';

  @override
  String get authEmailErrorWrong => 'Wrong email address or password.';

  @override
  String get calendarTitle => 'Calendar';

  @override
  String get calendarToday => 'Today';

  @override
  String get calendarAdd => 'Add';

  @override
  String get calendarPartner => 'Partner';

  @override
  String get calendarMe => 'Me';

  @override
  String get calendarDeleteEventTitle => 'Delete event?';

  @override
  String calendarDeleteEventConfirm(String title) {
    return '\"$title\" will be deleted for both of you.';
  }

  @override
  String get calendarCancel => 'Cancel';

  @override
  String get calendarDelete => 'Delete';

  @override
  String calendarNothingInMonth(String month) {
    return 'Nothing planned in $month';
  }

  @override
  String get calendarCreateEvent => 'Add an event';

  @override
  String get calendarPreviousMonth => 'Previous month';

  @override
  String get calendarNextMonth => 'Next month';

  @override
  String get calendarImportAllowAccess => 'Allow calendar access';

  @override
  String get calendarImportOpenSettings => 'Open settings';

  @override
  String get calendarEventEdit => 'Edit event';

  @override
  String get calendarEventNew => 'New event';

  @override
  String get calendarEventTitleLabel => 'Title';

  @override
  String get calendarEventTitleRequired => 'Add a title.';

  @override
  String get calendarEventDescriptionLabel => 'Description (optional)';

  @override
  String get calendarEventStart => 'Start';

  @override
  String get calendarEventEnd => 'End';

  @override
  String get calendarEventSave => 'Save';

  @override
  String get calendarEventCountdown => 'Countdown';

  @override
  String get calendarEventCountdownHint =>
      'Shown on the Nous tab until the day comes.';

  @override
  String get calendarEventEndBeforeStart =>
      'The end has to come after the start.';

  @override
  String get calendarFollowLabel => 'Phone calendar';

  @override
  String get calendarFollowTitle => 'Calendars you follow';

  @override
  String calendarFollowIntro(String partnerName) {
    return 'Their titles and times are copied into Nous Deux and kept up to date: $partnerName sees them. Nothing else leaves your phone.';
  }

  @override
  String get calendarFollowTip =>
      'Simplest: an “Us” calendar on your phone, for what concerns you both. The rest of your calendar stays yours.';

  @override
  String get calendarFollowLastSync => 'Last updated';

  @override
  String get calendarFollowFootnote =>
      'From last month to six months ahead. Events are changed in your calendar; unfollowing a calendar removes its copies from that period, turning them all off removes every copy.';

  @override
  String get calendarFollowOtherPhone =>
      'Your calendars are followed from another phone. Following one here takes over.';

  @override
  String get calendarFollowGone =>
      'A followed calendar is no longer on this phone, so nothing is updated.';

  @override
  String get calendarFollowDropGone => 'Stop following it';

  @override
  String get calendarFollowFailed =>
      'The update didn\'t go through. Try again later.';

  @override
  String get calendarFollowNone => 'No calendar on this phone.';

  @override
  String get calendarFollowPermission =>
      'Nous Deux needs access to your calendars to follow them. If no prompt appears, allow access in Settings.';

  @override
  String get calendarAllDay => 'All day';

  @override
  String get cycleAskTitle => 'Do you track your cycle in the app?';

  @override
  String get cycleAskBody =>
      'If you do, this tab becomes your tracker. If not, it shows your partner\'s cycle when they share it.';

  @override
  String get cycleConsent =>
      'By tracking your cycle, you agree that the app stores your period dates, how you feel each day and your notes on our servers in Germany. This is health data. Your partner sees your dates and how you feel while you share them; your notes stay private. You can stop and delete everything at any time in Settings.';

  @override
  String get cycleConsentTitle => 'Track your cycle in the app?';

  @override
  String get cycleConsentAccept => 'I agree';

  @override
  String get cyclePrivacyPolicy => 'Privacy policy';

  @override
  String get cycleStopTitle => 'Stop tracking your cycle?';

  @override
  String get cycleStopBody =>
      'You can keep your cycle data in case you start again, or delete it now: dates, check-ins and notes. Deleting can\'t be undone.';

  @override
  String get cycleStopKeep => 'Keep my data';

  @override
  String get cycleStopDelete => 'Delete everything';

  @override
  String get cycleDataDeleted => 'Your cycle data is deleted.';

  @override
  String get cycleAskYes => 'Yes, I do';

  @override
  String get cycleAskNo => 'No';

  @override
  String get settingsTracksCycle => 'I track my cycle in the app';

  @override
  String get cycleDayWord => 'day';

  @override
  String cycleOfAbout(int length) {
    return 'of ~$length';
  }

  @override
  String cycleRingLabel(int day, int length) {
    return 'Cycle of about $length days, today day $day';
  }

  @override
  String get cycleNoDataTitle => 'Log your next period';

  @override
  String get cycleNoDataBody => 'The app learns your rhythm cycle after cycle.';

  @override
  String get cycleStarted => 'My period started';

  @override
  String get cycleEnded => 'My period ended';

  @override
  String get cycleOtherDay => 'It was another day';

  @override
  String get cycleToday => 'Today';

  @override
  String cycleSeenBy(String name) {
    return '$name can see this';
  }

  @override
  String get cycleSeenByNobody => 'Not shared';

  @override
  String get cycleNoteLabel => 'A note for you';

  @override
  String get cycleNoteHint => 'Only for you, never shared';

  @override
  String get cycleNoteSaved => 'Note saved.';

  @override
  String get cycleThisWeek => 'Good to know this week';

  @override
  String cycleReadChapter(String title) {
    return 'Read: $title';
  }

  @override
  String get cycleHistoryLink => 'Your cycles';

  @override
  String cycleSharingLink(String name) {
    return 'What $name sees';
  }

  @override
  String cyclePartnerLink(String name) {
    return '$name\'s cycle';
  }

  @override
  String get cycleUndo => 'Undo';

  @override
  String get cycleOtherState => '+ Other';

  @override
  String get cycleNewStateHint => 'How you feel';

  @override
  String get cycleAddState => 'Add';

  @override
  String get cycleOwnStateHint => 'remove from your list';

  @override
  String cycleStateRemoved(String state) {
    return '\"$state\" won\'t be offered any more.';
  }

  @override
  String get cycleTooManyStates => 'Twelve at most a day.';

  @override
  String get cycleSaveFailed => 'That wasn\'t saved. Try again.';

  @override
  String get cycleNeedsCouple =>
      'Tracking is saved in your couple: invite your partner first.';

  @override
  String get cycleSheetStarted => 'Period started';

  @override
  String get cycleSheetEnded => 'Period ended';

  @override
  String get cycleSheetWhen => 'When?';

  @override
  String get cycleYesterday => 'Yesterday';

  @override
  String get cycleAnotherDay => 'Another day…';

  @override
  String get cycleSave => 'Save';

  @override
  String get cycleSheetFootnote =>
      'When it stops, the button becomes \"My period ended\".';

  @override
  String get cycleHistoryTitle => 'Your cycles';

  @override
  String get cycleAverage => 'Average cycle';

  @override
  String get cyclePeriod => 'Period';

  @override
  String get cycleDaysWord => 'days';

  @override
  String get cycleNeedTwo =>
      'Two full cycles are needed for an average; until then the app counts 28 days.';

  @override
  String cycleCurrentRow(int day) {
    return 'now · day $day';
  }

  @override
  String get cycleRestOfCycle => 'Rest of the cycle';

  @override
  String get cycleHistoryHint =>
      'Tap a cycle to fix it, long-press to delete it.';

  @override
  String get cycleHistoryEmpty =>
      'Your cycles will appear here month after month.';

  @override
  String cyclePartnerLabel(String name) {
    return 'Period · $name';
  }

  @override
  String cyclePartnerNotShared(String name) {
    return '$name isn\'t sharing their cycle right now.';
  }

  @override
  String cyclePartnerNothingYet(String name) {
    return '$name hasn\'t logged anything yet.';
  }

  @override
  String cyclePartnerNotTracking(String name) {
    return '$name doesn\'t track a cycle in the app.';
  }

  @override
  String get cycleNoPartner =>
      'Here you\'ll follow your partner\'s cycle, if they share it, with ideas for being there at the right time.';

  @override
  String get cycleWhatHelps => 'What tends to help this week';

  @override
  String cyclePartnerNoted(String name) {
    return '$name noted today';
  }

  @override
  String get cycleLittleNote => 'A little note?';

  @override
  String get cycleRemindMe => 'Remind me the day before';

  @override
  String get cycleRemindNoDate => 'As soon as a date is expected';

  @override
  String cycleSharingTitle(String name) {
    return 'What $name sees';
  }

  @override
  String get cycleSharingIntro =>
      'You choose what your partner sees. It changes on their phone right away.';

  @override
  String get cycleShareCycle => 'My cycle';

  @override
  String get cycleShareCycleHint =>
      'Day, phase, expected date and the reminder';

  @override
  String get cycleShareCheckins => 'How I feel each day';

  @override
  String get cycleShareCheckinsHint => 'What you check each day';

  @override
  String get cycleNotesRow => 'Your notes';

  @override
  String get cycleNotesAlwaysPrivate => 'Always private';

  @override
  String get cycleStopSharing => 'Stop sharing everything';

  @override
  String get guideLabel => 'Guide';

  @override
  String get guideTitle => 'Understanding the cycle';

  @override
  String guideForYouNow(int day) {
    return 'For you now · day $day';
  }

  @override
  String guideForPartnerNow(String name, int day) {
    return 'For $name now · day $day';
  }

  @override
  String guideChapter(int n) {
    return 'Chapter $n';
  }

  @override
  String get guideRead => 'read';

  @override
  String get guideFootnote =>
      'Based on public health sources. Not medical advice.';

  @override
  String get guideContents => 'Contents';

  @override
  String guideNext(String title) {
    return 'Next: $title';
  }

  @override
  String get guideSearch => 'Search the guide';

  @override
  String guideNoMatch(String query) {
    return 'No chapter mentions \"$query\".';
  }

  @override
  String get guideBody => 'In the body';

  @override
  String get guideMood => 'Mood';

  @override
  String get guideWhatHelps => 'What helps';

  @override
  String get guideYouAreHere => 'you are here';

  @override
  String guidePartnerIsHere(String name) {
    return '$name is here';
  }

  @override
  String get guideSources => 'Sources';

  @override
  String guideDaysShort(String range) {
    return 'days $range';
  }

  @override
  String get listsTitle => 'Lists';

  @override
  String listsSubtitle(String partnerName) {
    return 'Shared with $partnerName, live.';
  }

  @override
  String get listsSeeAll => 'See all';

  @override
  String get listsNew => 'New list';

  @override
  String get listsEmptyTitle => 'No lists yet';

  @override
  String get listsEmptyBody =>
      'Groceries, to-dos, weekend ideas: whatever you add shows up on your partner\'s phone too.';

  @override
  String get listsNameLabel => 'List name';

  @override
  String get listsNameHint => 'Groceries';

  @override
  String get listsIconLabel => 'Icon';

  @override
  String get listsCreate => 'Create';

  @override
  String get listsRename => 'Rename';

  @override
  String get listsDelete => 'Delete list';

  @override
  String listsDeleteConfirm(String name) {
    return '\"$name\" and all its items will be deleted for both of you.';
  }

  @override
  String get listsCancel => 'Cancel';

  @override
  String get listsSave => 'Save';

  @override
  String get listsOptions => 'List options';

  @override
  String get listsBack => 'Back';

  @override
  String get listsAddLabel => 'Add an item';

  @override
  String get listsAddHint => 'Oat milk, bread…';

  @override
  String get listsAddButton => 'Add';

  @override
  String listsChecked(int n) {
    return 'Ticked ($n)';
  }

  @override
  String get listsClearChecked => 'Clear all';

  @override
  String get listsAddedByMe => 'Added by you';

  @override
  String listsAddedBy(String name) {
    return 'Added by $name';
  }

  @override
  String listsItemDeleted(String text) {
    return '\"$text\" deleted.';
  }

  @override
  String get listsUndo => 'Undo';

  @override
  String get listsDeleteItem => 'Delete';

  @override
  String get listsGoneTitle => 'This list is gone';

  @override
  String get listsGoneBody => 'It was probably deleted on the other phone.';

  @override
  String get listsAll => 'All lists';

  @override
  String get listsEmptyListBody => 'Add the first item above.';

  @override
  String get listsError => 'That didn\'t work. Try again.';

  @override
  String get nousTitle => 'Us';

  @override
  String get nousSettingsTooltip => 'Settings';

  @override
  String get nousTogetherSince => 'Together for';

  @override
  String get nousEdit => 'Edit';

  @override
  String get nousPickStartHelp => 'The day it all started';

  @override
  String get nousStartSaved => 'Date updated.';

  @override
  String get nousSendNote => 'Send a little note';

  @override
  String get nousNoteCooldown =>
      'One little note every 30 seconds at most. Try again in a moment.';

  @override
  String get nousNoteFailed => 'The note didn\'t go through. Try again.';

  @override
  String get pingWriteBack => 'Reply with a note';

  @override
  String get nousWrite => 'Write…';

  @override
  String get nousMyWords => 'My notes';

  @override
  String nousWriteTo(String name) {
    return 'A little note for $name';
  }

  @override
  String get nousWriteHint => 'Your little note';

  @override
  String get nousWriteReplaces =>
      'It replaces your last note, like the others.';

  @override
  String get nousKeepWord => 'Keep it in my notes';

  @override
  String get nousSend => 'Send';

  @override
  String get myWordsTitle => 'My little notes';

  @override
  String get myWordsHelp =>
      'The ticked ones show on Nous, in this order. Six at most.';

  @override
  String get myWordsAddHint => 'Add a note…';

  @override
  String get myWordsAdd => 'Add';

  @override
  String myWordsRemove(String word) {
    return 'Remove \"$word\"';
  }

  @override
  String myWordsMove(String word) {
    return 'Move \"$word\"';
  }

  @override
  String get myWordsFull => 'Six notes at most on Nous. Untick one first.';

  @override
  String get myWordsAlready => 'That note is already there.';

  @override
  String get myWordsDrag => 'Drag the handle on the right to change the order.';

  @override
  String get pingJustNow => 'Just now';

  @override
  String get pingReplyMeToo => 'Me too';

  @override
  String get pingTapToClose => 'Tap to close';

  @override
  String get nousPartnerFallback => 'Your partner';

  @override
  String get nousNextPlan => 'Next plan';

  @override
  String get nousNoCountdown => 'Nothing planned';

  @override
  String get nousNoCountdownHint => 'Turn on Countdown for an event.';

  @override
  String get nousAnniversary => 'Anniversary';

  @override
  String get nousNoPartnerTitle => 'Invite your partner';

  @override
  String get nousNoPartnerBody =>
      'The counter starts on the day there are two of you.';

  @override
  String get nousInvite => 'Invite';

  @override
  String get onboardingTitle => 'Introduce yourself';

  @override
  String get onboardingSubtitle =>
      'Your partner will see this name. You can change it later in Settings.';

  @override
  String get onboardingDisplayNameLabel => 'Name or nickname';

  @override
  String get onboardingDisplayNameHint => 'Alex';

  @override
  String get onboardingLanguageLabel => 'Language';

  @override
  String get onboardingContinue => 'Continue';

  @override
  String get onboardingErrorDisplayName =>
      'Add the name your partner will see.';

  @override
  String get onboardingErrorGeneric => 'Couldn\'t save that. Try again.';

  @override
  String get pairingInviteTitle => 'Invite your partner';

  @override
  String get pairingIntro =>
      'Generate a code and show it to your partner. They can scan the QR code or type the 6 characters.';

  @override
  String get pairingGenerateCode => 'Generate a code';

  @override
  String get pairingScanQrPrompt => 'Scan this with your partner\'s phone:';

  @override
  String get pairingOrEnterCode => 'Or type this code:';

  @override
  String get pairingAlreadyHaveCode => 'Already invited by your partner?';

  @override
  String get pairingJoinWithCode => 'I have a code';

  @override
  String get pairingScanQr => 'Scan a QR code';

  @override
  String get pairingAlreadyPaired => 'You\'re already paired. Taking you back…';

  @override
  String get pairingError => 'That didn\'t work. Try again.';

  @override
  String get pairingJoinTitle => 'Join your partner';

  @override
  String get pairingJoinInstructions =>
      'Type the 6-character code shown on your partner\'s phone.';

  @override
  String get pairingJoinCodeLabel => 'Code';

  @override
  String get pairingJoinButton => 'Join';

  @override
  String get pairingJoinErrorCode => 'Type your partner\'s code.';

  @override
  String get pairingJoinErrorUsed =>
      'This code has already been used. Ask your partner for a new one.';

  @override
  String get pairingJoinErrorOwnCode =>
      'That\'s your own code. Your partner needs to enter it.';

  @override
  String get pairingJoinErrorInvalid =>
      'That code doesn\'t match an invite. Check it with your partner.';

  @override
  String get pairingJoinErrorAlreadyPaired =>
      'You\'re already in a couple in the app. Leave it in Settings before joining another.';

  @override
  String get pairingJoinErrorTooManyAttempts =>
      'Too many wrong codes. Try again in 10 minutes.';

  @override
  String get pairingScanTitle => 'Scan the QR code';

  @override
  String get pairingScanConnecting => 'Connecting…';

  @override
  String get periodLearnMore => 'Learn more';

  @override
  String get periodCouldNotOpenLink => 'Could not open link';

  @override
  String get mainNavCalendar => 'Calendar';

  @override
  String get mainNavPeriod => 'Period';

  @override
  String get mainNavPosition => 'Location';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAboutApp => 'About';

  @override
  String get settingsUsername => 'Name or nickname';

  @override
  String get settingsProfilePhoto => 'Profile photo';

  @override
  String get settingsChangePhoto => 'Change photo';

  @override
  String get settingsPermissions => 'Permissions';

  @override
  String get settingsOpenAppSettings => 'Open app settings';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsPeriodReminder =>
      'Remind me the day before my partner\'s period';

  @override
  String get settingsCalendarReminders => 'Calendar reminders';

  @override
  String get settingsCalendarRemindersSubtitle => 'Coming soon';

  @override
  String get settingsPermissionGranted => 'Granted';

  @override
  String get settingsPermissionDenied => 'Denied';

  @override
  String get settingsPermissionRestricted => 'Restricted';

  @override
  String get settingsPermissionPermanentDenied => 'Blocked';

  @override
  String get settingsCalendars => 'Calendar';

  @override
  String get settingsNotificationsPerm => 'Notifications';

  @override
  String get settingsLocation => 'Location';

  @override
  String get settingsPermissionsReloadTooltip => 'Refresh permissions';

  @override
  String get settingsPermissionsReloadDone => 'Permissions updated';

  @override
  String get settingsShareMyLocation => 'Share my location';

  @override
  String get settingsShareMyLocationSubtitle =>
      'Your partner sees where you are on the map. No history is kept.';

  @override
  String get settingsLocationRequiredForSharing =>
      'Allow location access to share where you are.';

  @override
  String get settingsCamera => 'Camera';

  @override
  String get settingsCoupleGroup => 'Couple';

  @override
  String get settingsLeaveCouple => 'Leave couple';

  @override
  String get settingsLeaveCoupleSubtitle =>
      'Unlinks you from your partner and deletes what you share: calendar, cycle, location, lists and little notes.';

  @override
  String get settingsLeaveCoupleConfirmTitle => 'Leave the couple?';

  @override
  String get settingsLeaveCoupleConfirmMessage =>
      'Your calendar, cycle, location, lists and little notes will be deleted for both of you. This can\'t be undone.';

  @override
  String get settingsLeaveCoupleConfirm => 'Leave';

  @override
  String get settingsLeaveCoupleSuccess => 'You\'ve left the couple.';

  @override
  String get settingsAccountGroup => 'Account';

  @override
  String get settingsSignOut => 'Sign out';

  @override
  String get settingsSignOutConfirmTitle => 'Sign out?';

  @override
  String get settingsSignOutConfirmMessage =>
      'Your couple and what you share stay as they are. Sign in with the same account to find them again.';

  @override
  String get settingsDeleteAccount => 'Delete my account';

  @override
  String get settingsDeleteAccountConfirmTitle => 'Delete your account?';

  @override
  String get settingsDeleteAccountConfirm => 'Delete';

  @override
  String get settingsDeleteAccountDone => 'Your account has been deleted.';

  @override
  String get settingsDeleteAccountFailed =>
      'Your account couldn\'t be deleted. Check your connection and try again.';

  @override
  String get appInfoTitle => 'About the app';

  @override
  String get appInfoDescription =>
      'Nous Deux is a private app for couples: a shared calendar, cycle tracking and, if you want it, location sharing.';

  @override
  String get appInfoFree =>
      'The project is free and will stay free. There will never be ads.';

  @override
  String get appInfoSource => 'Source code';

  @override
  String get appInfoContributors => 'Contributors';

  @override
  String get appInfoThomasMoser => 'Development';

  @override
  String get appInfoEvahBaumlin =>
      'Content, scientific explanations and a woman\'s perspective';

  @override
  String get appInfoFriends => 'Support along the way';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageUpdated => 'Language updated';

  @override
  String get settingsEditUsername => 'Edit name';

  @override
  String get settingsSave => 'Save';

  @override
  String get settingsCancel => 'Cancel';

  @override
  String get timeAgoJustNow => 'just now';

  @override
  String timeAgoMinutes(int minutes) {
    return '$minutes min ago';
  }

  @override
  String timeAgoHours(int hours) {
    return '$hours h ago';
  }

  @override
  String timeAgoOnDay(String day) {
    return 'on $day';
  }

  @override
  String get calendarSyncedFromMine => 'From your calendar';

  @override
  String calendarSyncedFrom(String name, String nameStart) {
    String _temp0 = intl.Intl.selectLogic(nameStart, {
      'other': 'From $name\'s calendar',
    });
    return '$_temp0';
  }

  @override
  String get calendarSyncedReadOnlyMine =>
      'This event follows your phone\'s calendar: change or delete it there.';

  @override
  String calendarSyncedReadOnly(String name) {
    return 'This event follows $name\'s phone calendar: it is changed or deleted there.';
  }

  @override
  String get cyclePartnerFallback => 'Your partner';

  @override
  String cyclePhaseLabel(String phase) {
    String _temp0 = intl.Intl.selectLogic(phase, {
      'menstrual': 'Period',
      'follicular': 'Follicular phase',
      'ovulation': 'Ovulation',
      'luteal': 'Luteal phase',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String cycleHeadlineOngoing(int day) {
    return 'Period, day $day';
  }

  @override
  String cycleHeadlineIn(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Period in ~$days days',
      one: 'Period expected tomorrow',
      zero: 'Period expected today',
    );
    return '$_temp0';
  }

  @override
  String cycleHeadlineLate(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Period expected $days days ago',
      one: 'Period expected $days day ago',
    );
    return '$_temp0';
  }

  @override
  String cycleBasis(String date, int cyclesUsed) {
    String _temp0 = intl.Intl.pluralLogic(
      cyclesUsed,
      locale: localeName,
      other: 'around $date, based on your last $cyclesUsed cycles',
      one: 'around $date, based on your last cycle',
      zero: 'around $date, assuming 28 days until there is more to go on',
    );
    return '$_temp0';
  }

  @override
  String cycleLoggedStart(String date) {
    return 'Start logged: $date';
  }

  @override
  String cycleLoggedEnd(String date) {
    return 'End logged: $date';
  }

  @override
  String cycleSelfTip(String phase) {
    String _temp0 = intl.Intl.selectLogic(phase, {
      'menstrual':
          'Heat, rest and water often help during your period. Pain that stops you from living normally is worth a doctor\'s opinion.',
      'follicular':
          'Energy often rises after your period: a good time for things that need drive.',
      'ovulation':
          'Around ovulation many feel at their best. Slight discomfort on one side of the belly can happen too.',
      'luteal':
          'Late in the cycle, lighter sleep and lower energy are common. Nothing unusual.',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String cycleRegularitySame(int count, int days) {
    return 'Your last $count cycles all lasted $days days.';
  }

  @override
  String cycleRegularityRange(int count, int shortest, int longest) {
    return 'Your last $count cycles lasted $shortest to $longest days.';
  }

  @override
  String cycleSpanRow(int length) {
    return '$length d';
  }

  @override
  String cycleSpanRowWithPeriod(int length, int periodDays) {
    return '$length d · period $periodDays d';
  }

  @override
  String cyclePartnerHeadlineOngoing(String name, int day) {
    return '$name has their period, day $day';
  }

  @override
  String cyclePartnerHeadlineDay(String name, int day) {
    return '$name is on day $day';
  }

  @override
  String cyclePartnerNextLate(String date) {
    return 'The period was expected around $date.';
  }

  @override
  String cyclePartnerNext(String date) {
    return 'Next period around $date.';
  }

  @override
  String cycleRemindOn(String date) {
    return 'on the evening of $date';
  }

  @override
  String cyclePartnerTip1(String phase) {
    String _temp0 = intl.Intl.selectLogic(phase, {
      'menstrual':
          'Offer a heat pack or a hot drink without waiting to be asked.',
      'follicular': 'Energy often comes back: a good time for a plan together.',
      'ovulation': 'Many feel at their best these days: enjoy it together.',
      'luteal': 'Keep evenings calm if tiredness shows.',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String cyclePartnerTip2(String phase) {
    String _temp0 = intl.Intl.selectLogic(phase, {
      'menstrual': 'Lighten the day: take on the shopping or dinner.',
      'follicular': 'Suggest something you\'ve been putting off.',
      'ovulation':
          'A little lower-belly discomfort can happen; just ask how they feel.',
      'luteal': 'Offer rather than ask: \"Shall I make dinner?\"',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String cyclePartnerTip3(String phase) {
    String _temp0 = intl.Intl.selectLogic(phase, {
      'menstrual': 'Ask \"What do you need?\" rather than guess.',
      'follicular': 'Follow their pace without pushing it.',
      'ovulation': 'Keep listening: every cycle is different.',
      'luteal':
          'Don\'t put everything down to hormones: listen to what is said.',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String guideNowTitle(String phase) {
    return '$phase: what happens, what helps';
  }

  @override
  String get listsCountsEmpty => 'Empty';

  @override
  String get listsCountsAllDone => 'All done';

  @override
  String listsCounts(int open, int total) {
    return '$open left of $total';
  }

  @override
  String listsIconName(String icon) {
    String _temp0 = intl.Intl.selectLogic(icon, {
      'list': 'List',
      'cart': 'Shopping',
      'star': 'Wishes',
      'home': 'Home',
      'gift': 'Gifts',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String nousDaysUnit(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'days',
      one: 'day',
    );
    return '$_temp0';
  }

  @override
  String nousSinceDate(String date) {
    return 'Since $date';
  }

  @override
  String pingLabel(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'thinkingOfYou': 'Thinking of you',
      'goodNight': 'Good night',
      'onMyWay': 'On my way',
      'missYou': 'Miss you',
      'kiss': 'Kiss',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String nousNoteSent(String note) {
    return 'Sent: $note';
  }

  @override
  String pingReceivedTitle(String kind, String name) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'thinkingOfYou': '$name is thinking of you.',
      'goodNight': '$name says good night.',
      'onMyWay': '$name is on the way.',
      'missYou': '$name misses you.',
      'kiss': '$name sends you a kiss.',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String nousReceivedLine(String name, String note, String when) {
    return '$name: $note, $when';
  }

  @override
  String nousInDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'in $days d',
      one: 'tomorrow',
      zero: 'today',
    );
    return '$_temp0';
  }

  @override
  String nousYearsTogether(int years) {
    String _temp0 = intl.Intl.pluralLogic(
      years,
      locale: localeName,
      other: '$years years together',
      one: '$years year together',
    );
    return '$_temp0';
  }

  @override
  String get settingsDeleteAccountConfirmPaired =>
      'Your account, profile, photo and cycle notes will be deleted. You\'ll also leave the couple: your calendar, cycle, location, lists and little notes will be deleted for both of you. This can\'t be undone.';

  @override
  String get settingsDeleteAccountConfirmSolo =>
      'Your account, profile, photo and cycle notes will be deleted. This can\'t be undone.';

  @override
  String get periodScreenTitle => 'Period';

  @override
  String get periodLogNew => 'New entry';

  @override
  String get periodLogEdit => 'Edit entry';

  @override
  String get periodDeleteConfirmTitle => 'Delete this entry?';

  @override
  String get periodCancel => 'Cancel';

  @override
  String get periodDelete => 'Delete';

  @override
  String get periodSave => 'Save';

  @override
  String get periodStartDate => 'Start date';

  @override
  String get periodEndDate => 'End date (optional)';

  @override
  String get periodReminderNotificationTitle => 'Period expected tomorrow';

  @override
  String get periodReminderNotificationBody =>
      'Going by their cycle, your partner\'s period should start tomorrow.';

  @override
  String periodMoodLabel(String value) {
    String _temp0 = intl.Intl.selectLogic(value, {
      'good': 'Good',
      'tired': 'Tired',
      'anxious': 'Anxious',
      'irritable': 'Irritable',
      'other': '$value',
    });
    return '$_temp0';
  }

  @override
  String periodSymptomLabel(String value) {
    String _temp0 = intl.Intl.selectLogic(value, {
      'cramps': 'Cramps',
      'headache': 'Headache',
      'acne': 'Acne',
      'pain': 'Pain',
      'bloating': 'Bloating',
      'other': '$value',
    });
    return '$_temp0';
  }

  @override
  String guideLabelPrefix(String label) {
    return '$label: ';
  }

  @override
  String get positionTitle => 'Location';

  @override
  String get positionNoPartnerMessage => 'Invite your partner';

  @override
  String get positionNoPartnerSecondary =>
      'Once they join, you\'ll see each other on the map.';

  @override
  String get positionInvitePartner => 'Invite';

  @override
  String get positionEnableSharingMessage => 'Turn on location';

  @override
  String get positionEnableSharingSecondary =>
      'Allow location access in your phone\'s settings.';

  @override
  String get positionOpenSettings => 'Open settings';

  @override
  String get positionReloadTooltip => 'Refresh';

  @override
  String get positionReloadDone => 'Up to date';

  @override
  String get positionMapPhoneOnly => 'The map shows on phones.';

  @override
  String get positionTogether => 'Together ❤️';

  @override
  String get positionTogetherTitle => 'Together';

  @override
  String get positionMe => 'Me';

  @override
  String get positionSeeAll => 'See all';

  @override
  String get positionPartnerFallback => 'Partner';

  @override
  String get appInfoFriendsName => 'Friends';

  @override
  String get profileUnavailableTitle => 'Can\'t connect';

  @override
  String get profileUnavailableBody =>
      'Nous Deux can\'t reach its server. Check your connection, then try again.';

  @override
  String get profileUnavailableRetry => 'Try again';

  @override
  String get newsTitle => 'What\'s new';

  @override
  String get newsSignature => 'The Nous Deux team';

  @override
  String newsUnread(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count unread',
      one: '$count unread',
    );
    return '$_temp0';
  }

  @override
  String get newsEmpty => 'Nothing new yet.';

  @override
  String get newsLoadFailed =>
      'The news couldn\'t load. Check your connection and try again.';

  @override
  String get settingsNewsPush => 'App news';

  @override
  String get settingsNewsPushSubtitle =>
      'New features and messages from the Nous Deux team.';

  @override
  String newsAvatarUnread(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Settings, $count new messages',
      one: 'Settings, $count new message',
    );
    return '$_temp0';
  }

  @override
  String get settingsFeedback => 'Send feedback';

  @override
  String feedbackSubject(String build, String device) {
    return 'Nous Deux · build $build · $device';
  }

  @override
  String settingsFeedbackNoMail(String email) {
    return 'No mail app found. Write to $email.';
  }

  @override
  String pillReminderTitle(String style) {
    String _temp0 = intl.Intl.selectLogic(style, {
      'clear': 'Pill',
      'other': 'Little reminder',
    });
    return '$_temp0';
  }

  @override
  String pillReminderBodyClear(int number) {
    return 'Time for your pill. Pill $number.';
  }

  @override
  String pillReminderBodyDiscreet(String time) {
    return 'Your $time reminder.';
  }

  @override
  String get pillReminderLaterClear => 'Not ticked yet: time for your pill.';

  @override
  String pillReminderLaterDiscreet(String time) {
    return 'Still here: your $time reminder.';
  }

  @override
  String pillActionTaken(String style) {
    String _temp0 = intl.Intl.selectLogic(style, {
      'clear': 'Taken',
      'other': 'Done',
    });
    return '$_temp0';
  }

  @override
  String get pillActionSnooze => 'In 30 min';

  @override
  String get pillLabel => 'Pill';

  @override
  String get pillSetupQuestion => 'Do you take a hormonal pill?';

  @override
  String get pillSetupWhy =>
      'Birth control, cycle, skin: whatever the reason. Nous Deux can remind you every day. Your partner sees whether today\'s is taken, and when; you can turn that off at any time.';

  @override
  String get pillSetupYes => 'Yes, remind me';

  @override
  String get pillSetupNo => 'No';

  @override
  String get pillSetupLater => 'Later';

  @override
  String get pillReminderLabel => 'Reminder';

  @override
  String get pillTodayLabel => 'Today';

  @override
  String pillNumberToday(int number) {
    return 'Pill $number';
  }

  @override
  String get pillPackLabel => 'Pack';

  @override
  String pillPackType(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'p21x7': '21 + 7 off',
      'p28': '28 days',
      'other': 'Continuous',
    });
    return '$_temp0';
  }

  @override
  String get pillHealthNote =>
      'This is health data, like your cycle: it stays yours, and you can delete it all at any time.';

  @override
  String get pillContinue => 'Continue';

  @override
  String get pillConsentTitle => 'Before you start';

  @override
  String get pillConsent =>
      'Pill tracking keeps health data: your pack, your reminder and the days you take it. It is stored on our servers in Germany. Your partner sees whether today\'s pill is ticked, and at what time, as long as you share it: it\'s on to start with. In Settings › Period › Pill tracking you can turn sharing off, or stop and delete it all.';

  @override
  String get pillTrackLink => 'Track my pill';

  @override
  String pillReminderAt(String time) {
    return 'Reminder at $time';
  }

  @override
  String pillOfPack(int total) {
    return 'of $total';
  }

  @override
  String get pillNotTickedToday => 'Not ticked yet today';

  @override
  String pillTakenAt(String time) {
    return 'Taken at $time';
  }

  @override
  String get pillTakeButton => 'I took it';

  @override
  String get pillUntick => 'Untick';

  @override
  String get pillDayOff => 'No pill today';

  @override
  String pillPackLine21(int day, String from, String to) {
    return 'Day $day of 21 · break from $from to $to';
  }

  @override
  String pillPackLine(int day) {
    return 'Day $day of 28';
  }

  @override
  String pillNextPack(String date) {
    return 'New pack on $date';
  }

  @override
  String get pillThisWeek => 'This week';

  @override
  String get pillWeekMissed => 'missed';

  @override
  String get pillWeekOff => 'off';

  @override
  String get pillLateTitle => 'Not ticked yet tonight';

  @override
  String get pillTookItAt => 'I took it at';

  @override
  String get pillTakingNow => 'I\'m taking it now';

  @override
  String get pillIfMissed => 'If you missed it';

  @override
  String get pillIfMissedBody =>
      'Follow your pill\'s leaflet: what to do depends on the pill and how late it is. If in doubt, ask a pharmacy or your doctor.';

  @override
  String pillOfficialSheet(String name) {
    return 'Official sheet: $name';
  }

  @override
  String get pillNoteMissed => 'Note a missed pill';

  @override
  String get pillNotedMissed => 'Noted as missed';

  @override
  String get pillNoScore => 'No streaks, no score.';

  @override
  String pillPartnerTaken(String time) {
    return 'Pill taken at $time';
  }

  @override
  String get pillPartnerNotYet => 'Pill not ticked yet';

  @override
  String get pillSettingsTitle => 'Pill tracking';

  @override
  String get pillReminderDaily => 'Daily reminder';

  @override
  String get pillReminderTime => 'Time';

  @override
  String get pillLockScreen => 'On the lock screen';

  @override
  String get pillPackTypeLabel => 'Type';

  @override
  String get pillTodayPill => 'Today\'s pill';

  @override
  String pillWithPartner(String name) {
    return 'With $name';
  }

  @override
  String pillShareWith(String name) {
    return '$name sees whether it\'s taken';
  }

  @override
  String get pillShareWithNote => 'Only “taken” or “not yet”, for today.';

  @override
  String get pillStop => 'Stop tracking';

  @override
  String pillStopNote(String name) {
    return 'Deletes your pill history from our servers. Nothing is sent to $name.';
  }

  @override
  String get pillStopConfirmTitle => 'Stop pill tracking?';

  @override
  String get pillStopConfirmBody =>
      'Your settings and history are deleted, and the reminders stop.';

  @override
  String get pillStopConfirm => 'Stop';

  @override
  String get pillYesterdayPending => 'Yesterday: not ticked yet';

  @override
  String get pillTookItYesterday => 'I took it yesterday';

  @override
  String pillBreakUntil(String date) {
    return 'Break until $date';
  }

  @override
  String get pillReminderKeepAlive => 'Open Nous Deux to keep your reminders.';

  @override
  String get updateLabel => 'Update';

  @override
  String get updateTitle => 'A new version is here';

  @override
  String get updateBodyDefault => 'It brings the latest features and fixes.';

  @override
  String get updateYourVersion => 'Your version';

  @override
  String get updateLatestVersion => 'The latest';

  @override
  String updateBuild(int build) {
    return 'build $build';
  }

  @override
  String get updateButton => 'Update';

  @override
  String updateOpens(String store) {
    String _temp0 = intl.Intl.selectLogic(store, {
      'testflight': 'Opens TestFlight',
      'other': 'Opens Google Play',
    });
    return '$_temp0';
  }

  @override
  String get updateLater => 'Later';

  @override
  String get updateRequiredLabel => 'Update needed';

  @override
  String get updateRequiredTitle => 'This version no longer works';

  @override
  String get updateRequiredBody =>
      'To keep using Nous Deux, install the latest version. Your data and your couple stay as they are.';
}
