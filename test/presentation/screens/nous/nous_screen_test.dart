import 'package:flutter_test/flutter_test.dart';

import 'package:nousdeux/core/constants/nous_strings.dart';
import 'package:nousdeux/core/errors/failures.dart';
import 'package:nousdeux/core/utils/app_routes.dart';
import 'package:nousdeux/domain/entities/ping_entity.dart';
import 'package:nousdeux/presentation/screens/nous/nous_screen.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/test_app.dart';

final _now = DateTime(2026, 11, 10, 18);

TestDeps _paired({
  String lang = 'fr',
  DateTime? since,
  List<PingEntity>? pings,
  bool withCountdown = false,
}) {
  return TestDeps(
    now: _now,
    myProfile: profile(partner: partnerId, language: lang),
    partner: partnerProfile(),
    couple: couple(pairingCode: null, togetherSince: since ?? DateTime(2025, 9, 24)),
    pings: pings,
    events: withCountdown
        ? [
            event(id: 'lyon', title: 'Lyon', start: DateTime(2026, 11, 20, 8), isCountdown: true),
            event(id: 'dentist', title: 'Dentiste', start: DateTime(2026, 11, 12, 9)),
          ]
        : null,
  );
}

Future<void> _pump(WidgetTester tester, TestDeps deps) => pumpRouter(
  tester,
  deps: deps,
  initialLocation: AppRoutes.home,
  routes: [
    screenRoute(AppRoutes.home, const NousScreen()),
    stubRoute(AppRoutes.settings),
    stubRoute(AppRoutes.pairing),
    stubRoute(AppRoutes.calendar),
  ],
).then((_) {});

void main() {
  testWidgets('without a partner it invites one', (tester) async {
    final deps = TestDeps(now: _now);
    await _pump(tester, deps);

    expect(find.text(nousNoPartnerTitle('fr')), findsOneWidget);
    await tester.tap(find.text(nousInvite('fr')));
    await tester.pumpAndSettle();
    expect(find.text('stub:${AppRoutes.pairing}'), findsOneWidget);
  });

  for (final lang in ['fr', 'en']) {
    testWidgets('[$lang] counts the days together since the start date', (tester) async {
      await _pump(tester, _paired(lang: lang));

      expect(find.text('412'), findsOneWidget);
      expect(find.text(nousDaysUnit(lang, 412)), findsOneWidget);
      expect(find.text(nousSinceDate(lang, DateTime(2025, 9, 24))), findsOneWidget);
    });
  }

  testWidgets('falls back to the pairing day when no start date is stored', (tester) async {
    final deps = TestDeps(
      now: _now,
      myProfile: profile(partner: partnerId),
      partner: partnerProfile(),
      couple: couple(pairingCode: null, createdAt: DateTime.utc(2026, 11, 1, 10)),
    );
    await _pump(tester, deps);

    expect(find.text('9'), findsOneWidget);
  });

  testWidgets('the avatar opens the settings', (tester) async {
    await _pump(tester, _paired());

    await tester.tap(find.byTooltip(nousSettingsTooltip('fr')));
    await tester.pumpAndSettle();
    expect(find.text('stub:${AppRoutes.settings}'), findsOneWidget);
  });

  testWidgets('editing the start date saves the picked day', (tester) async {
    final deps = _paired();
    await _pump(tester, deps);

    await tester.tap(find.text(nousEdit('fr')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(deps.pairing.togetherSinceUpdates, [DateTime(2025, 9, 24)]);
    expect(find.text(nousStartSaved('fr')), findsOneWidget);
  });

  group('little notes', () {
    testWidgets('offers the five notes and sends the one tapped', (tester) async {
      final deps = _paired();
      await _pump(tester, deps);

      for (final kind in PingKind.values) {
        expect(find.text(pingLabel('fr', kind)), findsOneWidget);
      }
      await tester.tap(find.text(pingLabel('fr', PingKind.goodNight)));
      await tester.pumpAndSettle();

      expect(deps.pings.sent, [PingKind.goodNight]);
      expect(find.text(nousNoteSent('fr', PingKind.goodNight)), findsOneWidget);
    });

    testWidgets('explains the 30-second limit', (tester) async {
      final deps = _paired()..pings.nextFailure = const PingFailure(PingProblem.cooldown);
      await _pump(tester, deps);

      await tester.tap(find.text(pingLabel('fr', PingKind.kiss)));
      await tester.pumpAndSettle();

      expect(find.text(nousNoteCooldown('fr')), findsOneWidget);
    });

    testWidgets("shows when the partner's last note arrived", (tester) async {
      await _pump(
        tester,
        _paired(
          pings: [
            PingEntity(
              coupleId: coupleId,
              senderId: partnerId,
              kind: PingKind.thinkingOfYou,
              sentAt: _now.subtract(const Duration(minutes: 12)),
            ),
          ],
        ),
      );

      expect(find.text('Alex, il y a 12 min'), findsOneWidget);
    });
  });

  testWidgets('shows the next countdown and the anniversary', (tester) async {
    await _pump(tester, _paired(withCountdown: true));

    expect(find.text('Lyon'), findsOneWidget);
    expect(find.text('Dentiste'), findsNothing);
    expect(find.text(nousInDays('fr', 10)), findsOneWidget);
    expect(find.text(nousYearsTogether('fr', 2)), findsOneWidget);
    expect(find.text(nousInDays('fr', 318)), findsOneWidget);
  });

  testWidgets('without a countdown it says how to add one', (tester) async {
    await _pump(tester, _paired());

    expect(find.text(nousNoCountdown('fr')), findsOneWidget);
    expect(find.text(nousNoCountdownHint('fr')), findsOneWidget);
  });
}
