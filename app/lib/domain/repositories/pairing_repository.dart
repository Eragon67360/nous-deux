import 'package:nousdeux/core/errors/failures.dart';
import 'package:nousdeux/domain/entities/couple_entity.dart';

typedef PairingResult = ({CoupleEntity? couple, Failure? failure});

abstract class PairingRepository {
  /// Get current user's couple (if any).
  Future<PairingResult> getMyCouple();

  /// Create a new couple for current user (user1) and generate pairing code. Fails if already in a couple.
  Future<PairingResult> createCoupleAndGetCode();

  /// Join an existing couple by pairing code. Fails if current user already in a couple or code invalid.
  Future<PairingResult> joinByCode(String code);

  /// Change the day the relationship started (shown as "days together").
  /// Returns a failure, or null on success.
  Future<Failure?> updateTogetherSince(DateTime day);

  /// Leave current couple. Clears partner link for both users and deletes the couple (shared data is removed). On success, result has no couple and no failure.
  Future<PairingResult> leaveCouple();
}
