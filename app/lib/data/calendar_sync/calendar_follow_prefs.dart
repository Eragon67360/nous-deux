import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// Ids of the phone calendars followed on this phone.
const calendarFollowedKey = 'calendar_followed_ids';

/// This install's id, named in `profiles.calendar_sync_device` while it
/// follows calendars.
const calendarInstallIdKey = 'calendar_install_id';

/// What this phone remembers about following calendars. Calendar ids are
/// the phone's own, so they never leave it.
class CalendarFollowPrefs {
  Future<Set<String>> followed() async {
    final prefs = await SharedPreferences.getInstance();
    return {...?prefs.getStringList(calendarFollowedKey)};
  }

  Future<void> setFollowed(Set<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    if (ids.isEmpty) {
      await prefs.remove(calendarFollowedKey);
    } else {
      await prefs.setStringList(calendarFollowedKey, ids.toList()..sort());
    }
  }

  /// A random UUID made the first time it is asked for, then kept.
  Future<String> installId() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(calendarInstallIdKey);
    if (existing != null) return existing;
    final id = const Uuid().v4();
    await prefs.setString(calendarInstallIdKey, id);
    return id;
  }
}
