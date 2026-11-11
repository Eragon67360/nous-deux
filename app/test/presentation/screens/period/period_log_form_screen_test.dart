import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nousdeux/core/constants/cycle_strings.dart';
import 'package:nousdeux/core/constants/period_education.dart';
import 'package:nousdeux/core/errors/failures.dart';
import 'package:nousdeux/domain/entities/period_log_entity.dart';
import 'package:nousdeux/presentation/screens/period/period_log_form_screen.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/test_app.dart';

/// Opens the form from a host page so that saving can pop back to it.
Future<TestDeps> _openForm(
  WidgetTester tester, {
  PeriodLogEntity? editing,
  String lang = 'fr',
}) async {
  final deps = TestDeps(
    myProfile: profile(language: lang),
    logs: [?editing],
  );
  await pumpScreen(
    tester,
    Builder(
      builder: (context) => Scaffold(
        body: TextButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => PeriodLogFormScreen(log: editing),
            ),
          ),
          child: const Text('open'),
        ),
      ),
    ),
    deps: deps,
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  return deps;
}

Future<void> _save(WidgetTester tester, String lang) async {
  // The button sits below the fold on the 800x600 test surface.
  await tester.ensureVisible(find.text(periodSave(lang)));
  await tester.pumpAndSettle();
  await tester.tap(find.text(periodSave(lang)));
  await tester.pumpAndSettle();
}

void main() {
  group('new entry', () {
    for (final lang in ['fr', 'en']) {
      testWidgets('[$lang] starts today with no end date', (tester) async {
        await _openForm(tester, lang: lang);
        final now = DateTime.now();

        expect(find.text(periodLogNew(lang)), findsOneWidget);
        expect(find.text(periodStartDate(lang)), findsOneWidget);
        expect(find.text(cycleShortDate(lang, now)), findsOneWidget);
        expect(find.text(periodEndDate(lang)), findsOneWidget);
        expect(find.text('—'), findsOneWidget);
      });
    }

    testWidgets('saving right away sends only today\'s start, then closes', (
      tester,
    ) async {
      final deps = await _openForm(tester);
      final now = DateTime.now();

      await _save(tester, 'fr');

      final call = deps.period.createCalls.single;
      expect(call.startDate, DateTime(now.year, now.month, now.day));
      expect(call.endDate, isNull);
      expect(find.byType(PeriodLogFormScreen), findsNothing);
    });

    testWidgets('a failure shows its message and keeps the form open', (
      tester,
    ) async {
      final deps = await _openForm(tester);
      deps.period.nextFailure = const ServerFailure('Hors ligne');

      await _save(tester, 'fr');

      expect(find.text('Hors ligne'), findsOneWidget);
      expect(find.byType(PeriodLogFormScreen), findsOneWidget);
    });
  });

  group('fixing a period', () {
    final existing = periodLog(
      id: 'l1',
      start: DateTime(2026, 3, 1),
      end: DateTime(2026, 3, 5),
    );

    testWidgets('is prefilled with its dates, and only dates', (tester) async {
      await _openForm(tester, editing: existing);

      expect(find.text(periodLogEdit('fr')), findsOneWidget);
      expect(
        find.text(cycleShortDate('fr', DateTime(2026, 3, 1))),
        findsOneWidget,
      );
      expect(
        find.text(cycleShortDate('fr', DateTime(2026, 3, 5))),
        findsOneWidget,
      );
      expect(find.byType(TextField), findsNothing);
      expect(find.byType(FilterChip), findsNothing);
    });

    testWidgets('saving updates the dates', (tester) async {
      final deps = await _openForm(tester, editing: existing);

      await _save(tester, 'fr');

      expect(deps.period.createCalls, isEmpty);
      final call = deps.period.updateCalls.single;
      expect(call.id, 'l1');
      expect(call.startDate, DateTime(2026, 3, 1));
      expect(call.endDate, DateTime(2026, 3, 5));
      expect(find.byType(PeriodLogFormScreen), findsNothing);
    });

    testWidgets('the end date can be cleared', (tester) async {
      final deps = await _openForm(tester, editing: existing);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();
      await _save(tester, 'fr');

      expect(deps.period.updateCalls.single.endDate, isNull);
    });
  });
}
