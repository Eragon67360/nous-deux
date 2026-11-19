import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;

import 'package:nousdeux/core/constants/cycle_strings.dart';
import 'package:nousdeux/core/constants/news_strings.dart';
import 'package:nousdeux/core/constants/pill_strings.dart';
import 'package:nousdeux/core/services/feedback_mail.dart';
import 'package:nousdeux/core/services/local_notifications.dart';
import 'package:nousdeux/core/services/pill_reminders.dart';
import 'package:nousdeux/core/constants/period_education.dart';
import 'package:nousdeux/core/constants/period_reminder_prefs.dart';
import 'package:nousdeux/core/constants/settings_strings.dart';
import 'package:nousdeux/core/errors/failures.dart';
import 'package:nousdeux/core/l10n/app_languages.dart';
import 'package:nousdeux/data/calendar_sync/calendar_follow_prefs.dart';
import 'package:nousdeux/domain/entities/announcement_entity.dart';
import 'package:nousdeux/domain/entities/pill_entities.dart';
import 'package:nousdeux/domain/pill/pill_schedule.dart';
import 'package:nousdeux/presentation/providers/location_provider.dart';
import 'package:nousdeux/presentation/providers/settings_provider.dart';
import 'package:nousdeux/presentation/screens/settings/settings_screen.dart';

import '../../../helpers/fakes.dart';
import '../../../helpers/fixtures.dart';
import '../../../helpers/test_app.dart';

const _permissionsChannel = MethodChannel(
  'flutter.baseflow.com/permissions/methods',
);

final _statuses = <Permission, PermissionStatus>{
  // The screen still reads the deprecated combined calendar permission.
  // ignore: deprecated_member_use
  Permission.calendar: PermissionStatus.granted,
  Permission.notification: PermissionStatus.denied,
  Permission.location: PermissionStatus.permanentlyDenied,
  Permission.camera: PermissionStatus.restricted,
};

/// Answers `Permission.location.request()` with [status].
void _answerLocationRequest(WidgetTester tester, PermissionStatus status) {
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    _permissionsChannel,
    (call) async {
      if (call.method == 'requestPermissions') {
        return {Permission.location.value: status.index};
      }
      return null;
    },
  );
  addTearDown(
    () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      _permissionsChannel,
      null,
    ),
  );
}

/// The phone refuses `Permission.location.request()` because an earlier
/// request never got its answer (seen on iOS, GlitchTip APP-4), and
/// reports [current] when asked for the status.
void _locationRequestAlreadyRunning(
  WidgetTester tester,
  PermissionStatus current,
) {
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    _permissionsChannel,
    (call) async {
      if (call.method == 'requestPermissions') {
        throw PlatformException(code: 'ERROR_ALREADY_REQUESTING_PERMISSIONS');
      }
      if (call.method == 'checkPermissionStatus') return current.index;
      return null;
    },
  );
  addTearDown(
    () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      _permissionsChannel,
      null,
    ),
  );
}

