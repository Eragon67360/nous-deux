import 'package:nousdeux/data/calendar_sync/calendar_follow_prefs.dart';
import 'package:nousdeux/data/calendar_sync/phone_calendar.dart';
import 'package:nousdeux/domain/calendar/calendar_sync_plan.dart';
import 'package:nousdeux/domain/repositories/calendar_repository.dart';
import 'package:nousdeux/domain/repositories/profile_repository.dart';

/// How far back and ahead followed calendars are kept in sync.
const calendarSyncPastDays = 30;
const calendarSyncFutureDays = 183;

enum CalendarSyncOutcome { notFollowing, otherPhone, noAccess, synced, failed }

/// Keeps my copies of the phone calendars I follow in line with them
/// (docs/CALENDAR_SYNC.md). Runs in the app and in the background, so it
/// takes plain repositories rather than Riverpod.
class CalendarSyncService {
  CalendarSyncService({
    required PhoneCalendar phone,
    required CalendarRepository calendar,
    required ProfileRepository profiles,
    required CalendarFollowPrefs prefs,
    DateTime Function() now = DateTime.now,
  }) : _phone = phone,
       _calendar = calendar,
       _profiles = profiles,
       _prefs = prefs,
       _now = now;

  final PhoneCalendar _phone;
  final CalendarRepository _calendar;
  final ProfileRepository _profiles;
  final CalendarFollowPrefs _prefs;
  final DateTime Function() _now;

  Future<CalendarSyncOutcome>? _running;

  /// One sync at a time: a call during a run gets that run's outcome.
  Future<CalendarSyncOutcome> run() =>
      _running ??= _run().whenComplete(() => _running = null);

  /// Follows [calendarIds] from this phone (none: [stopFollowing]), then
  /// syncs them.
  Future<CalendarSyncOutcome> follow(Set<String> calendarIds) async {
    if (calendarIds.isEmpty) {
      await stopFollowing();
      return CalendarSyncOutcome.notFollowing;
    }
    final named = await _profiles.setCalendarSyncDevice(
      await _prefs.installId(),
    );
    if (named.failure != null) return CalendarSyncOutcome.failed;
    await _prefs.setFollowed(calendarIds);
    return run();
  }

  /// Removes my copies in the window (older ones stay as history) and stops
  /// following from this phone.
  Future<void> stopFollowing() async {
    final (:from, :to) = _window();
    final synced = await _calendar.getMySyncedEvents(from: from, to: to);
    for (final e in synced.events) {
      await _calendar.deleteEvent(e.id);
    }
    await _prefs.setFollowed({});
    await _profiles.setCalendarSyncDevice(null);
  }

  Future<CalendarSyncOutcome> _run() async {
    final followed = await _prefs.followed();
    if (followed.isEmpty) return CalendarSyncOutcome.notFollowing;
    final me = await _profiles.getOrCreateMyProfile();
    if (me.failure != null || me.profile == null) {
      return CalendarSyncOutcome.failed;
    }
    if (me.profile!.calendarSyncDevice != await _prefs.installId()) {
      // Another phone of mine follows calendars now; its sync owns them.
      await _prefs.setFollowed({});
      return CalendarSyncOutcome.otherPhone;
    }
    final (:from, :to) = _window();
    final phone = await _phone.events(followed, from, to);
    if (phone == null) return CalendarSyncOutcome.noAccess;
    // A day's margin each side: an all-day copy starts at local midnight,
    // which can sit just outside the window its phone event is in.
    final synced = await _calendar.getMySyncedEvents(
      from: from.subtract(const Duration(days: 1)),
      to: to.add(const Duration(days: 1)),
    );
    if (synced.failure != null) return CalendarSyncOutcome.failed;
    final plan = planCalendarSync(
      phone: phone,
      synced: synced.events,
      from: from,
      to: to,
    );
    for (final id in plan.toDelete) {
      if (await _calendar.deleteEvent(id) != null) {
        return CalendarSyncOutcome.failed;
      }
    }
    for (final (:id, :event) in plan.toUpdate) {
      final r = await _calendar.updateSyncedEvent(
        id: id,
        title: event.title,
        startTime: event.start,
        endTime: event.end,
      );
      if (r.failure != null) return CalendarSyncOutcome.failed;
    }
    for (final e in plan.toInsert) {
      final r = await _calendar.createEvent(
        title: e.title,
        startTime: e.start,
        endTime: e.end,
        sourceKey: e.key,
      );
      if (r.failure != null) return CalendarSyncOutcome.failed;
    }
    final marked = await _profiles.markCalendarSynced();
    if (marked.failure != null) return CalendarSyncOutcome.failed;
    return CalendarSyncOutcome.synced;
  }

  ({DateTime from, DateTime to}) _window() {
    final now = _now();
    return (
      from: now.subtract(const Duration(days: calendarSyncPastDays)),
      to: now.add(const Duration(days: calendarSyncFutureDays)),
    );
  }
}
