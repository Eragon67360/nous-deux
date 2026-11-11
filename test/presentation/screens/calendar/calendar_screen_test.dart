import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

import 'package:nousdeux/core/constants/calendar_strings.dart';
import 'package:nousdeux/domain/entities/calendar_event_entity.dart';
import 'package:nousdeux/presentation/providers/calendar_provider.dart';
import 'package:nousdeux/presentation/screens/calendar/calendar_event_form_screen.dart';
import 'package:nousdeux/presentation/screens/calendar/calendar_screen.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/test_app.dart';

DateTime _today({int hour = 0, int minute = 0}) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day, hour, minute);
}

/// Another day of the current month (the 1st, or the 2nd on the 1st).
DateTime _otherDayThisMonth({int hour = 0}) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day == 1 ? 2 : 1, hour);
}

DateTime _nextMonth({int hour = 0}) {
  final now = DateTime.now();
  return DateTime(now.year, now.month + 1, 10, hour);
}

String _locale(String lang) => lang == 'fr' ? 'fr_FR' : 'en_US';

Finder _ownerDots({required bool mine}) =>
    find.byWidgetPredicate((w) => w is OwnerDot && w.isMine == mine);

void main() {
  Future<TestDeps> pumpCalendar(
    WidgetTester tester, {
    List<CalendarEventEntity> events = const [],
    String lang = 'fr',
    String? partnerName = 'Alex',
    List<Override> overrides = const [],
  }) async {
    final deps = TestDeps(
      myProfile: profile(language: lang, partner: partnerId),
      partner: partnerProfile(username: partnerName),
      events: events,
    );
    await pumpScreen(
      tester,
      const CalendarHomeScreen(),
      deps: deps,
      overrides: overrides,
    );
    return deps;
  }

  for (final lang in ['fr', 'en']) {
    testWidgets('[$lang] header shows the month and the title', (tester) async {
      await pumpCalendar(tester, lang: lang);

      expect(find.text(calendarTitle(lang)), findsOneWidget);
      expect(
        find.text(
          DateFormat(
            'MMMM y',
            _locale(lang),
          ).format(DateTime.now()).toUpperCase(),
        ),
        findsOneWidget,
      );
      expect(find.byTooltip(calendarAdd(lang)), findsOneWidget);
    });

    testWidgets('[$lang] an empty month says nothing is planned', (
      tester,
    ) async {
      await pumpCalendar(tester, lang: lang);
      final month = DateFormat.MMMM(_locale(lang)).format(DateTime.now());

      expect(find.text(calendarNothingInMonth(lang, month)), findsOneWidget);
      expect(find.text(calendarCreateEvent(lang)), findsOneWidget);
    });
  }

  testWidgets('the arrows move between months, "today" comes back', (
    tester,
  ) async {
    await pumpCalendar(tester);
    final next = DateTime(DateTime.now().year, DateTime.now().month + 1);
    String label(DateTime m) =>
        DateFormat('MMMM y', 'fr_FR').format(m).toUpperCase();

    await tester.tap(find.byTooltip(calendarNextMonth('fr')));
    await tester.pumpAndSettle();
    expect(find.text(label(next)), findsOneWidget);
    expect(
      find.text(
        calendarNothingInMonth('fr', DateFormat.MMMM('fr_FR').format(next)),
      ),
      findsOneWidget,
    );

    await tester.tap(find.byTooltip(calendarToday('fr')));
    await tester.pumpAndSettle();
    expect(find.text(label(DateTime.now())), findsOneWidget);

    await tester.tap(find.byTooltip(calendarPreviousMonth('fr')));
    await tester.pumpAndSettle();
    expect(
      find.text(label(DateTime(DateTime.now().year, DateTime.now().month - 1))),
      findsOneWidget,
    );
  });

  testWidgets('the empty-state action opens a new event form', (tester) async {
    await pumpCalendar(tester);

    await tester.tap(find.text(calendarCreateEvent('fr')));
    await tester.pumpAndSettle();

    expect(find.byType(CalendarEventFormScreen), findsOneWidget);
    expect(find.text(calendarEventNew('fr')), findsOneWidget);
  });

  testWidgets('the add button opens a new event form too', (tester) async {
    await pumpCalendar(tester, lang: 'en');

    await tester.tap(find.byTooltip(calendarAdd('en')));
    await tester.pumpAndSettle();

    expect(find.text(calendarEventNew('en')), findsOneWidget);
  });

  group("the month's events", () {
    final mine = event(
      id: 'mine',
      title: 'Cinéma',
      description: 'Séance de 20h',
      start: _today(hour: 19, minute: 45),
    );
    final theirs = event(
      id: 'theirs',
      title: 'Dentiste',
      start: _today(hour: 9, minute: 5),
      createdBy: partnerId,
    );
    final otherDay = event(
      id: 'other-day',
      title: 'Brunch',
      start: _otherDayThisMonth(hour: 11),
    );
    final later = event(id: 'later', title: 'Ski', start: _nextMonth(hour: 8));

    testWidgets('are listed by day and time, with their details', (
      tester,
    ) async {
      await pumpCalendar(tester, events: [mine, theirs, otherDay, later]);

      expect(find.text('Cinéma'), findsOneWidget);
      expect(find.text('Séance de 20h'), findsOneWidget);
      expect(find.text('19:45'), findsOneWidget);
      expect(find.text('Dentiste'), findsOneWidget);
      expect(find.text('09:05'), findsOneWidget);
      expect(find.text('Brunch'), findsOneWidget);
      expect(find.text('Ski'), findsNothing);
      // The morning appointment comes before the evening one.
      expect(
        tester.getTopLeft(find.text('Dentiste')).dy,
        lessThan(tester.getTopLeft(find.text('Cinéma')).dy),
      );
    });

    testWidgets('the next month shows its own events', (tester) async {
      await pumpCalendar(tester, events: [mine, later]);

      await tester.tap(find.byTooltip(calendarNextMonth('fr')));
      await tester.pumpAndSettle();

      expect(find.text('Ski'), findsOneWidget);
      expect(find.text('Cinéma'), findsNothing);
    });

    testWidgets('mine are marked "Me", the partner\'s with their name', (
      tester,
    ) async {
      await pumpCalendar(tester, events: [mine, theirs]);

      // Once on the event, once in the legend.
      expect(find.text(calendarMe('fr')), findsNWidgets(2));
      expect(find.text('Alex'), findsNWidgets(2));
      expect(_ownerDots(mine: true), findsNWidgets(2));
      expect(_ownerDots(mine: false), findsNWidgets(2));
    });

    testWidgets('a partner without a name is "Partner"', (tester) async {
      await pumpCalendar(
        tester,
        events: [theirs],
        lang: 'en',
        partnerName: '  ',
      );

      expect(find.text(calendarPartner('en')), findsNWidgets(2));
    });

    testWidgets('a countdown says so', (tester) async {
      await pumpCalendar(
        tester,
        events: [
          event(
            id: 'trip',
            title: 'Annecy',
            start: _today(hour: 18),
            isCountdown: true,
          ),
        ],
      );

      expect(find.text(calendarEventCountdown('fr')), findsOneWidget);
    });

    testWidgets('tapping an event opens it for editing', (tester) async {
      await pumpCalendar(tester, events: [mine]);

      await tester.tap(find.text('Cinéma'));
      await tester.pumpAndSettle();

      expect(find.text(calendarEventEdit('fr')), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Cinéma'), findsOneWidget);
    });

    testWidgets('long-press asks before deleting, for both of you', (
      tester,
    ) async {
      final deps = await pumpCalendar(tester, events: [mine, theirs]);

      await tester.longPress(find.text('Cinéma'));
      await tester.pumpAndSettle();
      expect(find.text(calendarDeleteEventTitle('fr')), findsOneWidget);
      expect(
        find.text(calendarDeleteEventConfirm('fr', 'Cinéma')),
        findsOneWidget,
      );

      await tester.tap(find.text(calendarCancel('fr')));
      await tester.pumpAndSettle();
      expect(deps.calendar.deletedIds, isEmpty);
      expect(find.text('Cinéma'), findsOneWidget);

      await tester.longPress(find.text('Cinéma'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(calendarDelete('fr')));
      await tester.pumpAndSettle();
      expect(deps.calendar.deletedIds, ['mine']);
      expect(find.text('Cinéma'), findsNothing);
      expect(find.text('Dentiste'), findsOneWidget);
    });
  });

  testWidgets('a stream error is shown in place of the list', (tester) async {
    await pumpCalendar(
      tester,
      overrides: [
        calendarEventsProvider.overrideWith(
          (ref) => Stream.error(Exception('offline')),
        ),
      ],
    );

    expect(find.text('Exception: offline'), findsOneWidget);
    expect(find.text(calendarCreateEvent('fr')), findsNothing);
  });
}
