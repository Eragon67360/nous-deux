import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

// The phone's time zone for everything planned on the clock (pill and
// period reminders) and read from the phone calendars.

/// Loads the time zone database, once: loading it again resets `tz.local`
/// to UTC. Packages that offer to load it themselves (device_calendar) are
/// told not to.
void ensureTimeZoneDatabase() {
  if (!tz.timeZoneDatabase.isInitialized) tz_data.initializeTimeZones();
}

/// Loads the time zone database once and sets `tz.local` to the phone's zone.
/// Without it `tz.local` is UTC.
///
/// Called again on resume: `tz.local` keeps its value until the phone has
/// answered, since reminders may be planned meanwhile (loading the database
/// again would reset it to UTC).
Future<void> initLocalTimeZone() async {
  ensureTimeZoneDatabase();
  try {
    final zone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(zone.identifier));
  } catch (_) {
    // An unknown zone name: keep the current zone rather than failing.
  }
}
