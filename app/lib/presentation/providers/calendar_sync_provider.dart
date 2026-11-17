import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nousdeux/data/calendar_sync/calendar_follow_prefs.dart';
import 'package:nousdeux/data/calendar_sync/calendar_sync_service.dart';
import 'package:nousdeux/data/calendar_sync/phone_calendar.dart';
import 'package:nousdeux/presentation/providers/calendar_provider.dart';
import 'package:nousdeux/presentation/providers/profile_provider.dart';

/// The phone's calendars, injectable so tests can play them.
final phoneCalendarProvider = Provider<PhoneCalendar>(
  (ref) => DevicePhoneCalendar(),
);

final calendarFollowPrefsProvider = Provider<CalendarFollowPrefs>(
  (ref) => CalendarFollowPrefs(),
);

/// Syncs the phone calendars this phone follows (docs/CALENDAR_SYNC.md).
final calendarSyncServiceProvider = Provider<CalendarSyncService>((ref) {
  return CalendarSyncService(
    phone: ref.watch(phoneCalendarProvider),
    calendar: ref.watch(calendarRepositoryProvider),
    profiles: ref.watch(profileRepositoryProvider),
    prefs: ref.watch(calendarFollowPrefsProvider),
  );
});
