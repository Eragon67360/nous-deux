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

      expect(find.text(pillLateTitle('fr')), findsOneWidget);
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
