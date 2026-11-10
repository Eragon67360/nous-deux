import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nousdeux/core/constants/period_education.dart';
import 'package:nousdeux/domain/entities/period_log_entity.dart';
import 'package:nousdeux/presentation/providers/period_provider.dart';
import 'package:nousdeux/presentation/screens/period/period_log_form_screen.dart';
import 'package:nousdeux/presentation/screens/period/period_screen.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/test_app.dart';

const _guideVisitedKey = 'period_guide_visited';

void main() {
  setUp(() {
    // By default the partner's first visit does not jump to the Guide tab.
    SharedPreferences.setMockInitialValues({_guideVisitedKey: true});
  });

  Future<TestDeps> pumpPeriod(
    WidgetTester tester, {
    List<PeriodLogEntity> logs = const [],
    String lang = 'fr',
    bool withPartner = false,
    String? partnerName = 'Alex',
    int? initialTab,
    List<Override> overrides = const [],
  }) async {
    final deps = TestDeps(
      myProfile: profile(
        language: lang,
        partner: withPartner ? partnerId : null,
      ),
      partner: withPartner ? partnerProfile(username: partnerName) : null,
      logs: logs,
    );
    await pumpScreen(
      tester,
      PeriodScreen(initialTab: initialTab),
      deps: deps,
      overrides: overrides,
    );
    return deps;
  }

  TabController tabs(WidgetTester tester) =>
      tester.widget<TabBar>(find.byType(TabBar)).controller!;

  for (final lang in ['fr', 'en']) {
    testWidgets('[$lang] no entries: tabs, empty state and add button', (
      tester,
    ) async {
      await pumpPeriod(tester, lang: lang);

      expect(find.text(periodScreenTitle(lang)), findsOneWidget);
      expect(find.text(periodTabLogs(lang)), findsOneWidget);
      expect(find.text(periodTabGuide(lang)), findsOneWidget);
      expect(find.text(periodEmptyMessage(lang)), findsOneWidget);
      expect(find.text(periodEmptySecondary(lang)), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byType(FilterChip), findsNothing, reason: 'no partner');
    });
  }

  group('the log list', () {
    testWidgets('shows date ranges, owner and details', (tester) async {
      await pumpPeriod(
        tester,
        withPartner: true,
        logs: [
          periodLog(
            id: 'mine',
            start: DateTime(2026, 3, 1),
            end: DateTime(2026, 3, 5),
            mood: 'tired',
            symptoms: ['cramps', 'headache'],
            notes: 'Canapé',
          ),
          periodLog(
            id: 'theirs',
            userId: partnerId,
            start: DateTime(2026, 2, 3),
          ),
        ],
      );

      expect(find.text('1 mars 2026 – 5 mars 2026'), findsOneWidget);
      expect(
        find.text('Fatigué(e) · Crampes, Maux de tête · Canapé'),
        findsOneWidget,
      );
      expect(find.text(periodMe('fr')), findsOneWidget);
      expect(find.text('3 févr. 2026'), findsOneWidget);
      expect(find.text('Alex'), findsOneWidget);
      expect(find.text(periodEmptyMessage('fr')), findsNothing);
    });

    testWidgets('English dates and labels', (tester) async {
      await pumpPeriod(
        tester,
        lang: 'en',
        logs: [
          periodLog(
            start: DateTime(2026, 3, 1),
            end: DateTime(2026, 3, 5),
            mood: 'anxious',
            symptoms: ['acne'],
          ),
        ],
      );

      expect(find.text('Mar 1, 2026 – Mar 5, 2026'), findsOneWidget);
      expect(find.text('Anxious · Acne'), findsOneWidget);
      expect(find.text(periodMe('en')), findsOneWidget);
    });

    testWidgets('an end on the start day shows a single date', (tester) async {
      await pumpPeriod(
        tester,
        logs: [
          periodLog(
            start: DateTime(2026, 3, 1, 8),
            end: DateTime(2026, 3, 1, 20),
          ),
        ],
      );
      expect(find.text('1 mars 2026'), findsOneWidget);
    });

    testWidgets('long notes are cut at 40 characters', (tester) async {
      const notes = 'Une journée très fatigante avec beaucoup de douleurs';
      await pumpPeriod(
        tester,
        logs: [periodLog(start: DateTime(2026, 3, 1), notes: notes)],
      );
      expect(find.text('${notes.substring(0, 40)}…'), findsOneWidget);
    });

    testWidgets('an unnamed partner is "Partner"', (tester) async {
      await pumpPeriod(
        tester,
        lang: 'en',
        withPartner: true,
        partnerName: null,
        logs: [periodLog(userId: partnerId, start: DateTime(2026, 3, 1))],
      );
      expect(find.text(periodPartner('en')), findsWidgets);
    });

    testWidgets(
      'shows the stored calendar day whatever the device timezone',
      (tester) async {
        // Regression: DATE columns used to be parsed as UTC midnight and
        // shown after .toLocal(), i.e. the previous day west of UTC.
        await pumpPeriod(
          tester,
          logs: [periodLog(start: DateTime.utc(2026, 3, 1))],
        );
        expect(find.text('1 mars 2026'), findsOneWidget);
      },
    );
  });

  group('my entries vs the partner\'s', () {
    final mine = periodLog(id: 'mine', start: DateTime(2026, 3, 1));
    final theirs = periodLog(
      id: 'theirs',
      userId: partnerId,
      start: DateTime(2026, 2, 3),
    );

    testWidgets('tapping mine opens it for editing', (tester) async {
      await pumpPeriod(tester, withPartner: true, logs: [mine, theirs]);

      await tester.tap(find.text('1 mars 2026'));
      await tester.pumpAndSettle();

      expect(find.byType(PeriodLogFormScreen), findsOneWidget);
      expect(find.text(periodLogEdit('fr')), findsOneWidget);
    });

    testWidgets('the partner\'s entries are read-only', (tester) async {
      final deps = await pumpPeriod(
        tester,
        withPartner: true,
        logs: [mine, theirs],
      );

      await tester.tap(find.text('3 févr. 2026'));
      await tester.pumpAndSettle();
      expect(find.byType(PeriodLogFormScreen), findsNothing);

      await tester.longPress(find.text('3 févr. 2026'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(deps.period.deletedIds, isEmpty);
    });

    testWidgets('long-pressing mine asks before deleting', (tester) async {
      final deps = await pumpPeriod(tester, logs: [mine]);

      await tester.longPress(find.text('1 mars 2026'));
      await tester.pumpAndSettle();
      expect(find.text(periodDeleteConfirmTitle('fr')), findsOneWidget);

      await tester.tap(find.text(periodCancel('fr')));
      await tester.pumpAndSettle();
      expect(deps.period.deletedIds, isEmpty);

      await tester.longPress(find.text('1 mars 2026'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(periodDelete('fr')));
      await tester.pumpAndSettle();

      expect(deps.period.deletedIds, ['mine']);
      expect(find.text(periodEmptyMessage('fr')), findsOneWidget);
    });
  });

  testWidgets('the add button opens a new entry form', (tester) async {
    await pumpPeriod(tester);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.text(periodLogNew('fr')), findsOneWidget);
  });

  group('partner mode', () {
    testWidgets('the chip shows the partner banner', (tester) async {
      await pumpPeriod(tester, withPartner: true);

      expect(find.text('Journal de Alex'), findsNothing);
      await tester.tap(find.text(periodPartnerModeLabel('fr')));
      await tester.pumpAndSettle();
      expect(find.text('Journal de Alex'), findsOneWidget);
    });

    testWidgets('turns on by itself when most entries are the partner\'s', (
      tester,
    ) async {
      await pumpPeriod(
        tester,
        lang: 'en',
        withPartner: true,
        logs: [
          periodLog(id: 'p1', userId: partnerId, start: DateTime(2026, 2, 3)),
          periodLog(id: 'p2', userId: partnerId, start: DateTime(2026, 3, 3)),
          periodLog(id: 'm1', start: DateTime(2026, 1, 3)),
        ],
      );

      expect(find.text("Alex's log"), findsOneWidget);
      expect(tabs(tester).index, 0, reason: 'guide already visited');
    });

    testWidgets('a first visit as the partner jumps to the Guide, once', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      await pumpPeriod(
        tester,
        withPartner: true,
        logs: [periodLog(userId: partnerId, start: DateTime(2026, 3, 3))],
      );

      // The switch is a post-frame callback scheduled once prefs load; in the
      // app the next frame comes on its own, here we ask for one.
      tester.binding.scheduleFrame();
      await tester.pumpAndSettle();

      expect(tabs(tester).index, 1);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool(_guideVisitedKey), isTrue);
    });
  });

  group('guide tab', () {
    testWidgets('initialTab 1 opens on the guide with the phase tip', (
      tester,
    ) async {
      await pumpPeriod(
        tester,
        initialTab: 1,
        logs: [periodLog(start: utcDaysAgo(0))], // day 1: menstrual
      );

      expect(tabs(tester).index, 1);
      expect(find.text(tipOfTheDayTitle('fr')), findsWidgets); // card + TOC
      expect(
        find.text(phaseTipFor(CyclePhase.menstrual).get('fr')),
        findsOneWidget,
      );
      expect(find.byType(FloatingActionButton), findsNothing);
    });

    testWidgets('without entries the tip falls back to the generic one', (
      tester,
    ) async {
      await pumpPeriod(tester, lang: 'en');

      await tester.tap(find.text(periodTabGuide('en')));
      await tester.pumpAndSettle();

      expect(find.text(tipFallback('en')), findsOneWidget);
    });
  });

  testWidgets('a load error shows the error state', (tester) async {
    await pumpPeriod(
      tester,
      overrides: [
        periodLogsProvider.overrideWith(
          (ref) => Stream.error(Exception('offline')),
        ),
      ],
    );

    expect(find.text(periodErrorLoad('fr')), findsOneWidget);
    expect(find.text('Exception: offline'), findsOneWidget);
  });
}
