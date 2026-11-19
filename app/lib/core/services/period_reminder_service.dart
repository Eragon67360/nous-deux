import 'package:timezone/timezone.dart' as tz;

import 'package:nousdeux/core/constants/period_education.dart';
import 'package:nousdeux/core/services/local_notifications.dart';

/// Id used for the single reminder about the partner's period (so it can be
/// moved or cancelled).
const int periodReminderNotificationId = 1;

/// Schedules the reminder for 19:00 on [day] (the evening before the
/// partner's period is expected), in the phone's time zone, with the text in
/// [lang]. Nothing when that evening has passed ([now], the clock).
Future<void> schedulePartnerPeriodReminder(
  LocalNotifications notifications,
  DateTime day,
  String lang, {
  DateTime? now,
}) async {
  final at = tz.TZDateTime(tz.local, day.year, day.month, day.day, 19);
  if (!at.isAfter(now ?? DateTime.now())) return;
  try {
    await notifications.schedule(
      id: periodReminderNotificationId,
      at: at,
      channel: LocalChannel.periodReminder,
      title: periodReminderNotificationTitle(lang),
      body: periodReminderNotificationBody(lang),
    );
  } catch (_) {
    // Scheduling may fail on some phones; the reminder is best effort.
  }
}

/// Cancels the reminder about the partner's period.
Future<void> cancelPartnerPeriodReminder(
  LocalNotifications notifications,
) async {
  try {
    await notifications.cancel(periodReminderNotificationId);
  } catch (_) {}
}
