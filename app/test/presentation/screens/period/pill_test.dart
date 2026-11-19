import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nousdeux/core/constants/cycle_strings.dart';
import 'package:nousdeux/core/constants/period_education.dart'
    show periodCancel;
import 'package:nousdeux/core/constants/period_verified_sources.dart';
import 'package:nousdeux/core/constants/pill_strings.dart';
import 'package:nousdeux/domain/entities/pill_entities.dart';
import 'package:nousdeux/domain/pill/pill_schedule.dart';
import 'package:nousdeux/presentation/screens/period/pill_section.dart';
import 'package:nousdeux/presentation/screens/period/pill_setup_screen.dart';
import 'package:nousdeux/presentation/screens/settings/pill_settings_screen.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/test_app.dart';

// Wednesday 18 November 2026, pill 12 of a 21 + 7 pack started on 7 Nov.
final _today = DateTime(2026, 11, 18);
PillSettings _settings({
  bool reminderOn = true,
  ReminderText text = ReminderText.discreet,
  bool share = true,
}) => PillSettings(
  packType: PackType.p21x7,
  packStartedOn: DateTime(2026, 11, 7),
  reminderOn: reminderOn,
  reminderText: text,
  shareWithPartner: share,
);

Widget _inPage(Widget child) => Scaffold(body: ListView(children: [child]));

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('the setup (board 1)', () {
    testWidgets('« Oui » saves the pack and today\'s pill, after the consent', (
      tester,
    ) async {
      useTallSurface(tester);
      final deps = TestDeps(now: DateTime(2026, 11, 18, 10));
      await pumpScreen(tester, const PillSetupScreen(), deps: deps);

      expect(find.text(pillSetupQuestion('fr')), findsOneWidget);
      await tester.tap(find.text(pillPackType('fr', PackType.p28)));
      await tester.tap(find.byTooltip('+'));
      await tester.tap(find.byTooltip('+'));
      await tester.pumpAndSettle();
      expect(find.text(pillNumberToday('fr', 3)), findsOneWidget);

      await tester.tap(find.text(pillContinue('fr')));
      await tester.pumpAndSettle();
      expect(find.text(pillConsentTitle('fr')), findsOneWidget);
      await tester.tap(find.text(cycleConsentAccept('fr')));
      await tester.pumpAndSettle();

      final saved = deps.pill.savedSettings.single;
      expect(saved.packType, PackType.p28);
      expect(saved.packStartedOn, DateTime(2026, 11, 16));
      expect(saved.reminderTime, (hour: 21, minute: 0));
      expect(saved.reminderText, ReminderText.discreet);
    });

    testWidgets('each pack type says what it means', (tester) async {
      useTallSurface(tester);
      await pumpScreen(
        tester,
        const PillSetupScreen(),
        deps: TestDeps(now: DateTime(2026, 11, 18, 10)),
      );

      expect(
        find.text("21 comprimés, puis 7 jours d'arrêt sans rappel."),
        findsOneWidget,
      );
      await tester.tap(find.text(pillPackType('fr', PackType.p28)));
      await tester.pumpAndSettle();
      expect(
        find.text(
          "28 comprimés sans arrêt, y compris ceux sans hormone s'il y en a.",
        ),
        findsOneWidget,
      );
      await tester.tap(find.text(pillPackType('fr', PackType.continuous)));
      await tester.pumpAndSettle();
      expect(find.text('Un comprimé chaque jour, sans arrêt.'), findsOneWidget);
      expect(find.textContaining('21 comprimés'), findsNothing);
    });

    testWidgets('no consent: nothing saved', (tester) async {
      useTallSurface(tester);
      final deps = TestDeps(now: DateTime(2026, 11, 18, 10));
      await pumpScreen(tester, const PillSetupScreen(), deps: deps);

      await tester.tap(find.text(pillContinue('fr')));
      await tester.pumpAndSettle();
      await tester.tap(find.text(periodCancel('fr')));
      await tester.pumpAndSettle();

      expect(deps.pill.savedSettings, isEmpty);
    });

    testWidgets('already tracking: the setup changes nothing', (tester) async {
      useTallSurface(tester);
      final deps = TestDeps(
        now: DateTime(2026, 11, 18, 10),
        pillSettings: _settings(share: false, text: ReminderText.clear),
      );
      await pumpScreen(tester, const PillSetupScreen(), deps: deps);

      await tester.tap(find.text(pillContinue('fr')));
      await tester.pumpAndSettle();
      if (find.text(cycleConsentAccept('fr')).evaluate().isNotEmpty) {
        await tester.tap(find.text(cycleConsentAccept('fr')));
        await tester.pumpAndSettle();
      }
      expect(deps.pill.savedSettings, isEmpty);
    });

    testWidgets('« Non » is remembered and saves nothing', (tester) async {
      useTallSurface(tester);
      final deps = TestDeps(now: DateTime(2026, 11, 18, 10));
      await pumpScreen(tester, const PillSetupScreen(), deps: deps);

      await tester.tap(find.text(pillSetupNo('fr')));
      await tester.tap(find.text(pillContinue('fr')));
      await tester.pumpAndSettle();

      expect(deps.pill.savedSettings, isEmpty);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool(pillSetupDeclinedKey), isTrue);
    });
  });

  group('today in Règles (boards 2 and 4)', () {
    testWidgets('not tracking: a link to start', (tester) async {
      await pumpScreen(
        tester,
        _inPage(const PillSection()),
        deps: TestDeps(now: DateTime(2026, 11, 18, 20)),
      );
      expect(find.text('${pillTrackLink('fr')} ›'), findsOneWidget);
    });

    testWidgets('after « Non », no link', (tester) async {
      SharedPreferences.setMockInitialValues({pillSetupDeclinedKey: true});
      await pumpScreen(
        tester,
        _inPage(const PillSection()),
        deps: TestDeps(now: DateTime(2026, 11, 18, 20)),
      );
      expect(find.text('${pillTrackLink('fr')} ›'), findsNothing);
    });

    testWidgets('due: the pill number, the pack, and « Je l\'ai prise »', (
      tester,
    ) async {
      useTallSurface(tester);
      final deps = TestDeps(
        now: DateTime(2026, 11, 18, 20),
        pillSettings: _settings(),
        pillIntakes: [
          PillIntake.taken(
            DateTime(2026, 11, 17),
            DateTime(2026, 11, 17, 21, 3),
          ),
        ],
      );
      await pumpScreen(tester, _inPage(const PillSection()), deps: deps);

      expect(find.text('12'), findsOneWidget);
      expect(find.text(pillOfPack('fr', 21)), findsOneWidget);
      expect(find.text(pillNotTickedToday('fr')), findsOneWidget);
      expect(find.byKey(const ValueKey('pill-grid')), findsOneWidget);
      // A row per week of the pack, as on the board.
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('pill-grid')),
          matching: find.byType(Row),
        ),
        findsNWidgets(4),
      );
      // A short French month ends with a dot: never two at the end.
      expect(find.textContaining('..'), findsNothing);
      expect(
        find.text(pillPackLine('fr', _settings().schedule, _today)),
        findsOneWidget,
      );

      await tester.tap(find.text(pillTakeButton('fr')));
      await tester.pumpAndSettle();

      expect(deps.pill.takenCalls, [_today]);
      expect(
        find.text(pillTakenAt('fr', DateTime(2026, 11, 18, 20))),
        findsOneWidget,
      );
    });

    testWidgets('late: the missed block with the official sheet', (
      tester,
    ) async {
      useTallSurface(tester);
      final deps = TestDeps(
        now: DateTime(2026, 11, 18, 22, 30),
        pillSettings: _settings(),
      );
      await pumpScreen(tester, _inPage(const PillSection()), deps: deps);

      expect(find.text(pillNotTickedToday('fr')), findsOneWidget);
      expect(find.text(pillIfMissedBody('fr')), findsOneWidget);
      final sheet = sourcesMissedPill('fr').first;
      expect(
        find.text('${pillOfficialSheet('fr', sheet.name('fr'))} ›'),
        findsOneWidget,
      );
      expect(find.text(pillNoScore('fr')), findsOneWidget);

      await tester.tap(find.text('${pillNoteMissed('fr')} ›'));
      await tester.pumpAndSettle();
      expect(deps.pill.missedCalls, [_today]);
      expect(find.text(pillNotedMissed('fr')), findsOneWidget);
    });

    testWidgets('late after a morning reminder: never « ce soir »', (
      tester,
    ) async {
      useTallSurface(tester);
      final deps = TestDeps(
        now: DateTime(2026, 11, 18, 10, 30),
        pillSettings: PillSettings(
          packType: PackType.p21x7,
          packStartedOn: DateTime(2026, 11, 7),
          reminderTime: (hour: 9, minute: 0),
        ),
      );
      await pumpScreen(tester, _inPage(const PillSection()), deps: deps);

      expect(find.text(pillIfMissedBody('fr')), findsOneWidget);
      expect(find.textContaining('ce soir'), findsNothing);
      expect(find.text("Pas encore cochée aujourd'hui"), findsOneWidget);
    });

    testWidgets('missed days have their own grey mark in the pack', (
      tester,
    ) async {
      useTallSurface(tester);
      final deps = TestDeps(
        now: DateTime(2026, 11, 18, 20),
        pillSettings: _settings(),
        pillIntakes: [
          // Two in the same week of the pack: the same row.
          PillIntake.missed(DateTime(2026, 11, 15)),
          PillIntake.missed(DateTime(2026, 11, 16)),
          PillIntake.taken(
            DateTime(2026, 11, 17),
            DateTime(2026, 11, 17, 21, 3),
          ),
        ],
      );
      await pumpScreen(tester, _inPage(const PillSection()), deps: deps);

      expect(tester.takeException(), isNull);
      final lines = find.byKey(const ValueKey('pill-dot-missed-line'));
      expect(lines, findsNWidgets(2));
      final scheme = Theme.of(tester.element(lines.first)).colorScheme;
      for (final line in tester.widgetList<Container>(lines)) {
        expect(line.color, scheme.outline);
        expect(line.color, isNot(scheme.error));
      }
    });

    testWidgets('after midnight, yesterday\'s pill can still be ticked', (
      tester,
    ) async {
      useTallSurface(tester);
      final deps = TestDeps(
        now: DateTime(2026, 11, 19, 1, 51),
        pillSettings: _settings(),
      );
      await pumpScreen(tester, _inPage(const PillSection()), deps: deps);

      expect(find.text(pillYesterdayPending('fr')), findsOneWidget);
      await tester.tap(find.text(pillTookItYesterday('fr')));
      await tester.pumpAndSettle();
      expect(deps.pill.takenCalls, [DateTime(2026, 11, 18)]);
    });

    testWidgets('a day off says so', (tester) async {
      await pumpScreen(
        tester,
        _inPage(const PillSection()),
        deps: TestDeps(
          now: DateTime(2026, 11, 30, 20),
          pillSettings: _settings(),
        ),
      );
      expect(find.text(pillDayOff('fr')), findsOneWidget);
      expect(find.text(pillTakeButton('fr')), findsNothing);
      // Not « Jour 24 sur 21 »: the break and when it ends.
      expect(find.textContaining('sur 21'), findsNothing);
      expect(
        find.text(pillBreakUntil('fr', DateTime(2026, 12, 4))),
        findsOneWidget,
      );
    });
  });

  group('the partner\'s line (board 5)', () {
    Future<void> pump(WidgetTester tester, PartnerPillToday p) => pumpScreen(
      tester,
      _inPage(const PartnerPillLine(lang: 'fr')),
      deps: TestDeps(
        now: DateTime(2026, 11, 18, 22),
        myProfile: profile(partner: partnerId),
        partner: partnerProfile(),
        couple: couple(pairingCode: null),
        partnerPill: p,
      ),
    );

    testWidgets('taken, with the time', (tester) async {
      await pump(
        tester,
        PartnerPillToday(
          tracking: true,
          expected: true,
          takenAt: DateTime(2026, 11, 18, 21, 4),
        ),
      );
      expect(
        find.text(pillPartnerTaken('fr', DateTime(2026, 11, 18, 21, 4))),
        findsOneWidget,
      );
    });

    testWidgets('not ticked yet', (tester) async {
      await pump(
        tester,
        const PartnerPillToday(tracking: true, expected: true, takenAt: null),
      );
      expect(find.text(pillPartnerNotYet('fr')), findsOneWidget);
    });

    testWidgets('a day off, or nothing shared: no line', (tester) async {
      await pump(
        tester,
        const PartnerPillToday(tracking: true, expected: false, takenAt: null),
      );
      expect(find.text(pillPartnerNotYet('fr')), findsNothing);
      await pump(tester, PartnerPillToday.nothing);
      expect(find.text(pillPartnerNotYet('fr')), findsNothing);
      expect(find.text(pillLabel('fr').toUpperCase()), findsNothing);
    });
  });

  group('the settings (board 7)', () {
    Future<TestDeps> pump(WidgetTester tester) async {
      useTallSurface(tester);
      final deps = TestDeps(
        now: DateTime(2026, 11, 18, 12),
        myProfile: profile(partner: partnerId),
        partner: partnerProfile(),
        couple: couple(pairingCode: null),
        pillSettings: _settings(),
      );
      await pumpScreen(tester, const PillSettingsScreen(), deps: deps);
      return deps;
    }

    testWidgets('each switch and choice is saved', (tester) async {
      final deps = await pump(tester);

      await tester.tap(
        find.widgetWithText(SwitchListTile, pillReminderDaily('fr')),
      );
      await tester.pumpAndSettle();
      expect(deps.pill.savedSettings.last.reminderOn, isFalse);

      await tester.tap(
        find.text(pillLockScreenChoice('fr', ReminderText.clear)),
      );
      await tester.pumpAndSettle();
      expect(deps.pill.savedSettings.last.reminderText, ReminderText.clear);

      await tester.tap(
        find.widgetWithText(SwitchListTile, pillShareWith('fr', 'Alex')),
      );
      await tester.pumpAndSettle();
      expect(deps.pill.savedSettings.last.shareWithPartner, isFalse);
    });

    testWidgets('the lock-screen choice shows what will appear', (
      tester,
    ) async {
      await pump(tester);

      expect(
        find.text(
          'Vous verrez\u00a0: «\u00a0Petit rappel · Votre rappel de 21:00.\u00a0»',
        ),
        findsOneWidget,
      );
      expect(
        find.text("21 comprimés, puis 7 jours d'arrêt sans rappel."),
        findsOneWidget,
      );

      await tester.tap(
        find.text(pillLockScreenChoice('fr', ReminderText.clear)),
      );
      await tester.pumpAndSettle();
      expect(
        find.text(
          "Vous verrez\u00a0: «\u00a0Pilule · C'est l'heure de votre pilule. Comprimé 12.\u00a0»",
        ),
        findsOneWidget,
      );
    });

    testWidgets('the preview shows the next reminder that will ring', (
      tester,
    ) async {
      useTallSurface(tester);
      Future<void> pumpWith(PillSettings s, List<PillIntake> intakes) =>
          pumpScreen(
            tester,
            const PillSettingsScreen(),
            deps: TestDeps(
              now: DateTime(2026, 11, 18, 21, 10),
              myProfile: profile(partner: partnerId),
              partner: partnerProfile(),
              couple: couple(pairingCode: null),
              pillSettings: s,
              pillIntakes: intakes,
            ),
          );

      // Today's pill 12 ticked: the next one is tomorrow's, pill 13.
      await pumpWith(_settings(text: ReminderText.clear), [
        PillIntake.taken(_today, DateTime(2026, 11, 18, 21, 5)),
      ]);
      expect(
        find.text(
          "Vous verrez\u00a0: «\u00a0Pilule · C'est l'heure de votre pilule. Comprimé 13.\u00a0»",
        ),
        findsOneWidget,
      );

      // Reminders off: nothing will show, so no preview.
      await pumpWith(_settings(reminderOn: false), const []);
      expect(find.textContaining('Vous verrez'), findsNothing);
    });

    testWidgets('stopping asks first, then deletes everything', (tester) async {
      final deps = await pump(tester);

      await tester.tap(find.text(pillStop('fr')));
      await tester.pumpAndSettle();
      expect(find.text(pillStopConfirmTitle('fr')), findsOneWidget);
      await tester.tap(find.text(pillStopConfirm('fr')));
      await tester.pumpAndSettle();

      expect(deps.pill.stopCalls, 1);
    });
  });
}
