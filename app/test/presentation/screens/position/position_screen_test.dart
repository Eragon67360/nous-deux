import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:nousdeux/domain/entities/location_sharing_entity.dart';
import 'package:nousdeux/presentation/providers/location_provider.dart';
import 'package:nousdeux/presentation/screens/position/position_screen.dart';

import '../../../helpers/fakes.dart';
import '../../../helpers/fixtures.dart';
import '../../../helpers/test_app.dart';

// Only the states without a map are covered: the MapLibre map is a platform
// view. Its copy is private to position_screen.dart, so it is spelled out.
//
// No couple is set up on purpose: with one, the screen subscribes to Supabase
// Realtime through Supabase.instance.client, which is not initialized here.

/// The map only runs on Android/iOS; any other platform shows the placeholder.
final _noMap = TargetPlatformVariant.only(TargetPlatform.macOS);

const _paris = (lat: 48.8566, lng: 2.3522);

Future<(TestDeps, GoRouter)> _pumpPosition(
  WidgetTester tester, {
  String lang = 'fr',
  bool withPartner = true,
  LocationSharingEntity? mine,
  LocationSharingEntity? theirs,
}) async {
  final deps = TestDeps(
    myProfile: profile(language: lang, partner: withPartner ? partnerId : null),
    partner: withPartner ? partnerProfile(username: 'Alex') : null,
    myLocation: mine,
    partnerLocation: theirs,
  );
  final router = await pumpRouter(
    tester,
    deps: deps,
    initialLocation: '/main/position',
    routes: [
      screenRoute('/main/position', const PositionScreen()),
      stubRoute('/settings'),
      stubRoute('/pairing'),
    ],
  );
  return (deps, router);
}

const _disposeBug = 'Cannot use "ref" after the widget was disposed.';

/// Unmounts the screen inside the test body. PositionScreen.dispose() calls
/// `ref.read` after Riverpod has detached the element (see the skipped test
/// below), which throws while the tree is finalized. That one known error is
/// swallowed here so the other states stay testable; anything else fails.
Future<void> _unmount(WidgetTester tester) async {
  // Let snackbars time out first: the failing dispose aborts the rest of the
  // unmount, so their ScaffoldMessenger timer would never be cancelled.
  await tester.pump(const Duration(seconds: 5));
  await tester.pumpAndSettle();
  await tester.pumpWidget(const SizedBox());
  final error = tester.takeException();
  if (error == null) return;
  if (error is StateError && error.message == _disposeBug) return;
  throw error;
}

/// A widget test for PositionScreen that unmounts it before the framework does.
void positionTest(
  String description,
  Future<void> Function(WidgetTester tester) body, {
  TestVariant<Object?> variant = const DefaultTestVariant(),
}) {
  testWidgets(description, variant: variant, (tester) async {
    await body(tester);
    await _unmount(tester);
  });
}

FakeLocationUpdateNotifier _updates(WidgetTester tester) =>
    containerOf(tester).read(locationUpdateNotifierProvider.notifier)
        as FakeLocationUpdateNotifier;

