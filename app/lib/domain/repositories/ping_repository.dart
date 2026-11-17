import 'package:nousdeux/core/errors/failures.dart';
import 'package:nousdeux/domain/entities/ping_entity.dart';

typedef PingResult = ({PingEntity? ping, Failure? failure});

abstract class PingRepository {
  /// The latest note of each person in the current couple, live. Empty when
  /// not paired.
  Stream<List<PingEntity>> watchPings();

  /// Send a note to the partner: a preset [kind], or [PingKind.custom] with
  /// its [text]. Fails with [PingFailure] on the 30-second limit or when not
  /// paired.
  Future<PingResult> send(PingKind kind, {String? text});
}
