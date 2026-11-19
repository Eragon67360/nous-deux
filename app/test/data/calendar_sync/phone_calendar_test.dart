import 'package:flutter_test/flutter_test.dart';
import 'package:nousdeux/data/calendar_sync/phone_calendar.dart';
import 'package:timezone/timezone.dart' as tz;

void main() {
  test('reading the phone calendars keeps the phone zone', () {
    // device_calendar reloads the zone database by default, which set
    // tz.local to UTC: reminders planned after a calendar sync rang an
    // hour late in France.
    tz.setLocalLocation(tz.getLocation('Europe/Paris'));

    DevicePhoneCalendar();

    expect(tz.local.name, 'Europe/Paris');
  });
}