void main() {
  group('no partner yet', () {
    positionTest('invites to pair', (tester) async {
      await _pumpPosition(tester, withPartner: false);

      expect(find.text('Position'), findsOneWidget);
      expect(find.text('Invitez votre partenaire'), findsOneWidget);
      expect(
        find.text('Une fois à deux, vous vous verrez sur la carte.'),
        findsOneWidget,
      );
      expect(find.text('Inviter'), findsOneWidget);
    });

    positionTest('the invite button opens pairing', (tester) async {
      final (_, router) = await _pumpPosition(
        tester,
        withPartner: false,
        lang: 'en',
      );

      expect(find.text('Invite your partner'), findsOneWidget);
      await tester.tap(find.text('Invite'));
      await tester.pumpAndSettle();

      expect(router.state.uri.path, '/pairing');
    });
  });

  group('partner, but no position shared', () {
    positionTest('asks to turn on location', (tester) async {
      await _pumpPosition(
        tester,
        mine: location(isSharing: false),
        theirs: location(userId: partnerId, isSharing: false),
      );

      expect(find.text('Activez la position'), findsOneWidget);
      expect(
        find.text(
          "Autorisez l'accès à la position dans les réglages de votre téléphone.",
        ),
        findsOneWidget,
      );
    });

    positionTest('the button goes to Settings', (tester) async {
      final (_, router) = await _pumpPosition(tester, lang: 'en');

      expect(find.text('Turn on location'), findsOneWidget);
      await tester.tap(find.text('Open settings'));
      await tester.pumpAndSettle();

      expect(router.state.uri.path, '/settings');
    });

    positionTest('a sharing row without coordinates still counts as none', (
      tester,
    ) async {
      await _pumpPosition(tester, mine: location());
      expect(find.text('Activez la position'), findsOneWidget);
      expect(_updates(tester).startCalls, 1, reason: 'sharing is on');
    });

    positionTest('refresh confirms with a snackbar', (tester) async {
      await _pumpPosition(tester);

      await tester.tap(find.byTooltip('Actualiser'));
      await tester.pump();

      expect(find.text('À jour'), findsOneWidget);
      expect(_updates(tester).pushCalls, 0, reason: 'not sharing');
      await tester.pumpAndSettle();
    });
  });

  group('positions known, map unavailable', () {
    positionTest('shows the placeholder, the distance and both names', (
      tester,
    ) async {
      await _pumpPosition(
        tester,
        mine: location(lat: _paris.lat, lng: _paris.lng),
        theirs: location(userId: partnerId, lat: 48.8666, lng: _paris.lng),
      );

      expect(find.text("La carte s'affiche sur téléphone."), findsOneWidget);
      expect(find.text('1.1 km'), findsOneWidget);
      expect(find.text('Moi'), findsOneWidget);
      expect(find.text('Alex'), findsOneWidget);
      expect(find.byTooltip('Voir tout'), findsOneWidget);
    }, variant: _noMap);

    positionTest('under a kilometre the distance is in metres', (tester) async {
      await _pumpPosition(
        tester,
        lang: 'en',
        mine: location(lat: _paris.lat, lng: _paris.lng),
        theirs: location(userId: partnerId, lat: 48.8606, lng: _paris.lng),
      );

      expect(find.text('The map shows on phones.'), findsOneWidget);
      expect(find.text('445 m'), findsOneWidget);
    }, variant: _noMap);

    positionTest('within 10 m the two of you are together', (tester) async {
      await _pumpPosition(
        tester,
        mine: location(lat: _paris.lat, lng: _paris.lng),
        theirs: location(userId: partnerId, lat: 48.85665, lng: _paris.lng),
      );

      expect(find.text('Ensemble ❤️'), findsOneWidget);
      expect(find.text('Nous Deux'), findsOneWidget);
      expect(find.text('Moi'), findsNothing);
    }, variant: _noMap);

    positionTest('only the partner shared: no distance, partner shown', (
      tester,
    ) async {
      await _pumpPosition(
        tester,
        mine: location(isSharing: false),
        theirs: location(userId: partnerId, lat: _paris.lat, lng: _paris.lng),
      );

      expect(find.textContaining(' km'), findsNothing);
      expect(find.textContaining(' m'), findsNothing);
      expect(find.text('Alex'), findsOneWidget);
      expect(find.byTooltip('Voir tout'), findsNothing);
      expect(_updates(tester).stopCalls, greaterThan(0), reason: 'not sharing');
    }, variant: _noMap);

    positionTest(
      'while sharing, updates start and refresh pushes a position',
      (tester) async {
        await _pumpPosition(
          tester,
          mine: location(lat: _paris.lat, lng: _paris.lng),
        );

        expect(_updates(tester).startCalls, 1);
        await tester.tap(find.byTooltip('Actualiser'));
        await tester.pumpAndSettle();
        expect(_updates(tester).pushCalls, 1);
      },
      variant: _noMap,
    );
  });

  testWidgets('leaving the screen stops the periodic updates', (tester) async {
    // Regression: dispose() used to call ref.read after unmount, which
    // Riverpod 2.6 forbids, so stop() never ran and the timer kept going.
    final (_, router) = await _pumpPosition(tester);
    final updates = _updates(tester);
    final stopsBefore = updates.stopCalls;

    router.go('/settings');
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(updates.stopCalls, stopsBefore + 1);
  });
}
