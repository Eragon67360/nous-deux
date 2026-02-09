import 'package:nous_deux/core/errors/failures.dart';
import 'package:nous_deux/domain/entities/couple_entity.dart';

typedef PairingResult = ({CoupleEntity? couple, Failure? failure});

abstract class PairingRepository {
  /// Get current user's couple (if any).
  Future<PairingResult> getMyCouple();

  /// Create a new couple for current user (user1) and generate pairing code. Fails if already in a couple.
  Future<PairingResult> createCoupleAndGetCode();

  /// Join an existing couple by pairing code. Fails if current user already in a couple or code invalid.
  Future<PairingResult> joinByCode(String code);
}
