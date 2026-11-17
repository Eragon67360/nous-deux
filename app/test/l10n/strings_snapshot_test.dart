// Generated once by a script for the move to ARB files (docs/LOCALIZATION.md,
// phase 2). It pins every string the app shows, in every language plus an
// unsupported one, so the move can be proven to change nothing.
//
// Refresh the snapshot on purpose with:
//   UPDATE_STRINGS_SNAPSHOT=1 flutter test test/l10n/strings_snapshot_test.dart
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:nousdeux/core/constants/period_education.dart' show CyclePhase;
import 'package:nousdeux/core/constants/app_strings.dart';
import 'package:nousdeux/core/constants/auth_strings.dart';
import 'package:nousdeux/core/constants/calendar_strings.dart';
import 'package:nousdeux/core/constants/cycle_strings.dart';
import 'package:nousdeux/core/constants/lists_strings.dart';
import 'package:nousdeux/core/constants/nous_strings.dart';
import 'package:nousdeux/core/constants/onboarding_strings.dart';
import 'package:nousdeux/core/constants/pairing_strings.dart';
import 'package:nousdeux/core/constants/period_ui_strings.dart';
import 'package:nousdeux/core/constants/position_strings.dart';
import 'package:nousdeux/core/constants/settings_strings.dart';
import 'package:nousdeux/core/errors/failures.dart';
import 'package:nousdeux/core/l10n/app_languages.dart';
import 'package:nousdeux/domain/entities/ping_entity.dart';
import 'package:nousdeux/domain/entities/shared_list_entity.dart';

