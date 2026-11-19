import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nousdeux/core/constants/update_strings.dart';
import 'package:nousdeux/core/services/store_links.dart';
import 'package:nousdeux/domain/app_update.dart';
import 'package:nousdeux/presentation/providers/app_update_provider.dart';
import 'package:nousdeux/presentation/screens/update/update_gate.dart';

import '../../../helpers/fakes.dart';
import '../../../helpers/test_app.dart';

const _pill = PublishedBuild(
  latestBuild: 30,
  minBuild: 0,
  note: {'fr': 'Le suivi de la pilule.', 'en': 'Pill tracking.'},
);

Future<void> pumpGate(WidgetTester tester, TestDeps deps) =>
    pumpScreen(tester, const UpdateGate(child: Text('app')), deps: deps);

/// Runs [body] as if on [platform], and puts the platform back.
Future<void> on(TargetPlatform platform, Future<void> Function() body) async {
  debugDefaultTargetPlatformOverride = platform;
  try {
    await body();
  } finally {
    debugDefaultTargetPlatformOverride = null;
  }
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('a newer build on the iPhone shows board 1 with its line', (
    tester,
  ) async {
    await on(TargetPlatform.iOS, () async {
      final deps = TestDeps(appBuilds: FakeAppBuildsRepository(ios: _pill));
      await pumpGate(tester, deps);
      expect(find.text('MISE À JOUR'), findsOneWidget);
      expect(find.text(updateTitle('fr')), findsOneWidget);
      expect(find.text('Le suivi de la pilule.'), findsOneWidget);
      expect(find.text('Votre version'), findsOneWidget);
      expect(find.text('build 29'), findsOneWidget);
      expect(find.text('La dernière'), findsOneWidget);
      expect(find.text('build 30'), findsOneWidget);
      expect(find.text('Ouvre TestFlight'), findsOneWidget);
      expect(find.text('Plus tard'), findsOneWidget);
      expect(deps.appBuilds.asked, ['ios']);
    });
  });

  testWidgets('« Mettre à jour » opens TestFlight, else the public beta link', (
    tester,
  ) async {
    await on(TargetPlatform.iOS, () async {
      final deps = TestDeps(appBuilds: FakeAppBuildsRepository(ios: _pill))
        ..linksThatOpen = {testFlightLinks.last};
      await pumpGate(tester, deps);
      await tester.tap(find.text('Mettre à jour'));
      await tester.pumpAndSettle();
      expect(deps.openedLinks, testFlightLinks);
    });
  });

  testWidgets(
    'on Android, Google Play decides and « Mettre à jour » opens it',
    (tester) async {
      final deps = TestDeps(
        appBuilds: FakeAppBuildsRepository(
          ios: const PublishedBuild(latestBuild: 40, minBuild: 0),
          android: _pill,
        ),
        playBuild: 30,
      );
      await pumpGate(tester, deps);
      expect(deps.appBuilds.asked, ['android']);
      expect(find.text('Le suivi de la pilule.'), findsOneWidget);
      expect(find.text('Ouvre Google Play'), findsOneWidget);
      await tester.tap(find.text('Mettre à jour'));
      await tester.pumpAndSettle();
      expect(deps.openedLinks, [playStoreLinks.first]);
    },
  );

  testWidgets('on Android, nothing while Play offers nothing', (tester) async {
    await pumpGate(
      tester,
      TestDeps(appBuilds: FakeAppBuildsRepository(android: _pill)),
    );
    expect(find.text('app'), findsOneWidget);
    expect(find.text(updateTitle('fr')), findsNothing);
  });

  testWidgets('« Plus tard » hides it at once and for the day; the next day '
      'it is back', (tester) async {
    await on(TargetPlatform.iOS, () async {
      await pumpGate(
        tester,
        TestDeps(appBuilds: FakeAppBuildsRepository(ios: _pill)),
      );
      await tester.tap(find.text('Plus tard'));
      await tester.pump();
      expect(find.text(updateTitle('fr')), findsNothing);
      expect(find.text('app'), findsOneWidget);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(updateLaterDayKey), '2026-11-10');

      // The app opens again the same evening, then the next morning.
      await tester.pumpWidget(const SizedBox());
      await pumpGate(
        tester,
        TestDeps(
          appBuilds: FakeAppBuildsRepository(ios: _pill),
          now: DateTime(2026, 11, 10, 23),
        ),
      );
      expect(find.text(updateTitle('fr')), findsNothing);
      await tester.pumpWidget(const SizedBox());
      await pumpGate(
        tester,
        TestDeps(
          appBuilds: FakeAppBuildsRepository(ios: _pill),
          now: DateTime(2026, 11, 11, 8),
        ),
      );
      expect(find.text(updateTitle('fr')), findsOneWidget);
    });
  });

  testWidgets('too old: board 2, with no way past it', (tester) async {
    await on(TargetPlatform.iOS, () async {
      SharedPreferences.setMockInitialValues({updateLaterDayKey: '2026-11-10'});
      await pumpGate(
        tester,
        TestDeps(
          appBuilds: FakeAppBuildsRepository(
            ios: const PublishedBuild(latestBuild: 31, minBuild: 30),
          ),
        ),
      );
      expect(find.text('MISE À JOUR NÉCESSAIRE'), findsOneWidget);
      expect(find.text(updateRequiredTitle('fr')), findsOneWidget);
      expect(
        find.text(
          'Pour continuer avec Nous Deux, installez la dernière version. '
          'Vos données et votre couple restent là.',
        ),
        findsOneWidget,
      );
      expect(find.text('build 29'), findsOneWidget);
      expect(find.text('La dernière'), findsNothing);
      expect(find.text('Plus tard'), findsNothing);
      expect(find.text('Mettre à jour'), findsOneWidget);
    });
  });

  testWidgets('up to date, or signed out: only the app', (tester) async {
    await on(TargetPlatform.iOS, () async {
      await pumpGate(
        tester,
        TestDeps(
          appBuilds: FakeAppBuildsRepository(ios: _pill),
          installedBuild: '30',
        ),
      );
      expect(find.text('app'), findsOneWidget);
      expect(find.text(updateTitle('fr')), findsNothing);

      final signedOut = TestDeps(
        user: null,
        appBuilds: FakeAppBuildsRepository(ios: _pill),
      );
      await tester.pumpWidget(const SizedBox());
      await pumpGate(tester, signedOut);
      expect(find.text(updateTitle('fr')), findsNothing);
      expect(signedOut.appBuilds.asked, isEmpty);
    });
  });

  testWidgets('back in the app, it checks again and stays up meanwhile', (
    tester,
  ) async {
    await on(TargetPlatform.iOS, () async {
      final builds = FakeAppBuildsRepository(ios: _pill);
      await pumpGate(tester, TestDeps(appBuilds: builds));
      expect(find.text(updateTitle('fr')), findsOneWidget);

      // The installed build caught up elsewhere: the next answer is "none".
      final answer = Completer<PublishedBuild?>();
      builds.next = answer;
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      expect(builds.asked, ['ios', 'ios']);
      expect(find.text(updateTitle('fr')), findsOneWidget);
      answer.complete(const PublishedBuild(latestBuild: 29, minBuild: 0));
      await tester.pumpAndSettle();
      expect(find.text(updateTitle('fr')), findsNothing);
    });
  });

  testWidgets('a failed check on return keeps the screen up', (tester) async {
    await on(TargetPlatform.iOS, () async {
      final builds = FakeAppBuildsRepository(
        ios: const PublishedBuild(latestBuild: 31, minBuild: 30),
      );
      await pumpGate(tester, TestDeps(appBuilds: builds));
      expect(find.text(updateRequiredTitle('fr')), findsOneWidget);

      // Back in the app in the metro: the server can't be reached.
      final answer = Completer<PublishedBuild?>();
      builds.next = answer;
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      answer.completeError(Exception('offline'));
      await tester.pumpAndSettle();
      expect(find.text(updateRequiredTitle('fr')), findsOneWidget);
    });
  });

  testWidgets('Google Play is asked at most every 30 minutes, and keeps its '
      'last answer when it fails', (tester) async {
    final deps = TestDeps(
      appBuilds: FakeAppBuildsRepository(android: _pill),
      playBuild: 30,
    );
    await pumpGate(tester, deps);
    expect(deps.playChecks, 1);
    expect(find.text(updateTitle('fr')), findsOneWidget);

    Future<void> comeBack() async {
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
    }

    await comeBack();
    expect(deps.playChecks, 1);

    // 40 minutes later Play fails: the last answer stands.
    await tester.pumpWidget(const SizedBox());
    final later = TestDeps(
      appBuilds: FakeAppBuildsRepository(android: _pill),
      playBuild: 30,
      now: DateTime(2026, 11, 10, 18, 40),
    );
    await pumpGate(tester, later);
    later.playFails = true;
    await comeBack();
    expect(find.text(updateTitle('fr')), findsOneWidget);
  });

  testWidgets('the build rows fit with the largest text', (tester) async {
    await on(TargetPlatform.iOS, () async {
      tester.view.physicalSize = const Size(320 * 3, 640 * 3);
      tester.view.devicePixelRatio = 3;
      tester.platformDispatcher.textScaleFactorTestValue = 3;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await pumpGate(
        tester,
        TestDeps(appBuilds: FakeAppBuildsRepository(ios: _pill)),
      );
      expect(tester.takeException(), isNull);
      expect(find.text('build 30'), findsOneWidget);
    });
  });

  testWidgets('the page underneath loses the keyboard when the screen shows', (
    tester,
  ) async {
    await on(TargetPlatform.iOS, () async {
      await pumpScreen(
        tester,
        const UpdateGate(child: Material(child: TextField(autofocus: true))),
        deps: TestDeps(appBuilds: FakeAppBuildsRepository(ios: _pill)),
      );
      expect(find.text(updateTitle('fr')), findsOneWidget);
      expect(
        tester
            .widget<EditableText>(find.byType(EditableText))
            .focusNode
            .hasFocus,
        isFalse,
      );
    });
  });
}
