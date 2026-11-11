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
  });

  /// Set a period log's dates; a null end clears it.
  Future<PeriodLogResult> updateLog({
    required String id,
    required DateTime startDate,
    required DateTime? endDate,
  });

  /// Delete a period log.
  Future<Failure?> deleteLog(String id);
}