void main() {
  test('every string reads exactly as in the snapshot', () {
    final out = <String, String>{};
    // 'de' is not supported: it pins the fallback to English.
    for (final lang in [...AppLanguages.supported, 'de']) {
      void put(String key, Object value) =>
          out['$lang $key'] = value is List ? value.join(' | ') : '$value';
      put('appName()', appName(lang));
      put('splashTagline()', splashTagline(lang));
      put('mainNoPartnerBubble()', mainNoPartnerBubble(lang));
      put('pairingCelebrationTitle()', pairingCelebrationTitle(lang));
      put('pairingCelebrationBody()', pairingCelebrationBody(lang));
      put('appSupabaseConfigMessage()', appSupabaseConfigMessage(lang));
      put('authTitle()', authTitle(lang));
      put('authSubtitle()', authSubtitle(lang));
      put('authOr()', authOr(lang));
      put('authPhoneLabel()', authPhoneLabel(lang));
      put('authPhoneHint()', authPhoneHint(lang));
      put('authSendCode()', authSendCode(lang));
      put('authContinueWithGoogle()', authContinueWithGoogle(lang));
      put('authContinueWithApple()', authContinueWithApple(lang));
      put('authWithEmail()', authWithEmail(lang));
      put('authErrorEnterPhone()', authErrorEnterPhone(lang));
      put('authErrorGeneric()', authErrorGeneric(lang));
      put('authVerifyTitle()', authVerifyTitle(lang));
      put(
        'authVerifyInstructions(phone=\'<phone>\')',
        authVerifyInstructions(lang, '<phone>'),
      );
      put('authVerifyCodeHint()', authVerifyCodeHint(lang));
      put('authVerifyButton()', authVerifyButton(lang));
      put('authVerifyErrorEnterCode()', authVerifyErrorEnterCode(lang));
      put('authVerifyErrorInvalid()', authVerifyErrorInvalid(lang));
      put('authEmailTitle()', authEmailTitle(lang));
      put('authEmailIntro()', authEmailIntro(lang));
      put('authEmailLabel()', authEmailLabel(lang));
      put('authPasswordLabel()', authPasswordLabel(lang));
      put('authEmailButton()', authEmailButton(lang));
      put('authEmailErrorEmpty()', authEmailErrorEmpty(lang));
      put('authEmailErrorWrong()', authEmailErrorWrong(lang));
      put('calendarTitle()', calendarTitle(lang));
      put('calendarToday()', calendarToday(lang));
      put('calendarAdd()', calendarAdd(lang));
      put('calendarPartner()', calendarPartner(lang));
      put('calendarMe()', calendarMe(lang));
      put('calendarDeleteEventTitle()', calendarDeleteEventTitle(lang));
      put(
        'calendarDeleteEventConfirm(title=\'Alex\')',
        calendarDeleteEventConfirm(lang, 'Alex'),
      );
      put(
        'calendarDeleteEventConfirm(title=\'Camille\')',
        calendarDeleteEventConfirm(lang, 'Camille'),
      );
      put('calendarCancel()', calendarCancel(lang));
      put('calendarDelete()', calendarDelete(lang));
      put(
        'calendarNothingInMonth(month=\'<month>\')',
        calendarNothingInMonth(lang, '<month>'),
      );
      put('calendarCreateEvent()', calendarCreateEvent(lang));
      put('calendarPreviousMonth()', calendarPreviousMonth(lang));
      put('calendarNextMonth()', calendarNextMonth(lang));
      put('calendarImportAllowAccess()', calendarImportAllowAccess(lang));
      put('calendarImportOpenSettings()', calendarImportOpenSettings(lang));
      put('calendarEventEdit()', calendarEventEdit(lang));
      put('calendarEventNew()', calendarEventNew(lang));
      put('calendarEventTitleLabel()', calendarEventTitleLabel(lang));
      put('calendarEventTitleRequired()', calendarEventTitleRequired(lang));
      put(
        'calendarEventDescriptionLabel()',
        calendarEventDescriptionLabel(lang),
      );
      put('calendarEventStart()', calendarEventStart(lang));
      put('calendarEventEnd()', calendarEventEnd(lang));
      put('calendarEventSave()', calendarEventSave(lang));
      put('calendarEventCountdown()', calendarEventCountdown(lang));
      put('calendarEventCountdownHint()', calendarEventCountdownHint(lang));
      put('calendarEventEndBeforeStart()', calendarEventEndBeforeStart(lang));
      put('calendarFollowLabel()', calendarFollowLabel(lang));
      put('calendarFollowTitle()', calendarFollowTitle(lang));
      put(
        'calendarFollowIntro(partnerName=\'Alex\')',
        calendarFollowIntro(lang, 'Alex'),
      );
      put(
        'calendarFollowIntro(partnerName=\'Camille\')',
        calendarFollowIntro(lang, 'Camille'),
      );
      put('calendarFollowTip()', calendarFollowTip(lang));
      put('calendarFollowLastSync()', calendarFollowLastSync(lang));
      put('calendarFollowFootnote()', calendarFollowFootnote(lang));
      put('calendarFollowOtherPhone()', calendarFollowOtherPhone(lang));
      put('calendarFollowGone()', calendarFollowGone(lang));
      put('calendarFollowDropGone()', calendarFollowDropGone(lang));
      put('calendarFollowFailed()', calendarFollowFailed(lang));
      put('calendarFollowNone()', calendarFollowNone(lang));
      put('calendarFollowPermission()', calendarFollowPermission(lang));
      put(
        'calendarAgo(ago=Duration(seconds: 20))',
        calendarAgo(
          lang,
          DateTime(2026, 11, 17, 12).subtract(const Duration(seconds: 20)),
          DateTime(2026, 11, 17, 12),
        ),
      );
      put(
        'calendarAgo(ago=Duration(minutes: 10))',
        calendarAgo(
          lang,
          DateTime(2026, 11, 17, 12).subtract(const Duration(minutes: 10)),
          DateTime(2026, 11, 17, 12),
        ),
      );
      put(
        'calendarAgo(ago=Duration(hours: 3))',
        calendarAgo(
          lang,
          DateTime(2026, 11, 17, 12).subtract(const Duration(hours: 3)),
          DateTime(2026, 11, 17, 12),
        ),
      );
      put(
        'calendarAgo(ago=Duration(days: 2))',
        calendarAgo(
          lang,
          DateTime(2026, 11, 17, 12).subtract(const Duration(days: 2)),
          DateTime(2026, 11, 17, 12),
        ),
      );
      put(
        'calendarAgo(ago=Duration(days: 40))',
        calendarAgo(
          lang,
          DateTime(2026, 11, 17, 12).subtract(const Duration(days: 40)),
          DateTime(2026, 11, 17, 12),
        ),
      );
      put(
        'calendarPartnerFresh(name=\'Alex\', ago=\'<ago>\')',
        calendarPartnerFresh(lang, 'Alex', '<ago>'),
      );
      put(
        'calendarPartnerFresh(name=\'Camille\', ago=\'<ago>\')',
        calendarPartnerFresh(lang, 'Camille', '<ago>'),
      );
      put(
        'calendarSyncedFrom(name=\'Alex\', mine=true)',
        calendarSyncedFrom(lang, 'Alex', mine: true),
      );
      put(
        'calendarSyncedFrom(name=\'Alex\', mine=false)',
        calendarSyncedFrom(lang, 'Alex', mine: false),
      );
      put(
        'calendarSyncedFrom(name=\'Camille\', mine=true)',
        calendarSyncedFrom(lang, 'Camille', mine: true),
      );
      put(
        'calendarSyncedFrom(name=\'Camille\', mine=false)',
        calendarSyncedFrom(lang, 'Camille', mine: false),
      );
      put(
        'calendarSyncedReadOnly(name=\'Alex\', mine=true)',
        calendarSyncedReadOnly(lang, 'Alex', mine: true),
      );
      put(
        'calendarSyncedReadOnly(name=\'Alex\', mine=false)',
        calendarSyncedReadOnly(lang, 'Alex', mine: false),
      );
      put(
        'calendarSyncedReadOnly(name=\'Camille\', mine=true)',
        calendarSyncedReadOnly(lang, 'Camille', mine: true),
      );
      put(
        'calendarSyncedReadOnly(name=\'Camille\', mine=false)',
        calendarSyncedReadOnly(lang, 'Camille', mine: false),
      );
      put('calendarAllDay()', calendarAllDay(lang));
      put('cyclePartnerName(username=null)', cyclePartnerName(lang, null));
      put(
        'cyclePartnerName(username=\'Alex\')',
        cyclePartnerName(lang, 'Alex'),
      );
      put(
        'cyclePartnerName(username=\'Camille\')',
        cyclePartnerName(lang, 'Camille'),
      );
      put('cycleAskTitle()', cycleAskTitle(lang));
      put('cycleAskBody()', cycleAskBody(lang));
      put('cycleConsent()', cycleConsent(lang));
      put('cycleConsentTitle()', cycleConsentTitle(lang));
      put('cycleConsentAccept()', cycleConsentAccept(lang));
      put('cyclePrivacyPolicy()', cyclePrivacyPolicy(lang));
      put('cyclePrivacyUrl()', cyclePrivacyUrl(lang));
      put('cycleStopTitle()', cycleStopTitle(lang));
      put('cycleStopBody()', cycleStopBody(lang));
      put('cycleStopKeep()', cycleStopKeep(lang));
      put('cycleStopDelete()', cycleStopDelete(lang));
      put('cycleDataDeleted()', cycleDataDeleted(lang));
      put('cycleAskYes()', cycleAskYes(lang));
      put('cycleAskNo()', cycleAskNo(lang));
      put('settingsTracksCycle()', settingsTracksCycle(lang));
      put(
        'cyclePhaseLabel(phase=CyclePhase.menstrual)',
        cyclePhaseLabel(lang, CyclePhase.menstrual),
      );
      put(
        'cyclePhaseLabel(phase=CyclePhase.follicular)',
        cyclePhaseLabel(lang, CyclePhase.follicular),
      );
      put(
        'cyclePhaseLabel(phase=CyclePhase.ovulation)',
        cyclePhaseLabel(lang, CyclePhase.ovulation),
      );
      put(
        'cyclePhaseLabel(phase=CyclePhase.luteal)',
        cyclePhaseLabel(lang, CyclePhase.luteal),
      );
      put('cycleDayWord()', cycleDayWord(lang));
      put('cycleOfAbout(length=0)', cycleOfAbout(lang, 0));
      put('cycleOfAbout(length=1)', cycleOfAbout(lang, 1));
      put('cycleOfAbout(length=2)', cycleOfAbout(lang, 2));
      put('cycleOfAbout(length=5)', cycleOfAbout(lang, 5));
      put('cycleOfAbout(length=21)', cycleOfAbout(lang, 21));
      put('cycleRingLabel(day=0, length=0)', cycleRingLabel(lang, 0, 0));
      put('cycleRingLabel(day=0, length=1)', cycleRingLabel(lang, 0, 1));
      put('cycleRingLabel(day=0, length=2)', cycleRingLabel(lang, 0, 2));
      put('cycleRingLabel(day=0, length=5)', cycleRingLabel(lang, 0, 5));
      put('cycleRingLabel(day=0, length=21)', cycleRingLabel(lang, 0, 21));
      put('cycleRingLabel(day=1, length=0)', cycleRingLabel(lang, 1, 0));
      put('cycleRingLabel(day=1, length=1)', cycleRingLabel(lang, 1, 1));
      put('cycleRingLabel(day=1, length=2)', cycleRingLabel(lang, 1, 2));
      put('cycleRingLabel(day=1, length=5)', cycleRingLabel(lang, 1, 5));
      put('cycleRingLabel(day=1, length=21)', cycleRingLabel(lang, 1, 21));
      put('cycleRingLabel(day=2, length=0)', cycleRingLabel(lang, 2, 0));
      put('cycleRingLabel(day=2, length=1)', cycleRingLabel(lang, 2, 1));
      put('cycleRingLabel(day=2, length=2)', cycleRingLabel(lang, 2, 2));
      put('cycleRingLabel(day=2, length=5)', cycleRingLabel(lang, 2, 5));
      put('cycleRingLabel(day=2, length=21)', cycleRingLabel(lang, 2, 21));
      put('cycleRingLabel(day=5, length=0)', cycleRingLabel(lang, 5, 0));
      put('cycleRingLabel(day=5, length=1)', cycleRingLabel(lang, 5, 1));
      put('cycleRingLabel(day=5, length=2)', cycleRingLabel(lang, 5, 2));
      put('cycleRingLabel(day=5, length=5)', cycleRingLabel(lang, 5, 5));
      put('cycleRingLabel(day=5, length=21)', cycleRingLabel(lang, 5, 21));
      put('cycleRingLabel(day=21, length=0)', cycleRingLabel(lang, 21, 0));
      put('cycleRingLabel(day=21, length=1)', cycleRingLabel(lang, 21, 1));
      put('cycleRingLabel(day=21, length=2)', cycleRingLabel(lang, 21, 2));
      put('cycleRingLabel(day=21, length=5)', cycleRingLabel(lang, 21, 5));
      put('cycleRingLabel(day=21, length=21)', cycleRingLabel(lang, 21, 21));
      put(
        'cycleHeadline(ongoing=true, dayOfCycle=0, daysUntil=null)',
        cycleHeadline(lang, ongoing: true, dayOfCycle: 0, daysUntil: null),
      );
      put(
        'cycleHeadline(ongoing=true, dayOfCycle=0, daysUntil=-3)',
        cycleHeadline(lang, ongoing: true, dayOfCycle: 0, daysUntil: -3),
      );
      put(
        'cycleHeadline(ongoing=true, dayOfCycle=0, daysUntil=-1)',
        cycleHeadline(lang, ongoing: true, dayOfCycle: 0, daysUntil: -1),
      );
      put(
        'cycleHeadline(ongoing=true, dayOfCycle=0, daysUntil=0)',
        cycleHeadline(lang, ongoing: true, dayOfCycle: 0, daysUntil: 0),
      );
      put(
        'cycleHeadline(ongoing=true, dayOfCycle=0, daysUntil=1)',
        cycleHeadline(lang, ongoing: true, dayOfCycle: 0, daysUntil: 1),
      );
      put(
        'cycleHeadline(ongoing=true, dayOfCycle=0, daysUntil=2)',
        cycleHeadline(lang, ongoing: true, dayOfCycle: 0, daysUntil: 2),
      );
      put(
        'cycleHeadline(ongoing=true, dayOfCycle=0, daysUntil=5)',
        cycleHeadline(lang, ongoing: true, dayOfCycle: 0, daysUntil: 5),
      );
      put(
        'cycleHeadline(ongoing=true, dayOfCycle=1, daysUntil=null)',
        cycleHeadline(lang, ongoing: true, dayOfCycle: 1, daysUntil: null),
      );
      put(
        'cycleHeadline(ongoing=true, dayOfCycle=1, daysUntil=-3)',
        cycleHeadline(lang, ongoing: true, dayOfCycle: 1, daysUntil: -3),
      );
      put(
        'cycleHeadline(ongoing=true, dayOfCycle=1, daysUntil=-1)',
        cycleHeadline(lang, ongoing: true, dayOfCycle: 1, daysUntil: -1),
      );
      put(
        'cycleHeadline(ongoing=true, dayOfCycle=1, daysUntil=0)',
        cycleHeadline(lang, ongoing: true, dayOfCycle: 1, daysUntil: 0),
      );
      put(
        'cycleHeadline(ongoing=true, dayOfCycle=1, daysUntil=1)',
        cycleHeadline(lang, ongoing: true, dayOfCycle: 1, daysUntil: 1),
      );
      put(
        'cycleHeadline(ongoing=true, dayOfCycle=1, daysUntil=2)',
        cycleHeadline(lang, ongoing: true, dayOfCycle: 1, daysUntil: 2),
      );
      put(
        'cycleHeadline(ongoing=true, dayOfCycle=1, daysUntil=5)',
        cycleHeadline(lang, ongoing: true, dayOfCycle: 1, daysUntil: 5),
      );
      put(
        'cycleHeadline(ongoing=true, dayOfCycle=2, daysUntil=null)',
        cycleHeadline(lang, ongoing: true, dayOfCycle: 2, daysUntil: null),
      );
      put(
        'cycleHeadline(ongoing=true, dayOfCycle=2, daysUntil=-3)',
        cycleHeadline(lang, ongoing: true, dayOfCycle: 2, daysUntil: -3),
      );
      put(
        'cycleHeadline(ongoing=true, dayOfCycle=2, daysUntil=-1)',
        cycleHeadline(lang, ongoing: true, dayOfCycle: 2, daysUntil: -1),
      );
      put(
        'cycleHeadline(ongoing=true, dayOfCycle=2, daysUntil=0)',
        cycleHeadline(lang, ongoing: true, dayOfCycle: 2, daysUntil: 0),
      );
      put(
        'cycleHeadline(ongoing=true, dayOfCycle=2, daysUntil=1)',
        cycleHeadline(lang, ongoing: true, dayOfCycle: 2, daysUntil: 1),
      );
      put(
        'cycleHeadline(ongoing=true, dayOfCycle=2, daysUntil=2)',
        cycleHeadline(lang, ongoing: true, dayOfCycle: 2, daysUntil: 2),
      );
      put(
        'cycleHeadline(ongoing=true, dayOfCycle=2, daysUntil=5)',
        cycleHeadline(lang, ongoing: true, dayOfCycle: 2, daysUntil: 5),
      );
      put(
        'cycleHeadline(ongoing=true, dayOfCycle=5, daysUntil=null)',
        cycleHeadline(lang, ongoing: true, dayOfCycle: 5, daysUntil: null),
      );
      put(
        'cycleHeadline(ongoing=true, dayOfCycle=5, daysUntil=-3)',
        cycleHeadline(lang, ongoing: true, dayOfCycle: 5, daysUntil: -3),
      );
      put(
        'cycleHeadline(ongoing=true, dayOfCycle=5, daysUntil=-1)',
        cycleHeadline(lang, ongoing: true, dayOfCycle: 5, daysUntil: -1),
      );
      put(
        'cycleHeadline(ongoing=true, dayOfCycle=5, daysUntil=0)',
        cycleHeadline(lang, ongoing: true, dayOfCycle: 5, daysUntil: 0),
      );
      put(
        'cycleHeadline(ongoing=true, dayOfCycle=5, daysUntil=1)',
        cycleHeadline(lang, ongoing: true, dayOfCycle: 5, daysUntil: 1),
      );
      put(
        'cycleHeadline(ongoing=true, dayOfCycle=5, daysUntil=2)',
        cycleHeadline(lang, ongoing: true, dayOfCycle: 5, daysUntil: 2),
      );
      put(
        'cycleHeadline(ongoing=true, dayOfCycle=5, daysUntil=5)',
        cycleHeadline(lang, ongoing: true, dayOfCycle: 5, daysUntil: 5),
      );
      put(
        'cycleHeadline(ongoing=true, dayOfCycle=21, daysUntil=null)',
        cycleHeadline(lang, ongoing: true, dayOfCycle: 21, daysUntil: null),
      );
      put(
        'cycleHeadline(ongoing=true, dayOfCycle=21, daysUntil=-3)',
        cycleHeadline(lang, ongoing: true, dayOfCycle: 21, daysUntil: -3),
      );
      put(
        'cycleHeadline(ongoing=true, dayOfCycle=21, daysUntil=-1)',
        cycleHeadline(lang, ongoing: true, dayOfCycle: 21, daysUntil: -1),
      );
      put(
        'cycleHeadline(ongoing=true, dayOfCycle=21, daysUntil=0)',
        cycleHeadline(lang, ongoing: true, dayOfCycle: 21, daysUntil: 0),
      );
      put(
        'cycleHeadline(ongoing=true, dayOfCycle=21, daysUntil=1)',
        cycleHeadline(lang, ongoing: true, dayOfCycle: 21, daysUntil: 1),
      );
      put(
        'cycleHeadline(ongoing=true, dayOfCycle=21, daysUntil=2)',
        cycleHeadline(lang, ongoing: true, dayOfCycle: 21, daysUntil: 2),
      );
      put(
        'cycleHeadline(ongoing=true, dayOfCycle=21, daysUntil=5)',
        cycleHeadline(lang, ongoing: true, dayOfCycle: 21, daysUntil: 5),
      );
      put(
        'cycleHeadline(ongoing=false, dayOfCycle=0, daysUntil=null)',
        cycleHeadline(lang, ongoing: false, dayOfCycle: 0, daysUntil: null),
      );
      put(
        'cycleHeadline(ongoing=false, dayOfCycle=0, daysUntil=-3)',
        cycleHeadline(lang, ongoing: false, dayOfCycle: 0, daysUntil: -3),
      );
      put(
        'cycleHeadline(ongoing=false, dayOfCycle=0, daysUntil=-1)',
        cycleHeadline(lang, ongoing: false, dayOfCycle: 0, daysUntil: -1),
      );
      put(
        'cycleHeadline(ongoing=false, dayOfCycle=0, daysUntil=0)',
        cycleHeadline(lang, ongoing: false, dayOfCycle: 0, daysUntil: 0),
      );
      put(
        'cycleHeadline(ongoing=false, dayOfCycle=0, daysUntil=1)',
        cycleHeadline(lang, ongoing: false, dayOfCycle: 0, daysUntil: 1),
      );
      put(
        'cycleHeadline(ongoing=false, dayOfCycle=0, daysUntil=2)',
        cycleHeadline(lang, ongoing: false, dayOfCycle: 0, daysUntil: 2),
      );
      put(
        'cycleHeadline(ongoing=false, dayOfCycle=0, daysUntil=5)',
        cycleHeadline(lang, ongoing: false, dayOfCycle: 0, daysUntil: 5),
      );
      put(
        'cycleHeadline(ongoing=false, dayOfCycle=1, daysUntil=null)',
        cycleHeadline(lang, ongoing: false, dayOfCycle: 1, daysUntil: null),
      );
      put(
        'cycleHeadline(ongoing=false, dayOfCycle=1, daysUntil=-3)',
        cycleHeadline(lang, ongoing: false, dayOfCycle: 1, daysUntil: -3),
      );
      put(
        'cycleHeadline(ongoing=false, dayOfCycle=1, daysUntil=-1)',
        cycleHeadline(lang, ongoing: false, dayOfCycle: 1, daysUntil: -1),
      );
      put(
        'cycleHeadline(ongoing=false, dayOfCycle=1, daysUntil=0)',
        cycleHeadline(lang, ongoing: false, dayOfCycle: 1, daysUntil: 0),
      );
      put(
        'cycleHeadline(ongoing=false, dayOfCycle=1, daysUntil=1)',
        cycleHeadline(lang, ongoing: false, dayOfCycle: 1, daysUntil: 1),
      );
      put(
        'cycleHeadline(ongoing=false, dayOfCycle=1, daysUntil=2)',
        cycleHeadline(lang, ongoing: false, dayOfCycle: 1, daysUntil: 2),
      );
      put(
        'cycleHeadline(ongoing=false, dayOfCycle=1, daysUntil=5)',
        cycleHeadline(lang, ongoing: false, dayOfCycle: 1, daysUntil: 5),
      );
      put(
        'cycleHeadline(ongoing=false, dayOfCycle=2, daysUntil=null)',
        cycleHeadline(lang, ongoing: false, dayOfCycle: 2, daysUntil: null),
      );
      put(
        'cycleHeadline(ongoing=false, dayOfCycle=2, daysUntil=-3)',
        cycleHeadline(lang, ongoing: false, dayOfCycle: 2, daysUntil: -3),
      );
      put(
        'cycleHeadline(ongoing=false, dayOfCycle=2, daysUntil=-1)',
        cycleHeadline(lang, ongoing: false, dayOfCycle: 2, daysUntil: -1),
      );
      put(
        'cycleHeadline(ongoing=false, dayOfCycle=2, daysUntil=0)',
        cycleHeadline(lang, ongoing: false, dayOfCycle: 2, daysUntil: 0),
      );
      put(
        'cycleHeadline(ongoing=false, dayOfCycle=2, daysUntil=1)',
        cycleHeadline(lang, ongoing: false, dayOfCycle: 2, daysUntil: 1),
      );
      put(
        'cycleHeadline(ongoing=false, dayOfCycle=2, daysUntil=2)',
        cycleHeadline(lang, ongoing: false, dayOfCycle: 2, daysUntil: 2),
      );
      put(
        'cycleHeadline(ongoing=false, dayOfCycle=2, daysUntil=5)',
        cycleHeadline(lang, ongoing: false, dayOfCycle: 2, daysUntil: 5),
      );
      put(
        'cycleHeadline(ongoing=false, dayOfCycle=5, daysUntil=null)',
        cycleHeadline(lang, ongoing: false, dayOfCycle: 5, daysUntil: null),
      );
      put(
        'cycleHeadline(ongoing=false, dayOfCycle=5, daysUntil=-3)',
        cycleHeadline(lang, ongoing: false, dayOfCycle: 5, daysUntil: -3),
      );
      put(
        'cycleHeadline(ongoing=false, dayOfCycle=5, daysUntil=-1)',
        cycleHeadline(lang, ongoing: false, dayOfCycle: 5, daysUntil: -1),
      );
      put(
        'cycleHeadline(ongoing=false, dayOfCycle=5, daysUntil=0)',
        cycleHeadline(lang, ongoing: false, dayOfCycle: 5, daysUntil: 0),
      );
      put(
        'cycleHeadline(ongoing=false, dayOfCycle=5, daysUntil=1)',
        cycleHeadline(lang, ongoing: false, dayOfCycle: 5, daysUntil: 1),
      );
      put(
        'cycleHeadline(ongoing=false, dayOfCycle=5, daysUntil=2)',
        cycleHeadline(lang, ongoing: false, dayOfCycle: 5, daysUntil: 2),
      );
      put(
        'cycleHeadline(ongoing=false, dayOfCycle=5, daysUntil=5)',
        cycleHeadline(lang, ongoing: false, dayOfCycle: 5, daysUntil: 5),
      );
      put(
        'cycleHeadline(ongoing=false, dayOfCycle=21, daysUntil=null)',
        cycleHeadline(lang, ongoing: false, dayOfCycle: 21, daysUntil: null),
      );
      put(
        'cycleHeadline(ongoing=false, dayOfCycle=21, daysUntil=-3)',
        cycleHeadline(lang, ongoing: false, dayOfCycle: 21, daysUntil: -3),
      );
      put(
        'cycleHeadline(ongoing=false, dayOfCycle=21, daysUntil=-1)',
        cycleHeadline(lang, ongoing: false, dayOfCycle: 21, daysUntil: -1),
      );
      put(
        'cycleHeadline(ongoing=false, dayOfCycle=21, daysUntil=0)',
        cycleHeadline(lang, ongoing: false, dayOfCycle: 21, daysUntil: 0),
      );
      put(
        'cycleHeadline(ongoing=false, dayOfCycle=21, daysUntil=1)',
        cycleHeadline(lang, ongoing: false, dayOfCycle: 21, daysUntil: 1),
      );
      put(
        'cycleHeadline(ongoing=false, dayOfCycle=21, daysUntil=2)',
        cycleHeadline(lang, ongoing: false, dayOfCycle: 21, daysUntil: 2),
      );
      put(
        'cycleHeadline(ongoing=false, dayOfCycle=21, daysUntil=5)',
        cycleHeadline(lang, ongoing: false, dayOfCycle: 21, daysUntil: 5),
      );
      put(
        'cycleBasis(next=DateTime(2026, 3, 1), cyclesUsed=0)',
        cycleBasis(lang, DateTime(2026, 3, 1), 0),
      );
      put(
        'cycleBasis(next=DateTime(2026, 3, 1), cyclesUsed=1)',
        cycleBasis(lang, DateTime(2026, 3, 1), 1),
      );
      put(
        'cycleBasis(next=DateTime(2026, 3, 1), cyclesUsed=2)',
        cycleBasis(lang, DateTime(2026, 3, 1), 2),
      );
      put(
        'cycleBasis(next=DateTime(2026, 3, 1), cyclesUsed=5)',
        cycleBasis(lang, DateTime(2026, 3, 1), 5),
      );
      put(
        'cycleBasis(next=DateTime(2026, 3, 1), cyclesUsed=21)',
        cycleBasis(lang, DateTime(2026, 3, 1), 21),
      );
      put(
        'cycleBasis(next=DateTime(2026, 11, 17, 9, 5), cyclesUsed=0)',
        cycleBasis(lang, DateTime(2026, 11, 17, 9, 5), 0),
      );
      put(
        'cycleBasis(next=DateTime(2026, 11, 17, 9, 5), cyclesUsed=1)',
        cycleBasis(lang, DateTime(2026, 11, 17, 9, 5), 1),
      );
      put(
        'cycleBasis(next=DateTime(2026, 11, 17, 9, 5), cyclesUsed=2)',
        cycleBasis(lang, DateTime(2026, 11, 17, 9, 5), 2),
      );
      put(
        'cycleBasis(next=DateTime(2026, 11, 17, 9, 5), cyclesUsed=5)',
        cycleBasis(lang, DateTime(2026, 11, 17, 9, 5), 5),
      );
      put(
        'cycleBasis(next=DateTime(2026, 11, 17, 9, 5), cyclesUsed=21)',
        cycleBasis(lang, DateTime(2026, 11, 17, 9, 5), 21),
      );
      put('cycleNoDataTitle()', cycleNoDataTitle(lang));
      put('cycleNoDataBody()', cycleNoDataBody(lang));
      put('cycleStarted()', cycleStarted(lang));
      put('cycleEnded()', cycleEnded(lang));
      put('cycleOtherDay()', cycleOtherDay(lang));
      put('cycleToday()', cycleToday(lang));
      put('cycleSeenBy(name=\'Alex\')', cycleSeenBy(lang, 'Alex'));
      put('cycleSeenBy(name=\'Camille\')', cycleSeenBy(lang, 'Camille'));
      put('cycleSeenByNobody()', cycleSeenByNobody(lang));
      put('cycleNoteLabel()', cycleNoteLabel(lang));
      put('cycleNoteHint()', cycleNoteHint(lang));
      put('cycleNoteSaved()', cycleNoteSaved(lang));
      put('cycleThisWeek()', cycleThisWeek(lang));
      put('cycleReadChapter(title=\'Alex\')', cycleReadChapter(lang, 'Alex'));
      put(
        'cycleReadChapter(title=\'Camille\')',
        cycleReadChapter(lang, 'Camille'),
      );
      put('cycleHistoryLink()', cycleHistoryLink(lang));
      put('cycleSharingLink(name=\'Alex\')', cycleSharingLink(lang, 'Alex'));
      put(
        'cycleSharingLink(name=\'Camille\')',
        cycleSharingLink(lang, 'Camille'),
      );
      put('cyclePartnerLink(name=\'Alex\')', cyclePartnerLink(lang, 'Alex'));
      put(
        'cyclePartnerLink(name=\'Camille\')',
        cyclePartnerLink(lang, 'Camille'),
      );
      put(
        'cycleLoggedStart(day=DateTime(2026, 3, 1))',
        cycleLoggedStart(lang, DateTime(2026, 3, 1)),
      );
      put(
        'cycleLoggedStart(day=DateTime(2026, 11, 17, 9, 5))',
        cycleLoggedStart(lang, DateTime(2026, 11, 17, 9, 5)),
      );
      put(
        'cycleLoggedEnd(day=DateTime(2026, 3, 1))',
        cycleLoggedEnd(lang, DateTime(2026, 3, 1)),
      );
      put(
        'cycleLoggedEnd(day=DateTime(2026, 11, 17, 9, 5))',
        cycleLoggedEnd(lang, DateTime(2026, 11, 17, 9, 5)),
      );
      put('cycleUndo()', cycleUndo(lang));
      put(
        'cycleShortDate(day=DateTime(2026, 3, 1))',
        cycleShortDate(lang, DateTime(2026, 3, 1)),
      );
      put(
        'cycleShortDate(day=DateTime(2026, 11, 17, 9, 5))',
        cycleShortDate(lang, DateTime(2026, 11, 17, 9, 5)),
      );
      put('cycleOtherState()', cycleOtherState(lang));
      put('cycleNewStateHint()', cycleNewStateHint(lang));
      put('cycleAddState()', cycleAddState(lang));
      put('cycleOwnStateHint()', cycleOwnStateHint(lang));
      put(
        'cycleStateRemoved(state=\'<state>\')',
        cycleStateRemoved(lang, '<state>'),
      );
      put('cycleTooManyStates()', cycleTooManyStates(lang));
      put('cycleSaveFailed()', cycleSaveFailed(lang));
      put('cycleNeedsCouple()', cycleNeedsCouple(lang));
      put(
        'cycleSelfTip(phase=CyclePhase.menstrual)',
        cycleSelfTip(lang, CyclePhase.menstrual),
      );
      put(
        'cycleSelfTip(phase=CyclePhase.follicular)',
        cycleSelfTip(lang, CyclePhase.follicular),
      );
      put(
        'cycleSelfTip(phase=CyclePhase.ovulation)',
        cycleSelfTip(lang, CyclePhase.ovulation),
      );
      put(
        'cycleSelfTip(phase=CyclePhase.luteal)',
        cycleSelfTip(lang, CyclePhase.luteal),
      );
      put('cycleSheetStarted()', cycleSheetStarted(lang));
      put('cycleSheetEnded()', cycleSheetEnded(lang));
      put('cycleSheetWhen()', cycleSheetWhen(lang));
      put('cycleYesterday()', cycleYesterday(lang));
      put('cycleAnotherDay()', cycleAnotherDay(lang));
      put('cycleSave()', cycleSave(lang));
      put('cycleSheetFootnote()', cycleSheetFootnote(lang));
      put('cycleHistoryTitle()', cycleHistoryTitle(lang));
      put('cycleAverage()', cycleAverage(lang));
      put('cyclePeriod()', cyclePeriod(lang));
      put('cycleDaysWord()', cycleDaysWord(lang));
      put(
        'cycleRegularity(count=0, shortest=0, longest=0)',
        cycleRegularity(lang, 0, 0, 0),
      );
      put(
        'cycleRegularity(count=0, shortest=0, longest=1)',
        cycleRegularity(lang, 0, 0, 1),
      );
      put(
        'cycleRegularity(count=0, shortest=0, longest=2)',
        cycleRegularity(lang, 0, 0, 2),
      );
      put(
        'cycleRegularity(count=0, shortest=0, longest=5)',
        cycleRegularity(lang, 0, 0, 5),
      );
      put(
        'cycleRegularity(count=0, shortest=0, longest=21)',
        cycleRegularity(lang, 0, 0, 21),
      );
      put(
        'cycleRegularity(count=0, shortest=1, longest=0)',
        cycleRegularity(lang, 0, 1, 0),
      );
      put(
        'cycleRegularity(count=0, shortest=1, longest=1)',
        cycleRegularity(lang, 0, 1, 1),
      );
      put(
        'cycleRegularity(count=0, shortest=1, longest=2)',
        cycleRegularity(lang, 0, 1, 2),
      );
      put(
        'cycleRegularity(count=0, shortest=1, longest=5)',
        cycleRegularity(lang, 0, 1, 5),
      );
      put(
        'cycleRegularity(count=0, shortest=1, longest=21)',
        cycleRegularity(lang, 0, 1, 21),
      );
      put(
        'cycleRegularity(count=0, shortest=2, longest=0)',
        cycleRegularity(lang, 0, 2, 0),
      );
      put(
        'cycleRegularity(count=0, shortest=2, longest=1)',
        cycleRegularity(lang, 0, 2, 1),
      );
      put(
        'cycleRegularity(count=0, shortest=2, longest=2)',
        cycleRegularity(lang, 0, 2, 2),
      );
      put(
        'cycleRegularity(count=0, shortest=2, longest=5)',
        cycleRegularity(lang, 0, 2, 5),
      );
      put(
        'cycleRegularity(count=0, shortest=2, longest=21)',
        cycleRegularity(lang, 0, 2, 21),
      );
      put(
        'cycleRegularity(count=0, shortest=5, longest=0)',
        cycleRegularity(lang, 0, 5, 0),
      );
      put(
        'cycleRegularity(count=0, shortest=5, longest=1)',
        cycleRegularity(lang, 0, 5, 1),
      );
      put(
        'cycleRegularity(count=0, shortest=5, longest=2)',
        cycleRegularity(lang, 0, 5, 2),
      );
      put(
        'cycleRegularity(count=0, shortest=5, longest=5)',
        cycleRegularity(lang, 0, 5, 5),
      );
      put(
        'cycleRegularity(count=0, shortest=5, longest=21)',
        cycleRegularity(lang, 0, 5, 21),
      );
      put(
        'cycleRegularity(count=0, shortest=21, longest=0)',
        cycleRegularity(lang, 0, 21, 0),
      );
      put(
        'cycleRegularity(count=0, shortest=21, longest=1)',
        cycleRegularity(lang, 0, 21, 1),
      );
      put(
        'cycleRegularity(count=0, shortest=21, longest=2)',
        cycleRegularity(lang, 0, 21, 2),
      );
      put(
        'cycleRegularity(count=0, shortest=21, longest=5)',
        cycleRegularity(lang, 0, 21, 5),
      );
      put(
        'cycleRegularity(count=0, shortest=21, longest=21)',
        cycleRegularity(lang, 0, 21, 21),
      );
      put(
        'cycleRegularity(count=1, shortest=0, longest=0)',
        cycleRegularity(lang, 1, 0, 0),
      );
      put(
        'cycleRegularity(count=1, shortest=0, longest=1)',
        cycleRegularity(lang, 1, 0, 1),
      );
      put(
        'cycleRegularity(count=1, shortest=0, longest=2)',
        cycleRegularity(lang, 1, 0, 2),
      );
      put(
        'cycleRegularity(count=1, shortest=0, longest=5)',
        cycleRegularity(lang, 1, 0, 5),
      );
      put(
        'cycleRegularity(count=1, shortest=0, longest=21)',
        cycleRegularity(lang, 1, 0, 21),
      );
      put(
        'cycleRegularity(count=1, shortest=1, longest=0)',
        cycleRegularity(lang, 1, 1, 0),
      );
      put(
        'cycleRegularity(count=1, shortest=1, longest=1)',
        cycleRegularity(lang, 1, 1, 1),
      );
      put(
        'cycleRegularity(count=1, shortest=1, longest=2)',
        cycleRegularity(lang, 1, 1, 2),
      );
      put(
        'cycleRegularity(count=1, shortest=1, longest=5)',
        cycleRegularity(lang, 1, 1, 5),
      );
      put(
        'cycleRegularity(count=1, shortest=1, longest=21)',
        cycleRegularity(lang, 1, 1, 21),
      );
      put(
        'cycleRegularity(count=1, shortest=2, longest=0)',
        cycleRegularity(lang, 1, 2, 0),
      );
      put(
        'cycleRegularity(count=1, shortest=2, longest=1)',
        cycleRegularity(lang, 1, 2, 1),
      );
      put(
        'cycleRegularity(count=1, shortest=2, longest=2)',
        cycleRegularity(lang, 1, 2, 2),
      );
      put(
        'cycleRegularity(count=1, shortest=2, longest=5)',
        cycleRegularity(lang, 1, 2, 5),
      );
      put(
        'cycleRegularity(count=1, shortest=2, longest=21)',
        cycleRegularity(lang, 1, 2, 21),
      );
      put(
        'cycleRegularity(count=1, shortest=5, longest=0)',
        cycleRegularity(lang, 1, 5, 0),
      );
      put(
        'cycleRegularity(count=1, shortest=5, longest=1)',
        cycleRegularity(lang, 1, 5, 1),
      );
      put(
        'cycleRegularity(count=1, shortest=5, longest=2)',
        cycleRegularity(lang, 1, 5, 2),
      );
      put(
        'cycleRegularity(count=1, shortest=5, longest=5)',
        cycleRegularity(lang, 1, 5, 5),
      );
      put(
        'cycleRegularity(count=1, shortest=5, longest=21)',
        cycleRegularity(lang, 1, 5, 21),
      );
      put(
        'cycleRegularity(count=1, shortest=21, longest=0)',
        cycleRegularity(lang, 1, 21, 0),
      );
      put(
        'cycleRegularity(count=1, shortest=21, longest=1)',
        cycleRegularity(lang, 1, 21, 1),
      );
      put(
        'cycleRegularity(count=1, shortest=21, longest=2)',
        cycleRegularity(lang, 1, 21, 2),
      );
      put(
        'cycleRegularity(count=1, shortest=21, longest=5)',
        cycleRegularity(lang, 1, 21, 5),
      );
      put(
        'cycleRegularity(count=1, shortest=21, longest=21)',
        cycleRegularity(lang, 1, 21, 21),
      );
      put(
        'cycleRegularity(count=2, shortest=0, longest=0)',
        cycleRegularity(lang, 2, 0, 0),
      );
      put(
        'cycleRegularity(count=2, shortest=0, longest=1)',
        cycleRegularity(lang, 2, 0, 1),
      );
      put(
        'cycleRegularity(count=2, shortest=0, longest=2)',
        cycleRegularity(lang, 2, 0, 2),
      );
      put(
        'cycleRegularity(count=2, shortest=0, longest=5)',
        cycleRegularity(lang, 2, 0, 5),
      );
      put(
        'cycleRegularity(count=2, shortest=0, longest=21)',
        cycleRegularity(lang, 2, 0, 21),
      );
      put(
        'cycleRegularity(count=2, shortest=1, longest=0)',
        cycleRegularity(lang, 2, 1, 0),
      );
      put(
        'cycleRegularity(count=2, shortest=1, longest=1)',
        cycleRegularity(lang, 2, 1, 1),
      );
      put(
        'cycleRegularity(count=2, shortest=1, longest=2)',
        cycleRegularity(lang, 2, 1, 2),
      );
      put(
        'cycleRegularity(count=2, shortest=1, longest=5)',
        cycleRegularity(lang, 2, 1, 5),
      );
      put(
        'cycleRegularity(count=2, shortest=1, longest=21)',
        cycleRegularity(lang, 2, 1, 21),
      );
      put(
        'cycleRegularity(count=2, shortest=2, longest=0)',
        cycleRegularity(lang, 2, 2, 0),
      );
      put(
        'cycleRegularity(count=2, shortest=2, longest=1)',
        cycleRegularity(lang, 2, 2, 1),
      );
      put(
        'cycleRegularity(count=2, shortest=2, longest=2)',
        cycleRegularity(lang, 2, 2, 2),
      );
      put(
        'cycleRegularity(count=2, shortest=2, longest=5)',
        cycleRegularity(lang, 2, 2, 5),
      );
      put(
        'cycleRegularity(count=2, shortest=2, longest=21)',
        cycleRegularity(lang, 2, 2, 21),
      );
      put(
        'cycleRegularity(count=2, shortest=5, longest=0)',
        cycleRegularity(lang, 2, 5, 0),
      );
      put(
        'cycleRegularity(count=2, shortest=5, longest=1)',
        cycleRegularity(lang, 2, 5, 1),
      );
      put(
        'cycleRegularity(count=2, shortest=5, longest=2)',
        cycleRegularity(lang, 2, 5, 2),
      );
      put(
        'cycleRegularity(count=2, shortest=5, longest=5)',
        cycleRegularity(lang, 2, 5, 5),
      );
      put(
        'cycleRegularity(count=2, shortest=5, longest=21)',
        cycleRegularity(lang, 2, 5, 21),
      );
      put(
        'cycleRegularity(count=2, shortest=21, longest=0)',
        cycleRegularity(lang, 2, 21, 0),
      );
      put(
        'cycleRegularity(count=2, shortest=21, longest=1)',
        cycleRegularity(lang, 2, 21, 1),
      );
      put(
        'cycleRegularity(count=2, shortest=21, longest=2)',
        cycleRegularity(lang, 2, 21, 2),
      );
      put(
        'cycleRegularity(count=2, shortest=21, longest=5)',
        cycleRegularity(lang, 2, 21, 5),
      );
      put(
        'cycleRegularity(count=2, shortest=21, longest=21)',
        cycleRegularity(lang, 2, 21, 21),
      );
      put(
        'cycleRegularity(count=5, shortest=0, longest=0)',
        cycleRegularity(lang, 5, 0, 0),
      );
      put(
        'cycleRegularity(count=5, shortest=0, longest=1)',
        cycleRegularity(lang, 5, 0, 1),
      );
      put(
        'cycleRegularity(count=5, shortest=0, longest=2)',
        cycleRegularity(lang, 5, 0, 2),
      );
      put(
        'cycleRegularity(count=5, shortest=0, longest=5)',
        cycleRegularity(lang, 5, 0, 5),
      );
      put(
        'cycleRegularity(count=5, shortest=0, longest=21)',
        cycleRegularity(lang, 5, 0, 21),
      );
      put(
        'cycleRegularity(count=5, shortest=1, longest=0)',
        cycleRegularity(lang, 5, 1, 0),
      );
      put(
        'cycleRegularity(count=5, shortest=1, longest=1)',
        cycleRegularity(lang, 5, 1, 1),
      );
      put(
        'cycleRegularity(count=5, shortest=1, longest=2)',
        cycleRegularity(lang, 5, 1, 2),
      );
      put(
        'cycleRegularity(count=5, shortest=1, longest=5)',
        cycleRegularity(lang, 5, 1, 5),
      );
      put(
        'cycleRegularity(count=5, shortest=1, longest=21)',
        cycleRegularity(lang, 5, 1, 21),
      );
      put(
        'cycleRegularity(count=5, shortest=2, longest=0)',
        cycleRegularity(lang, 5, 2, 0),
      );
      put(
        'cycleRegularity(count=5, shortest=2, longest=1)',
        cycleRegularity(lang, 5, 2, 1),
      );
      put(
        'cycleRegularity(count=5, shortest=2, longest=2)',
        cycleRegularity(lang, 5, 2, 2),
      );
      put(
        'cycleRegularity(count=5, shortest=2, longest=5)',
        cycleRegularity(lang, 5, 2, 5),
      );
      put(
        'cycleRegularity(count=5, shortest=2, longest=21)',
        cycleRegularity(lang, 5, 2, 21),
      );
      put(
        'cycleRegularity(count=5, shortest=5, longest=0)',
        cycleRegularity(lang, 5, 5, 0),
      );
      put(
        'cycleRegularity(count=5, shortest=5, longest=1)',
        cycleRegularity(lang, 5, 5, 1),
      );
      put(
        'cycleRegularity(count=5, shortest=5, longest=2)',
        cycleRegularity(lang, 5, 5, 2),
      );
      put(
        'cycleRegularity(count=5, shortest=5, longest=5)',
        cycleRegularity(lang, 5, 5, 5),
      );
      put(
        'cycleRegularity(count=5, shortest=5, longest=21)',
        cycleRegularity(lang, 5, 5, 21),
      );
      put(
        'cycleRegularity(count=5, shortest=21, longest=0)',
        cycleRegularity(lang, 5, 21, 0),
      );
      put(
        'cycleRegularity(count=5, shortest=21, longest=1)',
        cycleRegularity(lang, 5, 21, 1),
      );
      put(
        'cycleRegularity(count=5, shortest=21, longest=2)',
        cycleRegularity(lang, 5, 21, 2),
      );
      put(
        'cycleRegularity(count=5, shortest=21, longest=5)',
        cycleRegularity(lang, 5, 21, 5),
      );
      put(
        'cycleRegularity(count=5, shortest=21, longest=21)',
        cycleRegularity(lang, 5, 21, 21),
      );
      put(
        'cycleRegularity(count=21, shortest=0, longest=0)',
        cycleRegularity(lang, 21, 0, 0),
      );
      put(
        'cycleRegularity(count=21, shortest=0, longest=1)',
        cycleRegularity(lang, 21, 0, 1),
      );
      put(
        'cycleRegularity(count=21, shortest=0, longest=2)',
        cycleRegularity(lang, 21, 0, 2),
      );
      put(
        'cycleRegularity(count=21, shortest=0, longest=5)',
        cycleRegularity(lang, 21, 0, 5),
      );
      put(
        'cycleRegularity(count=21, shortest=0, longest=21)',
        cycleRegularity(lang, 21, 0, 21),
      );
      put(
        'cycleRegularity(count=21, shortest=1, longest=0)',
        cycleRegularity(lang, 21, 1, 0),
      );
      put(
        'cycleRegularity(count=21, shortest=1, longest=1)',
        cycleRegularity(lang, 21, 1, 1),
      );
      put(
        'cycleRegularity(count=21, shortest=1, longest=2)',
        cycleRegularity(lang, 21, 1, 2),
      );
      put(
        'cycleRegularity(count=21, shortest=1, longest=5)',
        cycleRegularity(lang, 21, 1, 5),
      );
      put(
        'cycleRegularity(count=21, shortest=1, longest=21)',
        cycleRegularity(lang, 21, 1, 21),
      );
      put(
        'cycleRegularity(count=21, shortest=2, longest=0)',
        cycleRegularity(lang, 21, 2, 0),
      );
      put(
        'cycleRegularity(count=21, shortest=2, longest=1)',
        cycleRegularity(lang, 21, 2, 1),
      );
      put(
        'cycleRegularity(count=21, shortest=2, longest=2)',
        cycleRegularity(lang, 21, 2, 2),
      );
      put(
        'cycleRegularity(count=21, shortest=2, longest=5)',
        cycleRegularity(lang, 21, 2, 5),
      );
      put(
        'cycleRegularity(count=21, shortest=2, longest=21)',
        cycleRegularity(lang, 21, 2, 21),
      );
      put(
        'cycleRegularity(count=21, shortest=5, longest=0)',
        cycleRegularity(lang, 21, 5, 0),
      );
      put(
        'cycleRegularity(count=21, shortest=5, longest=1)',
        cycleRegularity(lang, 21, 5, 1),
      );
      put(
        'cycleRegularity(count=21, shortest=5, longest=2)',
        cycleRegularity(lang, 21, 5, 2),
      );
      put(
        'cycleRegularity(count=21, shortest=5, longest=5)',
        cycleRegularity(lang, 21, 5, 5),
      );
      put(
        'cycleRegularity(count=21, shortest=5, longest=21)',
        cycleRegularity(lang, 21, 5, 21),
      );
      put(
        'cycleRegularity(count=21, shortest=21, longest=0)',
        cycleRegularity(lang, 21, 21, 0),
      );
      put(
        'cycleRegularity(count=21, shortest=21, longest=1)',
        cycleRegularity(lang, 21, 21, 1),
      );
      put(
        'cycleRegularity(count=21, shortest=21, longest=2)',
        cycleRegularity(lang, 21, 21, 2),
      );
      put(
        'cycleRegularity(count=21, shortest=21, longest=5)',
        cycleRegularity(lang, 21, 21, 5),
      );
      put(
        'cycleRegularity(count=21, shortest=21, longest=21)',
        cycleRegularity(lang, 21, 21, 21),
      );
      put('cycleNeedTwo()', cycleNeedTwo(lang));
      put('cycleCurrentRow(day=0)', cycleCurrentRow(lang, 0));
      put('cycleCurrentRow(day=1)', cycleCurrentRow(lang, 1));
      put('cycleCurrentRow(day=2)', cycleCurrentRow(lang, 2));
      put('cycleCurrentRow(day=5)', cycleCurrentRow(lang, 5));
      put('cycleCurrentRow(day=21)', cycleCurrentRow(lang, 21));
      put(
        'cycleSpanRow(length=0, periodDays=null)',
        cycleSpanRow(lang, 0, null),
      );
      put('cycleSpanRow(length=0, periodDays=0)', cycleSpanRow(lang, 0, 0));
      put('cycleSpanRow(length=0, periodDays=1)', cycleSpanRow(lang, 0, 1));
      put('cycleSpanRow(length=0, periodDays=2)', cycleSpanRow(lang, 0, 2));
      put('cycleSpanRow(length=0, periodDays=5)', cycleSpanRow(lang, 0, 5));
      put('cycleSpanRow(length=0, periodDays=21)', cycleSpanRow(lang, 0, 21));
      put(
        'cycleSpanRow(length=1, periodDays=null)',
        cycleSpanRow(lang, 1, null),
      );
      put('cycleSpanRow(length=1, periodDays=0)', cycleSpanRow(lang, 1, 0));
      put('cycleSpanRow(length=1, periodDays=1)', cycleSpanRow(lang, 1, 1));
      put('cycleSpanRow(length=1, periodDays=2)', cycleSpanRow(lang, 1, 2));
      put('cycleSpanRow(length=1, periodDays=5)', cycleSpanRow(lang, 1, 5));
      put('cycleSpanRow(length=1, periodDays=21)', cycleSpanRow(lang, 1, 21));
      put(
        'cycleSpanRow(length=2, periodDays=null)',
        cycleSpanRow(lang, 2, null),
      );
      put('cycleSpanRow(length=2, periodDays=0)', cycleSpanRow(lang, 2, 0));
      put('cycleSpanRow(length=2, periodDays=1)', cycleSpanRow(lang, 2, 1));
      put('cycleSpanRow(length=2, periodDays=2)', cycleSpanRow(lang, 2, 2));
      put('cycleSpanRow(length=2, periodDays=5)', cycleSpanRow(lang, 2, 5));
      put('cycleSpanRow(length=2, periodDays=21)', cycleSpanRow(lang, 2, 21));
      put(
        'cycleSpanRow(length=5, periodDays=null)',
        cycleSpanRow(lang, 5, null),
      );
      put('cycleSpanRow(length=5, periodDays=0)', cycleSpanRow(lang, 5, 0));
      put('cycleSpanRow(length=5, periodDays=1)', cycleSpanRow(lang, 5, 1));
      put('cycleSpanRow(length=5, periodDays=2)', cycleSpanRow(lang, 5, 2));
      put('cycleSpanRow(length=5, periodDays=5)', cycleSpanRow(lang, 5, 5));
      put('cycleSpanRow(length=5, periodDays=21)', cycleSpanRow(lang, 5, 21));
      put(
        'cycleSpanRow(length=21, periodDays=null)',
        cycleSpanRow(lang, 21, null),
      );
      put('cycleSpanRow(length=21, periodDays=0)', cycleSpanRow(lang, 21, 0));
      put('cycleSpanRow(length=21, periodDays=1)', cycleSpanRow(lang, 21, 1));
      put('cycleSpanRow(length=21, periodDays=2)', cycleSpanRow(lang, 21, 2));
      put('cycleSpanRow(length=21, periodDays=5)', cycleSpanRow(lang, 21, 5));
      put('cycleSpanRow(length=21, periodDays=21)', cycleSpanRow(lang, 21, 21));
      put('cycleRestOfCycle()', cycleRestOfCycle(lang));
      put('cycleHistoryHint()', cycleHistoryHint(lang));
      put('cycleHistoryEmpty()', cycleHistoryEmpty(lang));
      put('cyclePartnerLabel(name=\'Alex\')', cyclePartnerLabel(lang, 'Alex'));
      put(
        'cyclePartnerLabel(name=\'Camille\')',
        cyclePartnerLabel(lang, 'Camille'),
      );
      put(
        'cyclePartnerHeadline(name=\'Alex\', ongoing=true, day=0)',
        cyclePartnerHeadline(lang, 'Alex', ongoing: true, day: 0),
      );
      put(
        'cyclePartnerHeadline(name=\'Alex\', ongoing=true, day=1)',
        cyclePartnerHeadline(lang, 'Alex', ongoing: true, day: 1),
      );
      put(
        'cyclePartnerHeadline(name=\'Alex\', ongoing=true, day=2)',
        cyclePartnerHeadline(lang, 'Alex', ongoing: true, day: 2),
      );
      put(
        'cyclePartnerHeadline(name=\'Alex\', ongoing=true, day=5)',
        cyclePartnerHeadline(lang, 'Alex', ongoing: true, day: 5),
      );
      put(
        'cyclePartnerHeadline(name=\'Alex\', ongoing=true, day=21)',
        cyclePartnerHeadline(lang, 'Alex', ongoing: true, day: 21),
      );
      put(
        'cyclePartnerHeadline(name=\'Alex\', ongoing=false, day=0)',
        cyclePartnerHeadline(lang, 'Alex', ongoing: false, day: 0),
      );
      put(
        'cyclePartnerHeadline(name=\'Alex\', ongoing=false, day=1)',
        cyclePartnerHeadline(lang, 'Alex', ongoing: false, day: 1),
      );
      put(
        'cyclePartnerHeadline(name=\'Alex\', ongoing=false, day=2)',
        cyclePartnerHeadline(lang, 'Alex', ongoing: false, day: 2),
      );
      put(
        'cyclePartnerHeadline(name=\'Alex\', ongoing=false, day=5)',
        cyclePartnerHeadline(lang, 'Alex', ongoing: false, day: 5),
      );
      put(
        'cyclePartnerHeadline(name=\'Alex\', ongoing=false, day=21)',
        cyclePartnerHeadline(lang, 'Alex', ongoing: false, day: 21),
      );
      put(
        'cyclePartnerHeadline(name=\'Camille\', ongoing=true, day=0)',
        cyclePartnerHeadline(lang, 'Camille', ongoing: true, day: 0),
      );
      put(
        'cyclePartnerHeadline(name=\'Camille\', ongoing=true, day=1)',
        cyclePartnerHeadline(lang, 'Camille', ongoing: true, day: 1),
      );
      put(
        'cyclePartnerHeadline(name=\'Camille\', ongoing=true, day=2)',
        cyclePartnerHeadline(lang, 'Camille', ongoing: true, day: 2),
      );
      put(
        'cyclePartnerHeadline(name=\'Camille\', ongoing=true, day=5)',
        cyclePartnerHeadline(lang, 'Camille', ongoing: true, day: 5),
      );
      put(
        'cyclePartnerHeadline(name=\'Camille\', ongoing=true, day=21)',
        cyclePartnerHeadline(lang, 'Camille', ongoing: true, day: 21),
      );
      put(
        'cyclePartnerHeadline(name=\'Camille\', ongoing=false, day=0)',
        cyclePartnerHeadline(lang, 'Camille', ongoing: false, day: 0),
      );
      put(
        'cyclePartnerHeadline(name=\'Camille\', ongoing=false, day=1)',
        cyclePartnerHeadline(lang, 'Camille', ongoing: false, day: 1),
      );
      put(
        'cyclePartnerHeadline(name=\'Camille\', ongoing=false, day=2)',
        cyclePartnerHeadline(lang, 'Camille', ongoing: false, day: 2),
      );
      put(
        'cyclePartnerHeadline(name=\'Camille\', ongoing=false, day=5)',
        cyclePartnerHeadline(lang, 'Camille', ongoing: false, day: 5),
      );
      put(
        'cyclePartnerHeadline(name=\'Camille\', ongoing=false, day=21)',
        cyclePartnerHeadline(lang, 'Camille', ongoing: false, day: 21),
      );
      put(
        'cyclePartnerNext(next=DateTime(2026, 3, 1), daysUntil=null)',
        cyclePartnerNext(lang, DateTime(2026, 3, 1), null),
      );
      put(
        'cyclePartnerNext(next=DateTime(2026, 3, 1), daysUntil=-3)',
        cyclePartnerNext(lang, DateTime(2026, 3, 1), -3),
      );
      put(
        'cyclePartnerNext(next=DateTime(2026, 3, 1), daysUntil=-1)',
        cyclePartnerNext(lang, DateTime(2026, 3, 1), -1),
      );
      put(
        'cyclePartnerNext(next=DateTime(2026, 3, 1), daysUntil=0)',
        cyclePartnerNext(lang, DateTime(2026, 3, 1), 0),
      );
      put(
        'cyclePartnerNext(next=DateTime(2026, 3, 1), daysUntil=1)',
        cyclePartnerNext(lang, DateTime(2026, 3, 1), 1),
      );
      put(
        'cyclePartnerNext(next=DateTime(2026, 3, 1), daysUntil=2)',
        cyclePartnerNext(lang, DateTime(2026, 3, 1), 2),
      );
      put(
        'cyclePartnerNext(next=DateTime(2026, 3, 1), daysUntil=5)',
        cyclePartnerNext(lang, DateTime(2026, 3, 1), 5),
      );
      put(
        'cyclePartnerNext(next=DateTime(2026, 11, 17, 9, 5), daysUntil=null)',
        cyclePartnerNext(lang, DateTime(2026, 11, 17, 9, 5), null),
      );
      put(
        'cyclePartnerNext(next=DateTime(2026, 11, 17, 9, 5), daysUntil=-3)',
        cyclePartnerNext(lang, DateTime(2026, 11, 17, 9, 5), -3),
      );
      put(
        'cyclePartnerNext(next=DateTime(2026, 11, 17, 9, 5), daysUntil=-1)',
        cyclePartnerNext(lang, DateTime(2026, 11, 17, 9, 5), -1),
      );
      put(
        'cyclePartnerNext(next=DateTime(2026, 11, 17, 9, 5), daysUntil=0)',
        cyclePartnerNext(lang, DateTime(2026, 11, 17, 9, 5), 0),
      );
      put(
        'cyclePartnerNext(next=DateTime(2026, 11, 17, 9, 5), daysUntil=1)',
        cyclePartnerNext(lang, DateTime(2026, 11, 17, 9, 5), 1),
      );
      put(
        'cyclePartnerNext(next=DateTime(2026, 11, 17, 9, 5), daysUntil=2)',
        cyclePartnerNext(lang, DateTime(2026, 11, 17, 9, 5), 2),
      );
      put(
        'cyclePartnerNext(next=DateTime(2026, 11, 17, 9, 5), daysUntil=5)',
        cyclePartnerNext(lang, DateTime(2026, 11, 17, 9, 5), 5),
      );
      put(
        'cyclePartnerNotShared(name=\'Alex\')',
        cyclePartnerNotShared(lang, 'Alex'),
      );
      put(
        'cyclePartnerNotShared(name=\'Camille\')',
        cyclePartnerNotShared(lang, 'Camille'),
      );
      put(
        'cyclePartnerNothingYet(name=\'Alex\')',
        cyclePartnerNothingYet(lang, 'Alex'),
      );
      put(
        'cyclePartnerNothingYet(name=\'Camille\')',
        cyclePartnerNothingYet(lang, 'Camille'),
      );
      put(
        'cyclePartnerNotTracking(name=\'Alex\')',
        cyclePartnerNotTracking(lang, 'Alex'),
      );
      put(
        'cyclePartnerNotTracking(name=\'Camille\')',
        cyclePartnerNotTracking(lang, 'Camille'),
      );
      put('cycleNoPartner()', cycleNoPartner(lang));
      put('cycleWhatHelps()', cycleWhatHelps(lang));
      put('cyclePartnerNoted(name=\'Alex\')', cyclePartnerNoted(lang, 'Alex'));
      put(
        'cyclePartnerNoted(name=\'Camille\')',
        cyclePartnerNoted(lang, 'Camille'),
      );
      put('cycleLittleNote()', cycleLittleNote(lang));
      put('cycleRemindMe()', cycleRemindMe(lang));
      put(
        'cycleRemindOn(day=DateTime(2026, 3, 1))',
        cycleRemindOn(lang, DateTime(2026, 3, 1)),
      );
      put(
        'cycleRemindOn(day=DateTime(2026, 11, 17, 9, 5))',
        cycleRemindOn(lang, DateTime(2026, 11, 17, 9, 5)),
      );
      put('cycleRemindNoDate()', cycleRemindNoDate(lang));
      put(
        'cyclePartnerTips(phase=CyclePhase.menstrual)',
        cyclePartnerTips(lang, CyclePhase.menstrual),
      );
      put(
        'cyclePartnerTips(phase=CyclePhase.follicular)',
        cyclePartnerTips(lang, CyclePhase.follicular),
      );
      put(
        'cyclePartnerTips(phase=CyclePhase.ovulation)',
        cyclePartnerTips(lang, CyclePhase.ovulation),
      );
      put(
        'cyclePartnerTips(phase=CyclePhase.luteal)',
        cyclePartnerTips(lang, CyclePhase.luteal),
      );
      put('cycleSharingTitle(name=\'Alex\')', cycleSharingTitle(lang, 'Alex'));
      put(
        'cycleSharingTitle(name=\'Camille\')',
        cycleSharingTitle(lang, 'Camille'),
      );
      put('cycleSharingIntro()', cycleSharingIntro(lang));
      put('cycleShareCycle()', cycleShareCycle(lang));
      put('cycleShareCycleHint()', cycleShareCycleHint(lang));
      put('cycleShareCheckins()', cycleShareCheckins(lang));
      put('cycleShareCheckinsHint()', cycleShareCheckinsHint(lang));
      put('cycleNotesRow()', cycleNotesRow(lang));
      put('cycleNotesAlwaysPrivate()', cycleNotesAlwaysPrivate(lang));
      put('cycleStopSharing()', cycleStopSharing(lang));
      put('guideLabel()', guideLabel(lang));
      put('guideTitle()', guideTitle(lang));
      put('guideForYouNow(day=0)', guideForYouNow(lang, 0));
      put('guideForYouNow(day=1)', guideForYouNow(lang, 1));
      put('guideForYouNow(day=2)', guideForYouNow(lang, 2));
      put('guideForYouNow(day=5)', guideForYouNow(lang, 5));
      put('guideForYouNow(day=21)', guideForYouNow(lang, 21));
      put(
        'guideForPartnerNow(name=\'Alex\', day=0)',
        guideForPartnerNow(lang, 'Alex', 0),
      );
      put(
        'guideForPartnerNow(name=\'Alex\', day=1)',
        guideForPartnerNow(lang, 'Alex', 1),
      );
      put(
        'guideForPartnerNow(name=\'Alex\', day=2)',
        guideForPartnerNow(lang, 'Alex', 2),
      );
      put(
        'guideForPartnerNow(name=\'Alex\', day=5)',
        guideForPartnerNow(lang, 'Alex', 5),
      );
      put(
        'guideForPartnerNow(name=\'Alex\', day=21)',
        guideForPartnerNow(lang, 'Alex', 21),
      );
      put(
        'guideForPartnerNow(name=\'Camille\', day=0)',
        guideForPartnerNow(lang, 'Camille', 0),
      );
      put(
        'guideForPartnerNow(name=\'Camille\', day=1)',
        guideForPartnerNow(lang, 'Camille', 1),
      );
      put(
        'guideForPartnerNow(name=\'Camille\', day=2)',
        guideForPartnerNow(lang, 'Camille', 2),
      );
      put(
        'guideForPartnerNow(name=\'Camille\', day=5)',
        guideForPartnerNow(lang, 'Camille', 5),
      );
      put(
        'guideForPartnerNow(name=\'Camille\', day=21)',
        guideForPartnerNow(lang, 'Camille', 21),
      );
      put(
        'guideNowTitle(phase=CyclePhase.menstrual)',
        guideNowTitle(lang, CyclePhase.menstrual),
      );
      put(
        'guideNowTitle(phase=CyclePhase.follicular)',
        guideNowTitle(lang, CyclePhase.follicular),
      );
      put(
        'guideNowTitle(phase=CyclePhase.ovulation)',
        guideNowTitle(lang, CyclePhase.ovulation),
      );
      put(
        'guideNowTitle(phase=CyclePhase.luteal)',
        guideNowTitle(lang, CyclePhase.luteal),
      );
      put('guideChapter(n=0)', guideChapter(lang, 0));
      put('guideChapter(n=1)', guideChapter(lang, 1));
      put('guideChapter(n=2)', guideChapter(lang, 2));
      put('guideChapter(n=5)', guideChapter(lang, 5));
      put('guideChapter(n=21)', guideChapter(lang, 21));
      put('guideRead()', guideRead(lang));
      put('guideFootnote()', guideFootnote(lang));
      put('guideContents()', guideContents(lang));
      put('guideNext(title=\'Alex\')', guideNext(lang, 'Alex'));
      put('guideNext(title=\'Camille\')', guideNext(lang, 'Camille'));
      put('guideSearch()', guideSearch(lang));
      put('guideNoMatch(query=\'<query>\')', guideNoMatch(lang, '<query>'));
      put('guideBody()', guideBody(lang));
      put('guideMood()', guideMood(lang));
      put('guideWhatHelps()', guideWhatHelps(lang));
      put('guideYouAreHere()', guideYouAreHere(lang));
      put(
        'guidePartnerIsHere(name=\'Alex\')',
        guidePartnerIsHere(lang, 'Alex'),
      );
      put(
        'guidePartnerIsHere(name=\'Camille\')',
        guidePartnerIsHere(lang, 'Camille'),
      );
      put('guideSources()', guideSources(lang));
      put('guideDaysShort(range=\'<range>\')', guideDaysShort(lang, '<range>'));
      put(
        'guideLabelPrefix(label=\'<label>\')',
        guideLabelPrefix(lang, '<label>'),
      );
      put('listsTitle()', listsTitle(lang));
      put('listsSubtitle(partnerName=\'Alex\')', listsSubtitle(lang, 'Alex'));
      put(
        'listsSubtitle(partnerName=\'Camille\')',
        listsSubtitle(lang, 'Camille'),
      );
      put('listsSeeAll()', listsSeeAll(lang));
      put('listsNew()', listsNew(lang));
      put('listsEmptyTitle()', listsEmptyTitle(lang));
      put('listsEmptyBody()', listsEmptyBody(lang));
      put('listsCounts(open=0, total=0)', listsCounts(lang, 0, 0));
      put('listsCounts(open=0, total=1)', listsCounts(lang, 0, 1));
      put('listsCounts(open=0, total=2)', listsCounts(lang, 0, 2));
      put('listsCounts(open=0, total=5)', listsCounts(lang, 0, 5));
      put('listsCounts(open=0, total=21)', listsCounts(lang, 0, 21));
      put('listsCounts(open=1, total=0)', listsCounts(lang, 1, 0));
      put('listsCounts(open=1, total=1)', listsCounts(lang, 1, 1));
      put('listsCounts(open=1, total=2)', listsCounts(lang, 1, 2));
      put('listsCounts(open=1, total=5)', listsCounts(lang, 1, 5));
      put('listsCounts(open=1, total=21)', listsCounts(lang, 1, 21));
      put('listsCounts(open=2, total=0)', listsCounts(lang, 2, 0));
      put('listsCounts(open=2, total=1)', listsCounts(lang, 2, 1));
      put('listsCounts(open=2, total=2)', listsCounts(lang, 2, 2));
      put('listsCounts(open=2, total=5)', listsCounts(lang, 2, 5));
      put('listsCounts(open=2, total=21)', listsCounts(lang, 2, 21));
      put('listsCounts(open=5, total=0)', listsCounts(lang, 5, 0));
      put('listsCounts(open=5, total=1)', listsCounts(lang, 5, 1));
      put('listsCounts(open=5, total=2)', listsCounts(lang, 5, 2));
      put('listsCounts(open=5, total=5)', listsCounts(lang, 5, 5));
      put('listsCounts(open=5, total=21)', listsCounts(lang, 5, 21));
      put('listsCounts(open=21, total=0)', listsCounts(lang, 21, 0));
      put('listsCounts(open=21, total=1)', listsCounts(lang, 21, 1));
      put('listsCounts(open=21, total=2)', listsCounts(lang, 21, 2));
      put('listsCounts(open=21, total=5)', listsCounts(lang, 21, 5));
      put('listsCounts(open=21, total=21)', listsCounts(lang, 21, 21));
      put('listsNameLabel()', listsNameLabel(lang));
      put('listsNameHint()', listsNameHint(lang));
      put('listsIconLabel()', listsIconLabel(lang));
      put('listsCreate()', listsCreate(lang));
      put('listsRename()', listsRename(lang));
      put('listsDelete()', listsDelete(lang));
      put(
        'listsDeleteConfirm(name=\'Alex\')',
        listsDeleteConfirm(lang, 'Alex'),
      );
      put(
        'listsDeleteConfirm(name=\'Camille\')',
        listsDeleteConfirm(lang, 'Camille'),
      );
      put('listsCancel()', listsCancel(lang));
      put('listsSave()', listsSave(lang));
      put('listsOptions()', listsOptions(lang));
      put('listsBack()', listsBack(lang));
      put('listsAddLabel()', listsAddLabel(lang));
      put('listsAddHint()', listsAddHint(lang));
      put('listsAddButton()', listsAddButton(lang));
      put('listsChecked(n=0)', listsChecked(lang, 0));
      put('listsChecked(n=1)', listsChecked(lang, 1));
      put('listsChecked(n=2)', listsChecked(lang, 2));
      put('listsChecked(n=5)', listsChecked(lang, 5));
      put('listsChecked(n=21)', listsChecked(lang, 21));
      put('listsClearChecked()', listsClearChecked(lang));
      put('listsAddedByMe()', listsAddedByMe(lang));
      put('listsAddedBy(name=\'Alex\')', listsAddedBy(lang, 'Alex'));
      put('listsAddedBy(name=\'Camille\')', listsAddedBy(lang, 'Camille'));
      put(
        'listsItemDeleted(text=\'<text>\')',
        listsItemDeleted(lang, '<text>'),
      );
      put('listsUndo()', listsUndo(lang));
      put('listsDeleteItem()', listsDeleteItem(lang));
      put('listsGoneTitle()', listsGoneTitle(lang));
      put('listsGoneBody()', listsGoneBody(lang));
      put('listsAll()', listsAll(lang));
      put('listsEmptyListBody()', listsEmptyListBody(lang));
      put('listsError()', listsError(lang));
      put(
        'listsIconName(icon=ListIcon.list)',
        listsIconName(lang, ListIcon.list),
      );
      put(
        'listsIconName(icon=ListIcon.cart)',
        listsIconName(lang, ListIcon.cart),
      );
      put(
        'listsIconName(icon=ListIcon.star)',
        listsIconName(lang, ListIcon.star),
      );
      put(
        'listsIconName(icon=ListIcon.home)',
        listsIconName(lang, ListIcon.home),
      );
      put(
        'listsIconName(icon=ListIcon.gift)',
        listsIconName(lang, ListIcon.gift),
      );
      put('nousTitle()', nousTitle(lang));
      put('nousSettingsTooltip()', nousSettingsTooltip(lang));
      put('nousTogetherSince()', nousTogetherSince(lang));
      put('nousDaysUnit(n=0)', nousDaysUnit(lang, 0));
      put('nousDaysUnit(n=1)', nousDaysUnit(lang, 1));
      put('nousDaysUnit(n=2)', nousDaysUnit(lang, 2));
      put('nousDaysUnit(n=5)', nousDaysUnit(lang, 5));
      put('nousDaysUnit(n=21)', nousDaysUnit(lang, 21));
      put(
        'nousSinceDate(day=DateTime(2026, 3, 1))',
        nousSinceDate(lang, DateTime(2026, 3, 1)),
      );
      put(
        'nousSinceDate(day=DateTime(2026, 11, 17, 9, 5))',
        nousSinceDate(lang, DateTime(2026, 11, 17, 9, 5)),
      );
      put('nousEdit()', nousEdit(lang));
      put('nousPickStartHelp()', nousPickStartHelp(lang));
      put('nousStartSaved()', nousStartSaved(lang));
      put('nousSendNote()', nousSendNote(lang));
      put(
        'pingLabel(kind=PingKind.thinkingOfYou, text=null)',
        pingLabel(lang, PingKind.thinkingOfYou, text: null),
      );
      put(
        'pingLabel(kind=PingKind.thinkingOfYou, text=\'<text>\')',
        pingLabel(lang, PingKind.thinkingOfYou, text: '<text>'),
      );
      put(
        'pingLabel(kind=PingKind.goodNight, text=null)',
        pingLabel(lang, PingKind.goodNight, text: null),
      );
      put(
        'pingLabel(kind=PingKind.goodNight, text=\'<text>\')',
        pingLabel(lang, PingKind.goodNight, text: '<text>'),
      );
      put(
        'pingLabel(kind=PingKind.onMyWay, text=null)',
        pingLabel(lang, PingKind.onMyWay, text: null),
      );
      put(
        'pingLabel(kind=PingKind.onMyWay, text=\'<text>\')',
        pingLabel(lang, PingKind.onMyWay, text: '<text>'),
      );
      put(
        'pingLabel(kind=PingKind.missYou, text=null)',
        pingLabel(lang, PingKind.missYou, text: null),
      );
      put(
        'pingLabel(kind=PingKind.missYou, text=\'<text>\')',
        pingLabel(lang, PingKind.missYou, text: '<text>'),
      );
      put(
        'pingLabel(kind=PingKind.kiss, text=null)',
        pingLabel(lang, PingKind.kiss, text: null),
      );
      put(
        'pingLabel(kind=PingKind.kiss, text=\'<text>\')',
        pingLabel(lang, PingKind.kiss, text: '<text>'),
      );
      put(
        'pingLabel(kind=PingKind.custom, text=null)',
        pingLabel(lang, PingKind.custom, text: null),
      );
      put(
        'pingLabel(kind=PingKind.custom, text=\'<text>\')',
        pingLabel(lang, PingKind.custom, text: '<text>'),
      );
      put(
        'nousNoteSent(kind=PingKind.thinkingOfYou, text=null)',
        nousNoteSent(lang, PingKind.thinkingOfYou, text: null),
      );
      put(
        'nousNoteSent(kind=PingKind.thinkingOfYou, text=\'<text>\')',
        nousNoteSent(lang, PingKind.thinkingOfYou, text: '<text>'),
      );
      put(
        'nousNoteSent(kind=PingKind.goodNight, text=null)',
        nousNoteSent(lang, PingKind.goodNight, text: null),
      );
      put(
        'nousNoteSent(kind=PingKind.goodNight, text=\'<text>\')',
        nousNoteSent(lang, PingKind.goodNight, text: '<text>'),
      );
      put(
        'nousNoteSent(kind=PingKind.onMyWay, text=null)',
        nousNoteSent(lang, PingKind.onMyWay, text: null),
      );
      put(
        'nousNoteSent(kind=PingKind.onMyWay, text=\'<text>\')',
        nousNoteSent(lang, PingKind.onMyWay, text: '<text>'),
      );
      put(
        'nousNoteSent(kind=PingKind.missYou, text=null)',
        nousNoteSent(lang, PingKind.missYou, text: null),
      );
      put(
        'nousNoteSent(kind=PingKind.missYou, text=\'<text>\')',
        nousNoteSent(lang, PingKind.missYou, text: '<text>'),
      );
      put(
        'nousNoteSent(kind=PingKind.kiss, text=null)',
        nousNoteSent(lang, PingKind.kiss, text: null),
      );
      put(
        'nousNoteSent(kind=PingKind.kiss, text=\'<text>\')',
        nousNoteSent(lang, PingKind.kiss, text: '<text>'),
      );
      put(
        'nousNoteSent(kind=PingKind.custom, text=null)',
        nousNoteSent(lang, PingKind.custom, text: null),
      );
      put(
        'nousNoteSent(kind=PingKind.custom, text=\'<text>\')',
        nousNoteSent(lang, PingKind.custom, text: '<text>'),
      );
      put('nousNoteCooldown()', nousNoteCooldown(lang));
      put('nousNoteFailed()', nousNoteFailed(lang));
      put(
        'pingResultMessage(kind=PingKind.thinkingOfYou, failure=null, text=null)',
        pingResultMessage(lang, PingKind.thinkingOfYou, null, text: null),
      );
      put(
        'pingResultMessage(kind=PingKind.thinkingOfYou, failure=null, text=\'<text>\')',
        pingResultMessage(lang, PingKind.thinkingOfYou, null, text: '<text>'),
      );
      put(
        'pingResultMessage(kind=PingKind.thinkingOfYou, failure=const NetworkFailure(), text=null)',
        pingResultMessage(
          lang,
          PingKind.thinkingOfYou,
          const NetworkFailure(),
          text: null,
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.thinkingOfYou, failure=const NetworkFailure(), text=\'<text>\')',
        pingResultMessage(
          lang,
          PingKind.thinkingOfYou,
          const NetworkFailure(),
          text: '<text>',
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.thinkingOfYou, failure=const ServerFailure(\'x\'), text=null)',
        pingResultMessage(
          lang,
          PingKind.thinkingOfYou,
          const ServerFailure('x'),
          text: null,
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.thinkingOfYou, failure=const ServerFailure(\'x\'), text=\'<text>\')',
        pingResultMessage(
          lang,
          PingKind.thinkingOfYou,
          const ServerFailure('x'),
          text: '<text>',
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.thinkingOfYou, failure=const UnknownFailure(), text=null)',
        pingResultMessage(
          lang,
          PingKind.thinkingOfYou,
          const UnknownFailure(),
          text: null,
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.thinkingOfYou, failure=const UnknownFailure(), text=\'<text>\')',
        pingResultMessage(
          lang,
          PingKind.thinkingOfYou,
          const UnknownFailure(),
          text: '<text>',
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.thinkingOfYou, failure=const WrongCredentialsFailure(), text=null)',
        pingResultMessage(
          lang,
          PingKind.thinkingOfYou,
          const WrongCredentialsFailure(),
          text: null,
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.thinkingOfYou, failure=const WrongCredentialsFailure(), text=\'<text>\')',
        pingResultMessage(
          lang,
          PingKind.thinkingOfYou,
          const WrongCredentialsFailure(),
          text: '<text>',
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.thinkingOfYou, failure=const PairingFailure(PairingProblem.invalidCode), text=null)',
        pingResultMessage(
          lang,
          PingKind.thinkingOfYou,
          const PairingFailure(PairingProblem.invalidCode),
          text: null,
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.thinkingOfYou, failure=const PairingFailure(PairingProblem.invalidCode), text=\'<text>\')',
        pingResultMessage(
          lang,
          PingKind.thinkingOfYou,
          const PairingFailure(PairingProblem.invalidCode),
          text: '<text>',
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.thinkingOfYou, failure=const PairingFailure(PairingProblem.codeUsed), text=null)',
        pingResultMessage(
          lang,
          PingKind.thinkingOfYou,
          const PairingFailure(PairingProblem.codeUsed),
          text: null,
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.thinkingOfYou, failure=const PairingFailure(PairingProblem.codeUsed), text=\'<text>\')',
        pingResultMessage(
          lang,
          PingKind.thinkingOfYou,
          const PairingFailure(PairingProblem.codeUsed),
          text: '<text>',
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.thinkingOfYou, failure=const PairingFailure(PairingProblem.ownCode), text=null)',
        pingResultMessage(
          lang,
          PingKind.thinkingOfYou,
          const PairingFailure(PairingProblem.ownCode),
          text: null,
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.thinkingOfYou, failure=const PairingFailure(PairingProblem.ownCode), text=\'<text>\')',
        pingResultMessage(
          lang,
          PingKind.thinkingOfYou,
          const PairingFailure(PairingProblem.ownCode),
          text: '<text>',
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.thinkingOfYou, failure=const PairingFailure(PairingProblem.alreadyPaired), text=null)',
        pingResultMessage(
          lang,
          PingKind.thinkingOfYou,
          const PairingFailure(PairingProblem.alreadyPaired),
          text: null,
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.thinkingOfYou, failure=const PairingFailure(PairingProblem.alreadyPaired), text=\'<text>\')',
        pingResultMessage(
          lang,
          PingKind.thinkingOfYou,
          const PairingFailure(PairingProblem.alreadyPaired),
          text: '<text>',
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.thinkingOfYou, failure=const PairingFailure(PairingProblem.tooManyAttempts), text=null)',
        pingResultMessage(
          lang,
          PingKind.thinkingOfYou,
          const PairingFailure(PairingProblem.tooManyAttempts),
          text: null,
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.thinkingOfYou, failure=const PairingFailure(PairingProblem.tooManyAttempts), text=\'<text>\')',
        pingResultMessage(
          lang,
          PingKind.thinkingOfYou,
          const PairingFailure(PairingProblem.tooManyAttempts),
          text: '<text>',
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.thinkingOfYou, failure=const PingFailure(PingProblem.cooldown), text=null)',
        pingResultMessage(
          lang,
          PingKind.thinkingOfYou,
          const PingFailure(PingProblem.cooldown),
          text: null,
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.thinkingOfYou, failure=const PingFailure(PingProblem.cooldown), text=\'<text>\')',
        pingResultMessage(
          lang,
          PingKind.thinkingOfYou,
          const PingFailure(PingProblem.cooldown),
          text: '<text>',
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.thinkingOfYou, failure=const PingFailure(PingProblem.notPaired), text=null)',
        pingResultMessage(
          lang,
          PingKind.thinkingOfYou,
          const PingFailure(PingProblem.notPaired),
          text: null,
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.thinkingOfYou, failure=const PingFailure(PingProblem.notPaired), text=\'<text>\')',
        pingResultMessage(
          lang,
          PingKind.thinkingOfYou,
          const PingFailure(PingProblem.notPaired),
          text: '<text>',
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.goodNight, failure=null, text=null)',
        pingResultMessage(lang, PingKind.goodNight, null, text: null),
      );
      put(
        'pingResultMessage(kind=PingKind.goodNight, failure=null, text=\'<text>\')',
        pingResultMessage(lang, PingKind.goodNight, null, text: '<text>'),
      );
      put(
        'pingResultMessage(kind=PingKind.goodNight, failure=const NetworkFailure(), text=null)',
        pingResultMessage(
          lang,
          PingKind.goodNight,
          const NetworkFailure(),
          text: null,
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.goodNight, failure=const NetworkFailure(), text=\'<text>\')',
        pingResultMessage(
          lang,
          PingKind.goodNight,
          const NetworkFailure(),
          text: '<text>',
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.goodNight, failure=const ServerFailure(\'x\'), text=null)',
        pingResultMessage(
          lang,
          PingKind.goodNight,
          const ServerFailure('x'),
          text: null,
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.goodNight, failure=const ServerFailure(\'x\'), text=\'<text>\')',
        pingResultMessage(
          lang,
          PingKind.goodNight,
          const ServerFailure('x'),
          text: '<text>',
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.goodNight, failure=const UnknownFailure(), text=null)',
        pingResultMessage(
          lang,
          PingKind.goodNight,
          const UnknownFailure(),
          text: null,
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.goodNight, failure=const UnknownFailure(), text=\'<text>\')',
        pingResultMessage(
          lang,
          PingKind.goodNight,
          const UnknownFailure(),
          text: '<text>',
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.goodNight, failure=const WrongCredentialsFailure(), text=null)',
        pingResultMessage(
          lang,
          PingKind.goodNight,
          const WrongCredentialsFailure(),
          text: null,
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.goodNight, failure=const WrongCredentialsFailure(), text=\'<text>\')',
        pingResultMessage(
          lang,
          PingKind.goodNight,
          const WrongCredentialsFailure(),
          text: '<text>',
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.goodNight, failure=const PairingFailure(PairingProblem.invalidCode), text=null)',
        pingResultMessage(
          lang,
          PingKind.goodNight,
          const PairingFailure(PairingProblem.invalidCode),
          text: null,
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.goodNight, failure=const PairingFailure(PairingProblem.invalidCode), text=\'<text>\')',
        pingResultMessage(
          lang,
          PingKind.goodNight,
          const PairingFailure(PairingProblem.invalidCode),
          text: '<text>',
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.goodNight, failure=const PairingFailure(PairingProblem.codeUsed), text=null)',
        pingResultMessage(
          lang,
          PingKind.goodNight,
          const PairingFailure(PairingProblem.codeUsed),
          text: null,
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.goodNight, failure=const PairingFailure(PairingProblem.codeUsed), text=\'<text>\')',
        pingResultMessage(
          lang,
          PingKind.goodNight,
          const PairingFailure(PairingProblem.codeUsed),
          text: '<text>',
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.goodNight, failure=const PairingFailure(PairingProblem.ownCode), text=null)',
        pingResultMessage(
          lang,
          PingKind.goodNight,
          const PairingFailure(PairingProblem.ownCode),
          text: null,
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.goodNight, failure=const PairingFailure(PairingProblem.ownCode), text=\'<text>\')',
        pingResultMessage(
          lang,
          PingKind.goodNight,
          const PairingFailure(PairingProblem.ownCode),
          text: '<text>',
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.goodNight, failure=const PairingFailure(PairingProblem.alreadyPaired), text=null)',
        pingResultMessage(
          lang,
          PingKind.goodNight,
          const PairingFailure(PairingProblem.alreadyPaired),
          text: null,
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.goodNight, failure=const PairingFailure(PairingProblem.alreadyPaired), text=\'<text>\')',
        pingResultMessage(
          lang,
          PingKind.goodNight,
          const PairingFailure(PairingProblem.alreadyPaired),
          text: '<text>',
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.goodNight, failure=const PairingFailure(PairingProblem.tooManyAttempts), text=null)',
        pingResultMessage(
          lang,
          PingKind.goodNight,
          const PairingFailure(PairingProblem.tooManyAttempts),
          text: null,
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.goodNight, failure=const PairingFailure(PairingProblem.tooManyAttempts), text=\'<text>\')',
        pingResultMessage(
          lang,
          PingKind.goodNight,
          const PairingFailure(PairingProblem.tooManyAttempts),
          text: '<text>',
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.goodNight, failure=const PingFailure(PingProblem.cooldown), text=null)',
        pingResultMessage(
          lang,
          PingKind.goodNight,
          const PingFailure(PingProblem.cooldown),
          text: null,
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.goodNight, failure=const PingFailure(PingProblem.cooldown), text=\'<text>\')',
        pingResultMessage(
          lang,
          PingKind.goodNight,
          const PingFailure(PingProblem.cooldown),
          text: '<text>',
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.goodNight, failure=const PingFailure(PingProblem.notPaired), text=null)',
        pingResultMessage(
          lang,
          PingKind.goodNight,
          const PingFailure(PingProblem.notPaired),
          text: null,
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.goodNight, failure=const PingFailure(PingProblem.notPaired), text=\'<text>\')',
        pingResultMessage(
          lang,
          PingKind.goodNight,
          const PingFailure(PingProblem.notPaired),
          text: '<text>',
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.onMyWay, failure=null, text=null)',
        pingResultMessage(lang, PingKind.onMyWay, null, text: null),
      );
      put(
        'pingResultMessage(kind=PingKind.onMyWay, failure=null, text=\'<text>\')',
        pingResultMessage(lang, PingKind.onMyWay, null, text: '<text>'),
      );
      put(
        'pingResultMessage(kind=PingKind.onMyWay, failure=const NetworkFailure(), text=null)',
        pingResultMessage(
          lang,
          PingKind.onMyWay,
          const NetworkFailure(),
          text: null,
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.onMyWay, failure=const NetworkFailure(), text=\'<text>\')',
        pingResultMessage(
          lang,
          PingKind.onMyWay,
          const NetworkFailure(),
          text: '<text>',
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.onMyWay, failure=const ServerFailure(\'x\'), text=null)',
        pingResultMessage(
          lang,
          PingKind.onMyWay,
          const ServerFailure('x'),
          text: null,
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.onMyWay, failure=const ServerFailure(\'x\'), text=\'<text>\')',
        pingResultMessage(
          lang,
          PingKind.onMyWay,
          const ServerFailure('x'),
          text: '<text>',
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.onMyWay, failure=const UnknownFailure(), text=null)',
        pingResultMessage(
          lang,
          PingKind.onMyWay,
          const UnknownFailure(),
          text: null,
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.onMyWay, failure=const UnknownFailure(), text=\'<text>\')',
        pingResultMessage(
          lang,
          PingKind.onMyWay,
          const UnknownFailure(),
          text: '<text>',
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.onMyWay, failure=const WrongCredentialsFailure(), text=null)',
        pingResultMessage(
          lang,
          PingKind.onMyWay,
          const WrongCredentialsFailure(),
          text: null,
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.onMyWay, failure=const WrongCredentialsFailure(), text=\'<text>\')',
        pingResultMessage(
          lang,
          PingKind.onMyWay,
          const WrongCredentialsFailure(),
          text: '<text>',
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.onMyWay, failure=const PairingFailure(PairingProblem.invalidCode), text=null)',
        pingResultMessage(
          lang,
          PingKind.onMyWay,
          const PairingFailure(PairingProblem.invalidCode),
          text: null,
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.onMyWay, failure=const PairingFailure(PairingProblem.invalidCode), text=\'<text>\')',
        pingResultMessage(
          lang,
          PingKind.onMyWay,
          const PairingFailure(PairingProblem.invalidCode),
          text: '<text>',
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.onMyWay, failure=const PairingFailure(PairingProblem.codeUsed), text=null)',
        pingResultMessage(
          lang,
          PingKind.onMyWay,
          const PairingFailure(PairingProblem.codeUsed),
          text: null,
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.onMyWay, failure=const PairingFailure(PairingProblem.codeUsed), text=\'<text>\')',
        pingResultMessage(
          lang,
          PingKind.onMyWay,
          const PairingFailure(PairingProblem.codeUsed),
          text: '<text>',
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.onMyWay, failure=const PairingFailure(PairingProblem.ownCode), text=null)',
        pingResultMessage(
          lang,
          PingKind.onMyWay,
          const PairingFailure(PairingProblem.ownCode),
          text: null,
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.onMyWay, failure=const PairingFailure(PairingProblem.ownCode), text=\'<text>\')',
        pingResultMessage(
          lang,
          PingKind.onMyWay,
          const PairingFailure(PairingProblem.ownCode),
          text: '<text>',
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.onMyWay, failure=const PairingFailure(PairingProblem.alreadyPaired), text=null)',
        pingResultMessage(
          lang,
          PingKind.onMyWay,
          const PairingFailure(PairingProblem.alreadyPaired),
          text: null,
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.onMyWay, failure=const PairingFailure(PairingProblem.alreadyPaired), text=\'<text>\')',
        pingResultMessage(
          lang,
          PingKind.onMyWay,
          const PairingFailure(PairingProblem.alreadyPaired),
          text: '<text>',
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.onMyWay, failure=const PairingFailure(PairingProblem.tooManyAttempts), text=null)',
        pingResultMessage(
          lang,
          PingKind.onMyWay,
          const PairingFailure(PairingProblem.tooManyAttempts),
          text: null,
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.onMyWay, failure=const PairingFailure(PairingProblem.tooManyAttempts), text=\'<text>\')',
        pingResultMessage(
          lang,
          PingKind.onMyWay,
          const PairingFailure(PairingProblem.tooManyAttempts),
          text: '<text>',
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.onMyWay, failure=const PingFailure(PingProblem.cooldown), text=null)',
        pingResultMessage(
          lang,
          PingKind.onMyWay,
          const PingFailure(PingProblem.cooldown),
          text: null,
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.onMyWay, failure=const PingFailure(PingProblem.cooldown), text=\'<text>\')',
        pingResultMessage(
          lang,
          PingKind.onMyWay,
          const PingFailure(PingProblem.cooldown),
          text: '<text>',
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.onMyWay, failure=const PingFailure(PingProblem.notPaired), text=null)',
        pingResultMessage(
          lang,
          PingKind.onMyWay,
          const PingFailure(PingProblem.notPaired),
          text: null,
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.onMyWay, failure=const PingFailure(PingProblem.notPaired), text=\'<text>\')',
        pingResultMessage(
          lang,
          PingKind.onMyWay,
          const PingFailure(PingProblem.notPaired),
          text: '<text>',
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.missYou, failure=null, text=null)',
        pingResultMessage(lang, PingKind.missYou, null, text: null),
      );
      put(
        'pingResultMessage(kind=PingKind.missYou, failure=null, text=\'<text>\')',
        pingResultMessage(lang, PingKind.missYou, null, text: '<text>'),
      );
      put(
        'pingResultMessage(kind=PingKind.missYou, failure=const NetworkFailure(), text=null)',
        pingResultMessage(
          lang,
          PingKind.missYou,
          const NetworkFailure(),
          text: null,
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.missYou, failure=const NetworkFailure(), text=\'<text>\')',
        pingResultMessage(
          lang,
          PingKind.missYou,
          const NetworkFailure(),
          text: '<text>',
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.missYou, failure=const ServerFailure(\'x\'), text=null)',
        pingResultMessage(
          lang,
          PingKind.missYou,
          const ServerFailure('x'),
          text: null,
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.missYou, failure=const ServerFailure(\'x\'), text=\'<text>\')',
        pingResultMessage(
          lang,
          PingKind.missYou,
          const ServerFailure('x'),
          text: '<text>',
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.missYou, failure=const UnknownFailure(), text=null)',
        pingResultMessage(
          lang,
          PingKind.missYou,
          const UnknownFailure(),
          text: null,
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.missYou, failure=const UnknownFailure(), text=\'<text>\')',
        pingResultMessage(
          lang,
          PingKind.missYou,
          const UnknownFailure(),
          text: '<text>',
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.missYou, failure=const WrongCredentialsFailure(), text=null)',
        pingResultMessage(
          lang,
          PingKind.missYou,
          const WrongCredentialsFailure(),
          text: null,
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.missYou, failure=const WrongCredentialsFailure(), text=\'<text>\')',
        pingResultMessage(
          lang,
          PingKind.missYou,
          const WrongCredentialsFailure(),
          text: '<text>',
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.missYou, failure=const PairingFailure(PairingProblem.invalidCode), text=null)',
        pingResultMessage(
          lang,
          PingKind.missYou,
          const PairingFailure(PairingProblem.invalidCode),
          text: null,
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.missYou, failure=const PairingFailure(PairingProblem.invalidCode), text=\'<text>\')',
        pingResultMessage(
          lang,
          PingKind.missYou,
          const PairingFailure(PairingProblem.invalidCode),
          text: '<text>',
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.missYou, failure=const PairingFailure(PairingProblem.codeUsed), text=null)',
        pingResultMessage(
          lang,
          PingKind.missYou,
          const PairingFailure(PairingProblem.codeUsed),
          text: null,
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.missYou, failure=const PairingFailure(PairingProblem.codeUsed), text=\'<text>\')',
        pingResultMessage(
          lang,
          PingKind.missYou,
          const PairingFailure(PairingProblem.codeUsed),
          text: '<text>',
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.missYou, failure=const PairingFailure(PairingProblem.ownCode), text=null)',
        pingResultMessage(
          lang,
          PingKind.missYou,
          const PairingFailure(PairingProblem.ownCode),
          text: null,
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.missYou, failure=const PairingFailure(PairingProblem.ownCode), text=\'<text>\')',
        pingResultMessage(
          lang,
          PingKind.missYou,
          const PairingFailure(PairingProblem.ownCode),
          text: '<text>',
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.missYou, failure=const PairingFailure(PairingProblem.alreadyPaired), text=null)',
        pingResultMessage(
          lang,
          PingKind.missYou,
          const PairingFailure(PairingProblem.alreadyPaired),
          text: null,
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.missYou, failure=const PairingFailure(PairingProblem.alreadyPaired), text=\'<text>\')',
        pingResultMessage(
          lang,
          PingKind.missYou,
          const PairingFailure(PairingProblem.alreadyPaired),
          text: '<text>',
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.missYou, failure=const PairingFailure(PairingProblem.tooManyAttempts), text=null)',
        pingResultMessage(
          lang,
          PingKind.missYou,
          const PairingFailure(PairingProblem.tooManyAttempts),
          text: null,
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.missYou, failure=const PairingFailure(PairingProblem.tooManyAttempts), text=\'<text>\')',
        pingResultMessage(
          lang,
          PingKind.missYou,
          const PairingFailure(PairingProblem.tooManyAttempts),
          text: '<text>',
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.missYou, failure=const PingFailure(PingProblem.cooldown), text=null)',
        pingResultMessage(
          lang,
          PingKind.missYou,
          const PingFailure(PingProblem.cooldown),
          text: null,
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.missYou, failure=const PingFailure(PingProblem.cooldown), text=\'<text>\')',
        pingResultMessage(
          lang,
          PingKind.missYou,
          const PingFailure(PingProblem.cooldown),
          text: '<text>',
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.missYou, failure=const PingFailure(PingProblem.notPaired), text=null)',
        pingResultMessage(
          lang,
          PingKind.missYou,
          const PingFailure(PingProblem.notPaired),
          text: null,
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.missYou, failure=const PingFailure(PingProblem.notPaired), text=\'<text>\')',
        pingResultMessage(
          lang,
          PingKind.missYou,
          const PingFailure(PingProblem.notPaired),
          text: '<text>',
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.kiss, failure=null, text=null)',
        pingResultMessage(lang, PingKind.kiss, null, text: null),
      );
      put(
        'pingResultMessage(kind=PingKind.kiss, failure=null, text=\'<text>\')',
        pingResultMessage(lang, PingKind.kiss, null, text: '<text>'),
      );
      put(
        'pingResultMessage(kind=PingKind.kiss, failure=const NetworkFailure(), text=null)',
        pingResultMessage(
          lang,
          PingKind.kiss,
          const NetworkFailure(),
          text: null,
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.kiss, failure=const NetworkFailure(), text=\'<text>\')',
        pingResultMessage(
          lang,
          PingKind.kiss,
          const NetworkFailure(),
          text: '<text>',
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.kiss, failure=const ServerFailure(\'x\'), text=null)',
        pingResultMessage(
          lang,
          PingKind.kiss,
          const ServerFailure('x'),
          text: null,
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.kiss, failure=const ServerFailure(\'x\'), text=\'<text>\')',
        pingResultMessage(
          lang,
          PingKind.kiss,
          const ServerFailure('x'),
          text: '<text>',
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.kiss, failure=const UnknownFailure(), text=null)',
        pingResultMessage(
          lang,
          PingKind.kiss,
          const UnknownFailure(),
          text: null,
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.kiss, failure=const UnknownFailure(), text=\'<text>\')',
        pingResultMessage(
          lang,
          PingKind.kiss,
          const UnknownFailure(),
          text: '<text>',
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.kiss, failure=const WrongCredentialsFailure(), text=null)',
        pingResultMessage(
          lang,
          PingKind.kiss,
          const WrongCredentialsFailure(),
          text: null,
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.kiss, failure=const WrongCredentialsFailure(), text=\'<text>\')',
        pingResultMessage(
          lang,
          PingKind.kiss,
          const WrongCredentialsFailure(),
          text: '<text>',
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.kiss, failure=const PairingFailure(PairingProblem.invalidCode), text=null)',
        pingResultMessage(
          lang,
          PingKind.kiss,
          const PairingFailure(PairingProblem.invalidCode),
          text: null,
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.kiss, failure=const PairingFailure(PairingProblem.invalidCode), text=\'<text>\')',
        pingResultMessage(
          lang,
          PingKind.kiss,
          const PairingFailure(PairingProblem.invalidCode),
          text: '<text>',
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.kiss, failure=const PairingFailure(PairingProblem.codeUsed), text=null)',
        pingResultMessage(
          lang,
          PingKind.kiss,
          const PairingFailure(PairingProblem.codeUsed),
          text: null,
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.kiss, failure=const PairingFailure(PairingProblem.codeUsed), text=\'<text>\')',
        pingResultMessage(
          lang,
          PingKind.kiss,
          const PairingFailure(PairingProblem.codeUsed),
          text: '<text>',
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.kiss, failure=const PairingFailure(PairingProblem.ownCode), text=null)',
        pingResultMessage(
          lang,
          PingKind.kiss,
          const PairingFailure(PairingProblem.ownCode),
          text: null,
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.kiss, failure=const PairingFailure(PairingProblem.ownCode), text=\'<text>\')',
        pingResultMessage(
          lang,
          PingKind.kiss,
          const PairingFailure(PairingProblem.ownCode),
          text: '<text>',
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.kiss, failure=const PairingFailure(PairingProblem.alreadyPaired), text=null)',
        pingResultMessage(
          lang,
          PingKind.kiss,
          const PairingFailure(PairingProblem.alreadyPaired),
          text: null,
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.kiss, failure=const PairingFailure(PairingProblem.alreadyPaired), text=\'<text>\')',
        pingResultMessage(
          lang,
          PingKind.kiss,
          const PairingFailure(PairingProblem.alreadyPaired),
          text: '<text>',
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.kiss, failure=const PairingFailure(PairingProblem.tooManyAttempts), text=null)',
        pingResultMessage(
          lang,
          PingKind.kiss,
          const PairingFailure(PairingProblem.tooManyAttempts),
          text: null,
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.kiss, failure=const PairingFailure(PairingProblem.tooManyAttempts), text=\'<text>\')',
        pingResultMessage(
          lang,
          PingKind.kiss,
          const PairingFailure(PairingProblem.tooManyAttempts),
          text: '<text>',
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.kiss, failure=const PingFailure(PingProblem.cooldown), text=null)',
        pingResultMessage(
          lang,
          PingKind.kiss,
          const PingFailure(PingProblem.cooldown),
          text: null,
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.kiss, failure=const PingFailure(PingProblem.cooldown), text=\'<text>\')',
        pingResultMessage(
          lang,
          PingKind.kiss,
          const PingFailure(PingProblem.cooldown),
          text: '<text>',
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.kiss, failure=const PingFailure(PingProblem.notPaired), text=null)',
        pingResultMessage(
          lang,
          PingKind.kiss,
          const PingFailure(PingProblem.notPaired),
          text: null,
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.kiss, failure=const PingFailure(PingProblem.notPaired), text=\'<text>\')',
        pingResultMessage(
          lang,
          PingKind.kiss,
          const PingFailure(PingProblem.notPaired),
          text: '<text>',
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.custom, failure=null, text=null)',
        pingResultMessage(lang, PingKind.custom, null, text: null),
      );
      put(
        'pingResultMessage(kind=PingKind.custom, failure=null, text=\'<text>\')',
        pingResultMessage(lang, PingKind.custom, null, text: '<text>'),
      );
      put(
        'pingResultMessage(kind=PingKind.custom, failure=const NetworkFailure(), text=null)',
        pingResultMessage(
          lang,
          PingKind.custom,
          const NetworkFailure(),
          text: null,
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.custom, failure=const NetworkFailure(), text=\'<text>\')',
        pingResultMessage(
          lang,
          PingKind.custom,
          const NetworkFailure(),
          text: '<text>',
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.custom, failure=const ServerFailure(\'x\'), text=null)',
        pingResultMessage(
          lang,
          PingKind.custom,
          const ServerFailure('x'),
          text: null,
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.custom, failure=const ServerFailure(\'x\'), text=\'<text>\')',
        pingResultMessage(
          lang,
          PingKind.custom,
          const ServerFailure('x'),
          text: '<text>',
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.custom, failure=const UnknownFailure(), text=null)',
        pingResultMessage(
          lang,
          PingKind.custom,
          const UnknownFailure(),
          text: null,
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.custom, failure=const UnknownFailure(), text=\'<text>\')',
        pingResultMessage(
          lang,
          PingKind.custom,
          const UnknownFailure(),
          text: '<text>',
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.custom, failure=const WrongCredentialsFailure(), text=null)',
        pingResultMessage(
          lang,
          PingKind.custom,
          const WrongCredentialsFailure(),
          text: null,
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.custom, failure=const WrongCredentialsFailure(), text=\'<text>\')',
        pingResultMessage(
          lang,
          PingKind.custom,
          const WrongCredentialsFailure(),
          text: '<text>',
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.custom, failure=const PairingFailure(PairingProblem.invalidCode), text=null)',
        pingResultMessage(
          lang,
          PingKind.custom,
          const PairingFailure(PairingProblem.invalidCode),
          text: null,
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.custom, failure=const PairingFailure(PairingProblem.invalidCode), text=\'<text>\')',
        pingResultMessage(
          lang,
          PingKind.custom,
          const PairingFailure(PairingProblem.invalidCode),
          text: '<text>',
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.custom, failure=const PairingFailure(PairingProblem.codeUsed), text=null)',
        pingResultMessage(
          lang,
          PingKind.custom,
          const PairingFailure(PairingProblem.codeUsed),
          text: null,
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.custom, failure=const PairingFailure(PairingProblem.codeUsed), text=\'<text>\')',
        pingResultMessage(
          lang,
          PingKind.custom,
          const PairingFailure(PairingProblem.codeUsed),
          text: '<text>',
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.custom, failure=const PairingFailure(PairingProblem.ownCode), text=null)',
        pingResultMessage(
          lang,
          PingKind.custom,
          const PairingFailure(PairingProblem.ownCode),
          text: null,
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.custom, failure=const PairingFailure(PairingProblem.ownCode), text=\'<text>\')',
        pingResultMessage(
          lang,
          PingKind.custom,
          const PairingFailure(PairingProblem.ownCode),
          text: '<text>',
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.custom, failure=const PairingFailure(PairingProblem.alreadyPaired), text=null)',
        pingResultMessage(
          lang,
          PingKind.custom,
          const PairingFailure(PairingProblem.alreadyPaired),
          text: null,
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.custom, failure=const PairingFailure(PairingProblem.alreadyPaired), text=\'<text>\')',
        pingResultMessage(
          lang,
          PingKind.custom,
          const PairingFailure(PairingProblem.alreadyPaired),
          text: '<text>',
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.custom, failure=const PairingFailure(PairingProblem.tooManyAttempts), text=null)',
        pingResultMessage(
          lang,
          PingKind.custom,
          const PairingFailure(PairingProblem.tooManyAttempts),
          text: null,
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.custom, failure=const PairingFailure(PairingProblem.tooManyAttempts), text=\'<text>\')',
        pingResultMessage(
          lang,
          PingKind.custom,
          const PairingFailure(PairingProblem.tooManyAttempts),
          text: '<text>',
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.custom, failure=const PingFailure(PingProblem.cooldown), text=null)',
        pingResultMessage(
          lang,
          PingKind.custom,
          const PingFailure(PingProblem.cooldown),
          text: null,
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.custom, failure=const PingFailure(PingProblem.cooldown), text=\'<text>\')',
        pingResultMessage(
          lang,
          PingKind.custom,
          const PingFailure(PingProblem.cooldown),
          text: '<text>',
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.custom, failure=const PingFailure(PingProblem.notPaired), text=null)',
        pingResultMessage(
          lang,
          PingKind.custom,
          const PingFailure(PingProblem.notPaired),
          text: null,
        ),
      );
      put(
        'pingResultMessage(kind=PingKind.custom, failure=const PingFailure(PingProblem.notPaired), text=\'<text>\')',
        pingResultMessage(
          lang,
          PingKind.custom,
          const PingFailure(PingProblem.notPaired),
          text: '<text>',
        ),
      );
      put(
        'nousReceivedLine(name=\'Alex\', kind=PingKind.thinkingOfYou, text=null, ago=Duration(seconds: 20))',
        nousReceivedLine(
          lang,
          'Alex',
          PingKind.thinkingOfYou,
          DateTime(2026, 11, 17, 12).subtract(const Duration(seconds: 20)),
          DateTime(2026, 11, 17, 12),
          text: null,
        ),
      );
      put(
        'nousReceivedLine(name=\'Alex\', kind=PingKind.thinkingOfYou, text=null, ago=Duration(minutes: 10))',
        nousReceivedLine(
          lang,
          'Alex',
          PingKind.thinkingOfYou,
          DateTime(2026, 11, 17, 12).subtract(const Duration(minutes: 10)),
          DateTime(2026, 11, 17, 12),
          text: null,
        ),
      );
      put(
        'nousReceivedLine(name=\'Alex\', kind=PingKind.thinkingOfYou, text=null, ago=Duration(hours: 3))',
        nousReceivedLine(
          lang,
          'Alex',
          PingKind.thinkingOfYou,
          DateTime(2026, 11, 17, 12).subtract(const Duration(hours: 3)),
          DateTime(2026, 11, 17, 12),
          text: null,
        ),
      );
      put(
        'nousReceivedLine(name=\'Alex\', kind=PingKind.thinkingOfYou, text=null, ago=Duration(days: 2))',
        nousReceivedLine(
          lang,
          'Alex',
          PingKind.thinkingOfYou,
          DateTime(2026, 11, 17, 12).subtract(const Duration(days: 2)),
          DateTime(2026, 11, 17, 12),
          text: null,
        ),
      );
      put(
        'nousReceivedLine(name=\'Alex\', kind=PingKind.thinkingOfYou, text=null, ago=Duration(days: 40))',
        nousReceivedLine(
          lang,
          'Alex',
          PingKind.thinkingOfYou,
          DateTime(2026, 11, 17, 12).subtract(const Duration(days: 40)),
          DateTime(2026, 11, 17, 12),
          text: null,
        ),
      );
      put(
        'nousReceivedLine(name=\'Alex\', kind=PingKind.thinkingOfYou, text=\'<text>\', ago=Duration(seconds: 20))',
        nousReceivedLine(
          lang,
          'Alex',
          PingKind.thinkingOfYou,
          DateTime(2026, 11, 17, 12).subtract(const Duration(seconds: 20)),
          DateTime(2026, 11, 17, 12),
          text: '<text>',
        ),
      );
      put(
        'nousReceivedLine(name=\'Alex\', kind=PingKind.thinkingOfYou, text=\'<text>\', ago=Duration(minutes: 10))',
        nousReceivedLine(
          lang,
          'Alex',
          PingKind.thinkingOfYou,
          DateTime(2026, 11, 17, 12).subtract(const Duration(minutes: 10)),
          DateTime(2026, 11, 17, 12),
          text: '<text>',
        ),
      );
      put(
        'nousReceivedLine(name=\'Alex\', kind=PingKind.thinkingOfYou, text=\'<text>\', ago=Duration(hours: 3))',
        nousReceivedLine(
          lang,
          'Alex',
          PingKind.thinkingOfYou,
          DateTime(2026, 11, 17, 12).subtract(const Duration(hours: 3)),
          DateTime(2026, 11, 17, 12),
          text: '<text>',
        ),
      );
      put(
        'nousReceivedLine(name=\'Alex\', kind=PingKind.thinkingOfYou, text=\'<text>\', ago=Duration(days: 2))',
        nousReceivedLine(
          lang,
          'Alex',
          PingKind.thinkingOfYou,
          DateTime(2026, 11, 17, 12).subtract(const Duration(days: 2)),
          DateTime(2026, 11, 17, 12),
          text: '<text>',
        ),
      );
      put(
        'nousReceivedLine(name=\'Alex\', kind=PingKind.thinkingOfYou, text=\'<text>\', ago=Duration(days: 40))',
        nousReceivedLine(
          lang,
          'Alex',
          PingKind.thinkingOfYou,
          DateTime(2026, 11, 17, 12).subtract(const Duration(days: 40)),
          DateTime(2026, 11, 17, 12),
          text: '<text>',
        ),
      );
      put(
        'nousReceivedLine(name=\'Alex\', kind=PingKind.goodNight, text=null, ago=Duration(seconds: 20))',
        nousReceivedLine(
          lang,
          'Alex',
          PingKind.goodNight,
          DateTime(2026, 11, 17, 12).subtract(const Duration(seconds: 20)),
          DateTime(2026, 11, 17, 12),
          text: null,
        ),
      );
      put(
        'nousReceivedLine(name=\'Alex\', kind=PingKind.goodNight, text=null, ago=Duration(minutes: 10))',
        nousReceivedLine(
          lang,
          'Alex',
          PingKind.goodNight,
          DateTime(2026, 11, 17, 12).subtract(const Duration(minutes: 10)),
          DateTime(2026, 11, 17, 12),
          text: null,
        ),
      );
      put(
        'nousReceivedLine(name=\'Alex\', kind=PingKind.goodNight, text=null, ago=Duration(hours: 3))',
        nousReceivedLine(
          lang,
          'Alex',
          PingKind.goodNight,
          DateTime(2026, 11, 17, 12).subtract(const Duration(hours: 3)),
          DateTime(2026, 11, 17, 12),
          text: null,
        ),
      );
      put(
        'nousReceivedLine(name=\'Alex\', kind=PingKind.goodNight, text=null, ago=Duration(days: 2))',
        nousReceivedLine(
          lang,
          'Alex',
          PingKind.goodNight,
          DateTime(2026, 11, 17, 12).subtract(const Duration(days: 2)),
          DateTime(2026, 11, 17, 12),
          text: null,
        ),
      );
      put(
        'nousReceivedLine(name=\'Alex\', kind=PingKind.goodNight, text=null, ago=Duration(days: 40))',
        nousReceivedLine(
          lang,
          'Alex',
          PingKind.goodNight,
          DateTime(2026, 11, 17, 12).subtract(const Duration(days: 40)),
          DateTime(2026, 11, 17, 12),
          text: null,
        ),
      );
      put(
        'nousReceivedLine(name=\'Alex\', kind=PingKind.goodNight, text=\'<text>\', ago=Duration(seconds: 20))',
        nousReceivedLine(
          lang,
          'Alex',
          PingKind.goodNight,
          DateTime(2026, 11, 17, 12).subtract(const Duration(seconds: 20)),
          DateTime(2026, 11, 17, 12),
          text: '<text>',
        ),
      );
      put(
        'nousReceivedLine(name=\'Alex\', kind=PingKind.goodNight, text=\'<text>\', ago=Duration(minutes: 10))',
        nousReceivedLine(
          lang,
          'Alex',
          PingKind.goodNight,
          DateTime(2026, 11, 17, 12).subtract(const Duration(minutes: 10)),
          DateTime(2026, 11, 17, 12),
          text: '<text>',
        ),
      );
      put(
        'nousReceivedLine(name=\'Alex\', kind=PingKind.goodNight, text=\'<text>\', ago=Duration(hours: 3))',
        nousReceivedLine(
          lang,
          'Alex',
          PingKind.goodNight,
          DateTime(2026, 11, 17, 12).subtract(const Duration(hours: 3)),
          DateTime(2026, 11, 17, 12),
          text: '<text>',
        ),
      );
      put(
        'nousReceivedLine(name=\'Alex\', kind=PingKind.goodNight, text=\'<text>\', ago=Duration(days: 2))',
        nousReceivedLine(
          lang,
          'Alex',
          PingKind.goodNight,
          DateTime(2026, 11, 17, 12).subtract(const Duration(days: 2)),
          DateTime(2026, 11, 17, 12),
          text: '<text>',
        ),
      );
      put(
        'nousReceivedLine(name=\'Alex\', kind=PingKind.goodNight, text=\'<text>\', ago=Duration(days: 40))',
        nousReceivedLine(
          lang,
          'Alex',
          PingKind.goodNight,
          DateTime(2026, 11, 17, 12).subtract(const Duration(days: 40)),
          DateTime(2026, 11, 17, 12),
          text: '<text>',
        ),
      );
      put(
        'nousReceivedLine(name=\'Alex\', kind=PingKind.onMyWay, text=null, ago=Duration(seconds: 20))',
        nousReceivedLine(
          lang,
          'Alex',
          PingKind.onMyWay,
          DateTime(2026, 11, 17, 12).subtract(const Duration(seconds: 20)),
          DateTime(2026, 11, 17, 12),
          text: null,
        ),
      );
      put(
        'nousReceivedLine(name=\'Alex\', kind=PingKind.onMyWay, text=null, ago=Duration(minutes: 10))',
        nousReceivedLine(
          lang,
          'Alex',
          PingKind.onMyWay,
          DateTime(2026, 11, 17, 12).subtract(const Duration(minutes: 10)),
          DateTime(2026, 11, 17, 12),
          text: null,
        ),
      );
      put(
        'nousReceivedLine(name=\'Alex\', kind=PingKind.onMyWay, text=null, ago=Duration(hours: 3))',
        nousReceivedLine(
          lang,
          'Alex',
          PingKind.onMyWay,
          DateTime(2026, 11, 17, 12).subtract(const Duration(hours: 3)),
          DateTime(2026, 11, 17, 12),
          text: null,
        ),
      );
      put(
        'nousReceivedLine(name=\'Alex\', kind=PingKind.onMyWay, text=null, ago=Duration(days: 2))',
        nousReceivedLine(
          lang,
          'Alex',
          PingKind.onMyWay,
          DateTime(2026, 11, 17, 12).subtract(const Duration(days: 2)),
          DateTime(2026, 11, 17, 12),
          text: null,
        ),
      );
      put(
        'nousReceivedLine(name=\'Alex\', kind=PingKind.onMyWay, text=null, ago=Duration(days: 40))',
        nousReceivedLine(
          lang,
          'Alex',
          PingKind.onMyWay,
          DateTime(2026, 11, 17, 12).subtract(const Duration(days: 40)),
          DateTime(2026, 11, 17, 12),
          text: null,
        ),
      );
      put(
        'nousReceivedLine(name=\'Alex\', kind=PingKind.onMyWay, text=\'<text>\', ago=Duration(seconds: 20))',
        nousReceivedLine(
          lang,
          'Alex',
          PingKind.onMyWay,
          DateTime(2026, 11, 17, 12).subtract(const Duration(seconds: 20)),
          DateTime(2026, 11, 17, 12),
          text: '<text>',
        ),
      );
      put(
        'nousReceivedLine(name=\'Alex\', kind=PingKind.onMyWay, text=\'<text>\', ago=Duration(minutes: 10))',
        nousReceivedLine(
          lang,
          'Alex',
          PingKind.onMyWay,
          DateTime(2026, 11, 17, 12).subtract(const Duration(minutes: 10)),
          DateTime(2026, 11, 17, 12),
          text: '<text>',
        ),
      );
      put(
        'nousReceivedLine(name=\'Alex\', kind=PingKind.onMyWay, text=\'<text>\', ago=Duration(hours: 3))',
        nousReceivedLine(
          lang,
          'Alex',
          PingKind.onMyWay,
          DateTime(2026, 11, 17, 12).subtract(const Duration(hours: 3)),
          DateTime(2026, 11, 17, 12),
          text: '<text>',
        ),
      );
      put(
        'nousReceivedLine(name=\'Alex\', kind=PingKind.onMyWay, text=\'<text>\', ago=Duration(days: 2))',
        nousReceivedLine(
          lang,
          'Alex',
          PingKind.onMyWay,
          DateTime(2026, 11, 17, 12).subtract(const Duration(days: 2)),
          DateTime(2026, 11, 17, 12),
          text: '<text>',
        ),
      );
      put(
        'nousReceivedLine(name=\'Alex\', kind=PingKind.onMyWay, text=\'<text>\', ago=Duration(days: 40))',
        nousReceivedLine(
          lang,
          'Alex',
          PingKind.onMyWay,
          DateTime(2026, 11, 17, 12).subtract(const Duration(days: 40)),
          DateTime(2026, 11, 17, 12),
          text: '<text>',
        ),
      );
      put(
        'nousReceivedLine(name=\'Alex\', kind=PingKind.missYou, text=null, ago=Duration(seconds: 20))',
        nousReceivedLine(
          lang,
          'Alex',
          PingKind.missYou,
          DateTime(2026, 11, 17, 12).subtract(const Duration(seconds: 20)),
          DateTime(2026, 11, 17, 12),
          text: null,
        ),
      );
      put(
        'nousReceivedLine(name=\'Alex\', kind=PingKind.missYou, text=null, ago=Duration(minutes: 10))',
        nousReceivedLine(
          lang,
          'Alex',
          PingKind.missYou,
          DateTime(2026, 11, 17, 12).subtract(const Duration(minutes: 10)),
          DateTime(2026, 11, 17, 12),
          text: null,
        ),
      );
      put(
        'nousReceivedLine(name=\'Alex\', kind=PingKind.missYou, text=null, ago=Duration(hours: 3))',
        nousReceivedLine(
          lang,
          'Alex',
          PingKind.missYou,
          DateTime(2026, 11, 17, 12).subtract(const Duration(hours: 3)),
          DateTime(2026, 11, 17, 12),
          text: null,
        ),
      );
      put(
        'nousReceivedLine(name=\'Alex\', kind=PingKind.missYou, text=null, ago=Duration(days: 2))',
        nousReceivedLine(
          lang,
          'Alex',
          PingKind.missYou,
          DateTime(2026, 11, 17, 12).subtract(const Duration(days: 2)),
          DateTime(2026, 11, 17, 12),
          text: null,
        ),
      );
      put(
        'nousReceivedLine(name=\'Alex\', kind=PingKind.missYou, text=null, ago=Duration(days: 40))',
        nousReceivedLine(
          lang,
          'Alex',
          PingKind.missYou,
          DateTime(2026, 11, 17, 12).subtract(const Duration(days: 40)),
          DateTime(2026, 11, 17, 12),
          text: null,
        ),
      );
      put(
        'nousReceivedLine(name=\'Alex\', kind=PingKind.missYou, text=\'<text>\', ago=Duration(seconds: 20))',
        nousReceivedLine(
          lang,
          'Alex',
          PingKind.missYou,
          DateTime(2026, 11, 17, 12).subtract(const Duration(seconds: 20)),
          DateTime(2026, 11, 17, 12),
          text: '<text>',
        ),
      );
      put(
        'nousReceivedLine(name=\'Alex\', kind=PingKind.missYou, text=\'<text>\', ago=Duration(minutes: 10))',
        nousReceivedLine(
          lang,
          'Alex',
          PingKind.missYou,
          DateTime(2026, 11, 17, 12).subtract(const Duration(minutes: 10)),
          DateTime(2026, 11, 17, 12),
          text: '<text>',
        ),
      );
      put(
        'nousReceivedLine(name=\'Alex\', kind=PingKind.missYou, text=\'<text>\', ago=Duration(hours: 3))',
        nousReceivedLine(
          lang,
          'Alex',
          PingKind.missYou,
          DateTime(2026, 11, 17, 12).subtract(const Duration(hours: 3)),
          DateTime(2026, 11, 17, 12),
          text: '<text>',
        ),
      );
      put(
        'nousReceivedLine(name=\'Alex\', kind=PingKind.missYou, text=\'<text>\', ago=Duration(days: 2))',
        nousReceivedLine(
          lang,
          'Alex',
          PingKind.missYou,
          DateTime(2026, 11, 17, 12).subtract(const Duration(days: 2)),
          DateTime(2026, 11, 17, 12),
          text: '<text>',
        ),
      );
      put(
        'nousReceivedLine(name=\'Alex\', kind=PingKind.missYou, text=\'<text>\', ago=Duration(days: 40))',
        nousReceivedLine(
          lang,
          'Alex',
          PingKind.missYou,
          DateTime(2026, 11, 17, 12).subtract(const Duration(days: 40)),
          DateTime(2026, 11, 17, 12),
          text: '<text>',
        ),
      );
      put(
        'nousReceivedLine(name=\'Alex\', kind=PingKind.kiss, text=null, ago=Duration(seconds: 20))',
        nousReceivedLine(
          lang,
          'Alex',
          PingKind.kiss,
          DateTime(2026, 11, 17, 12).subtract(const Duration(seconds: 20)),
          DateTime(2026, 11, 17, 12),
          text: null,
        ),
      );
      put(
        'nousReceivedLine(name=\'Alex\', kind=PingKind.kiss, text=null, ago=Duration(minutes: 10))',
        nousReceivedLine(
          lang,
          'Alex',
          PingKind.kiss,
          DateTime(2026, 11, 17, 12).subtract(const Duration(minutes: 10)),
          DateTime(2026, 11, 17, 12),
          text: null,
        ),
      );
      put(
        'nousReceivedLine(name=\'Alex\', kind=PingKind.kiss, text=null, ago=Duration(hours: 3))',
        nousReceivedLine(
          lang,
          'Alex',
          PingKind.kiss,
          DateTime(2026, 11, 17, 12).subtract(const Duration(hours: 3)),
          DateTime(2026, 11, 17, 12),
          text: null,
        ),
      );
      put(
        'nousReceivedLine(name=\'Alex\', kind=PingKind.kiss, text=null, ago=Duration(days: 2))',
        nousReceivedLine(
          lang,
          'Alex',
          PingKind.kiss,
          DateTime(2026, 11, 17, 12).subtract(const Duration(days: 2)),
          DateTime(2026, 11, 17, 12),
          text: null,
        ),
      );
      put(
        'nousReceivedLine(name=\'Alex\', kind=PingKind.kiss, text=null, ago=Duration(days: 40))',
        nousReceivedLine(
          lang,
          'Alex',
          PingKind.kiss,
          DateTime(2026, 11, 17, 12).subtract(const Duration(days: 40)),
          DateTime(2026, 11, 17, 12),
          text: null,
        ),
      );
      put(
        'nousReceivedLine(name=\'Alex\', kind=PingKind.kiss, text=\'<text>\', ago=Duration(seconds: 20))',
        nousReceivedLine(
          lang,
          'Alex',
          PingKind.kiss,
          DateTime(2026, 11, 17, 12).subtract(const Duration(seconds: 20)),
          DateTime(2026, 11, 17, 12),
          text: '<text>',
        ),
      );
      put(
        'nousReceivedLine(name=\'Alex\', kind=PingKind.kiss, text=\'<text>\', ago=Duration(minutes: 10))',
        nousReceivedLine(
          lang,
          'Alex',
          PingKind.kiss,
          DateTime(2026, 11, 17, 12).subtract(const Duration(minutes: 10)),
          DateTime(2026, 11, 17, 12),
          text: '<text>',
        ),
      );
      put(
        'nousReceivedLine(name=\'Alex\', kind=PingKind.kiss, text=\'<text>\', ago=Duration(hours: 3))',
        nousReceivedLine(
          lang,
          'Alex',
          PingKind.kiss,
          DateTime(2026, 11, 17, 12).subtract(const Duration(hours: 3)),
          DateTime(2026, 11, 17, 12),
          text: '<text>',
        ),
      );
      put(
        'nousReceivedLine(name=\'Alex\', kind=PingKind.kiss, text=\'<text>\', ago=Duration(days: 2))',
        nousReceivedLine(
          lang,
          'Alex',
          PingKind.kiss,
          DateTime(2026, 11, 17, 12).subtract(const Duration(days: 2)),
          DateTime(2026, 11, 17, 12),
          text: '<text>',
        ),
      );
      put(
        'nousReceivedLine(name=\'Alex\', kind=PingKind.kiss, text=\'<text>\', ago=Duration(days: 40))',
        nousReceivedLine(
          lang,
          'Alex',
          PingKind.kiss,
          DateTime(2026, 11, 17, 12).subtract(const Duration(days: 40)),
          DateTime(2026, 11, 17, 12),
          text: '<text>',
        ),
      );
      put(
        'nousReceivedLine(name=\'Alex\', kind=PingKind.custom, text=null, ago=Duration(seconds: 20))',
        nousReceivedLine(
          lang,
          'Alex',
          PingKind.custom,
          DateTime(2026, 11, 17, 12).subtract(const Duration(seconds: 20)),
          DateTime(2026, 11, 17, 12),
          text: null,
        ),
      );
      put(
        'nousReceivedLine(name=\'Alex\', kind=PingKind.custom, text=null, ago=Duration(minutes: 10))',
        nousReceivedLine(
          lang,
          'Alex',
          PingKind.custom,
          DateTime(2026, 11, 17, 12).subtract(const Duration(minutes: 10)),
          DateTime(2026, 11, 17, 12),
          text: null,
        ),
      );
      put(
        'nousReceivedLine(name=\'Alex\', kind=PingKind.custom, text=null, ago=Duration(hours: 3))',
        nousReceivedLine(
          lang,
          'Alex',
          PingKind.custom,
          DateTime(2026, 11, 17, 12).subtract(const Duration(hours: 3)),
          DateTime(2026, 11, 17, 12),
          text: null,
        ),
      );
      put(
        'nousReceivedLine(name=\'Alex\', kind=PingKind.custom, text=null, ago=Duration(days: 2))',
        nousReceivedLine(
          lang,
          'Alex',
          PingKind.custom,
          DateTime(2026, 11, 17, 12).subtract(const Duration(days: 2)),
          DateTime(2026, 11, 17, 12),
          text: null,
        ),
      );
      put(
        'nousReceivedLine(name=\'Alex\', kind=PingKind.custom, text=null, ago=Duration(days: 40))',
        nousReceivedLine(
          lang,
          'Alex',
          PingKind.custom,
          DateTime(2026, 11, 17, 12).subtract(const Duration(days: 40)),
          DateTime(2026, 11, 17, 12),
          text: null,
        ),
      );
      put(
        'nousReceivedLine(name=\'Alex\', kind=PingKind.custom, text=\'<text>\', ago=Duration(seconds: 20))',
        nousReceivedLine(
          lang,
          'Alex',
          PingKind.custom,
          DateTime(2026, 11, 17, 12).subtract(const Duration(seconds: 20)),
          DateTime(2026, 11, 17, 12),
          text: '<text>',
        ),
      );
      put(
        'nousReceivedLine(name=\'Alex\', kind=PingKind.custom, text=\'<text>\', ago=Duration(minutes: 10))',
        nousReceivedLine(
          lang,
          'Alex',
          PingKind.custom,
          DateTime(2026, 11, 17, 12).subtract(const Duration(minutes: 10)),
          DateTime(2026, 11, 17, 12),
          text: '<text>',
        ),
      );
      put(
        'nousReceivedLine(name=\'Alex\', kind=PingKind.custom, text=\'<text>\', ago=Duration(hours: 3))',
        nousReceivedLine(
          lang,
          'Alex',
          PingKind.custom,
          DateTime(2026, 11, 17, 12).subtract(const Duration(hours: 3)),
          DateTime(2026, 11, 17, 12),
          text: '<text>',
        ),
      );
      put(
        'nousReceivedLine(name=\'Alex\', kind=PingKind.custom, text=\'<text>\', ago=Duration(days: 2))',
        nousReceivedLine(
          lang,
          'Alex',
          PingKind.custom,
          DateTime(2026, 11, 17, 12).subtract(const Duration(days: 2)),
          DateTime(2026, 11, 17, 12),
          text: '<text>',
        ),
      );
      put(
        'nousReceivedLine(name=\'Alex\', kind=PingKind.custom, text=\'<text>\', ago=Duration(days: 40))',
        nousReceivedLine(
          lang,
          'Alex',
          PingKind.custom,
          DateTime(2026, 11, 17, 12).subtract(const Duration(days: 40)),
          DateTime(2026, 11, 17, 12),
          text: '<text>',
        ),
      );
      put(
        'nousReceivedLine(name=\'Camille\', kind=PingKind.thinkingOfYou, text=null, ago=Duration(seconds: 20))',
        nousReceivedLine(
          lang,
          'Camille',
          PingKind.thinkingOfYou,
          DateTime(2026, 11, 17, 12).subtract(const Duration(seconds: 20)),
          DateTime(2026, 11, 17, 12),
          text: null,
        ),
      );
      put(
        'nousReceivedLine(name=\'Camille\', kind=PingKind.thinkingOfYou, text=null, ago=Duration(minutes: 10))',
        nousReceivedLine(
          lang,
          'Camille',
          PingKind.thinkingOfYou,
          DateTime(2026, 11, 17, 12).subtract(const Duration(minutes: 10)),
          DateTime(2026, 11, 17, 12),
          text: null,
        ),
      );
      put(
        'nousReceivedLine(name=\'Camille\', kind=PingKind.thinkingOfYou, text=null, ago=Duration(hours: 3))',
        nousReceivedLine(
          lang,
          'Camille',
          PingKind.thinkingOfYou,
          DateTime(2026, 11, 17, 12).subtract(const Duration(hours: 3)),
          DateTime(2026, 11, 17, 12),
          text: null,
        ),
      );
      put(
        'nousReceivedLine(name=\'Camille\', kind=PingKind.thinkingOfYou, text=null, ago=Duration(days: 2))',
        nousReceivedLine(
          lang,
          'Camille',
          PingKind.thinkingOfYou,
          DateTime(2026, 11, 17, 12).subtract(const Duration(days: 2)),
          DateTime(2026, 11, 17, 12),
          text: null,
        ),
      );
      put(
        'nousReceivedLine(name=\'Camille\', kind=PingKind.thinkingOfYou, text=null, ago=Duration(days: 40))',
        nousReceivedLine(
          lang,
          'Camille',
          PingKind.thinkingOfYou,
          DateTime(2026, 11, 17, 12).subtract(const Duration(days: 40)),
          DateTime(2026, 11, 17, 12),
          text: null,
        ),
      );
      put(
        'nousReceivedLine(name=\'Camille\', kind=PingKind.thinkingOfYou, text=\'<text>\', ago=Duration(seconds: 20))',
        nousReceivedLine(
          lang,
          'Camille',
          PingKind.thinkingOfYou,
          DateTime(2026, 11, 17, 12).subtract(const Duration(seconds: 20)),
          DateTime(2026, 11, 17, 12),
          text: '<text>',
        ),
      );
      put(
        'nousReceivedLine(name=\'Camille\', kind=PingKind.thinkingOfYou, text=\'<text>\', ago=Duration(minutes: 10))',
        nousReceivedLine(
          lang,
          'Camille',
          PingKind.thinkingOfYou,
          DateTime(2026, 11, 17, 12).subtract(const Duration(minutes: 10)),
          DateTime(2026, 11, 17, 12),
          text: '<text>',
        ),
      );
      put(
        'nousReceivedLine(name=\'Camille\', kind=PingKind.thinkingOfYou, text=\'<text>\', ago=Duration(hours: 3))',
        nousReceivedLine(
          lang,
          'Camille',
          PingKind.thinkingOfYou,
          DateTime(2026, 11, 17, 12).subtract(const Duration(hours: 3)),
          DateTime(2026, 11, 17, 12),
          text: '<text>',
        ),
      );
      put(
        'nousReceivedLine(name=\'Camille\', kind=PingKind.thinkingOfYou, text=\'<text>\', ago=Duration(days: 2))',
        nousReceivedLine(
          lang,
          'Camille',
          PingKind.thinkingOfYou,
          DateTime(2026, 11, 17, 12).subtract(const Duration(days: 2)),
          DateTime(2026, 11, 17, 12),
          text: '<text>',
        ),
      );
      put(
        'nousReceivedLine(name=\'Camille\', kind=PingKind.thinkingOfYou, text=\'<text>\', ago=Duration(days: 40))',
        nousReceivedLine(
          lang,
          'Camille',
          PingKind.thinkingOfYou,
          DateTime(2026, 11, 17, 12).subtract(const Duration(days: 40)),
          DateTime(2026, 11, 17, 12),
          text: '<text>',
        ),
      );
      put(
        'nousReceivedLine(name=\'Camille\', kind=PingKind.goodNight, text=null, ago=Duration(seconds: 20))',
        nousReceivedLine(
          lang,
          'Camille',
          PingKind.goodNight,
          DateTime(2026, 11, 17, 12).subtract(const Duration(seconds: 20)),
          DateTime(2026, 11, 17, 12),
          text: null,
        ),
      );
      put(
        'nousReceivedLine(name=\'Camille\', kind=PingKind.goodNight, text=null, ago=Duration(minutes: 10))',
        nousReceivedLine(
          lang,
          'Camille',
          PingKind.goodNight,
          DateTime(2026, 11, 17, 12).subtract(const Duration(minutes: 10)),
          DateTime(2026, 11, 17, 12),
          text: null,
        ),
      );
      put(
        'nousReceivedLine(name=\'Camille\', kind=PingKind.goodNight, text=null, ago=Duration(hours: 3))',
        nousReceivedLine(
          lang,
          'Camille',
          PingKind.goodNight,
          DateTime(2026, 11, 17, 12).subtract(const Duration(hours: 3)),
          DateTime(2026, 11, 17, 12),
          text: null,
        ),
      );
      put(
        'nousReceivedLine(name=\'Camille\', kind=PingKind.goodNight, text=null, ago=Duration(days: 2))',
        nousReceivedLine(
          lang,
          'Camille',
          PingKind.goodNight,
          DateTime(2026, 11, 17, 12).subtract(const Duration(days: 2)),
          DateTime(2026, 11, 17, 12),
          text: null,
        ),
      );
      put(
        'nousReceivedLine(name=\'Camille\', kind=PingKind.goodNight, text=null, ago=Duration(days: 40))',
        nousReceivedLine(
          lang,
          'Camille',
          PingKind.goodNight,
          DateTime(2026, 11, 17, 12).subtract(const Duration(days: 40)),
          DateTime(2026, 11, 17, 12),
          text: null,
        ),
      );
      put(
        'nousReceivedLine(name=\'Camille\', kind=PingKind.goodNight, text=\'<text>\', ago=Duration(seconds: 20))',
        nousReceivedLine(
          lang,
          'Camille',
          PingKind.goodNight,
          DateTime(2026, 11, 17, 12).subtract(const Duration(seconds: 20)),
          DateTime(2026, 11, 17, 12),
          text: '<text>',
        ),
      );
      put(
        'nousReceivedLine(name=\'Camille\', kind=PingKind.goodNight, text=\'<text>\', ago=Duration(minutes: 10))',
        nousReceivedLine(
          lang,
          'Camille',
          PingKind.goodNight,
          DateTime(2026, 11, 17, 12).subtract(const Duration(minutes: 10)),
          DateTime(2026, 11, 17, 12),
          text: '<text>',
        ),
      );
      put(
        'nousReceivedLine(name=\'Camille\', kind=PingKind.goodNight, text=\'<text>\', ago=Duration(hours: 3))',
        nousReceivedLine(
          lang,
          'Camille',
          PingKind.goodNight,
          DateTime(2026, 11, 17, 12).subtract(const Duration(hours: 3)),
          DateTime(2026, 11, 17, 12),
          text: '<text>',
        ),
      );
      put(
        'nousReceivedLine(name=\'Camille\', kind=PingKind.goodNight, text=\'<text>\', ago=Duration(days: 2))',
        nousReceivedLine(
          lang,
          'Camille',
          PingKind.goodNight,
          DateTime(2026, 11, 17, 12).subtract(const Duration(days: 2)),
          DateTime(2026, 11, 17, 12),
          text: '<text>',
        ),
      );
      put(
        'nousReceivedLine(name=\'Camille\', kind=PingKind.goodNight, text=\'<text>\', ago=Duration(days: 40))',
        nousReceivedLine(
          lang,
          'Camille',
          PingKind.goodNight,
          DateTime(2026, 11, 17, 12).subtract(const Duration(days: 40)),
          DateTime(2026, 11, 17, 12),
          text: '<text>',
        ),
      );
      put(
        'nousReceivedLine(name=\'Camille\', kind=PingKind.onMyWay, text=null, ago=Duration(seconds: 20))',
        nousReceivedLine(
          lang,
          'Camille',
          PingKind.onMyWay,
          DateTime(2026, 11, 17, 12).subtract(const Duration(seconds: 20)),
          DateTime(2026, 11, 17, 12),
          text: null,
        ),
      );
      put(
        'nousReceivedLine(name=\'Camille\', kind=PingKind.onMyWay, text=null, ago=Duration(minutes: 10))',
        nousReceivedLine(
          lang,
          'Camille',
          PingKind.onMyWay,
          DateTime(2026, 11, 17, 12).subtract(const Duration(minutes: 10)),
          DateTime(2026, 11, 17, 12),
          text: null,
        ),
      );
      put(
        'nousReceivedLine(name=\'Camille\', kind=PingKind.onMyWay, text=null, ago=Duration(hours: 3))',
        nousReceivedLine(
          lang,
          'Camille',
          PingKind.onMyWay,
          DateTime(2026, 11, 17, 12).subtract(const Duration(hours: 3)),
          DateTime(2026, 11, 17, 12),
          text: null,
        ),
      );
      put(
        'nousReceivedLine(name=\'Camille\', kind=PingKind.onMyWay, text=null, ago=Duration(days: 2))',
        nousReceivedLine(
          lang,
          'Camille',
          PingKind.onMyWay,
          DateTime(2026, 11, 17, 12).subtract(const Duration(days: 2)),
          DateTime(2026, 11, 17, 12),
          text: null,
        ),
      );
      put(
        'nousReceivedLine(name=\'Camille\', kind=PingKind.onMyWay, text=null, ago=Duration(days: 40))',
        nousReceivedLine(
          lang,
          'Camille',
          PingKind.onMyWay,
          DateTime(2026, 11, 17, 12).subtract(const Duration(days: 40)),
          DateTime(2026, 11, 17, 12),
          text: null,
        ),
      );
      put(
        'nousReceivedLine(name=\'Camille\', kind=PingKind.onMyWay, text=\'<text>\', ago=Duration(seconds: 20))',
        nousReceivedLine(
          lang,
          'Camille',
          PingKind.onMyWay,
          DateTime(2026, 11, 17, 12).subtract(const Duration(seconds: 20)),
          DateTime(2026, 11, 17, 12),
          text: '<text>',
        ),
      );
      put(
        'nousReceivedLine(name=\'Camille\', kind=PingKind.onMyWay, text=\'<text>\', ago=Duration(minutes: 10))',
        nousReceivedLine(
          lang,
          'Camille',
          PingKind.onMyWay,
          DateTime(2026, 11, 17, 12).subtract(const Duration(minutes: 10)),
          DateTime(2026, 11, 17, 12),
          text: '<text>',
        ),
      );
      put(
        'nousReceivedLine(name=\'Camille\', kind=PingKind.onMyWay, text=\'<text>\', ago=Duration(hours: 3))',
        nousReceivedLine(
          lang,
          'Camille',
          PingKind.onMyWay,
          DateTime(2026, 11, 17, 12).subtract(const Duration(hours: 3)),
          DateTime(2026, 11, 17, 12),
          text: '<text>',
        ),
      );
      put(
        'nousReceivedLine(name=\'Camille\', kind=PingKind.onMyWay, text=\'<text>\', ago=Duration(days: 2))',
        nousReceivedLine(
          lang,
          'Camille',
          PingKind.onMyWay,
          DateTime(2026, 11, 17, 12).subtract(const Duration(days: 2)),
          DateTime(2026, 11, 17, 12),
          text: '<text>',
        ),
      );
      put(
        'nousReceivedLine(name=\'Camille\', kind=PingKind.onMyWay, text=\'<text>\', ago=Duration(days: 40))',
        nousReceivedLine(
          lang,
          'Camille',
          PingKind.onMyWay,
          DateTime(2026, 11, 17, 12).subtract(const Duration(days: 40)),
          DateTime(2026, 11, 17, 12),
          text: '<text>',
        ),
      );
      put(
        'nousReceivedLine(name=\'Camille\', kind=PingKind.missYou, text=null, ago=Duration(seconds: 20))',
        nousReceivedLine(
          lang,
          'Camille',
          PingKind.missYou,
          DateTime(2026, 11, 17, 12).subtract(const Duration(seconds: 20)),
          DateTime(2026, 11, 17, 12),
          text: null,
        ),
      );
      put(
        'nousReceivedLine(name=\'Camille\', kind=PingKind.missYou, text=null, ago=Duration(minutes: 10))',
        nousReceivedLine(
          lang,
          'Camille',
          PingKind.missYou,
          DateTime(2026, 11, 17, 12).subtract(const Duration(minutes: 10)),
          DateTime(2026, 11, 17, 12),
          text: null,
        ),
      );
      put(
        'nousReceivedLine(name=\'Camille\', kind=PingKind.missYou, text=null, ago=Duration(hours: 3))',
        nousReceivedLine(
          lang,
          'Camille',
          PingKind.missYou,
          DateTime(2026, 11, 17, 12).subtract(const Duration(hours: 3)),
          DateTime(2026, 11, 17, 12),
          text: null,
        ),
      );
      put(
        'nousReceivedLine(name=\'Camille\', kind=PingKind.missYou, text=null, ago=Duration(days: 2))',
        nousReceivedLine(
          lang,
          'Camille',
          PingKind.missYou,
          DateTime(2026, 11, 17, 12).subtract(const Duration(days: 2)),
          DateTime(2026, 11, 17, 12),
          text: null,
        ),
      );
      put(
        'nousReceivedLine(name=\'Camille\', kind=PingKind.missYou, text=null, ago=Duration(days: 40))',
        nousReceivedLine(
          lang,
          'Camille',
          PingKind.missYou,
          DateTime(2026, 11, 17, 12).subtract(const Duration(days: 40)),
          DateTime(2026, 11, 17, 12),
          text: null,
        ),
      );
      put(
        'nousReceivedLine(name=\'Camille\', kind=PingKind.missYou, text=\'<text>\', ago=Duration(seconds: 20))',
        nousReceivedLine(
          lang,
          'Camille',
          PingKind.missYou,
          DateTime(2026, 11, 17, 12).subtract(const Duration(seconds: 20)),
          DateTime(2026, 11, 17, 12),
          text: '<text>',
        ),
      );
      put(
        'nousReceivedLine(name=\'Camille\', kind=PingKind.missYou, text=\'<text>\', ago=Duration(minutes: 10))',
        nousReceivedLine(
          lang,
          'Camille',
          PingKind.missYou,
          DateTime(2026, 11, 17, 12).subtract(const Duration(minutes: 10)),
          DateTime(2026, 11, 17, 12),
          text: '<text>',
        ),
      );
      put(
        'nousReceivedLine(name=\'Camille\', kind=PingKind.missYou, text=\'<text>\', ago=Duration(hours: 3))',
        nousReceivedLine(
          lang,
          'Camille',
          PingKind.missYou,
          DateTime(2026, 11, 17, 12).subtract(const Duration(hours: 3)),
          DateTime(2026, 11, 17, 12),
          text: '<text>',
        ),
      );
      put(
        'nousReceivedLine(name=\'Camille\', kind=PingKind.missYou, text=\'<text>\', ago=Duration(days: 2))',
        nousReceivedLine(
          lang,
          'Camille',
          PingKind.missYou,
          DateTime(2026, 11, 17, 12).subtract(const Duration(days: 2)),
          DateTime(2026, 11, 17, 12),
          text: '<text>',
        ),
      );
      put(
        'nousReceivedLine(name=\'Camille\', kind=PingKind.missYou, text=\'<text>\', ago=Duration(days: 40))',
        nousReceivedLine(
          lang,
          'Camille',
          PingKind.missYou,
          DateTime(2026, 11, 17, 12).subtract(const Duration(days: 40)),
          DateTime(2026, 11, 17, 12),
          text: '<text>',
        ),
      );
      put(
        'nousReceivedLine(name=\'Camille\', kind=PingKind.kiss, text=null, ago=Duration(seconds: 20))',
        nousReceivedLine(
          lang,
          'Camille',
          PingKind.kiss,
          DateTime(2026, 11, 17, 12).subtract(const Duration(seconds: 20)),
          DateTime(2026, 11, 17, 12),
          text: null,
        ),
      );
      put(
        'nousReceivedLine(name=\'Camille\', kind=PingKind.kiss, text=null, ago=Duration(minutes: 10))',
        nousReceivedLine(
          lang,
          'Camille',
          PingKind.kiss,
          DateTime(2026, 11, 17, 12).subtract(const Duration(minutes: 10)),
          DateTime(2026, 11, 17, 12),
          text: null,
        ),
      );
      put(
        'nousReceivedLine(name=\'Camille\', kind=PingKind.kiss, text=null, ago=Duration(hours: 3))',
        nousReceivedLine(
          lang,
          'Camille',
          PingKind.kiss,
          DateTime(2026, 11, 17, 12).subtract(const Duration(hours: 3)),
          DateTime(2026, 11, 17, 12),
          text: null,
        ),
      );
      put(
        'nousReceivedLine(name=\'Camille\', kind=PingKind.kiss, text=null, ago=Duration(days: 2))',
        nousReceivedLine(
          lang,
          'Camille',
          PingKind.kiss,
          DateTime(2026, 11, 17, 12).subtract(const Duration(days: 2)),
          DateTime(2026, 11, 17, 12),
          text: null,
        ),
      );
      put(
        'nousReceivedLine(name=\'Camille\', kind=PingKind.kiss, text=null, ago=Duration(days: 40))',
        nousReceivedLine(
          lang,
          'Camille',
          PingKind.kiss,
          DateTime(2026, 11, 17, 12).subtract(const Duration(days: 40)),
          DateTime(2026, 11, 17, 12),
          text: null,
        ),
      );
      put(
        'nousReceivedLine(name=\'Camille\', kind=PingKind.kiss, text=\'<text>\', ago=Duration(seconds: 20))',
        nousReceivedLine(
          lang,
          'Camille',
          PingKind.kiss,
          DateTime(2026, 11, 17, 12).subtract(const Duration(seconds: 20)),
          DateTime(2026, 11, 17, 12),
          text: '<text>',
        ),
      );
      put(
        'nousReceivedLine(name=\'Camille\', kind=PingKind.kiss, text=\'<text>\', ago=Duration(minutes: 10))',
        nousReceivedLine(
          lang,
          'Camille',
          PingKind.kiss,
          DateTime(2026, 11, 17, 12).subtract(const Duration(minutes: 10)),
          DateTime(2026, 11, 17, 12),
          text: '<text>',
        ),
      );
      put(
        'nousReceivedLine(name=\'Camille\', kind=PingKind.kiss, text=\'<text>\', ago=Duration(hours: 3))',
        nousReceivedLine(
          lang,
          'Camille',
          PingKind.kiss,
          DateTime(2026, 11, 17, 12).subtract(const Duration(hours: 3)),
          DateTime(2026, 11, 17, 12),
          text: '<text>',
        ),
      );
      put(
        'nousReceivedLine(name=\'Camille\', kind=PingKind.kiss, text=\'<text>\', ago=Duration(days: 2))',
        nousReceivedLine(
          lang,
          'Camille',
          PingKind.kiss,
          DateTime(2026, 11, 17, 12).subtract(const Duration(days: 2)),
          DateTime(2026, 11, 17, 12),
          text: '<text>',
        ),
      );
      put(
        'nousReceivedLine(name=\'Camille\', kind=PingKind.kiss, text=\'<text>\', ago=Duration(days: 40))',
        nousReceivedLine(
          lang,
          'Camille',
          PingKind.kiss,
          DateTime(2026, 11, 17, 12).subtract(const Duration(days: 40)),
          DateTime(2026, 11, 17, 12),
          text: '<text>',
        ),
      );
      put(
        'nousReceivedLine(name=\'Camille\', kind=PingKind.custom, text=null, ago=Duration(seconds: 20))',
        nousReceivedLine(
          lang,
          'Camille',
          PingKind.custom,
          DateTime(2026, 11, 17, 12).subtract(const Duration(seconds: 20)),
          DateTime(2026, 11, 17, 12),
          text: null,
        ),
      );
      put(
        'nousReceivedLine(name=\'Camille\', kind=PingKind.custom, text=null, ago=Duration(minutes: 10))',
        nousReceivedLine(
          lang,
          'Camille',
          PingKind.custom,
          DateTime(2026, 11, 17, 12).subtract(const Duration(minutes: 10)),
          DateTime(2026, 11, 17, 12),
          text: null,
        ),
      );
      put(
        'nousReceivedLine(name=\'Camille\', kind=PingKind.custom, text=null, ago=Duration(hours: 3))',
        nousReceivedLine(
          lang,
          'Camille',
          PingKind.custom,
          DateTime(2026, 11, 17, 12).subtract(const Duration(hours: 3)),
          DateTime(2026, 11, 17, 12),
          text: null,
        ),
      );
      put(
        'nousReceivedLine(name=\'Camille\', kind=PingKind.custom, text=null, ago=Duration(days: 2))',
        nousReceivedLine(
          lang,
          'Camille',
          PingKind.custom,
          DateTime(2026, 11, 17, 12).subtract(const Duration(days: 2)),
          DateTime(2026, 11, 17, 12),
          text: null,
        ),
      );
      put(
        'nousReceivedLine(name=\'Camille\', kind=PingKind.custom, text=null, ago=Duration(days: 40))',
        nousReceivedLine(
          lang,
          'Camille',
          PingKind.custom,
          DateTime(2026, 11, 17, 12).subtract(const Duration(days: 40)),
          DateTime(2026, 11, 17, 12),
          text: null,
        ),
      );
      put(
        'nousReceivedLine(name=\'Camille\', kind=PingKind.custom, text=\'<text>\', ago=Duration(seconds: 20))',
        nousReceivedLine(
          lang,
          'Camille',
          PingKind.custom,
          DateTime(2026, 11, 17, 12).subtract(const Duration(seconds: 20)),
          DateTime(2026, 11, 17, 12),
          text: '<text>',
        ),
      );
      put(
        'nousReceivedLine(name=\'Camille\', kind=PingKind.custom, text=\'<text>\', ago=Duration(minutes: 10))',
        nousReceivedLine(
          lang,
          'Camille',
          PingKind.custom,
          DateTime(2026, 11, 17, 12).subtract(const Duration(minutes: 10)),
          DateTime(2026, 11, 17, 12),
          text: '<text>',
        ),
      );
      put(
        'nousReceivedLine(name=\'Camille\', kind=PingKind.custom, text=\'<text>\', ago=Duration(hours: 3))',
        nousReceivedLine(
          lang,
          'Camille',
          PingKind.custom,
          DateTime(2026, 11, 17, 12).subtract(const Duration(hours: 3)),
          DateTime(2026, 11, 17, 12),
          text: '<text>',
        ),
      );
      put(
        'nousReceivedLine(name=\'Camille\', kind=PingKind.custom, text=\'<text>\', ago=Duration(days: 2))',
        nousReceivedLine(
          lang,
          'Camille',
          PingKind.custom,
          DateTime(2026, 11, 17, 12).subtract(const Duration(days: 2)),
          DateTime(2026, 11, 17, 12),
          text: '<text>',
        ),
      );
      put(
        'nousReceivedLine(name=\'Camille\', kind=PingKind.custom, text=\'<text>\', ago=Duration(days: 40))',
        nousReceivedLine(
          lang,
          'Camille',
          PingKind.custom,
          DateTime(2026, 11, 17, 12).subtract(const Duration(days: 40)),
          DateTime(2026, 11, 17, 12),
          text: '<text>',
        ),
      );
      put(
        'pingReceivedTitle(kind=PingKind.thinkingOfYou, name=\'Alex\', text=null)',
        pingReceivedTitle(lang, PingKind.thinkingOfYou, 'Alex', text: null),
      );
      put(
        'pingReceivedTitle(kind=PingKind.thinkingOfYou, name=\'Alex\', text=\'<text>\')',
        pingReceivedTitle(lang, PingKind.thinkingOfYou, 'Alex', text: '<text>'),
      );
      put(
        'pingReceivedTitle(kind=PingKind.thinkingOfYou, name=\'Camille\', text=null)',
        pingReceivedTitle(lang, PingKind.thinkingOfYou, 'Camille', text: null),
      );
      put(
        'pingReceivedTitle(kind=PingKind.thinkingOfYou, name=\'Camille\', text=\'<text>\')',
        pingReceivedTitle(
          lang,
          PingKind.thinkingOfYou,
          'Camille',
          text: '<text>',
        ),
      );
      put(
        'pingReceivedTitle(kind=PingKind.goodNight, name=\'Alex\', text=null)',
        pingReceivedTitle(lang, PingKind.goodNight, 'Alex', text: null),
      );
      put(
        'pingReceivedTitle(kind=PingKind.goodNight, name=\'Alex\', text=\'<text>\')',
        pingReceivedTitle(lang, PingKind.goodNight, 'Alex', text: '<text>'),
      );
      put(
        'pingReceivedTitle(kind=PingKind.goodNight, name=\'Camille\', text=null)',
        pingReceivedTitle(lang, PingKind.goodNight, 'Camille', text: null),
      );
      put(
        'pingReceivedTitle(kind=PingKind.goodNight, name=\'Camille\', text=\'<text>\')',
        pingReceivedTitle(lang, PingKind.goodNight, 'Camille', text: '<text>'),
      );
      put(
        'pingReceivedTitle(kind=PingKind.onMyWay, name=\'Alex\', text=null)',
        pingReceivedTitle(lang, PingKind.onMyWay, 'Alex', text: null),
      );
      put(
        'pingReceivedTitle(kind=PingKind.onMyWay, name=\'Alex\', text=\'<text>\')',
        pingReceivedTitle(lang, PingKind.onMyWay, 'Alex', text: '<text>'),
      );
      put(
        'pingReceivedTitle(kind=PingKind.onMyWay, name=\'Camille\', text=null)',
        pingReceivedTitle(lang, PingKind.onMyWay, 'Camille', text: null),
      );
      put(
        'pingReceivedTitle(kind=PingKind.onMyWay, name=\'Camille\', text=\'<text>\')',
        pingReceivedTitle(lang, PingKind.onMyWay, 'Camille', text: '<text>'),
      );
      put(
        'pingReceivedTitle(kind=PingKind.missYou, name=\'Alex\', text=null)',
        pingReceivedTitle(lang, PingKind.missYou, 'Alex', text: null),
      );
      put(
        'pingReceivedTitle(kind=PingKind.missYou, name=\'Alex\', text=\'<text>\')',
        pingReceivedTitle(lang, PingKind.missYou, 'Alex', text: '<text>'),
      );
      put(
        'pingReceivedTitle(kind=PingKind.missYou, name=\'Camille\', text=null)',
        pingReceivedTitle(lang, PingKind.missYou, 'Camille', text: null),
      );
      put(
        'pingReceivedTitle(kind=PingKind.missYou, name=\'Camille\', text=\'<text>\')',
        pingReceivedTitle(lang, PingKind.missYou, 'Camille', text: '<text>'),
      );
      put(
        'pingReceivedTitle(kind=PingKind.kiss, name=\'Alex\', text=null)',
        pingReceivedTitle(lang, PingKind.kiss, 'Alex', text: null),
      );
      put(
        'pingReceivedTitle(kind=PingKind.kiss, name=\'Alex\', text=\'<text>\')',
        pingReceivedTitle(lang, PingKind.kiss, 'Alex', text: '<text>'),
      );
      put(
        'pingReceivedTitle(kind=PingKind.kiss, name=\'Camille\', text=null)',
        pingReceivedTitle(lang, PingKind.kiss, 'Camille', text: null),
      );
      put(
        'pingReceivedTitle(kind=PingKind.kiss, name=\'Camille\', text=\'<text>\')',
        pingReceivedTitle(lang, PingKind.kiss, 'Camille', text: '<text>'),
      );
      put(
        'pingReceivedTitle(kind=PingKind.custom, name=\'Alex\', text=null)',
        pingReceivedTitle(lang, PingKind.custom, 'Alex', text: null),
      );
      put(
        'pingReceivedTitle(kind=PingKind.custom, name=\'Alex\', text=\'<text>\')',
        pingReceivedTitle(lang, PingKind.custom, 'Alex', text: '<text>'),
      );
      put(
        'pingReceivedTitle(kind=PingKind.custom, name=\'Camille\', text=null)',
        pingReceivedTitle(lang, PingKind.custom, 'Camille', text: null),
      );
      put(
        'pingReceivedTitle(kind=PingKind.custom, name=\'Camille\', text=\'<text>\')',
        pingReceivedTitle(lang, PingKind.custom, 'Camille', text: '<text>'),
      );
      put('pingSignature(name=\'Alex\')', pingSignature(lang, 'Alex'));
      put('pingSignature(name=\'Camille\')', pingSignature(lang, 'Camille'));
      put('pingWriteBack()', pingWriteBack(lang));
      put('nousWrite()', nousWrite(lang));
      put('nousMyWords()', nousMyWords(lang));
      put('nousWriteTo(name=\'Alex\')', nousWriteTo(lang, 'Alex'));
      put('nousWriteTo(name=\'Camille\')', nousWriteTo(lang, 'Camille'));
      put('nousWriteHint()', nousWriteHint(lang));
      put('nousWriteReplaces()', nousWriteReplaces(lang));
      put('nousKeepWord()', nousKeepWord(lang));
      put('nousSend()', nousSend(lang));
      put('myWordsTitle()', myWordsTitle(lang));
      put('myWordsHelp()', myWordsHelp(lang));
      put('myWordsAddHint()', myWordsAddHint(lang));
      put('myWordsAdd()', myWordsAdd(lang));
      put('myWordsRemove(word=\'Alex\')', myWordsRemove(lang, 'Alex'));
      put('myWordsRemove(word=\'Camille\')', myWordsRemove(lang, 'Camille'));
      put('myWordsMove(word=\'Alex\')', myWordsMove(lang, 'Alex'));
      put('myWordsMove(word=\'Camille\')', myWordsMove(lang, 'Camille'));
      put('myWordsFull()', myWordsFull(lang));
      put('myWordsAlready()', myWordsAlready(lang));
      put('myWordsDrag()', myWordsDrag(lang));
      put('pingJustNow()', pingJustNow(lang));
      put('pingReplyMeToo()', pingReplyMeToo(lang));
      put('pingTapToClose()', pingTapToClose(lang));
      put('nousPartnerFallback()', nousPartnerFallback(lang));
      put('nousNextPlan()', nousNextPlan(lang));
      put('nousInDays(n=0)', nousInDays(lang, 0));
      put('nousInDays(n=1)', nousInDays(lang, 1));
      put('nousInDays(n=2)', nousInDays(lang, 2));
      put('nousInDays(n=5)', nousInDays(lang, 5));
      put('nousInDays(n=21)', nousInDays(lang, 21));
      put('nousNoCountdown()', nousNoCountdown(lang));
      put('nousNoCountdownHint()', nousNoCountdownHint(lang));
      put('nousAnniversary()', nousAnniversary(lang));
      put('nousYearsTogether(years=0)', nousYearsTogether(lang, 0));
      put('nousYearsTogether(years=1)', nousYearsTogether(lang, 1));
      put('nousYearsTogether(years=2)', nousYearsTogether(lang, 2));
      put('nousYearsTogether(years=5)', nousYearsTogether(lang, 5));
      put('nousYearsTogether(years=21)', nousYearsTogether(lang, 21));
      put('nousNoPartnerTitle()', nousNoPartnerTitle(lang));
      put('nousNoPartnerBody()', nousNoPartnerBody(lang));
      put('nousInvite()', nousInvite(lang));
      put('onboardingTitle()', onboardingTitle(lang));
      put('onboardingSubtitle()', onboardingSubtitle(lang));
      put('onboardingDisplayNameLabel()', onboardingDisplayNameLabel(lang));
      put('onboardingDisplayNameHint()', onboardingDisplayNameHint(lang));
      put('onboardingLanguageLabel()', onboardingLanguageLabel(lang));
      put('onboardingContinue()', onboardingContinue(lang));
      put('onboardingErrorDisplayName()', onboardingErrorDisplayName(lang));
      put('onboardingErrorGeneric()', onboardingErrorGeneric(lang));
      put('pairingInviteTitle()', pairingInviteTitle(lang));
      put('pairingIntro()', pairingIntro(lang));
      put('pairingGenerateCode()', pairingGenerateCode(lang));
      put('pairingScanQrPrompt()', pairingScanQrPrompt(lang));
      put('pairingOrEnterCode()', pairingOrEnterCode(lang));
      put('pairingAlreadyHaveCode()', pairingAlreadyHaveCode(lang));
      put('pairingJoinWithCode()', pairingJoinWithCode(lang));
      put('pairingScanQr()', pairingScanQr(lang));
      put('pairingAlreadyPaired()', pairingAlreadyPaired(lang));
      put('pairingError()', pairingError(lang));
      put('pairingJoinTitle()', pairingJoinTitle(lang));
      put('pairingJoinInstructions()', pairingJoinInstructions(lang));
      put('pairingJoinCodeLabel()', pairingJoinCodeLabel(lang));
      put('pairingJoinCodeHint()', pairingJoinCodeHint(lang));
      put('pairingJoinButton()', pairingJoinButton(lang));
      put('pairingJoinErrorCode()', pairingJoinErrorCode(lang));
      put('pairingJoinErrorUsed()', pairingJoinErrorUsed(lang));
      put('pairingJoinErrorOwnCode()', pairingJoinErrorOwnCode(lang));
      put('pairingJoinErrorInvalid()', pairingJoinErrorInvalid(lang));
      put(
        'pairingJoinErrorAlreadyPaired()',
        pairingJoinErrorAlreadyPaired(lang),
      );
      put(
        'pairingJoinErrorTooManyAttempts()',
        pairingJoinErrorTooManyAttempts(lang),
      );
      put(
        'pairingJoinError(failure=const NetworkFailure())',
        pairingJoinError(const NetworkFailure(), lang),
      );
      put(
        'pairingJoinError(failure=const ServerFailure(\'x\'))',
        pairingJoinError(const ServerFailure('x'), lang),
      );
      put(
        'pairingJoinError(failure=const UnknownFailure())',
        pairingJoinError(const UnknownFailure(), lang),
      );
      put(
        'pairingJoinError(failure=const WrongCredentialsFailure())',
        pairingJoinError(const WrongCredentialsFailure(), lang),
      );
      put(
        'pairingJoinError(failure=const PairingFailure(PairingProblem.invalidCode))',
        pairingJoinError(
          const PairingFailure(PairingProblem.invalidCode),
          lang,
        ),
      );
      put(
        'pairingJoinError(failure=const PairingFailure(PairingProblem.codeUsed))',
        pairingJoinError(const PairingFailure(PairingProblem.codeUsed), lang),
      );
      put(
        'pairingJoinError(failure=const PairingFailure(PairingProblem.ownCode))',
        pairingJoinError(const PairingFailure(PairingProblem.ownCode), lang),
      );
      put(
        'pairingJoinError(failure=const PairingFailure(PairingProblem.alreadyPaired))',
        pairingJoinError(
          const PairingFailure(PairingProblem.alreadyPaired),
          lang,
        ),
      );
      put(
        'pairingJoinError(failure=const PairingFailure(PairingProblem.tooManyAttempts))',
        pairingJoinError(
          const PairingFailure(PairingProblem.tooManyAttempts),
          lang,
        ),
      );
      put(
        'pairingJoinError(failure=const PingFailure(PingProblem.cooldown))',
        pairingJoinError(const PingFailure(PingProblem.cooldown), lang),
      );
      put(
        'pairingJoinError(failure=const PingFailure(PingProblem.notPaired))',
        pairingJoinError(const PingFailure(PingProblem.notPaired), lang),
      );
      put('pairingScanTitle()', pairingScanTitle(lang));
      put('pairingScanConnecting()', pairingScanConnecting(lang));
      put('periodLearnMore()', periodLearnMore(lang));
      put('periodCouldNotOpenLink()', periodCouldNotOpenLink(lang));
      put('positionTitle()', positionTitle(lang));
      put('positionNoPartnerMessage()', positionNoPartnerMessage(lang));
      put('positionNoPartnerSecondary()', positionNoPartnerSecondary(lang));
      put('positionInvitePartner()', positionInvitePartner(lang));
      put('positionEnableSharingMessage()', positionEnableSharingMessage(lang));
      put(
        'positionEnableSharingSecondary()',
        positionEnableSharingSecondary(lang),
      );
      put('positionOpenSettings()', positionOpenSettings(lang));
      put('positionReloadTooltip()', positionReloadTooltip(lang));
      put('positionReloadDone()', positionReloadDone(lang));
      put('positionMapPhoneOnly()', positionMapPhoneOnly(lang));
      put('positionTogether()', positionTogether(lang));
      put('positionTogetherTitle()', positionTogetherTitle(lang));
      put('positionMe()', positionMe(lang));
      put('positionSeeAll()', positionSeeAll(lang));
      put('positionPartnerFallback()', positionPartnerFallback(lang));
      put('mainNavCalendar()', mainNavCalendar(lang));
      put('mainNavPeriod()', mainNavPeriod(lang));
      put('mainNavPosition()', mainNavPosition(lang));
      put('settingsTitle()', settingsTitle(lang));
      put('settingsAboutApp()', settingsAboutApp(lang));
      put('settingsUsername()', settingsUsername(lang));
      put('settingsProfilePhoto()', settingsProfilePhoto(lang));
      put('settingsChangePhoto()', settingsChangePhoto(lang));
      put('settingsPermissions()', settingsPermissions(lang));
      put('settingsOpenAppSettings()', settingsOpenAppSettings(lang));
      put('settingsNotifications()', settingsNotifications(lang));
      put('settingsPeriodReminder()', settingsPeriodReminder(lang));
      put('settingsCalendarReminders()', settingsCalendarReminders(lang));
      put(
        'settingsCalendarRemindersSubtitle()',
        settingsCalendarRemindersSubtitle(lang),
      );
      put('settingsPermissionGranted()', settingsPermissionGranted(lang));
      put('settingsPermissionDenied()', settingsPermissionDenied(lang));
      put('settingsPermissionRestricted()', settingsPermissionRestricted(lang));
      put(
        'settingsPermissionPermanentDenied()',
        settingsPermissionPermanentDenied(lang),
      );
      put('settingsCalendars()', settingsCalendars(lang));
      put('settingsNotificationsPerm()', settingsNotificationsPerm(lang));
      put('settingsLocation()', settingsLocation(lang));
      put(
        'settingsPermissionsReloadTooltip()',
        settingsPermissionsReloadTooltip(lang),
      );
      put(
        'settingsPermissionsReloadDone()',
        settingsPermissionsReloadDone(lang),
      );
      put('settingsShareMyLocation()', settingsShareMyLocation(lang));
      put(
        'settingsShareMyLocationSubtitle()',
        settingsShareMyLocationSubtitle(lang),
      );
      put(
        'settingsLocationRequiredForSharing()',
        settingsLocationRequiredForSharing(lang),
      );
      put('settingsCamera()', settingsCamera(lang));
      put('settingsCoupleGroup()', settingsCoupleGroup(lang));
      put('settingsLeaveCouple()', settingsLeaveCouple(lang));
      put('settingsLeaveCoupleSubtitle()', settingsLeaveCoupleSubtitle(lang));
      put(
        'settingsLeaveCoupleConfirmTitle()',
        settingsLeaveCoupleConfirmTitle(lang),
      );
      put(
        'settingsLeaveCoupleConfirmMessage()',
        settingsLeaveCoupleConfirmMessage(lang),
      );
      put('settingsLeaveCoupleConfirm()', settingsLeaveCoupleConfirm(lang));
      put('settingsLeaveCoupleSuccess()', settingsLeaveCoupleSuccess(lang));
      put('settingsAccountGroup()', settingsAccountGroup(lang));
      put('settingsSignOut()', settingsSignOut(lang));
      put('settingsSignOutConfirmTitle()', settingsSignOutConfirmTitle(lang));
      put(
        'settingsSignOutConfirmMessage()',
        settingsSignOutConfirmMessage(lang),
      );
      put('settingsDeleteAccount()', settingsDeleteAccount(lang));
      put(
        'settingsDeleteAccountConfirmTitle()',
        settingsDeleteAccountConfirmTitle(lang),
      );
      put(
        'settingsDeleteAccountConfirmMessage(paired=true)',
        settingsDeleteAccountConfirmMessage(lang, paired: true),
      );
      put(
        'settingsDeleteAccountConfirmMessage(paired=false)',
        settingsDeleteAccountConfirmMessage(lang, paired: false),
      );
      put('settingsDeleteAccountConfirm()', settingsDeleteAccountConfirm(lang));
      put('settingsDeleteAccountDone()', settingsDeleteAccountDone(lang));
      put('settingsDeleteAccountFailed()', settingsDeleteAccountFailed(lang));
      put('appInfoTitle()', appInfoTitle(lang));
      put('appInfoDescription()', appInfoDescription(lang));
      put('appInfoFree()', appInfoFree(lang));
      put('appInfoSource()', appInfoSource(lang));
      put('appInfoContributors()', appInfoContributors(lang));
      put('appInfoThomasMoser()', appInfoThomasMoser(lang));
      put('appInfoEvahBaumlin()', appInfoEvahBaumlin(lang));
      put('appInfoFriends()', appInfoFriends(lang));
      put('settingsLanguage()', settingsLanguage(lang));
      put('settingsLanguageUpdated()', settingsLanguageUpdated(lang));
      put('settingsEditUsername()', settingsEditUsername(lang));
      put('settingsSave()', settingsSave(lang));
      put('settingsCancel()', settingsCancel(lang));
      put('appInfoFriendsName()', appInfoFriendsName(lang));
    }

    final file = File('test/l10n/strings_snapshot.json');
    if (Platform.environment['UPDATE_STRINGS_SNAPSHOT'] == '1') {
      file.writeAsStringSync(
        '${const JsonEncoder.withIndent('  ').convert(out)}\n',
      );
    }
    final expected = (jsonDecode(file.readAsStringSync()) as Map)
        .cast<String, String>();
    final changed = [
      for (final key in {...expected.keys, ...out.keys})
        if (expected[key] != out[key])
          '$key\n  was: ${expected[key]}\n  now: ${out[key]}',
    ];
    expect(changed, isEmpty, reason: changed.take(20).join('\n'));
  });
}
