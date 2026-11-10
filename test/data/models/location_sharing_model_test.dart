import 'package:flutter_test/flutter_test.dart';

import 'package:nousdeux/data/models/location_sharing_model.dart';

void main() {
  test('reads coordinates sent as ints or doubles', () {
    final e = LocationSharingModel.fromJson({
      'user_id': 'u1',
      'couple_id': 'c1',
      'latitude': 48,
      'longitude': 2.3522,
      'is_sharing': true,
      'updated_at': '2026-03-01T08:00:00Z',
    }).toEntity();

    expect(e.userId, 'u1');
    expect(e.coupleId, 'c1');
    expect(e.latitude, 48.0);
    expect(e.latitude, isA<double>());
    expect(e.longitude, 2.3522);
    expect(e.isSharing, isTrue);
    expect(e.updatedAt, DateTime.utc(2026, 3, 1, 8));
    expect(e.hasPosition, isTrue);
  });

  test(
    'missing is_sharing means not sharing; missing coordinates mean no position',
    () {
      final e = LocationSharingModel.fromJson({
        'user_id': 'u1',
        'couple_id': 'c1',
      }).toEntity();

      expect(e.isSharing, isFalse);
      expect(e.latitude, isNull);
      expect(e.longitude, isNull);
      expect(e.updatedAt, isNull);
      expect(e.hasPosition, isFalse);
    },
  );
}
