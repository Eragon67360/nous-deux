import 'package:nousdeux/domain/entities/location_sharing_entity.dart';

class LocationSharingModel {
  LocationSharingModel({
    required this.userId,
    required this.coupleId,
    this.latitude,
    this.longitude,
    required this.isSharing,
    this.updatedAt,
  });

  final String userId;
  final String coupleId;
  final double? latitude;
  final double? longitude;
  final bool isSharing;
  final DateTime? updatedAt;

  factory LocationSharingModel.fromJson(Map<String, dynamic> json) {
    return LocationSharingModel(
      userId: json['user_id'] as String,
      coupleId: json['couple_id'] as String,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      isSharing: json['is_sharing'] as bool? ?? false,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  LocationSharingEntity toEntity() {
    return LocationSharingEntity(
      userId: userId,
      coupleId: coupleId,
      latitude: latitude,
      longitude: longitude,
      isSharing: isSharing,
      updatedAt: updatedAt,
    );
  }
}
