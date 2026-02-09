import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nousdeux/data/repositories/period_repository_impl.dart';
import 'package:nousdeux/domain/entities/period_log_entity.dart';
import 'package:nousdeux/domain/repositories/period_repository.dart';

final periodRepositoryProvider = Provider<PeriodRepository>((ref) {
  return PeriodRepositoryImpl();
});

/// Stream of period logs for the current couple (own + partner's). Refetch by invalidating.
final periodLogsProvider = StreamProvider<List<PeriodLogEntity>>((ref) {
  return ref.watch(periodRepositoryProvider).watchLogs();
});
