import 'dart:async';

import 'package:device_calendar/device_calendar.dart' show Calendar;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nousdeux/core/constants/calendar_strings.dart';
import 'package:nousdeux/core/errors/failures.dart';
import 'package:nousdeux/core/l10n/app_languages.dart';
import 'package:nousdeux/data/calendar_sync/calendar_follow_prefs.dart';
import 'package:nousdeux/domain/calendar/phone_event.dart';
import 'package:nousdeux/domain/entities/calendar_event_entity.dart';
import 'package:nousdeux/presentation/screens/calendar/calendar_follow_screen.dart';

import '../../../helpers/fakes.dart';
import '../../../helpers/fixtures.dart';
import '../../../helpers/test_app.dart';

const _install = '7c9e6679-7425-40de-944b-e07fc1f90ae7';

FakePhoneCalendar _phone({bool allowed = true}) => FakePhoneCalendar(
  calendars: [
    Calendar(id: 'cal-perso', name: 'Personnel', accountName: 'Google'),
    Calendar(id: 'cal-nous', name: 'Nous', accountName: 'iCloud'),
  ],
  events: {
    'cal-nous': [
      PhoneEvent(
        key: 'k-diner',
        title: 'Dîner chez Léa',
        start: DateTime(2026, 11, 20, 20),
      ),
    ],
  },
  allowed: allowed,
);

