import 'package:equatable/equatable.dart';

class LocationSharingEntity extends Equatable {
  const LocationSharingEntity({
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

  bool get hasPosition =>
      latitude != null && longitude != null && latitude!.isFinite && longitude!.isFinite;

  @override
  List<Object?> get props => [userId, coupleId, latitude, longitude, isSharing, updatedAt];
}
