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

  /// Update a period log.
  Future<PeriodLogResult> updateLog({
    required String id,
    DateTime? startDate,
    DateTime? endDate,
    String? mood,
    List<String>? symptoms,
    String? notes,
  });

  /// Delete a period log.
  Future<Failure?> deleteLog(String id);
}
