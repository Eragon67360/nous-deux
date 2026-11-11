import 'package:flutter_test/flutter_test.dart';

import 'package:nousdeux/core/utils/geo_utils.dart';

void main() {
  group('distanceMeters', () {
    test('is zero for the same point', () {
      expect(distanceMeters(48.8566, 2.3522, 48.8566, 2.3522), 0);
    });

    test('Paris to London is about 344 km', () {
      final d = distanceMeters(48.8566, 2.3522, 51.5074, -0.1278);
      expect(d, closeTo(343560, 1000));
    });

    test('one degree of latitude is about 111.2 km', () {
      expect(distanceMeters(0, 0, 1, 0), closeTo(111195, 10));
    });

    test('is symmetric', () {
      final ab = distanceMeters(48.5734, 7.7521, 43.2965, 5.3698);
      final ba = distanceMeters(43.2965, 5.3698, 48.5734, 7.7521);
      expect(ab, closeTo(ba, 1e-6));
    });

    test('takes the short way across the antimeridian', () {
      // 179.5°E to 179.5°W on the equator: 1° of longitude, not 359°.
      expect(distanceMeters(0, 179.5, 0, -179.5), closeTo(111195, 10));
    });

    test('a few metres apart stays under the merge threshold', () {
      // ~5.6 m north.
      final d = distanceMeters(48.85660, 2.35220, 48.85665, 2.35220);
      expect(d, closeTo(5.56, 0.05));
      expect(d < positionMergeThresholdMeters, isTrue);
    });
  });

  test('merge threshold is 10 m', () {
    expect(positionMergeThresholdMeters, 10);
  });
}
