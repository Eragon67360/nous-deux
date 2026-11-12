import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nousdeux/data/repositories/period_repository_impl.dart';
import 'package:nousdeux/domain/entities/period_log_entity.dart';
import 'package:nousdeux/domain/repositories/period_repository.dart';

final periodRepositoryProvider = Provider<PeriodRepository>((ref) {
  return PeriodRepositoryImpl();
});

/// Period logs of the current couple the caller may read: theirs, and the
/// partner's while shared. Cycle maths and the reminder live in
/// cycle_provider.dart.
final periodLogsProvider = StreamProvider<List<PeriodLogEntity>>((ref) {
  return ref.watch(periodRepositoryProvider).watchLogs();
});
