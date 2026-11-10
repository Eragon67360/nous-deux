import 'package:nousdeux/core/errors/failures.dart';
import 'package:nousdeux/domain/entities/period_log_entity.dart';

typedef PeriodLogResult = ({PeriodLogEntity? log, Failure? failure});
typedef PeriodLogsResult = ({List<PeriodLogEntity> logs, Failure? failure});

abstract class PeriodRepository {
  /// Stream of period logs for the current couple (own + partner's).
  Stream<List<PeriodLogEntity>> watchLogs();

  /// Fetch logs in an optional date range.
  Future<PeriodLogsResult> getLogs({DateTime? start, DateTime? end});

  /// Create a period log.
  Future<PeriodLogResult> createLog({
    required DateTime startDate,
    DateTime? endDate,
    String? mood,
    List<String>? symptoms,
    String? notes,
  });

  /// Update a period log. Every editable field is sent; null clears the
  /// end date, mood or notes.
  Future<PeriodLogResult> updateLog({
    required String id,
    required DateTime startDate,
    required DateTime? endDate,
    required String? mood,
    required List<String> symptoms,
    required String? notes,
  });

  /// Delete a period log.
  Future<Failure?> deleteLog(String id);
}
