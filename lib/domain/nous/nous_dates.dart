import 'package:nousdeux/core/utils/date_only.dart';
import 'package:nousdeux/domain/entities/calendar_event_entity.dart';

/// Whole days between [since] and [today], counting calendar days (never
/// negative). Day one is the day after [since].
int daysTogether(DateTime since, DateTime today) {
  final diff = DateTime.utc(today.year, today.month, today.day)
      .difference(DateTime.utc(since.year, since.month, since.day))
      .inDays;
  return diff < 0 ? 0 : diff;
}

/// The next anniversary of [since] on or after [today].
class Anniversary {
  const Anniversary({required this.date, required this.years, required this.inDays});

  final DateTime date;

  /// How many years together on that day.
  final int years;

  /// Days from [today] to [date]; 0 means today.
  final int inDays;
}

Anniversary nextAnniversary(DateTime since, DateTime today) {
  final day = dayOf(today);
  var years = day.year - since.year;
  var date = _anniversaryIn(since, day.year);
  if (date.isBefore(day)) {
    years += 1;
    date = _anniversaryIn(since, day.year + 1);
  }
  if (years < 1) {
    years = 1;
    date = _anniversaryIn(since, since.year + 1);
  }
  return Anniversary(date: date, years: years, inDays: daysTogether(day, date));
}

/// 29 February falls on 28 February in years without one.
DateTime _anniversaryIn(DateTime since, int year) {
  final lastDay = DateTime(year, since.month + 1, 0).day;
  return DateTime(year, since.month, since.day > lastDay ? lastDay : since.day);
}

/// Countdown events that have not started yet, soonest first.
List<CalendarEventEntity> upcomingCountdowns(
  Iterable<CalendarEventEntity> events,
  DateTime now,
) {
  return events.where((e) => e.isCountdown && e.startTime.isAfter(now)).toList()
    ..sort((a, b) => a.startTime.compareTo(b.startTime));
}

/// Calendar days from [now] until [target] (0 = today).
int daysUntil(DateTime target, DateTime now) => daysTogether(now, target);
