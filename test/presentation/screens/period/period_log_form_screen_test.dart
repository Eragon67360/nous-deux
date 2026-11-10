import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

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
        final fmt = lang == 'fr'
            ? DateFormat('d MMM y', 'fr_FR')
            : DateFormat('MMM d, y', 'en_US');

        expect(find.text(periodLogNew(lang)), findsOneWidget);
        expect(find.text(periodStartDate(lang)), findsOneWidget);
        expect(find.text(fmt.format(DateTime.now())), findsOneWidget);
        expect(find.text(periodEndDate(lang)), findsOneWidget);
        expect(find.text('—'), findsWidgets); // end date + empty mood
        expect(find.text(periodMoodLabelForm(lang)), findsOneWidget);
        expect(find.text(periodSymptomsLabel(lang)), findsOneWidget);
        expect(
          find.text(periodSymptomOptionLabel('cramps', lang)),
          findsOneWidget,
        );
        expect(find.text(periodNotesLabel(lang)), findsOneWidget);
      });
    }

    testWidgets('saving right away sends only today\'s start, then closes', (
      tester,
    ) async {
      final deps = await _openForm(tester);
      final before = DateTime.now();

      await _save(tester, 'fr');

      final call = deps.period.createCalls.single;
      expect(call.startDate.year, before.year);
      expect(call.startDate.month, before.month);
      expect(call.startDate.day, before.day);
      expect(call.endDate, isNull);
      expect(call.mood, isNull);
      expect(call.symptoms, isNull);
      expect(call.notes, isNull);
      expect(find.byType(PeriodLogFormScreen), findsNothing);
    });

    testWidgets('sends the mood, sorted symptoms and trimmed notes', (
      tester,
    ) async {
      final deps = await _openForm(tester);

      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text(periodMoodOptionLabel('tired', 'fr')).last);
      await tester.pumpAndSettle();

      await tester.tap(find.text(periodSymptomOptionLabel('headache', 'fr')));
      await tester.tap(find.text(periodSymptomOptionLabel('bloating', 'fr')));
      await tester.tap(find.text(periodSymptomOptionLabel('acne', 'fr')));
      await tester.pump();
      // Tapping a selected chip again unselects it.
      await tester.tap(find.text(periodSymptomOptionLabel('acne', 'fr')));
      await tester.pump();

      await tester.enterText(
        find.widgetWithText(TextFormField, periodNotesLabel('fr')),
        '  Bouillotte  ',
      );
      await _save(tester, 'fr');

      final call = deps.period.createCalls.single;
      expect(call.mood, 'tired');
      expect(call.symptoms, ['bloating', 'headache']);
      expect(call.notes, 'Bouillotte');
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

  group('editing an entry', () {
    final existing = periodLog(
      id: 'l1',
      start: DateTime(2026, 3, 1),
      end: DateTime(2026, 3, 5),
      mood: 'irritable',
      symptoms: ['pain', 'cramps'],
      notes: 'Canapé',
    );

    testWidgets('is prefilled from the entry', (tester) async {
      await _openForm(tester, editing: existing);

      expect(find.text(periodLogEdit('fr')), findsOneWidget);
      expect(find.text('1 mars 2026'), findsOneWidget);
      expect(find.text('5 mars 2026'), findsOneWidget);
      expect(
        find.text(periodMoodOptionLabel('irritable', 'fr')),
        findsOneWidget,
      );
      expect(find.widgetWithText(TextFormField, 'Canapé'), findsOneWidget);

      bool selected(String value) => tester
          .widget<FilterChip>(
            find.widgetWithText(
              FilterChip,
              periodSymptomOptionLabel(value, 'fr'),
            ),
          )
          .selected;
      expect(selected('pain'), isTrue);
      expect(selected('cramps'), isTrue);
      expect(selected('acne'), isFalse);
    });

    testWidgets('saving updates the entry with sorted symptoms', (
      tester,
    ) async {
      final deps = await _openForm(tester, editing: existing);

      await _save(tester, 'fr');

      expect(deps.period.createCalls, isEmpty);
      final call = deps.period.updateCalls.single;
      expect(call.id, 'l1');
      expect(call.startDate, DateTime(2026, 3, 1));
      expect(call.endDate, DateTime(2026, 3, 5));
      expect(call.mood, 'irritable');
      expect(call.symptoms, ['cramps', 'pain']);
      expect(call.notes, 'Canapé');
      expect(find.byType(PeriodLogFormScreen), findsNothing);
    });

    testWidgets('clearing every symptom sends an empty list', (tester) async {
      final deps = await _openForm(tester, editing: existing);

      await tester.tap(find.text(periodSymptomOptionLabel('pain', 'fr')));
      await tester.tap(find.text(periodSymptomOptionLabel('cramps', 'fr')));
      await tester.pump();
      await _save(tester, 'fr');

      expect(deps.period.updateCalls.single.symptoms, isEmpty);
    });
  });
}
