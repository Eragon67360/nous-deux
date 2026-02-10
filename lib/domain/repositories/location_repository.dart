import 'package:nousdeux/core/errors/failures.dart';
import 'package:nousdeux/domain/entities/location_sharing_entity.dart';

typedef LocationSharingResult = ({LocationSharingEntity? entity, Failure? failure});

abstract class LocationRepository {
  /// Get current user's location sharing row (if any).
  Future<LocationSharingResult> getMyLocationSharing();

  /// Get partner's location sharing row when in same couple. Returns null if no partner or no row.
  Future<LocationSharingResult> getPartnerLocationSharing(String partnerUserId);

  /// Upsert current user's location: isSharing and optional lat/lng. Requires couple (for insert).
  Future<LocationSharingResult> setMyLocationSharing({
    required bool isSharing,
    required String coupleId,
    double? lat,
    double? lng,
  });
}
