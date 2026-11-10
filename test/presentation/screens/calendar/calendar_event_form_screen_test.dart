import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

import 'package:nousdeux/core/constants/calendar_strings.dart';
import 'package:nousdeux/core/errors/failures.dart';
import 'package:nousdeux/domain/entities/calendar_event_entity.dart';
import 'package:nousdeux/presentation/screens/calendar/calendar_event_form_screen.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/test_app.dart';

/// Opens the form from a host page so that saving can pop back to it.
Future<TestDeps> _openForm(
  WidgetTester tester, {
  CalendarEventEntity? editing,
  DateTime? initialDate,
  String lang = 'fr',
}) async {
  final deps = TestDeps(
    myProfile: profile(language: lang),
    events: [?editing],
  );
  await pumpScreen(
    tester,
    Builder(
      builder: (context) => Scaffold(
        body: TextButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => CalendarEventFormScreen(
                event: editing,
                initialDate: initialDate ?? DateTime(2026, 3, 14, 15, 28),
              ),
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

Finder _field(String label) => find.widgetWithText(TextFormField, label);

void main() {
  final frFormat = DateFormat('d MMM y HH:mm', 'fr_FR');

  group('new event', () {
    testWidgets('starts at the next full hour and lasts one hour', (
      tester,
    ) async {
      await _openForm(tester, initialDate: DateTime(2026, 3, 14, 15, 28));

      expect(find.text(calendarEventNew('fr')), findsOneWidget);
      expect(
        find.text(frFormat.format(DateTime(2026, 3, 14, 16))),
        findsOneWidget,
      );
      expect(
        find.text(frFormat.format(DateTime(2026, 3, 14, 17))),
        findsOneWidget,
      );
    });

    testWidgets('a start exactly on the hour is kept', (tester) async {
      await _openForm(tester, initialDate: DateTime(2026, 3, 14, 9));

      expect(
        find.text(frFormat.format(DateTime(2026, 3, 14, 9))),
        findsOneWidget,
      );
      expect(
        find.text(frFormat.format(DateTime(2026, 3, 14, 10))),
        findsOneWidget,
      );
    });

    testWidgets('English uses a 12-hour format', (tester) async {
      await _openForm(
        tester,
        lang: 'en',
        initialDate: DateTime(2026, 3, 14, 15, 28),
      );

      expect(find.text(calendarEventNew('en')), findsOneWidget);
      expect(find.text('Mar 14, 2026 4:00 PM'), findsOneWidget);
      expect(find.text('Mar 14, 2026 5:00 PM'), findsOneWidget);
    });

    testWidgets('an empty or blank title is refused', (tester) async {
      final deps = await _openForm(tester);

      await tester.tap(find.text(calendarEventSave('fr')));
      await tester.pumpAndSettle();
      expect(find.text(calendarEventTitleRequired('fr')), findsOneWidget);

      await tester.enterText(_field(calendarEventTitleLabel('fr')), '   ');
      await tester.tap(find.text(calendarEventSave('fr')));
      await tester.pumpAndSettle();
      expect(find.text(calendarEventTitleRequired('fr')), findsOneWidget);

      expect(deps.calendar.createCalls, isEmpty);
      expect(find.byType(CalendarEventFormScreen), findsOneWidget);
    });

    testWidgets('saves the trimmed title, no description, and closes', (
      tester,
    ) async {
      final deps = await _openForm(tester);

      await tester.enterText(_field(calendarEventTitleLabel('fr')), '  Dîner ');
      await tester.tap(find.text(calendarEventSave('fr')));
      await tester.pumpAndSettle();

      expect(deps.calendar.createCalls, [
        (
          title: 'Dîner',
          description: null,
          startTime: DateTime(2026, 3, 14, 16),
          endTime: DateTime(2026, 3, 14, 17),
        ),
      ]);
      expect(find.byType(CalendarEventFormScreen), findsNothing);
    });

    testWidgets('sends the trimmed description when given', (tester) async {
      final deps = await _openForm(tester);

      await tester.enterText(_field(calendarEventTitleLabel('fr')), 'Dîner');
      await tester.enterText(
        _field(calendarEventDescriptionLabel('fr')),
        '  Chez Paul  ',
      );
      await tester.tap(find.text(calendarEventSave('fr')));
      await tester.pumpAndSettle();

      expect(deps.calendar.createCalls.single.description, 'Chez Paul');
    });

    testWidgets('a failure shows its message and keeps the form open', (
      tester,
    ) async {
      final deps = await _openForm(tester);
      deps.calendar.nextFailure = const ServerFailure('Hors ligne');

      await tester.enterText(_field(calendarEventTitleLabel('fr')), 'Dîner');
      await tester.tap(find.text(calendarEventSave('fr')));
      await tester.pumpAndSettle();

      expect(find.text('Hors ligne'), findsOneWidget);
      expect(find.byType(CalendarEventFormScreen), findsOneWidget);
    });

    testWidgets('the title is capped at 200 characters', (tester) async {
      await _openForm(tester);

      await tester.enterText(_field(calendarEventTitleLabel('fr')), 'x' * 250);
      await tester.pump();

      final field = tester.widget<EditableText>(
        find.descendant(
          of: _field(calendarEventTitleLabel('fr')),
          matching: find.byType(EditableText),
        ),
      );
      expect(field.controller.text.length, 200);
    });
  });

  group('editing an event', () {
    final existing = event(
      id: 'e1',
      title: 'Cinéma',
      description: 'Séance de 20h',
      start: DateTime(2026, 3, 14, 20),
      end: DateTime(2026, 3, 14, 22, 30),
    );

    testWidgets('is prefilled from the event', (tester) async {
      await _openForm(tester, editing: existing);

      expect(find.text(calendarEventEdit('fr')), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Cinéma'), findsOneWidget);
      expect(
        find.widgetWithText(TextFormField, 'Séance de 20h'),
        findsOneWidget,
      );
      expect(
        find.text(frFormat.format(DateTime(2026, 3, 14, 20))),
        findsOneWidget,
      );
      expect(
        find.text(frFormat.format(DateTime(2026, 3, 14, 22, 30))),
        findsOneWidget,
      );
    });

    testWidgets('saving updates the event instead of creating one', (
      tester,
    ) async {
      final deps = await _openForm(tester, editing: existing);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Cinéma'),
        'Cinéma en plein air',
      );
      await tester.tap(find.text(calendarEventSave('fr')));
      await tester.pumpAndSettle();

      expect(deps.calendar.createCalls, isEmpty);
      expect(deps.calendar.updateCalls, [
        (
          id: 'e1',
          title: 'Cinéma en plein air',
          description: 'Séance de 20h',
          startTime: DateTime(2026, 3, 14, 20),
          endTime: DateTime(2026, 3, 14, 22, 30),
        ),
      ]);
      expect(find.byType(CalendarEventFormScreen), findsNothing);
    });

    testWidgets('an event without an end gets start + 1 h', (tester) async {
      final deps = await _openForm(
        tester,
        editing: event(
          id: 'e2',
          title: 'Appel',
          start: DateTime(2026, 3, 14, 8),
        ),
      );

      await tester.tap(find.text(calendarEventSave('fr')));
      await tester.pumpAndSettle();

      expect(
        deps.calendar.updateCalls.single.endTime,
        DateTime(2026, 3, 14, 9),
      );
      expect(deps.calendar.updateCalls.single.description, isNull);
    });

    testWidgets('an end before the start is refused with a message', (
      tester,
    ) async {
      final deps = await _openForm(
        tester,
        editing: event(
          id: 'e3',
          title: 'Dîner',
          start: DateTime(2026, 3, 14, 20),
          end: DateTime(2026, 3, 14, 19),
        ),
      );

      await tester.tap(find.text(calendarEventSave('fr')));
      await tester.pumpAndSettle();

      expect(find.text(calendarEventEndBeforeStart('fr')), findsOneWidget);
      expect(deps.calendar.updateCalls, isEmpty);
      expect(find.byType(CalendarEventFormScreen), findsOneWidget);
    });
  });
}
