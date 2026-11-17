import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:device_calendar/device_calendar.dart';
import 'package:equatable/equatable.dart';

import 'package:nousdeux/core/constants/app_constants.dart';

/// One occurrence of an event in a followed phone calendar, as Nous Deux
/// copies it: its title and times, nothing else (docs/CALENDAR_SYNC.md).
class PhoneEvent extends Equatable {
  const PhoneEvent({
    required this.key,
    required this.title,
    required this.start,
    this.end,
  });

  /// [phoneEventKey] of the occurrence; `calendar_events.source_key`.
  final String key;
  final String title;
  final DateTime start;
  final DateTime? end;

  @override
  List<Object?> get props => [key, title, start, end];
}

/// SHA-256 (lowercase hex) of the phone's calendar id, event id and the
/// occurrence's start instant, so each occurrence of a recurring event has
/// its own key and no phone identifier leaves the phone.
String phoneEventKey(String calendarId, String eventId, DateTime start) {
  final source = '$calendarId|$eventId|${start.toUtc().toIso8601String()}';
  return sha256.convert(utf8.encode(source)).toString();
}

/// The copy of [e], or null when it has no calendar, id, start or title.
/// The title is cut to [AppConstants.eventTitleMaxLength] characters. An
/// all-day event keeps its calendar day and starts and ends at local
/// midnight. Its day is read from the date the plugin gives (Android brings
/// it back to midnight UTC), or, with [floatingAllDay] (iPhone: EventKit
/// gives all-day events no time zone, so the plugin reads them as UTC),
/// from the instant in the phone's own time zone.
PhoneEvent? phoneEventFrom(Event e, {bool floatingAllDay = false}) {
  final calendarId = e.calendarId;
  final eventId = e.eventId;
  final start = e.start;
  final title = e.title?.trim() ?? '';
  if (calendarId == null || calendarId.isEmpty) return null;
  if (eventId == null || eventId.isEmpty || start == null || title.isEmpty) {
    return null;
  }
  final end = e.end;
  final allDay = e.allDay ?? false;
  return PhoneEvent(
    key: phoneEventKey(calendarId, eventId, start),
    title: String.fromCharCodes(
      title.runes.take(AppConstants.eventTitleMaxLength),
    ),
    start: allDay ? _day(start, floatingAllDay) : _local(start),
    end: end == null
        ? null
        : (allDay ? _day(end, floatingAllDay) : _local(end)),
  );
}

DateTime _local(DateTime d) =>
    DateTime.fromMillisecondsSinceEpoch(d.millisecondsSinceEpoch);

DateTime _day(DateTime d, bool floating) {
  final day = floating ? _local(d) : d;
  return DateTime(day.year, day.month, day.day);
}
