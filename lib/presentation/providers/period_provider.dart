import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nousdeux/core/constants/period_education.dart';
import 'package:nousdeux/core/constants/period_reminder_prefs.dart';
import 'package:nousdeux/core/services/period_reminder_service.dart';
import 'package:nousdeux/data/repositories/period_repository_impl.dart';
import 'package:nousdeux/domain/entities/period_log_entity.dart';
import 'package:nousdeux/domain/repositories/period_repository.dart';
import 'package:nousdeux/presentation/providers/auth_provider.dart';

final periodRepositoryProvider = Provider<PeriodRepository>((ref) {
  return PeriodRepositoryImpl();
});

/// Stream of period logs for the current couple (own + partner's). Refetch by invalidating.
final periodLogsProvider = StreamProvider<List<PeriodLogEntity>>((ref) {
  return ref.watch(periodRepositoryProvider).watchLogs();
});

const int _defaultCycleLengthDays = 28;

/// Current cycle phase derived from the most recent period start in the couple's logs.
/// Uses a 28-day cycle; returns null if there are no logs.
final currentCyclePhaseProvider = Provider<CyclePhase?>((ref) {
  final logsAsync = ref.watch(periodLogsProvider);
  return logsAsync.when(
    data: (logs) => _phaseFromLogs(logs),
    loading: () => null,
    error: (e, st) => null,
  );
});

/// Last period start date (UTC date of start) from the most recent log, or null.
DateTime? _lastPeriodStart(List<PeriodLogEntity> logs) {
  if (logs.isEmpty) return null;
  DateTime? latest;
  for (final log in logs) {
    final start = log.startDate.toUtc();
    final startDate = DateTime.utc(start.year, start.month, start.day);
    if (latest == null || startDate.isAfter(latest)) {
      latest = startDate;
    }
  }
  return latest;
}

/// Day of cycle (1-based) for [today] given [lastPeriodStart]. Returns null if lastStart is null.
int? _dayOfCycle(DateTime today, DateTime? lastPeriodStart) {
  if (lastPeriodStart == null) return null;
  final todayUtc = DateTime.utc(today.year, today.month, today.day);
  final startUtc = DateTime.utc(
    lastPeriodStart.year,
    lastPeriodStart.month,
    lastPeriodStart.day,
  );
  final diff = todayUtc.difference(startUtc).inDays;
  if (diff < 0) return null;
  final day = (diff % _defaultCycleLengthDays) + 1;
  return day;
}

CyclePhase? _phaseFromLogs(List<PeriodLogEntity> logs) {
  final lastStart = _lastPeriodStart(logs);
  final day = _dayOfCycle(DateTime.now(), lastStart);
  if (day == null) return null;
  if (day >= 1 && day <= 5) return CyclePhase.menstrual;
  if (day >= 6 && day <= 12) return CyclePhase.follicular;
  if (day >= 13 && day <= 15) return CyclePhase.ovulation;
  if (day >= 16 && day <= _defaultCycleLengthDays) return CyclePhase.luteal;
  return CyclePhase.menstrual;
}

/// Partner's most recent period start (from logs where userId != currentUserId).
DateTime? _partnerLastPeriodStart(
  List<PeriodLogEntity> logs,
  String? currentUserId,
) {
  if (currentUserId == null || logs.isEmpty) return null;
  DateTime? latest;
  for (final log in logs) {
    if (log.userId == currentUserId) continue;
    final start = log.startDate.toUtc();
    final startDate = DateTime.utc(start.year, start.month, start.day);
    if (latest == null || startDate.isAfter(latest)) {
      latest = startDate;
    }
  }
  return latest;
}

/// Estimated start of partner's next PMS week (partner's last period + 21 days).
/// Used for "Remind me when partner's PMS week is coming".
final nextPartnerPmsDateProvider = Provider<DateTime?>((ref) {
  final logsAsync = ref.watch(periodLogsProvider);
  final currentUserId = ref.watch(currentUserProvider).valueOrNull?.id;
  return logsAsync.when(
    data: (logs) {
      final lastStart = _partnerLastPeriodStart(logs, currentUserId);
      if (lastStart == null) return null;
      return lastStart.add(const Duration(days: 21));
    },
    loading: () => null,
    error: (e, st) => null,
  );
});

/// Whether the partner PMS reminder is enabled (stored in SharedPreferences).
final partnerReminderEnabledProvider = FutureProvider<bool>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(periodPartnerReminderEnabledKey) ?? false;
});

/// Enables or disables the partner PMS reminder and schedules/cancels the notification.
Future<void> setPartnerReminderEnabled(
  WidgetRef ref, {
  required bool enabled,
  required String lang,
}) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(periodPartnerReminderEnabledKey, enabled);
  ref.invalidate(partnerReminderEnabledProvider);
  if (enabled) {
    final date = ref.read(nextPartnerPmsDateProvider);
    if (date != null) {
      await schedulePartnerPmsReminder(date, lang);
    }
  } else {
    await cancelPartnerPmsReminder();
  }
}
