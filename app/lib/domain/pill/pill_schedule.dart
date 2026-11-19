/// The kinds of pill pack (docs/PILL.md): 21 pills then 7 days off, 28 pills
/// in a row, or one pill every day with no break.
enum PackType {
  p21x7('21_7'),
  p28('28'),
  continuous('continuous');

  const PackType(this.wire);

  /// As stored in `pill_tracking.pack_type`.
  final String wire;

  static PackType? fromWire(String? wire) {
    for (final t in values) {
      if (t.wire == wire) return t;
    }
    return null;
  }
}

/// Where a day falls in someone's packs, counted from the first day of one
/// of them. Days are calendar days on the phone; the same rule as the
/// database's `pill_is_pill_day()`.
class PillSchedule {
  PillSchedule(this.type, DateTime startedOn) : startedOn = _day(startedOn);

  final PackType type;

  /// Day 1 of a pack (any one: packs follow each other every 28 days).
  final DateTime startedOn;

  static const _cycle = 28;

  static DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

  /// Whole days from [startedOn] to [d], unaffected by clock changes.
  int _offset(DateTime d) => DateTime.utc(d.year, d.month, d.day)
      .difference(DateTime.utc(startedOn.year, startedOn.month, startedOn.day))
      .inDays;

  /// 1 to 28: the day of the pack [d] falls on.
  int dayInPack(DateTime d) => (_offset(d) % _cycle + _cycle) % _cycle + 1;

  /// Pills in a pack before any break: 21 for 21 + 7, otherwise 28.
  int get pillsInPack => type == PackType.p21x7 ? 21 : _cycle;

  bool isPillDay(DateTime d) => dayInPack(d) <= pillsInPack;

  /// The pill to take on [d] (1 = the first of the pack), or null on a day
  /// off.
  int? pillNumber(DateTime d) => isPillDay(d) ? dayInPack(d) : null;

  /// The first day of the pack after the one [d] is in.
  DateTime nextPackStart(DateTime d) {
    final day = _day(d);
    return DateTime(day.year, day.month, day.day + _cycle - dayInPack(day) + 1);
  }

  /// The 7 days off of the pack [d] is in, whether they are over, under way
  /// or to come; null for packs without a break.
  ({DateTime from, DateTime to})? pauseAround(DateTime d) {
    if (type != PackType.p21x7) return null;
    final day = _day(d);
    final first = DateTime(day.year, day.month, day.day - dayInPack(day) + 1);
    return (
      from: DateTime(first.year, first.month, first.day + 21),
      to: DateTime(first.year, first.month, first.day + 27),
    );
  }
}
