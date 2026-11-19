import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'package:nousdeux/core/services/local_notifications.dart';
import 'package:nousdeux/core/services/period_reminder_service.dart';

import '../../helpers/fakes.dart';

void main() {
  setUpAll(() {
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Europe/Paris'));
  });

  test(
    'rings at 19:00 on the phone, before and after the clocks change',
    () async {
      final n = FakeLocalNotifications();

      // Summer time (UTC+2) the day before the change of 25 October 2026…
      await schedulePartnerPeriodReminder(
        n,
        DateTime(2026, 10, 24),
        'fr',
        now: DateTime(2026, 10, 20, 12),
      );
      expect(
        n.scheduled[periodReminderNotificationId]!.at.toUtc(),
        DateTime.utc(2026, 10, 24, 17),
      );

      // …and winter time (UTC+1) the day after.
      await schedulePartnerPeriodReminder(
        n,
        DateTime(2026, 10, 26),
        'fr',
        now: DateTime(2026, 10, 20, 12),
      );
      final reminder = n.scheduled[periodReminderNotificationId]!;
      expect(reminder.at.toUtc(), DateTime.utc(2026, 10, 26, 18));
      expect(reminder.channel, LocalChannel.periodReminder);
    },
  );

  test('an evening already past schedules nothing', () async {
    final n = FakeLocalNotifications();
    await schedulePartnerPeriodReminder(
      n,
      DateTime(2026, 10, 24),
      'fr',
      now: DateTime(2026, 10, 24, 19, 30),
    );
    expect(n.scheduled, isEmpty);
  });

  test('cancelling removes it', () async {
    final n = FakeLocalNotifications();
    await cancelPartnerPeriodReminder(n);
    expect(n.cancelled, [periodReminderNotificationId]);
  });
}
