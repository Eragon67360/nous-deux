import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nousdeux/core/constants/cycle_strings.dart';
import 'package:nousdeux/core/constants/guide_chapters.dart';
import 'package:nousdeux/core/constants/nous_strings.dart';
import 'package:nousdeux/core/constants/period_education.dart';
import 'package:nousdeux/core/errors/failures.dart';
import 'package:nousdeux/domain/entities/cycle_checkin_entity.dart';
import 'package:nousdeux/domain/entities/period_log_entity.dart';
import 'package:nousdeux/domain/entities/ping_entity.dart';
import 'package:nousdeux/presentation/screens/period/period_screen.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/test_app.dart';

void main() {
  // TestDeps' "now": Tuesday 10 November 2026, 18:00.
  final today = DateTime(2026, 11, 10);
  DateTime day(int month, int d) => DateTime(2026, month, d);

  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<TestDeps> pumpRegles(
    WidgetTester tester, {
    bool? tracks = true,
    bool paired = true,
    bool partnerShares = true,
    List<PeriodLogEntity> logs = const [],
    List<CycleCheckinEntity> checkins = const [],
    String lang = 'fr',
    bool openGuide = false,
  }) async {
    useTallSurface(tester);
    final deps = TestDeps(
      myProfile: profile(
        language: lang,
        partner: paired ? partnerId : null,
        tracksCycle: tracks,
      ),
      partner: paired ? partnerProfile(shareCycle: partnerShares) : null,
      couple: paired ? couple() : null,
      logs: logs,
      checkins: checkins,
    );
    await pumpScreen(tester, PeriodScreen(openGuide: openGuide), deps: deps);
    return deps;
  }

  String label(String text) => text.toUpperCase();

  group('who tracks', () {
    for (final lang in ['fr', 'en']) {
      testWidgets('[$lang] asks once, then becomes my tracker', (tester) async {
        final deps = await pumpRegles(tester, tracks: null, lang: lang);

        expect(find.text(cycleAskTitle(lang)), findsOneWidget);
        // Cycle data is health data: what "yes" means is said right there.
        expect(find.text(cycleConsent(lang)), findsOneWidget);
        expect(find.text(cyclePrivacyPolicy(lang)), findsOneWidget);
        await tester.tap(find.text(cycleAskYes(lang)));
        await tester.pumpAndSettle();

        expect(deps.profiles.cycleSettingsCalls.single.tracksCycle, isTrue);
        expect(find.text(cycleAskTitle(lang)), findsNothing);
        expect(find.text(cycleNoDataTitle(lang)), findsOneWidget);
        expect(find.text(cycleStarted(lang)), findsOneWidget);
      });
    }

    testWidgets('"No" shows my partner\'s side instead', (tester) async {
      final deps = await pumpRegles(tester, tracks: null);

      await tester.tap(find.text(cycleAskNo('fr')));
      await tester.pumpAndSettle();

      expect(deps.profiles.cycleSettingsCalls.single.tracksCycle, isFalse);
      expect(find.text(cyclePartnerNothingYet('fr', 'Alex')), findsOneWidget);
    });
  });

  group('my cycle (R1)', () {
    final lastPeriod = [periodLog(start: day(11, 1), end: day(11, 5))];

    testWidgets('shows the day, the phase and when the next one comes', (
      tester,
    ) async {
      await pumpRegles(tester, logs: lastPeriod);

      expect(find.text('10'), findsOneWidget);
      expect(find.text(cycleOfAbout('fr', 28)), findsOneWidget);
      expect(
        find.text(label(cyclePhaseLabel('fr', CyclePhase.follicular))),
        findsOneWidget,
      );
      expect(
        find.text(
          cycleHeadline('fr', ongoing: false, dayOfCycle: 10, daysUntil: 19),
        ),
        findsOneWidget,
      );
      expect(find.text(cycleBasis('fr', day(11, 29), 0)), findsOneWidget);
      expect(
        find.text(cycleSelfTip('fr', CyclePhase.follicular)),
        findsOneWidget,
      );
    });

    testWidgets('one tap notes a start today, and can be undone', (
      tester,
    ) async {
      final deps = await pumpRegles(tester, logs: lastPeriod);

      await tester.tap(find.text(cycleStarted('fr')));
      await tester.pumpAndSettle();

      expect(deps.period.createCalls.single.startDate, today);
      expect(find.text(cycleLoggedStart('fr', today)), findsOneWidget);
      // The new period is on: the button now offers to end it.
      expect(find.text(cycleEnded('fr')), findsOneWidget);

      await tester.tap(find.text(cycleUndo('fr')));
      await tester.pumpAndSettle();
      expect(deps.period.deletedIds, ['log-2']);
      expect(find.text(cycleStarted('fr')), findsOneWidget);
    });

    testWidgets('while a period is on, the button ends it today', (
      tester,
    ) async {
      final deps = await pumpRegles(
        tester,
        logs: [periodLog(id: 'now', start: day(11, 9))],
      );

      expect(
        find.text(
          cycleHeadline('fr', ongoing: true, dayOfCycle: 2, daysUntil: 26),
        ),
        findsOneWidget,
      );
      await tester.tap(find.text(cycleEnded('fr')));
      await tester.pumpAndSettle();

      final call = deps.period.updateCalls.single;
      expect(call.id, 'now');
      expect(call.startDate, day(11, 9));
      expect(call.endDate, today);
      expect(find.text(cycleLoggedEnd('fr', today)), findsOneWidget);
    });

    testWidgets('"another day" notes the day picked in the sheet', (
      tester,
    ) async {
      final deps = await pumpRegles(tester, logs: lastPeriod);

      await tester.tap(find.text('${cycleOtherDay('fr')} ›'));
      await tester.pumpAndSettle();
      expect(find.text(cycleSheetStarted('fr')), findsOneWidget);
      // Yesterday is picked first: that is what "another day" usually means.
      await tester.tap(find.text(cycleSave('fr')));
      await tester.pumpAndSettle();

      expect(deps.period.createCalls.single.startDate, day(11, 9));
    });

    testWidgets('how today feels is saved as soon as a word is tapped', (
      tester,
    ) async {
      final deps = await pumpRegles(tester, logs: lastPeriod);

      expect(find.text(cycleSeenBy('fr', 'Alex')), findsOneWidget);
      await tester.tap(find.text(periodSymptomOptionLabel('cramps', 'fr')));
      await tester.pumpAndSettle();
      await tester.tap(find.text(periodMoodOptionLabel('tired', 'fr')));
      await tester.pumpAndSettle();

      expect(deps.cycle.checkinCalls, hasLength(2));
      final last = deps.cycle.checkinCalls.last;
      expect(last.day, today);
      expect(last.symptoms, ['cramps']);
      expect(last.mood, 'tired');
    });

    testWidgets('a failed check-in is undone on screen', (tester) async {
      final deps = await pumpRegles(tester, logs: lastPeriod);
      deps.cycle.nextFailure = const ServerFailure('down');

      await tester.tap(find.text(periodSymptomOptionLabel('cramps', 'fr')));
      await tester.pumpAndSettle();

      final chip = tester.widget<FilterChip>(
        find.widgetWithText(
          FilterChip,
          periodSymptomOptionLabel('cramps', 'fr'),
        ),
      );
      expect(chip.selected, isFalse);
      expect(find.text(cycleSaveFailed('fr')), findsOneWidget);
    });

    testWidgets('the private note is written in a sheet', (tester) async {
      final deps = await pumpRegles(tester, logs: lastPeriod);

      await tester.tap(find.text(cycleNoteLabel('fr')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Bouillotte ce soir');
      await tester.tap(find.text(cycleSave('fr')));
      await tester.pumpAndSettle();

      expect(deps.cycle.noteCalls.single.day, today);
      expect(deps.cycle.noteCalls.single.note, 'Bouillotte ce soir');
      expect(find.text('Bouillotte ce soir'), findsOneWidget);
    });

    testWidgets('without a couple there is nowhere to save yet', (
      tester,
    ) async {
      await pumpRegles(tester, paired: false);

      expect(find.text(cycleNeedsCouple('fr')), findsOneWidget);
      expect(find.text(cycleStarted('fr')), findsNothing);
    });
  });

  group('my partner\'s cycle (R3)', () {
    final partnerPeriod = [
      periodLog(userId: partnerId, start: day(10, 21), end: day(10, 25)),
    ];

    testWidgets('says where they are and what tends to help', (tester) async {
      await pumpRegles(
        tester,
        tracks: false,
        logs: partnerPeriod,
        checkins: [
          checkin(
            userId: partnerId,
            day: today,
            symptoms: ['headache'],
            mood: 'tired',
          ),
        ],
      );

      expect(
        find.text(cyclePartnerHeadline('fr', 'Alex', ongoing: false, day: 21)),
        findsOneWidget,
      );
      for (final tip in cyclePartnerTips('fr', CyclePhase.luteal)) {
        expect(find.text(tip), findsOneWidget);
      }
      expect(find.text(label(cyclePartnerNoted('fr', 'Alex'))), findsOneWidget);
      expect(find.text('Maux de tête · Fatigué(e)'), findsOneWidget);
      expect(find.text(cycleRemindMe('fr')), findsOneWidget);
      expect(find.text(cycleRemindOn('fr', day(11, 17))), findsOneWidget);
    });

    testWidgets('a little note goes straight to them', (tester) async {
      final deps = await pumpRegles(tester, tracks: false, logs: partnerPeriod);

      await tester.tap(find.text(pingLabel('fr', PingKind.kiss)));
      await tester.pumpAndSettle();

      expect(deps.pings.sent, [PingKind.kiss]);
    });

    testWidgets('says so when they don\'t share, without the reminder', (
      tester,
    ) async {
      await pumpRegles(tester, tracks: false, partnerShares: false);

      expect(find.text(cyclePartnerNotShared('fr', 'Alex')), findsOneWidget);
      expect(find.text(cycleRemindMe('fr')), findsNothing);
    });

    testWidgets('a tracker reaches their partner\'s cycle from a link', (
      tester,
    ) async {
      await pumpRegles(tester, logs: partnerPeriod);

      await tester.tap(find.text('${cyclePartnerLink('fr', 'Alex')} ›'));
      await tester.pumpAndSettle();

      expect(
        find.text(cyclePartnerHeadline('fr', 'Alex', ongoing: false, day: 21)),
        findsOneWidget,
      );
    });
  });

  group('sharing', () {
    testWidgets('two switches; notes stay private', (tester) async {
      final deps = await pumpRegles(tester);

      await tester.tap(find.text('${cycleSharingLink('fr', 'Alex')} ›'));
      await tester.pumpAndSettle();
      expect(find.text(cycleNotesAlwaysPrivate('fr')), findsOneWidget);

      await tester.tap(find.text(cycleShareCycle('fr')));
      await tester.pumpAndSettle();
      expect(deps.profiles.cycleSettingsCalls.single.shareCycle, isFalse);
      expect(deps.profiles.mine!.shareCycle, isFalse);

      await tester.tap(find.text(cycleStopSharing('fr')));
      await tester.pumpAndSettle();
      expect(deps.profiles.mine!.shareCheckins, isFalse);
      expect(find.text(cycleStopSharing('fr')), findsNothing);
    });
  });

  group('history', () {
    testWidgets('averages, one row per cycle, delete on long press', (
      tester,
    ) async {
      final deps = await pumpRegles(
        tester,
        logs: [
          periodLog(id: 'oct', start: day(10, 4), end: day(10, 8)),
          periodLog(id: 'nov', start: day(11, 1), end: day(11, 5)),
        ],
      );

      await tester.tap(find.text('${cycleHistoryLink('fr')} ›'));
      await tester.pumpAndSettle();

      expect(find.text(label(cycleAverage('fr'))), findsOneWidget);
      expect(find.text(cycleCurrentRow('fr', 10)), findsOneWidget);
      expect(find.text(cycleSpanRow('fr', 28, 5)), findsOneWidget);
      expect(find.text(cycleNeedTwo('fr')), findsOneWidget);

      await tester.longPress(find.text(cycleShortDate('fr', day(10, 4))));
      await tester.pumpAndSettle();
      await tester.tap(find.text(periodDelete('fr')));
      await tester.pumpAndSettle();

      expect(deps.period.deletedIds, ['oct']);
      expect(find.text(cycleSpanRow('fr', 28, 5)), findsNothing);
    });
  });

  group('guide (R4)', () {
    testWidgets('chapters, what matters now, and reading on', (tester) async {
      await pumpRegles(
        tester,
        logs: [periodLog(start: day(11, 1), end: day(11, 5))],
      );

      await tester.tap(find.text('${guideLabel('fr')} ›'));
      await tester.pumpAndSettle();

      expect(find.text(guideTitle('fr')), findsOneWidget);
      expect(find.text(label(guideForYouNow('fr', 10))), findsOneWidget);
      for (final c in GuideChapter.values) {
        expect(find.text(guideChapterTitle(c, 'fr')), findsOneWidget);
      }
      expect(find.byIcon(Icons.check), findsNothing);

      await tester.tap(find.text(guideChapterTitle(GuideChapter.cycle, 'fr')));
      await tester.pumpAndSettle();
      expect(find.text(label(guideChapter('fr', 1))), findsOneWidget);
      expect(
        find.textContaining(guideYouAreHere('fr')),
        findsOneWidget,
        reason: 'the follicular phase is marked',
      );

      final next = guideNext(
        'fr',
        guideChapterTitle(GuideChapter.bodyMind, 'fr'),
      );
      await tester.tap(find.text('$next ›'));
      await tester.pumpAndSettle();
      expect(find.text(label(guideChapter('fr', 2))), findsOneWidget);

      await tester.tap(find.text('‹ ${guideContents('fr')}'));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.check), findsNWidgets(2));
    });

    testWidgets('search keeps the chapters that mention the words', (
      tester,
    ) async {
      await pumpRegles(tester, openGuide: true);

      await tester.enterText(find.byType(TextField), 'PMDD');
      await tester.pumpAndSettle();
      expect(
        find.text(guideChapterTitle(GuideChapter.bodyMind, 'fr')),
        findsOneWidget,
      );
      expect(
        find.text(guideChapterTitle(GuideChapter.myths, 'fr')),
        findsNothing,
      );

      await tester.enterText(find.byType(TextField), 'zzqxw');
      await tester.pumpAndSettle();
      expect(find.text(guideNoMatch('fr', 'zzqxw')), findsOneWidget);
    });

    testWidgets('"for your partner now" speaks about them', (tester) async {
      await pumpRegles(
        tester,
        tracks: false,
        logs: [
          periodLog(userId: partnerId, start: day(10, 21), end: day(10, 25)),
        ],
        openGuide: true,
      );

      final now = guideForPartnerNow('fr', 'Alex', 21);
      expect(find.text(label(now)), findsOneWidget);
      await tester.tap(
        find.text('${guideNowTitle('fr', CyclePhase.luteal)} ›'),
      );
      await tester.pumpAndSettle();
      for (final tip in cyclePartnerTips('fr', CyclePhase.luteal)) {
        expect(find.text('· $tip'), findsOneWidget);
      }
    });
  });
}
