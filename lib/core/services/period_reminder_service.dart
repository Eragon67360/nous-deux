import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'package:nousdeux/core/constants/period_education.dart';

/// Id used for the single PMS reminder notification (so we can cancel it).
const int periodReminderNotificationId = 1;

bool _initialized = false;
bool _tzInitialized = false;

final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

/// Initializes local notifications for period reminders. Safe to call multiple times.
Future<void> initPeriodReminderNotifications() async {
  if (_initialized) return;
  try {
    if (!_tzInitialized) {
      tz_data.initializeTimeZones();
      _tzInitialized = true;
    }
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwin = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: false,
      requestSoundPermission: true,
    );
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: darwin),
    );
    _initialized = true;
  } catch (_) {
    // Notifications may not be available (e.g. missing config).
  }
}

/// Schedules a single notification for the given date at 09:00 local time.
/// [lang] is used for title/body (fr/en).
Future<void> schedulePartnerPmsReminder(DateTime date, String lang) async {
  await initPeriodReminderNotifications();
  if (!_initialized) return;
  try {
    final local = DateTime(date.year, date.month, date.day, 9, 0);
    if (local.isBefore(DateTime.now())) return;
    final tzDate = tz.TZDateTime.from(local, tz.local);
    await _plugin.zonedSchedule(
      periodReminderNotificationId,
      periodReminderNotificationTitle(lang),
      periodReminderNotificationBody(lang),
      tzDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'period_reminder',
          'Period reminder',
          channelDescription: 'Reminder for partner PMS week',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  } catch (_) {
    // Timezone or schedule may fail on some environments.
  }
}

/// Cancels the partner PMS reminder notification.
Future<void> cancelPartnerPmsReminder() async {
  try {
    await _plugin.cancel(periodReminderNotificationId);
  } catch (_) {}
}
