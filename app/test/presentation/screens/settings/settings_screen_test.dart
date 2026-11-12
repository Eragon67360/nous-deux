import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nousdeux/core/constants/cycle_strings.dart';
import 'package:nousdeux/core/constants/period_education.dart';
import 'package:nousdeux/core/constants/period_reminder_prefs.dart';
import 'package:nousdeux/core/constants/settings_strings.dart';
import 'package:nousdeux/core/errors/failures.dart';
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

Future<(TestDeps, GoRouter)> _pumpSettings(
  WidgetTester tester, {
  String lang = 'fr',
  bool paired = false,
  bool sharing = false,
  bool inCouple = true,
  bool? tracksCycle,
}) async {
  useTallSurface(tester);
  final deps = TestDeps(
    myProfile: profile(
      username: 'Camille',
      language: lang,
      partner: paired ? partnerId : null,
      tracksCycle: tracksCycle,
    ),
    partner: paired ? partnerProfile() : null,
    couple: inCouple ? couple(user2Id: paired ? partnerId : null) : null,
    myLocation: location(isSharing: sharing, lat: 48.85, lng: 2.35),
  );
  final router = await pumpRouter(
    tester,
    deps: deps,
    overrides: [
      permissionsProvider.overrideWith((ref) => Stream.value(_statuses)),
    ],
    initialLocation: '/settings',
    routes: [
      screenRoute(
        '/settings',
        const SettingsScreen(),
        routes: [stubRoute('info')],
      ),
    ],
  );
  return (deps, router);
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  for (final lang in ['fr', 'en']) {
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
    expect(find.text(settingsLanguageFrench('fr')), findsOneWidget);

    await tester.tap(find.text(settingsLanguage('fr')));
    await tester.pumpAndSettle();
    await tester.tap(find.text(settingsLanguageEnglish('fr')));
    await tester.pumpAndSettle();

    expect(deps.profiles.updateCalls.single.language, 'en');
    expect(find.text(settingsLanguageUpdated('en')), findsOneWidget);
    expect(find.text(settingsTitle('en')), findsOneWidget);
    expect(find.text(settingsLanguageEnglish('en')), findsOneWidget);
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
      final (deps, _) = await _pumpSettings(tester, tracksCycle: true);

      await tester.tap(find.text(settingsTracksCycle('fr')));
      await tester.pumpAndSettle();
      await tester.tap(inDialog(cycleStopDelete('fr')));
      await tester.pumpAndSettle();

      expect(deps.cycle.deleteAllCalls, 1);
      expect(deps.profiles.cycleSettingsCalls.single.tracksCycle, isFalse);
      expect(find.text(cycleDataDeleted('fr')), findsOneWidget);
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