void main() {
  Future<TestDeps> pumpFollow(
    WidgetTester tester, {
    String lang = 'fr',
    FakePhoneCalendar? phone,
    Map<String, Object> prefs = const {},
    String? syncDevice,
    List<CalendarEventEntity>? events,
  }) async {
    SharedPreferences.setMockInitialValues({
      calendarInstallIdKey: _install,
      ...prefs,
    });
    final deps = TestDeps(
      myProfile: profile(
        language: lang,
        partner: partnerId,
        calendarSyncDevice: syncDevice,
      ),
      partner: partnerProfile(),
      events: events,
      phoneCalendar: phone ?? _phone(),
    );
    await pumpScreen(
      tester,
      const CalendarFollowScreen(),
      deps: deps,
      locale: lang,
    );
    await tester.pumpAndSettle();
    return deps;
  }

  Finder switchOf(String name) => find.widgetWithText(SwitchListTile, name);

  for (final lang in AppLanguages.supported) {
    testWidgets(
      '[$lang] lists the calendars, says what is shared, and the tip',
      (tester) async {
        await pumpFollow(tester, lang: lang);

        expect(find.text(calendarFollowTitle(lang)), findsOneWidget);
        expect(find.text(calendarFollowIntro(lang, 'Alex')), findsOneWidget);
        expect(find.text(calendarFollowTip(lang)), findsOneWidget);
        expect(switchOf('Personnel'), findsOneWidget);
        expect(switchOf('Nous'), findsOneWidget);
        expect(find.text('iCloud'), findsOneWidget);
        expect(tester.widget<SwitchListTile>(switchOf('Nous')).value, isFalse);
      },
    );

    testWidgets('[$lang] following a calendar names this phone and copies it', (
      tester,
    ) async {
      final deps = await pumpFollow(tester, lang: lang);

      await tester.tap(switchOf('Nous'));
      await tester.pumpAndSettle();

      expect(deps.profiles.mine!.calendarSyncDevice, _install);
      expect(await CalendarFollowPrefs().followed(), {'cal-nous'});
      expect(deps.calendar.events.single.title, 'Dîner chez Léa');
      expect(deps.calendar.events.single.sourceKey, 'k-diner');
      expect(tester.widget<SwitchListTile>(switchOf('Nous')).value, isTrue);
      expect(
        find.text(calendarFollowLastSync(lang).toUpperCase()),
        findsOneWidget,
      );
    });

    testWidgets('[$lang] a slow first copy shows the switch on and progress', (
      tester,
    ) async {
      final phone = _phone();
      phone.hold = Completer<void>();
      await pumpFollow(tester, lang: lang, phone: phone);

      await tester.tap(switchOf('Nous'));
      await tester.pump();
      expect(tester.widget<SwitchListTile>(switchOf('Nous')).value, isTrue);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);

      phone.hold!.complete();
      await tester.pumpAndSettle();
      expect(find.byType(LinearProgressIndicator), findsNothing);
      expect(tester.widget<SwitchListTile>(switchOf('Nous')).value, isTrue);
    });

    testWidgets('[$lang] unfollowing the last calendar removes its copies', (
      tester,
    ) async {
      final deps = await pumpFollow(
        tester,
        lang: lang,
        prefs: {
          calendarFollowedKey: ['cal-nous'],
        },
        syncDevice: _install,
        events: [
          event(
            id: 'copy-1',
            title: 'Dîner chez Léa',
            start: DateTime(2026, 11, 20, 20),
            sourceKey: 'k-diner',
          ),
        ],
      );
      expect(tester.widget<SwitchListTile>(switchOf('Nous')).value, isTrue);

      await tester.tap(switchOf('Nous'));
      await tester.pumpAndSettle();

      expect(deps.calendar.events, isEmpty);
      expect(deps.profiles.mine!.calendarSyncDevice, isNull);
      expect(await CalendarFollowPrefs().followed(), isEmpty);
    });

    testWidgets('[$lang] without access it asks, then lists the calendars', (
      tester,
    ) async {
      final phone = _phone(allowed: false);
      await pumpFollow(tester, lang: lang, phone: phone);
      expect(find.text(calendarFollowPermission(lang)), findsOneWidget);
      expect(switchOf('Nous'), findsNothing);

      await tester.tap(find.text(calendarImportAllowAccess(lang)));
      await tester.pumpAndSettle();

      expect(phone.accessRequests, 1);
      expect(switchOf('Nous'), findsOneWidget);
      expect(find.text(calendarFollowPermission(lang)), findsNothing);
    });

    testWidgets('[$lang] without access, "open settings" opens them', (
      tester,
    ) async {
      final calls = <String>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('flutter.baseflow.com/permissions/methods'),
        (call) async {
          calls.add(call.method);
          return true;
        },
      );
      await pumpFollow(tester, lang: lang, phone: _phone(allowed: false));

      await tester.tap(find.text(calendarImportOpenSettings(lang)));
      await tester.pumpAndSettle();

      expect(calls, ['openAppSettings']);
    });

    testWidgets('[$lang] when another phone follows, it says so', (
      tester,
    ) async {
      await pumpFollow(
        tester,
        lang: lang,
        syncDevice: '00000000-0000-4000-8000-000000000000',
      );

      expect(find.text(calendarFollowOtherPhone(lang)), findsOneWidget);
      expect(tester.widget<SwitchListTile>(switchOf('Nous')).value, isFalse);
    });

    testWidgets(
      '[$lang] a followed calendar gone from the phone can be dropped',
      (tester) async {
        await pumpFollow(
          tester,
          lang: lang,
          prefs: {
            calendarFollowedKey: ['cal-nous', 'cal-gone'],
          },
          syncDevice: _install,
        );
        expect(find.text(calendarFollowGone(lang)), findsOneWidget);

        await tester.tap(find.text(calendarFollowDropGone(lang)));
        await tester.pumpAndSettle();

        expect(await CalendarFollowPrefs().followed(), {'cal-nous'});
        expect(find.text(calendarFollowGone(lang)), findsNothing);
      },
    );

    testWidgets('[$lang] a failed update says so and leaves the switch off', (
      tester,
    ) async {
      final deps = await pumpFollow(tester, lang: lang);
      deps.profiles.nextFailure = const ServerFailure('offline');

      await tester.tap(switchOf('Nous'));
      await tester.pumpAndSettle();

      expect(find.text(calendarFollowFailed(lang)), findsOneWidget);
      expect(tester.widget<SwitchListTile>(switchOf('Nous')).value, isFalse);
    });
  }
}
