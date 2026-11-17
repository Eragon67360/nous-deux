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

  /// One sync at a time: a call during a run gets that run's outcome. It
  /// runs unattended (on resume, from a push), so an error is a failed run.
  Future<CalendarSyncOutcome> run() =>
      _running ??= _guarded().whenComplete(() => _running = null);

  Future<CalendarSyncOutcome> _guarded() async {
    try {
      return await _run();
    } catch (_) {
      return CalendarSyncOutcome.failed;
    }
  }

  /// Follows [calendarIds] from this phone (none: [stopFollowing]), then
  /// syncs them. A sync already running finishes first, so the new set is
  /// read by a fresh one.
  Future<CalendarSyncOutcome> follow(Set<String> calendarIds) async {
    if (calendarIds.isEmpty) {
      return await stopFollowing()
          ? CalendarSyncOutcome.notFollowing
          : CalendarSyncOutcome.failed;
    }
    await _running;
    final named = await _profiles.setCalendarSyncDevice(
      await _prefs.installId(),
    );
    if (named.failure != null) return CalendarSyncOutcome.failed;
    await _prefs.setFollowed(calendarIds);
    return run();
  }

  /// Stops following from this phone and removes all my copies, older ones
  /// too; true when done. A phone that another of
  /// mine has replaced only forgets its settings: the copies are that
  /// phone's. When a delete fails, this phone keeps following, so stopping
  /// can be tried again and no copy is left without a phone to update it.
  Future<bool> stopFollowing() async {
    await _running;
    final me = await _profiles.getOrCreateMyProfile();
    if (me.failure != null || me.profile == null) return false;
    if (me.profile!.calendarSyncDevice != await _prefs.installId()) {
      await _prefs.setFollowed({});
      return true;
    }
    final previous = await _prefs.followed();
    // Followed nothing from here on, so no new run copies anything.
    await _prefs.setFollowed({});
    Future<bool> keepFollowing() async {
      await _prefs.setFollowed(previous);
      return false;
    }

    // Every copy goes, past ones too: nothing is left that no phone updates.
    final synced = await _calendar.getMySyncedEvents(
      from: DateTime.utc(1970),
      to: DateTime.utc(9999),
    );
    if (synced.failure != null) return keepFollowing();
    for (final e in synced.events) {
      if (await _calendar.deleteEvent(e.id) != null) return keepFollowing();
    }
    final cleared = await _profiles.setCalendarSyncDevice(null);
    if (cleared.failure != null) return keepFollowing();
    return true;
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
    // The phone also gives events that started earlier and still run in
    // the window (a trip): their copies are fetched too, or they would be
    // copied again. A day's margin each side: an all-day copy starts at
    // local midnight, which can sit just outside its phone event's window.
    final earliest = phone.fold(
      from,
      (d, e) => e.start.isBefore(d) ? e.start : d,
    );
    final synced = await _calendar.getMySyncedEvents(
      from: earliest.subtract(const Duration(days: 1)),
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
