// Postgres DATE columns are calendar days with no timezone. Keep them as
// local dates in the app so they never shift by a day.

/// Parses "YYYY-MM-DD" as a local date. A full timestamp keeps the calendar
/// day it names in UTC, as Postgres does when casting it to DATE.
DateTime parseDay(Object raw) {
  final text = '$raw';
  if (text.length == 10) return DateTime.parse(text);
  final t = DateTime.parse(text).toUtc();
  return DateTime(t.year, t.month, t.day);
}

/// Formats a date as "YYYY-MM-DD" from its own calendar fields.
String formatDay(DateTime d) {
  final m = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  return '${d.year}-$m-$day';
}

/// The calendar day of [d], at local midnight.
DateTime dayOf(DateTime d) => DateTime(d.year, d.month, d.day);
