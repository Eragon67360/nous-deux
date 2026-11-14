import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';

import 'package:nousdeux/presentation/providers/auth_provider.dart';
import 'package:nousdeux/presentation/providers/location_provider.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/test_app.dart';

/// A GPS that answers only when the test says so, like a slow first fix.
class _PendingGps extends GeolocatorPlatform {
  final _asked = Completer<void>();
  final _answer = Completer<Position>();

  Future<void> get asked => _asked.future;

  void answer(double lat, double lng) => _answer.complete(
    Position(
      latitude: lat,
      longitude: lng,
      timestamp: DateTime.utc(2026, 11, 14),
      accuracy: 20,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0,
    ),
  );

  @override
  Future<Position> getCurrentPosition({LocationSettings? locationSettings}) {
    _asked.complete();
    return _answer.future;
  }
}

void main() {
  late _PendingGps gps;

  setUp(() {
    final original = GeolocatorPlatform.instance;
    addTearDown(() => GeolocatorPlatform.instance = original);
    gps = _PendingGps();
    GeolocatorPlatform.instance = gps;
  });

  /// The real [LocationUpdateNotifier] over the test fakes, once signed in.
  Future<LocationUpdateNotifier> notifierFor(TestDeps deps) async {
    final parent = ProviderContainer(overrides: deps.overrides);
    addTearDown(parent.dispose);
    final c = ProviderContainer(
      parent: parent,
      overrides: [
        locationUpdateNotifierProvider.overrideWith(LocationUpdateNotifier.new),
      ],
    );
    addTearDown(c.dispose);
    await c.read(currentUserProvider.future);
    return c.read(locationUpdateNotifierProvider.notifier);
  }

  group('pushCurrentPosition', () {
    test('while sharing, sends the new position', () async {
      final deps = TestDeps(
        couple: couple(),
        myLocation: location(lat: 48.8566, lng: 2.3522),
      );

      final push = (await notifierFor(deps)).pushCurrentPosition();
      await gps.asked;
      gps.answer(43.2965, 5.3698);
      await push;

      final mine = deps.location.mine!;
      expect(mine.isSharing, isTrue);
      expect((mine.latitude, mine.longitude), (43.2965, 5.3698));
    });

    test('a position that arrives after sharing stopped does not turn it '
        'back on', () async {
      final deps = TestDeps(
        couple: couple(),
        myLocation: location(lat: 48.8566, lng: 2.3522),
      );

      final push = (await notifierFor(deps)).pushCurrentPosition();
      await gps.asked;
      // Meanwhile the person turns sharing off in Settings.
      await deps.location.setMyLocationSharing(
        isSharing: false,
        coupleId: coupleId,
      );
      gps.answer(43.2965, 5.3698);
      await push;

      final mine = deps.location.mine!;
      expect(mine.isSharing, isFalse);
      expect(mine.hasPosition, isFalse);
    });
  });
}
