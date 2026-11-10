import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

import 'package:nousdeux/core/constants/calendar_strings.dart';
import 'package:nousdeux/domain/entities/calendar_event_entity.dart';
import 'package:nousdeux/presentation/providers/calendar_provider.dart';
import 'package:nousdeux/presentation/screens/calendar/calendar_event_form_screen.dart';
import 'package:nousdeux/presentation/screens/calendar/calendar_screen.dart';
import 'package:nousdeux/presentation/theme/app_theme.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/test_app.dart';

DateTime _today({int hour = 0, int minute = 0, int addDays = 0}) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day + addDays, hour, minute);
}

/// The day cell of [day] in the two-week TableCalendar.
Finder _dayCell(DateTime day) => find.text('${day.day}');

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
    testWidgets('[$lang] header shows the title and today\'s date', (
      tester,
    ) async {
      await pumpCalendar(tester, lang: lang);
      final locale = lang == 'fr' ? 'fr_FR' : 'en_US';

      expect(find.text(calendarTitle(lang)), findsOneWidget);
      expect(
        find.text(DateFormat.yMMMMd(locale).format(DateTime.now())),
        findsOneWidget,
      );
      expect(find.text(calendarAdd(lang)), findsOneWidget);
      expect(find.text(calendarFormatTwoWeeks(lang)), findsOneWidget);
    });

    testWidgets('[$lang] an empty day says nothing is planned today', (
      tester,
    ) async {
      await pumpCalendar(tester, lang: lang);

      expect(find.text(calendarNothingToday(lang)), findsOneWidget);
      expect(find.text(calendarCreateEvent(lang)), findsOneWidget);
    });
  }

  testWidgets('another empty day names the date', (tester) async {
    await pumpCalendar(tester);
    final tomorrow = _today(addDays: 1);

    await tester.tap(_dayCell(tomorrow));
    await tester.pumpAndSettle();

    expect(
      find.text(
        calendarNoEventsOn('fr', DateFormat.MMMMd('fr_FR').format(tomorrow)),
      ),
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

  testWidgets('the Add button opens a new event form too', (tester) async {
    await pumpCalendar(tester, lang: 'en');

    await tester.tap(find.text(calendarAdd('en')));
    await tester.pumpAndSettle();

    expect(find.text(calendarEventNew('en')), findsOneWidget);
  });

  group('events of the selected day', () {
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
    final tomorrow = event(
      id: 'tomorrow',
      title: 'Brunch',
      start: _today(hour: 11, addDays: 1),
    );

    testWidgets('only today\'s events are listed, with time and details', (
      tester,
    ) async {
      await pumpCalendar(tester, events: [mine, theirs, tomorrow]);

      expect(find.text('Cinéma'), findsOneWidget);
      expect(find.text('Séance de 20h'), findsOneWidget);
      expect(find.text('19:45'), findsOneWidget);
      expect(find.text('Dentiste'), findsOneWidget);
      expect(find.text('09:05'), findsOneWidget);
      expect(find.text('Brunch'), findsNothing);
      expect(find.text(calendarNothingToday('fr')), findsNothing);
    });

    testWidgets('mine are labelled "Me", the partner\'s with their name', (
      tester,
    ) async {
      await pumpCalendar(tester, events: [mine, theirs]);

      final meLabel = tester.widget<Text>(find.text(calendarMe('fr')));
      final partnerLabel = tester.widget<Text>(find.text('Alex'));
      final colors = testTheme.extension<CoupleColors>()!;
      expect(meLabel.style?.color, colors.mine);
      expect(partnerLabel.style?.color, colors.partner);
    });

    testWidgets('a partner without a name is "Partner"', (tester) async {
      await pumpCalendar(
        tester,
        events: [theirs],
        lang: 'en',
        partnerName: '  ',
      );

      expect(find.text(calendarPartner('en')), findsOneWidget);
    });

    testWidgets('selecting another day shows that day\'s events', (
      tester,
    ) async {
      await pumpCalendar(tester, events: [mine, tomorrow]);

      await tester.tap(_dayCell(tomorrow.startTime));
      await tester.pumpAndSettle();

      expect(find.text('Brunch'), findsOneWidget);
      expect(find.text('Cinéma'), findsNothing);
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

  testWidgets('the format button switches from two weeks to one week', (
    tester,
  ) async {
    await pumpCalendar(tester);

    await tester.tap(find.text(calendarFormatTwoWeeks('fr')));
    await tester.pumpAndSettle();
    // Two weeks -> week (the order of availableCalendarFormats).
    expect(find.text(calendarFormatTwoWeeks('fr')), findsNothing);
    expect(find.text(calendarFormatWeek('fr')), findsOneWidget);
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
    expect(find.text(calendarNothingToday('fr')), findsNothing);
  });
}