Future<(TestDeps, GoRouter)> _pumpSettings(
  WidgetTester tester, {
  String lang = 'fr',
  bool paired = false,
  bool sharing = false,
  bool inCouple = true,
  bool? tracksCycle,
  List<AnnouncementEntity> announcements = const [],
  DateTime? announcementsSeenAt,
  List<Override> overrides = const [],
  PillSettings? pillSettings,
}) async {
  useTallSurface(tester);
  final deps = TestDeps(
    myProfile: profile(
      username: 'Camille',
      language: lang,
      partner: paired ? partnerId : null,
      tracksCycle: tracksCycle,
      announcementsSeenAt: announcementsSeenAt,
    ),
    announcements: announcements,
    pillSettings: pillSettings,
    partner: paired ? partnerProfile() : null,
    couple: inCouple ? couple(user2Id: paired ? partnerId : null) : null,
    myLocation: location(isSharing: sharing, lat: 48.85, lng: 2.35),
  );
  final router = await pumpRouter(
    tester,
    deps: deps,
    overrides: [
      permissionsProvider.overrideWith((ref) => Stream.value(_statuses)),
      ...overrides,
    ],
    initialLocation: '/settings',
    routes: [
      screenRoute(
        '/settings',
        const SettingsScreen(),
        routes: [stubRoute('info'), stubRoute('news')],
      ),
    ],
  );
  return (deps, router);
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  for (final lang in AppLanguages.supported) {
    testWidgets('[$lang] renders every section', (tester) async {
      await _pumpSettings(tester, lang: lang);

      expect(find.text(settingsTitle(lang)), findsOneWidget);
      expect(find.text('Camille'), findsOneWidget);
      for (final heading in [
        settingsLanguage(lang),
        settingsAboutApp(lang),
        settingsPermissions(lang),
        settingsLocation(lang),
        settingsNotifications(lang),
      ]) {
        expect(
          find.text(heading.toUpperCase()),
          findsOneWidget,
          reason: heading,
        );
      }
      expect(find.text(settingsOpenAppSettings(lang)), findsOneWidget);
      expect(find.text(settingsShareMyLocation(lang)), findsOneWidget);
      expect(find.text(settingsPeriodReminder(lang)), findsOneWidget);
      expect(find.text(settingsCalendarReminders(lang)), findsOneWidget);
      expect(
        find.text(settingsCalendarRemindersSubtitle(lang)),
        findsOneWidget,
      );
      expect(find.text(newsTitle(lang)), findsOneWidget);
      expect(find.text(settingsFeedback(lang)), findsOneWidget);
      expect(find.text(settingsNewsPush(lang)), findsOneWidget);
      expect(find.text(settingsNewsPushSubtitle(lang)), findsOneWidget);
    });
  }

  testWidgets('lists each permission with its status', (tester) async {
    await _pumpSettings(tester, lang: 'en');

    expect(find.text(settingsCalendars('en')), findsOneWidget);
    expect(find.text(settingsCamera('en')), findsOneWidget);
    expect(find.text(settingsPermissionGranted('en')), findsOneWidget);
    expect(find.text(settingsPermissionDenied('en')), findsOneWidget);
    expect(find.text(settingsPermissionPermanentDenied('en')), findsOneWidget);
    expect(find.text(settingsPermissionRestricted('en')), findsOneWidget);
  });

  testWidgets('"About" opens the app info page', (tester) async {
    final (_, router) = await _pumpSettings(tester);

    await tester.tap(find.text(settingsAboutApp('fr')));
    await tester.pumpAndSettle();

    expect(router.state.uri.path, '/settings/info');
  });

  group('Suivi de la pilule', () {
    testWidgets('someone who tracks a cycle finds it, and starts there', (
      tester,
    ) async {
      await _pumpSettings(tester, tracksCycle: true);

      await tester.ensureVisible(find.text(pillSettingsTitle('fr')));
      await tester.tap(find.text(pillSettingsTitle('fr')));
      await tester.pumpAndSettle();

      expect(find.text(pillSetupQuestion('fr')), findsOneWidget);
    });

    testWidgets('without cycle tracking it isn\'t offered', (tester) async {
      await _pumpSettings(tester, tracksCycle: false);
      expect(find.text(pillSettingsTitle('fr')), findsNothing);
    });

    testWidgets(
      'stopping the cycle and deleting everything stops the pill too',
      (tester) async {
        final (deps, _) = await _pumpSettings(
          tester,
          tracksCycle: true,
          pillSettings: PillSettings(
            packType: PackType.p28,
            packStartedOn: DateTime(2026, 11, 1),
          ),
        );

        await tester.tap(
          find.widgetWithText(SwitchListTile, settingsTracksCycle('fr')),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text(cycleStopDelete('fr')));
        await tester.pumpAndSettle();

        expect(deps.pill.stopCalls, 1);
      },
    );

    testWidgets('but a pill already tracked stays reachable', (tester) async {
      await _pumpSettings(
        tester,
        tracksCycle: false,
        pillSettings: PillSettings(
          packType: PackType.p28,
          packStartedOn: DateTime(2026, 11, 1),
        ),
      );
      expect(find.text(pillSettingsTitle('fr')), findsOneWidget);
    });
  });

  group('Envoyer un retour', () {
    testWidgets('opens the mail app with the build and the phone', (
      tester,
    ) async {
      final opened = <Uri>[];
      await _pumpSettings(
        tester,
        overrides: [
          openMailProvider.overrideWithValue((uri) async {
            opened.add(uri);
            return true;
          }),
        ],
      );

      await tester.tap(find.text(settingsFeedback('fr')));
      await tester.pumpAndSettle();

      // Tests run as Android, on build 29 (TestDeps).
      expect(opened, [feedbackMailUri(lang: 'fr', build: '29', isIos: false)]);
    });

    testWidgets('without a mail app, the address is shown instead', (
      tester,
    ) async {
      await _pumpSettings(
        tester,
        overrides: [openMailProvider.overrideWithValue((uri) async => false)],
      );

      await tester.tap(find.text(settingsFeedback('fr')));
      await tester.pumpAndSettle();

      expect(
        find.text(settingsFeedbackNoMail('fr', feedbackEmail)),
        findsOneWidget,
      );
    });
  });

  group('Nouveautés', () {
    final sent = AnnouncementEntity(
      id: 'a1',
      sentAt: DateTime.utc(2026, 11, 20, 18),
      texts: {'fr': (title: 'Les listes', body: 'Courses.')},
    );

    testWidgets('the row counts what is unread and opens the list', (
      tester,
    ) async {
      final (_, router) = await _pumpSettings(
        tester,
        announcements: [sent],
        announcementsSeenAt: DateTime.utc(2026, 11, 18),
      );

      expect(find.text(newsUnread('fr', 1)), findsOneWidget);
      expect(find.byKey(const ValueKey('news-unread-dot')), findsOneWidget);
      await tester.tap(find.text(newsTitle('fr')));
      await tester.pumpAndSettle();
      expect(router.state.uri.path, '/settings/news');
    });

    testWidgets('nothing unread: no count, no dot', (tester) async {
      await _pumpSettings(
        tester,
        announcements: [sent],
        announcementsSeenAt: DateTime.utc(2026, 11, 21),
      );

      expect(find.text(newsUnread('fr', 1)), findsNothing);
      expect(find.byKey(const ValueKey('news-unread-dot')), findsNothing);
    });

    testWidgets('the switch turns the app-news push off', (tester) async {
      final (deps, _) = await _pumpSettings(tester);

      final tile = find.widgetWithText(SwitchListTile, settingsNewsPush('fr'));
      expect(tester.widget<SwitchListTile>(tile).value, isTrue);
      await tester.tap(tile);
      await tester.pumpAndSettle();

      expect(deps.profiles.pushCalls, [false]);
      expect(tester.widget<SwitchListTile>(tile).value, isFalse);
    });
  });

  group('sign out', () {
    testWidgets('cancelling the confirmation keeps you signed in', (
      tester,
    ) async {
      final (deps, _) = await _pumpSettings(tester);

      await tester.ensureVisible(find.text(settingsSignOut('fr')));
      await tester.tap(find.text(settingsSignOut('fr')));
      await tester.pumpAndSettle();
      expect(find.text(settingsSignOutConfirmTitle('fr')), findsOneWidget);
      expect(find.text(settingsSignOutConfirmMessage('fr')), findsOneWidget);

      await tester.tap(find.text(settingsCancel('fr')));
      await tester.pumpAndSettle();

      expect(deps.auth.signOutCalls, 0);
    });

    testWidgets('confirming signs out through the repository', (tester) async {
      final (deps, _) = await _pumpSettings(tester, lang: 'en');

      await tester.ensureVisible(find.text(settingsSignOut('en')));
      await tester.tap(find.text(settingsSignOut('en')));
      await tester.pumpAndSettle();
      await tester.tap(
        find.widgetWithText(FilledButton, settingsSignOut('en')),
      );
      await tester.pumpAndSettle();

      expect(deps.auth.signOutCalls, 1);
    });
  });

  group('delete account', () {
    Future<void> openConfirmation(WidgetTester tester, String lang) async {
      await tester.ensureVisible(find.text(settingsDeleteAccount(lang)));
      await tester.tap(find.text(settingsDeleteAccount(lang)));
      await tester.pumpAndSettle();
    }

    Finder confirmButton(String lang) =>
        find.widgetWithText(FilledButton, settingsDeleteAccountConfirm(lang));

    testWidgets('cancelling keeps the account', (tester) async {
      final (deps, _) = await _pumpSettings(tester);

      await openConfirmation(tester, 'fr');
      expect(
        find.text(settingsDeleteAccountConfirmTitle('fr')),
        findsOneWidget,
      );
      expect(
        find.text(settingsDeleteAccountConfirmMessage('fr', paired: false)),
        findsOneWidget,
      );

      await tester.tap(find.text(settingsCancel('fr')));
      await tester.pumpAndSettle();

      expect(deps.auth.deleteAccountCalls, 0);
    });

    testWidgets('in a couple, the warning says the couple goes too', (
      tester,
    ) async {
      await _pumpSettings(tester, paired: true, lang: 'en');

      await openConfirmation(tester, 'en');

      expect(
        find.text(settingsDeleteAccountConfirmMessage('en', paired: true)),
        findsOneWidget,
      );
    });

    testWidgets('confirming deletes it and forgets it on this phone', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({
        periodPartnerReminderEnabledKey: true,
        calendarNotificationsEnabledKey: true,
        guideReadChaptersKey: <String>['cycle'],
        noteWordsKey: '[{"t":"Bonne journée","on":true}]',
        ownStatesKey: '["Besoin de chocolat"]',
        calendarFollowedKey: <String>['cal-1'],
        calendarInstallIdKey: '7c9e6679-7425-40de-944b-e07fc1f90ae7',
        'unrelated': 'kept',
      });
      final (deps, _) = await _pumpSettings(tester, lang: 'en');
      // A pill reminder planned on this phone.
      await deps.notifications.schedule(
        id: pillReminderFirstId,
        at: tz.TZDateTime(tz.local, 2030),
        channel: LocalChannel.pillReminder,
        title: 'Petit rappel',
        body: 'Votre rappel de 21:00.',
      );

      await openConfirmation(tester, 'en');
      await tester.tap(confirmButton('en'));
      await tester.pumpAndSettle();

      expect(deps.notifications.scheduled, isEmpty);
      expect(deps.auth.deleteAccountCalls, 1);
      expect(deps.auth.currentUser, isNull);
      expect(find.text(settingsDeleteAccountDone('en')), findsOneWidget);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getKeys(), {'unrelated'});
    });

    testWidgets('a failure keeps everything and says so', (tester) async {
      SharedPreferences.setMockInitialValues({
        periodPartnerReminderEnabledKey: true,
      });
      final (deps, _) = await _pumpSettings(tester);
      deps.auth.deleteFailure = const ServerFailure('offline');

      await openConfirmation(tester, 'fr');
      await tester.tap(confirmButton('fr'));
      await tester.pumpAndSettle();

      expect(find.text(settingsDeleteAccountFailed('fr')), findsOneWidget);
      expect(deps.auth.currentUser, isNotNull);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool(periodPartnerReminderEnabledKey), isTrue);
    });

    testWidgets('a second tap does nothing while it runs', (tester) async {
      final (deps, _) = await _pumpSettings(tester);
      final gate = deps.auth.gate = Completer<void>();

      await openConfirmation(tester, 'fr');
      await tester.tap(confirmButton('fr'));
      // Lets the dialog finish closing; settling would wait on the spinner.
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.tap(find.text(settingsDeleteAccount('fr')));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text(settingsDeleteAccountConfirmTitle('fr')), findsNothing);

      gate.complete();
      await tester.pumpAndSettle();
      expect(deps.auth.deleteAccountCalls, 1);
    });
  });

  group('leave couple', () {
    testWidgets('is hidden until the couple is complete', (tester) async {
      await _pumpSettings(tester);
      expect(find.text(settingsLeaveCouple('fr')), findsNothing);
      expect(find.text(settingsCoupleGroup('fr').toUpperCase()), findsNothing);
    });

    testWidgets('cancelling the confirmation keeps the couple', (tester) async {
      final (deps, _) = await _pumpSettings(tester, paired: true);

      await tester.tap(find.text(settingsLeaveCouple('fr')));
      await tester.pumpAndSettle();
      expect(find.text(settingsLeaveCoupleConfirmTitle('fr')), findsOneWidget);
      expect(
        find.text(settingsLeaveCoupleConfirmMessage('fr')),
        findsOneWidget,
      );

      await tester.tap(find.text(settingsCancel('fr')));
      await tester.pumpAndSettle();

      expect(deps.pairing.leaveCalls, 0);
      expect(find.text(settingsLeaveCouple('fr')), findsOneWidget);
    });

    testWidgets('confirming leaves through the repository', (tester) async {
      final (deps, _) = await _pumpSettings(tester, paired: true, lang: 'en');

      await tester.tap(find.text(settingsLeaveCouple('en')));
      await tester.pumpAndSettle();
      await tester.tap(find.text(settingsLeaveCoupleConfirm('en')));
      await tester.pumpAndSettle();

      expect(deps.pairing.leaveCalls, 1);
      expect(find.text(settingsLeaveCoupleSuccess('en')), findsOneWidget);
      expect(find.text(settingsLeaveCouple('en')), findsNothing);
    });

    testWidgets('a failure is reported in a snackbar', (tester) async {
      final (deps, _) = await _pumpSettings(tester, paired: true);
      deps.pairing.nextFailure = const ServerFailure('Impossible');

      await tester.tap(find.text(settingsLeaveCouple('fr')));
      await tester.pumpAndSettle();
      await tester.tap(find.text(settingsLeaveCoupleConfirm('fr')));
      await tester.pumpAndSettle();

      expect(deps.pairing.leaveCalls, 1);
      expect(find.text('Impossible'), findsOneWidget);
      expect(find.text(settingsLeaveCoupleSuccess('fr')), findsNothing);
    });
  });

  group('name', () {
    testWidgets('editing saves the trimmed name', (tester) async {
      final (deps, _) = await _pumpSettings(tester);

      await tester.tap(find.text('Camille'));
      await tester.pumpAndSettle();
      expect(find.text(settingsEditUsername('fr')), findsOneWidget);

      await tester.enterText(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.byType(TextField),
        ),
        '  Cam  ',
      );
      await tester.tap(find.text(settingsSave('fr')));
      await tester.pumpAndSettle();

      expect(deps.profiles.updateCalls.single.username, 'Cam');
      expect(find.text('Cam'), findsOneWidget);
    });

    testWidgets('an empty name is ignored', (tester) async {
      final (deps, _) = await _pumpSettings(tester);

      await tester.tap(find.text('Camille'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.byType(TextField),
        ),
        '   ',
      );
      await tester.tap(find.text(settingsSave('fr')));
      await tester.pumpAndSettle();

      expect(deps.profiles.updateCalls, isEmpty);
      expect(find.text('Camille'), findsOneWidget);
    });
  });

  testWidgets('switching to English saves it and relabels the screen', (
    tester,
  ) async {
    final (deps, _) = await _pumpSettings(tester);
    expect(find.text(AppLanguages.nativeName('fr')), findsOneWidget);

    await tester.tap(find.text(settingsLanguage('fr')));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppLanguages.nativeName('en')));
    await tester.pumpAndSettle();

    expect(deps.profiles.updateCalls.single.language, 'en');
    expect(find.text(settingsLanguageUpdated('en')), findsOneWidget);
    expect(find.text(settingsTitle('en')), findsOneWidget);
    expect(find.text(AppLanguages.nativeName('en')), findsOneWidget);
  });

  group('location sharing switch', () {
    SwitchListTile shareSwitch(WidgetTester tester) => tester.widget(
      find.widgetWithText(SwitchListTile, settingsShareMyLocation('fr')),
    );

    testWidgets('reflects the stored state', (tester) async {
      await _pumpSettings(tester, sharing: true);
      expect(shareSwitch(tester).value, isTrue);
    });

    testWidgets('is disabled without a couple', (tester) async {
      await _pumpSettings(tester, inCouple: false);
      expect(shareSwitch(tester).onChanged, isNull);
    });

    testWidgets('turning it off stops sharing without asking for location', (
      tester,
    ) async {
      final (deps, _) = await _pumpSettings(tester, sharing: true);

      await tester.tap(find.text(settingsShareMyLocation('fr')));
      await tester.pumpAndSettle();

      expect(deps.location.setCalls, [
        (isSharing: false, coupleId: coupleId, lat: null, lng: null),
      ]);
      expect(shareSwitch(tester).value, isFalse);
      final notifier =
          containerOf(tester).read(locationUpdateNotifierProvider.notifier)
              as FakeLocationUpdateNotifier;
      expect(notifier.pushCalls, 0);
    });

    testWidgets(
      'turning it on asks for location, then shares and pushes once',
      (tester) async {
        _answerLocationRequest(tester, PermissionStatus.granted);
        final (deps, _) = await _pumpSettings(tester);

        await tester.tap(find.text(settingsShareMyLocation('fr')));
        await tester.pumpAndSettle();

        expect(deps.location.setCalls, [
          (isSharing: true, coupleId: coupleId, lat: null, lng: null),
        ]);
        final notifier =
            containerOf(tester).read(locationUpdateNotifierProvider.notifier)
                as FakeLocationUpdateNotifier;
        expect(notifier.pushCalls, 1);
        expect(shareSwitch(tester).value, isTrue);
      },
    );

    testWidgets('a refused permission explains why and changes nothing', (
      tester,
    ) async {
      _answerLocationRequest(tester, PermissionStatus.denied);
      final (deps, _) = await _pumpSettings(tester);

      await tester.tap(find.text(settingsShareMyLocation('fr')));
      await tester.pumpAndSettle();

      expect(deps.location.setCalls, isEmpty);
      expect(
        find.text(settingsLocationRequiredForSharing('fr')),
        findsOneWidget,
      );
      expect(
        find.text(settingsOpenAppSettings('fr')),
        findsOneWidget,
        reason: 'only the settings tile, no snackbar action',
      );
    });

    testWidgets('a blocked permission offers to open the settings', (
      tester,
    ) async {
      _answerLocationRequest(tester, PermissionStatus.permanentlyDenied);
      await _pumpSettings(tester);

      await tester.tap(find.text(settingsShareMyLocation('fr')));
      await tester.pumpAndSettle();

      expect(
        find.text(settingsLocationRequiredForSharing('fr')),
        findsOneWidget,
      );
      expect(
        find.widgetWithText(SnackBarAction, settingsOpenAppSettings('fr')),
        findsOneWidget,
      );
    });
    testWidgets(
      'a request still waiting for its answer falls back to the status',
      (tester) async {
        _locationRequestAlreadyRunning(tester, PermissionStatus.granted);
        final (deps, _) = await _pumpSettings(tester);

        await tester.tap(find.text(settingsShareMyLocation('fr')));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(deps.location.setCalls, [
          (isSharing: true, coupleId: coupleId, lat: null, lng: null),
        ]);
      },
    );

    testWidgets(
      'a request still waiting and no answer yet offers the settings',
      (tester) async {
        _locationRequestAlreadyRunning(tester, PermissionStatus.denied);
        final (deps, _) = await _pumpSettings(tester);

        await tester.tap(find.text(settingsShareMyLocation('fr')));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(deps.location.setCalls, isEmpty);
        expect(
          find.text(settingsLocationRequiredForSharing('fr')),
          findsOneWidget,
        );
        expect(
          find.widgetWithText(SnackBarAction, settingsOpenAppSettings('fr')),
          findsOneWidget,
        );
      },
    );
  });

  group('notification switches', () {
    testWidgets('the PMS reminder switch stores the preference', (
      tester,
    ) async {
      await _pumpSettings(tester);

      await tester.tap(find.text(settingsPeriodReminder('fr')));
      await tester.pumpAndSettle();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool(periodPartnerReminderEnabledKey), isTrue);
      expect(
        tester
            .widget<SwitchListTile>(
              find.widgetWithText(SwitchListTile, settingsPeriodReminder('fr')),
            )
            .value,
        isTrue,
      );
    });

    testWidgets('the calendar reminder switch stores the preference', (
      tester,
    ) async {
      await _pumpSettings(tester);

      await tester.tap(find.text(settingsCalendarReminders('fr')));
      await tester.pumpAndSettle();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool(calendarNotificationsEnabledKey), isTrue);
    });
  });

  group('cycle tracking (health data)', () {
    Finder inDialog(String text) => find.descendant(
      of: find.byType(AlertDialog),
      matching: find.text(text),
    );

    testWidgets('turning it on asks for consent first', (tester) async {
      final (deps, _) = await _pumpSettings(tester, tracksCycle: false);

      await tester.tap(find.text(settingsTracksCycle('fr')));
      await tester.pumpAndSettle();
      expect(inDialog(cycleConsent('fr')), findsOneWidget);
      expect(inDialog(cyclePrivacyPolicy('fr')), findsOneWidget);
      await tester.tap(inDialog(periodCancel('fr')));
      await tester.pumpAndSettle();
      expect(deps.profiles.cycleSettingsCalls, isEmpty);

      await tester.tap(find.text(settingsTracksCycle('fr')));
      await tester.pumpAndSettle();
      await tester.tap(inDialog(cycleConsentAccept('fr')));
      await tester.pumpAndSettle();
      expect(deps.profiles.cycleSettingsCalls.single.tracksCycle, isTrue);
    });

    testWidgets('turning it off can keep the data', (tester) async {
      final (deps, _) = await _pumpSettings(tester, tracksCycle: true);

      await tester.tap(find.text(settingsTracksCycle('fr')));
      await tester.pumpAndSettle();
      await tester.tap(inDialog(cycleStopKeep('fr')));
      await tester.pumpAndSettle();

      expect(deps.cycle.deleteAllCalls, 0);
      expect(deps.profiles.cycleSettingsCalls.single.tracksCycle, isFalse);
    });

    testWidgets('or delete all of it: consent withdrawn', (tester) async {
      SharedPreferences.setMockInitialValues({
        ownStatesKey: '["Besoin de chocolat"]',
        noteWordsKey: '[{"t":"Bonne journée","on":true}]',
      });
      final (deps, _) = await _pumpSettings(tester, tracksCycle: true);

      await tester.tap(find.text(settingsTracksCycle('fr')));
      await tester.pumpAndSettle();
      await tester.tap(inDialog(cycleStopDelete('fr')));
      await tester.pumpAndSettle();

      expect(deps.cycle.deleteAllCalls, 1);
      expect(deps.profiles.cycleSettingsCalls.single.tracksCycle, isFalse);
      expect(find.text(cycleDataDeleted('fr')), findsOneWidget);
      // The states written for the check-in go with the cycle data; the
      // little notes are not cycle data and stay.
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getKeys(), {noteWordsKey});
    });

    testWidgets('a failed deletion keeps tracking on', (tester) async {
      final (deps, _) = await _pumpSettings(tester, tracksCycle: true);
      deps.cycle.nextFailure = const ServerFailure('down');

      await tester.tap(find.text(settingsTracksCycle('fr')));
      await tester.pumpAndSettle();
      await tester.tap(inDialog(cycleStopDelete('fr')));
      await tester.pumpAndSettle();

      expect(deps.profiles.cycleSettingsCalls, isEmpty);
      expect(find.text(cycleSaveFailed('fr')), findsOneWidget);
    });
  });

  testWidgets('the refresh button confirms with a snackbar', (tester) async {
    await _pumpSettings(tester);

    await tester.tap(find.byTooltip(settingsPermissionsReloadTooltip('fr')));
    await tester.pump();

    expect(find.text(settingsPermissionsReloadDone('fr')), findsOneWidget);
    await tester.pumpAndSettle();
  });
}
