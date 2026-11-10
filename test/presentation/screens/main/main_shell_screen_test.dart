import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:nousdeux/presentation/widgets/ping_received.dart';
import 'package:nousdeux/domain/entities/ping_entity.dart';
import 'package:nousdeux/core/utils/app_routes.dart';
import 'package:nousdeux/core/constants/nous_strings.dart';
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
        branches: [for (final path in AppRoutes.tabs) branch(path)],
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

      expect(find.text(nousTitle(lang)), findsOneWidget);
      expect(find.text(mainNavCalendar(lang)), findsOneWidget);
      expect(find.text(mainNavPeriod(lang)), findsOneWidget);
      expect(find.text(mainNavPosition(lang)), findsOneWidget);
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
      2,
    );

    await tester.tap(find.text(mainNavCalendar('fr')));
    await tester.pumpAndSettle();
    expect(router.state.uri.path, AppRoutes.calendar);

    await tester.tap(find.text(nousTitle('fr')));
    await tester.pumpAndSettle();
    expect(router.state.uri.path, AppRoutes.home);
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

  group('little note from the partner', () {
    PingEntity note(DateTime at, [PingKind kind = PingKind.thinkingOfYou]) =>
        PingEntity(coupleId: coupleId, senderId: partnerId, kind: kind, sentAt: at);

    TestDeps paired({List<PingEntity>? pings}) => TestDeps(
      myProfile: profile(partner: partnerId),
      partner: partnerProfile(),
      couple: couple(pairingCode: null),
      pings: pings,
    );

    testWidgets('a new note arriving while open shows the moment', (tester) async {
      final deps = paired(pings: [note(DateTime(2026, 11, 10, 9))]);
      await _pumpShell(tester, deps);
      expect(find.byType(PingReceived), findsNothing, reason: 'old note on start');

      deps.pings.emit([note(DateTime(2026, 11, 10, 18), PingKind.goodNight)]);
      await tester.pumpAndSettle();

      expect(
        find.text(pingReceivedTitle('fr', PingKind.goodNight, 'Alex')),
        findsOneWidget,
      );
    });

    testWidgets('"Me too" replies with "thinking of you" and closes', (tester) async {
      final deps = paired();
      await _pumpShell(tester, deps);
      deps.pings.emit([note(DateTime(2026, 11, 10, 18))]);
      await tester.pumpAndSettle();

      await tester.tap(find.text(pingReplyMeToo('fr')));
      await tester.pumpAndSettle();

      expect(deps.pings.sent, [PingKind.thinkingOfYou]);
      expect(find.byType(PingReceived), findsNothing);
    });

    testWidgets('a note sent within the last minute shows on start', (tester) async {
      final deps = paired(pings: [note(DateTime(2026, 11, 10, 17, 59, 30))]);
      await _pumpShell(tester, deps);

      expect(find.byType(PingReceived), findsOneWidget);
    });
  });
}
