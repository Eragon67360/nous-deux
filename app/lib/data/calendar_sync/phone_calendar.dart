import 'dart:io';

import 'package:device_calendar/device_calendar.dart';

import 'package:nousdeux/domain/calendar/phone_event.dart';

/// The phone's calendars, as the sync reads them.
abstract class PhoneCalendar {
  /// The phone's calendars, or null when they can't be read (no permission).
  Future<List<Calendar>?> calendars();

  /// Every occurrence between [from] and [to] in [calendarIds], or null when
  /// any of them can't be read: no permission, an error, or a calendar that
  /// is gone. The sync then changes nothing rather than deleting copies.
  Future<List<PhoneEvent>?> events(
    Set<String> calendarIds,
    DateTime from,
    DateTime to,
  );
}

class DevicePhoneCalendar implements PhoneCalendar {
  DevicePhoneCalendar([DeviceCalendarPlugin? plugin])
    : _plugin = plugin ?? DeviceCalendarPlugin();

  final DeviceCalendarPlugin _plugin;

  /// Never asks for permission: the sync may run in the background, where
  /// a prompt can't show. The follow screen asks.
  Future<bool> _allowed() async {
    final result = await _plugin.hasPermissions();
    return result.isSuccess && (result.data ?? false);
  }

  @override
  Future<List<Calendar>?> calendars() async {
    try {
      if (!await _allowed()) return null;
      final result = await _plugin.retrieveCalendars();
      return result.isSuccess ? [...?result.data] : null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<PhoneEvent>?> events(
    Set<String> calendarIds,
    DateTime from,
    DateTime to,
  ) async {
    try {
      final available = {for (final c in await calendars() ?? []) c.id};
      if (!available.containsAll(calendarIds)) return null;
      final out = <PhoneEvent>[];
      for (final id in calendarIds) {
        final result = await _plugin.retrieveEvents(
          id,
          RetrieveEventsParams(startDate: from, endDate: to),
        );
        if (!result.isSuccess) return null;
        for (final e in result.data ?? <Event>[]) {
          final p = phoneEventFrom(e, floatingAllDay: Platform.isIOS);
          if (p != null) out.add(p);
        }
      }
      return out;
    } catch (_) {
      return null;
    }
  }
}
