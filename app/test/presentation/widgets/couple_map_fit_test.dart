import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

import 'package:nousdeux/presentation/widgets/couple_map.dart';

void main() {
  // The Position screen's map on an iPhone 16 Plus, under the app bar and
  // above the tab bar.
  const size = Size(430, 690);
  const padding = CoupleMapState.fitPadding;

  void expectBothInside(LatLng a, LatLng b) {
    final camera = cameraToFit(a, b, size, padding);
    for (final p in [a, b]) {
      final s = screenPoint(p, camera, size);
      expect(
        s.dx,
        inInclusiveRange(padding.left - 0.5, size.width - padding.right + 0.5),
        reason: 'x of $p',
      );
      expect(
        s.dy,
        inInclusiveRange(padding.top - 0.5, size.height - padding.bottom + 0.5),
        reason: 'y of $p',
      );
    }
  }

  test('Croix-Rousse and Bellecour (1.9 km) both show, flat and north-up', () {
    const alex = LatLng(45.7745, 4.8290);
    const camille = LatLng(45.7578, 4.8322);
    final camera = cameraToFit(alex, camille, size, padding);
    expect(camera.tilt, 0);
    expect(camera.bearing, 0);
    expectBothInside(alex, camille);
    // Close enough to read the streets, not a whole region.
    expect(camera.zoom, inInclusiveRange(12, 15));
  });

  test('the closer dimension is used: one of the two fills its side', () {
    const a = LatLng(48.8566, 2.3522); // Paris
    const b = LatLng(48.8606, 2.3376);
    final camera = cameraToFit(a, b, size, padding);
    final sa = screenPoint(a, camera, size), sb = screenPoint(b, camera, size);
    final usedX = (sa.dx - sb.dx).abs() / (size.width - padding.horizontal);
    final usedY = (sa.dy - sb.dy).abs() / (size.height - padding.vertical);
    expect([usedX, usedY].reduce((x, y) => x > y ? x : y), closeTo(1, 0.001));
  });

  for (final (name, a, b) in [
    (
      'east-west, far apart',
      const LatLng(43.6, 1.44),
      const LatLng(43.7, 7.26),
    ),
    (
      'north-south, Lille to Marseille',
      const LatLng(50.63, 3.06),
      const LatLng(43.30, 5.37),
    ),
    (
      'across the date line side',
      const LatLng(-33.87, 151.21),
      const LatLng(-36.85, 174.76),
    ),
    (
      'a few metres apart',
      const LatLng(45.75, 4.85),
      const LatLng(45.7501, 4.8501),
    ),
  ]) {
    test('$name: both inside the padded box', () => expectBothInside(a, b));
  }

  test('the same point stops at the closest zoom', () {
    const p = LatLng(45.75, 4.85);
    final camera = cameraToFit(p, p, size, padding);
    expect(camera.zoom, 17);
    final s = screenPoint(p, camera, size);
    // Centred in the padded box, not under the names bar.
    expect(
      s.dy,
      closeTo(padding.top + (size.height - padding.vertical) / 2, 0.5),
    );
  });
}
