import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nousdeux/domain/entities/shared_list_entity.dart';
import 'package:nousdeux/core/constants/lists_strings.dart';
import 'package:nousdeux/core/constants/nous_strings.dart';
import 'package:nousdeux/core/errors/failures.dart';
import 'package:nousdeux/core/utils/app_routes.dart';
import 'package:nousdeux/domain/entities/ping_entity.dart';
import 'package:nousdeux/core/constants/period_reminder_prefs.dart';
import 'package:nousdeux/presentation/screens/nous/my_words_screen.dart';
import 'package:nousdeux/presentation/screens/nous/nous_screen.dart';
import 'package:nousdeux/presentation/widgets/note_composer.dart';

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
    couple: couple(
      pairingCode: null,
      togetherSince: since ?? DateTime(2025, 9, 24),
    ),
    pings: pings,
    events: withCountdown
        ? [
            event(
              id: 'lyon',
              title: 'Lyon',
              start: DateTime(2026, 11, 20, 8),
              isCountdown: true,
            ),
            event(
              id: 'dentist',
              title: 'Dentiste',
              start: DateTime(2026, 11, 12, 9),
            ),
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
    stubRoute(AppRoutes.lists),
    stubRoute('/lists/:id'),
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
    testWidgets('[$lang] counts the days together since the start date', (
      tester,
    ) async {
      await _pump(tester, _paired(lang: lang));

      expect(find.text('412'), findsOneWidget);
      expect(find.text(nousDaysUnit(lang, 412)), findsOneWidget);
      expect(
        find.text(nousSinceDate(lang, DateTime(2025, 9, 24))),
        findsOneWidget,
      );
    });
  }

  testWidgets('the day counter fits at the largest text size', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 3;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await _pump(tester, _paired(since: DateTime(1990, 1, 1)));

    expect(tester.takeException(), isNull);
    expect(find.text('13462'), findsOneWidget);
  });

  testWidgets('falls back to the pairing day when no start date is stored', (
    tester,
  ) async {
    final deps = TestDeps(
      now: _now,
      myProfile: profile(partner: partnerId),
      partner: partnerProfile(),
      couple: couple(
        pairingCode: null,
        createdAt: DateTime.utc(2026, 11, 1, 10),
      ),
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
    testWidgets('offers the five notes and sends the one tapped', (
      tester,
    ) async {
      final deps = _paired();
      await _pump(tester, deps);

      for (final kind in PingKind.presets) {
        expect(find.text(pingLabel('fr', kind)), findsOneWidget);
      }
      await tester.tap(find.text(pingLabel('fr', PingKind.goodNight)));
      await tester.pumpAndSettle();

      expect(deps.pings.sent, [PingKind.goodNight]);
      expect(find.text(nousNoteSent('fr', PingKind.goodNight)), findsOneWidget);
    });

    testWidgets('explains the 30-second limit', (tester) async {
      final deps = _paired()
        ..pings.nextFailure = const PingFailure(PingProblem.cooldown);
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

      expect(find.text('Alex : Je pense à toi, il y a 12 min'), findsOneWidget);
    });
  });

  group("notes of one's own", () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    Future<void> write(WidgetTester tester, String text) async {
      await tester.tap(find.text(nousWrite('fr')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), text);
      await tester.pumpAndSettle();
    }

    testWidgets('"Écrire…" sends them and keeps them on Nous', (tester) async {
      final deps = _paired();
      await _pump(tester, deps);

      await write(tester, '  Bonne journée ');
      expect(
        find.text(nousWriteTo('fr', 'Alex').toUpperCase()),
        findsOneWidget,
      );
      expect(find.text('13 / 40'), findsOneWidget);
      await tester.tap(find.text(nousSend('fr')));
      await tester.pumpAndSettle();

      expect(deps.pings.sent, [PingKind.custom]);
      expect(deps.pings.sentTexts, ['Bonne journée']);
      expect(find.byType(NoteComposer), findsNothing);
      expect(
        find.text(nousNoteSent('fr', PingKind.custom, text: 'Bonne journée')),
        findsOneWidget,
      );
      // Kept: now a word on Nous, sent again with one tap.
      await tester.tap(find.widgetWithText(TextButton, 'Bonne journée'));
      await tester.pumpAndSettle();
      expect(deps.pings.sentTexts, ['Bonne journée', 'Bonne journée']);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(noteWordsKey), contains('Bonne journée'));
    });

    testWidgets('"Le garder" off sends without keeping', (tester) async {
      final deps = _paired();
      await _pump(tester, deps);

      await write(tester, 'Courage');
      await tester.tap(find.text(nousKeepWord('fr')));
      await tester.tap(find.text(nousSend('fr')));
      await tester.pumpAndSettle();

      expect(deps.pings.sentTexts, ['Courage']);
      expect(find.widgetWithText(TextButton, 'Courage'), findsNothing);
    });

    testWidgets('a refusal stays on the sheet with the reason', (tester) async {
      final deps = _paired()
        ..pings.nextFailure = const PingFailure(PingProblem.cooldown);
      await _pump(tester, deps);

      await write(tester, 'Courage');
      await tester.tap(find.text(nousSend('fr')));
      await tester.pumpAndSettle();

      expect(find.byType(NoteComposer), findsOneWidget);
      expect(find.text(nousNoteCooldown('fr')), findsOneWidget);
    });

    testWidgets('nothing to send until something is written', (tester) async {
      final deps = _paired();
      await _pump(tester, deps);

      await write(tester, '   ');
      await tester.tap(find.text(nousSend('fr')));
      await tester.pumpAndSettle();

      expect(deps.pings.sent, isEmpty);
    });

    testWidgets('the chosen words show, in their order', (tester) async {
      SharedPreferences.setMockInitialValues({
        noteWordsKey:
            '[{"k":"kiss","on":true},{"t":"Courage","on":true},'
            '{"k":"thinking_of_you","on":false}]',
      });
      final deps = _paired();
      await _pump(tester, deps);

      expect(find.text(pingLabel('fr', PingKind.thinkingOfYou)), findsNothing);
      final kiss = tester.getTopLeft(find.text(pingLabel('fr', PingKind.kiss)));
      final courage = tester.getTopLeft(find.text('Courage'));
      expect(kiss.dx, lessThan(courage.dx));

      await tester.tap(find.text('Courage'));
      await tester.pumpAndSettle();
      expect(deps.pings.sent, [PingKind.custom]);
      expect(deps.pings.sentTexts, ['Courage']);
    });

    testWidgets("the partner's written note shows in the line", (tester) async {
      await _pump(
        tester,
        _paired(
          pings: [
            PingEntity(
              coupleId: coupleId,
              senderId: partnerId,
              kind: PingKind.custom,
              text: 'Bonne journée',
              sentAt: _now.subtract(const Duration(minutes: 12)),
            ),
          ],
        ),
      );

      expect(
        find.text('Alex\u00a0: Bonne journée, il y a 12 min'),
        findsOneWidget,
      );
    });

    testWidgets('"Mes mots" opens the list', (tester) async {
      await _pump(tester, _paired());

      await tester.tap(find.text(nousMyWords('fr')));
      await tester.pumpAndSettle();

      expect(find.byType(MyWordsScreen), findsOneWidget);
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

  testWidgets('previews the lists and opens them', (tester) async {
    final deps = TestDeps(
      now: _now,
      myProfile: profile(partner: partnerId),
      partner: partnerProfile(),
      couple: couple(pairingCode: null, togetherSince: DateTime(2025, 9, 24)),
      lists: const [
        SharedListEntity(
          id: 'l1',
          coupleId: coupleId,
          name: 'Courses',
          icon: ListIcon.cart,
          createdBy: meId,
        ),
      ],
    );
    await _pump(tester, deps);

    await tester.scrollUntilVisible(find.text('Courses'), 200);
    expect(find.text(listsCounts('fr', 0, 0)), findsOneWidget);
    await tester.ensureVisible(find.text(listsSeeAll('fr')));
    await tester.pumpAndSettle();
    await tester.tap(find.text(listsSeeAll('fr')));
    await tester.pumpAndSettle();
    expect(find.text('stub:${AppRoutes.lists}'), findsOneWidget);
  });
}
