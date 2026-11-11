import 'package:nousdeux/core/constants/period_education.dart' show CyclePhase;
import 'package:nousdeux/domain/entities/period_log_entity.dart';

/// Whole days from [from] to [to], by calendar date (DST-proof).
int daysBetween(DateTime from, DateTime to) => DateTime.utc(
  to.year,
  to.month,
  to.day,
).difference(DateTime.utc(from.year, from.month, from.day)).inDays;

DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

/// One finished cycle: from a period start to the next one.
class CycleSpan {
  const CycleSpan({required this.start, required this.length, this.periodDays});

  final DateTime start;
  final int length;

  /// How long that period lasted, when its end was noted.
  final int? periodDays;
}

/// Where one person is in their cycle, from their own period logs.
///
/// The expected length is the average of their last finished cycles (up to
/// six), not a fixed 28 days; 28 and 5 are only used until there is history.
class CycleStats {
  CycleStats._({
    required this.today,
    required this.lastStart,
    required this.lastEnd,
    required this.cycleLength,
    required this.periodLength,
    required this.cyclesUsed,
    required this.history,
    required this.shortestCycle,
    required this.longestCycle,
  });

  static const int defaultCycleLength = 28;
  static const int defaultPeriodLength = 5;
  static const int _averageOver = 6;

  /// A period still open after this many days is treated as ended.
  static const int _openPeriodLimit = 10;

  factory CycleStats.from(List<PeriodLogEntity> logs, DateTime now) {
    final today = _day(now);
    final byStart = <DateTime, PeriodLogEntity>{};
    for (final log in logs) {
      final start = _day(log.startDate);
      if (start.isAfter(today)) continue;
      byStart[start] = log;
    }
    final starts = byStart.keys.toList()..sort();

    final spans = <CycleSpan>[];
    for (var i = 0; i + 1 < starts.length; i++) {
      final log = byStart[starts[i]]!;
      spans.add(
        CycleSpan(
          start: starts[i],
          length: daysBetween(starts[i], starts[i + 1]),
          periodDays: log.endDate == null
              ? null
              : daysBetween(starts[i], log.endDate!) + 1,
        ),
      );
    }

    // Skipped or mistaken entries would distort the average.
    final plausible = spans
        .where((s) => s.length >= 15 && s.length <= 60)
        .toList()
        .reversed
        .take(_averageOver)
        .toList();
    final cycleLength = plausible.isEmpty
        ? defaultCycleLength
        : (plausible.map((s) => s.length).reduce((a, b) => a + b) /
                  plausible.length)
              .round();

    final periodSamples = <int>[
      for (final start in starts.reversed.take(_averageOver))
        if (byStart[start]!.endDate != null)
          daysBetween(start, byStart[start]!.endDate!) + 1,
    ].where((d) => d >= 1 && d <= 14).toList();
    final periodLength = periodSamples.isEmpty
        ? defaultPeriodLength
        : (periodSamples.reduce((a, b) => a + b) / periodSamples.length)
              .round();

    final last = starts.isEmpty ? null : byStart[starts.last];
    return CycleStats._(
      today: today,
      lastStart: starts.isEmpty ? null : starts.last,
      lastEnd: last?.endDate == null ? null : _day(last!.endDate!),
      cycleLength: cycleLength,
      periodLength: periodLength,
      cyclesUsed: plausible.length,
      history: spans.reversed.toList(),
      shortestCycle: plausible.isEmpty
          ? null
          : plausible.map((s) => s.length).reduce((a, b) => a < b ? a : b),
      longestCycle: plausible.isEmpty
          ? null
          : plausible.map((s) => s.length).reduce((a, b) => a > b ? a : b),
    );
  }

  final DateTime today;

  /// Start of the latest period, if any was logged.
  final DateTime? lastStart;

  /// End of the latest period, when noted.
  final DateTime? lastEnd;

  /// Expected cycle length in days (average, or 28 without history).
  final int cycleLength;

  /// Expected period length in days (average, or 5 without history).
  final int periodLength;

  /// How many finished cycles the averages come from (0: defaults).
  final int cyclesUsed;

  /// Finished cycles, newest first.
  final List<CycleSpan> history;

  final int? shortestCycle;
  final int? longestCycle;

  bool get hasData => lastStart != null;

  /// Day of the current cycle, 1 on the first day of the latest period.
  int? get dayOfCycle =>
      lastStart == null ? null : daysBetween(lastStart!, today) + 1;

  /// The latest period has no end yet and started recently.
  bool get periodOngoing =>
      lastStart != null && lastEnd == null && dayOfCycle! <= _openPeriodLimit;

  /// Expected start of the next period.
  DateTime? get nextStart {
    final start = lastStart;
    if (start == null) return null;
    return DateTime(start.year, start.month, start.day + cycleLength);
  }

  /// Days until [nextStart]; negative when it is late.
  int? get daysUntilNext =>
      nextStart == null ? null : daysBetween(today, nextStart!);

  /// First and last day of the current phase, by the same reckoning as
  /// [phase].
  ({int start, int end})? get phaseSpan {
    final current = phase;
    if (current == null) return null;
    final ovulation = cycleLength - 14;
    final bleeding = lastEnd == null
        ? (periodOngoing ? dayOfCycle! : periodLength)
        : daysBetween(lastStart!, lastEnd!) + 1;
    return switch (current) {
      CyclePhase.menstrual => (start: 1, end: bleeding),
      CyclePhase.follicular => (start: bleeding + 1, end: ovulation - 2),
      CyclePhase.ovulation => (start: ovulation - 1, end: ovulation + 1),
      CyclePhase.luteal => (start: ovulation + 2, end: cycleLength),
    };
  }

  CyclePhase? get phase {
    final day = dayOfCycle;
    if (day == null) return null;
    final inPeriod = lastEnd != null
        ? !today.isAfter(lastEnd!)
        : periodOngoing || day <= periodLength;
    if (inPeriod) return CyclePhase.menstrual;
    final ovulation = cycleLength - 14;
    if ((day - ovulation).abs() <= 1) return CyclePhase.ovulation;
    if (day > ovulation + 1) return CyclePhase.luteal;
    return CyclePhase.follicular;
  }
}
