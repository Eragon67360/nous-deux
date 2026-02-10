import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import 'package:nousdeux/core/constants/app_constants.dart';
import 'package:nousdeux/data/repositories/location_repository_impl.dart';
import 'package:nousdeux/domain/entities/location_sharing_entity.dart';
import 'package:nousdeux/domain/repositories/location_repository.dart';
import 'package:nousdeux/presentation/providers/auth_provider.dart';
import 'package:nousdeux/presentation/providers/pairing_provider.dart';
import 'package:nousdeux/presentation/providers/profile_provider.dart';

final locationRepositoryProvider = Provider<LocationRepository>((ref) {
  return LocationRepositoryImpl();
});

/// Current user's location sharing row. Invalidate after toggle or position update.
final myLocationSharingProvider = FutureProvider<LocationSharingEntity?>((ref) async {
  final user = ref.watch(currentUserProvider).valueOrNull;
  if (user == null) return null;
  final repo = ref.watch(locationRepositoryProvider);
  final result = await repo.getMyLocationSharing();
  return result.failure != null ? null : result.entity;
});

/// Partner's location sharing row (when current user has a partner). Subscribe to Realtime in Position screen and invalidate this + [myLocationSharingProvider] on changes.
final partnerLocationSharingProvider = FutureProvider<LocationSharingEntity?>((ref) async {
  final myProfile = await ref.watch(myProfileProvider.future);
  final partnerId = myProfile?.partnerId;
  if (partnerId == null || partnerId.isEmpty) return null;
  final repo = ref.watch(locationRepositoryProvider);
  final result = await repo.getPartnerLocationSharing(partnerId);
  return result.failure != null ? null : result.entity;
});

/// Manages periodic location updates when sharing. Call [start] when Position screen is visible and sharing is on; call [stop] on dispose.
class LocationUpdateNotifier extends Notifier<void> {
  Timer? _timer;

  @override
  void build() {}

  /// Push current device position to backend. Used when enabling sharing (Settings) and by the periodic timer.
  Future<void> pushCurrentPosition() async {
    final couple = await ref.read(myCoupleProvider.future);
    if (couple == null) return;
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium),
      );
      final repo = ref.read(locationRepositoryProvider);
      await repo.setMyLocationSharing(
        isSharing: true,
        coupleId: couple.id,
        lat: position.latitude,
        lng: position.longitude,
      );
      ref.invalidate(myLocationSharingProvider);
    } catch (_) {
      // Permission or service disabled; ignore
    }
  }

  /// Start periodic updates (and push once now) when user is sharing. Call from Position screen when mounted.
  void start() {
    stop();
    ref.read(myLocationSharingProvider.future).then((my) {
      if (my == null || !my.isSharing) return;
      pushCurrentPosition();
      _timer = Timer.periodic(
        Duration(seconds: AppConstants.locationUpdateIntervalSeconds),
        (_) => pushCurrentPosition(),
      );
    });
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }
}

final locationUpdateNotifierProvider =
    NotifierProvider<LocationUpdateNotifier, void>(LocationUpdateNotifier.new);
