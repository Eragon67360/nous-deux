import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:nousdeux/core/constants/app_strings.dart';
import 'package:nousdeux/core/constants/settings_strings.dart';
import 'package:nousdeux/presentation/screens/main/main_shell_screen.dart';
import 'package:nousdeux/presentation/widgets/pairing_celebration.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/test_app.dart';

const _channelName = 'profile-partner-$meId';

Future<GoRouter> _pumpShell(WidgetTester tester, TestDeps deps) {
  StatefulShellBranch branch(String path) =>
      StatefulShellBranch(routes: [stubRoute(path)]);
  return pumpRouter(
    tester,
    deps: deps,
    initialLocation: '/main',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) =>
            MainShellScreen(navigationShell: shell),
        branches: [
          branch('/main'),
          branch('/main/period'),
          branch('/main/position'),
          branch('/main/settings'),
        ],
      ),
      stubRoute('/pairing'),
    ],
  );
}

void main() {
  for (final lang in ['fr', 'en']) {
    testWidgets('[$lang] bottom navigation lists the four tabs', (
      tester,
    ) async {
      await _pumpShell(tester, TestDeps(myProfile: profile(language: lang)));

      expect(find.text(mainNavCalendar(lang)), findsOneWidget);
      expect(find.text(mainNavPeriod(lang)), findsOneWidget);
      expect(find.text(mainNavPosition(lang)), findsOneWidget);
      expect(find.text(mainNavSettings(lang)), findsOneWidget);
      expect(find.text('stub:/main'), findsOneWidget);
    });
  }

  testWidgets('tapping a tab switches branch', (tester) async {
    final router = await _pumpShell(tester, TestDeps());

    await tester.tap(find.text(mainNavPeriod('fr')));
    await tester.pumpAndSettle();
    expect(router.state.uri.path, '/main/period');
    expect(find.text('stub:/main/period'), findsOneWidget);
    expect(
      tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
      1,
    );

    await tester.tap(find.text(mainNavSettings('fr')));
    await tester.pumpAndSettle();
    expect(router.state.uri.path, '/main/settings');

    await tester.tap(find.text(mainNavCalendar('fr')));
    await tester.pumpAndSettle();
    expect(router.state.uri.path, '/main');
  });

  group('no-partner bubble', () {
    testWidgets('shows without a partner and opens pairing', (tester) async {
      final router = await _pumpShell(tester, TestDeps());

      expect(find.text(mainNoPartnerBubble('fr')), findsOneWidget);
      await tester.tap(find.text(mainNoPartnerBubble('fr')));
      await tester.pumpAndSettle();

      expect(router.state.uri.path, '/pairing');
    });

    testWidgets('is hidden once paired', (tester) async {
      await _pumpShell(tester, TestDeps(partner: partnerProfile()));
      expect(find.text(mainNoPartnerBubble('fr')), findsNothing);
    });

    testWidgets('is hidden while the profile is unknown', (tester) async {
      await _pumpShell(tester, TestDeps(user: null));
      expect(find.text(mainNoPartnerBubble('fr')), findsNothing);
    });
  });

  group('partner-joined realtime channel', () {
    testWidgets('subscribes to updates of my profile row', (tester) async {
      final deps = TestDeps();
      await _pumpShell(tester, deps);

      final channel = deps.realtime.named(_channelName);
      expect(deps.realtime.channels, hasLength(1));
      expect(channel.subscribed, isTrue);
      expect(channel.event, PostgresChangeEvent.update);
      expect(channel.table, 'profiles');
      expect(channel.filter?.column, 'id');
      expect(channel.filter?.value, meId);
    });

    testWidgets('does not subscribe when signed out', (tester) async {
      final deps = TestDeps(user: null);
      await _pumpShell(tester, deps);
      expect(deps.realtime.channels, isEmpty);
    });

    testWidgets('signing out unsubscribes', (tester) async {
      final deps = TestDeps();
      await _pumpShell(tester, deps);

      deps.auth.emit(null);
      await tester.pumpAndSettle();

      expect(deps.realtime.named(_channelName).unsubscribed, isTrue);
    });

    testWidgets('leaving the shell unsubscribes', (tester) async {
      final deps = TestDeps();
      final router = await _pumpShell(tester, deps);

      router.go('/pairing');
      await tester.pumpAndSettle();

      expect(deps.realtime.named(_channelName).unsubscribed, isTrue);
    });

    testWidgets(
      'when the partner joins: celebration, profile reloaded, tap to dismiss',
      (tester) async {
        final deps = TestDeps();
        await _pumpShell(tester, deps);
        expect(find.byType(PairingCelebration), findsNothing);
        final loadsBefore = deps.profiles.getOrCreateCalls;

        deps.profiles.mine = profile(partner: partnerId);
        deps.realtime.named(_channelName).emitUpdate({
          'id': meId,
          'partner_id': partnerId,
        });
        await tester.pumpAndSettle();

        expect(find.byType(PairingCelebration), findsOneWidget);
        expect(find.text(pairingCelebrationTitle('fr')), findsOneWidget);
        expect(deps.profiles.getOrCreateCalls, greaterThan(loadsBefore));
        expect(find.text(mainNoPartnerBubble('fr')), findsNothing);

        await tester.tap(find.byType(PairingCelebration));
        await tester.pumpAndSettle();
        expect(find.byType(PairingCelebration), findsNothing);
      },
    );

    testWidgets('other profile updates do not celebrate', (tester) async {
      final deps = TestDeps();
      await _pumpShell(tester, deps);

      final channel = deps.realtime.named(_channelName);
      channel.emitUpdate({'id': meId, 'partner_id': null});
      channel.emitUpdate({'id': meId, 'partner_id': ''});
      channel.emitUpdate({'id': meId, 'username': 'Cam'});
      await tester.pumpAndSettle();

      expect(find.byType(PairingCelebration), findsNothing);
    });
  });
}
