import 'package:flutter_test/flutter_test.dart';

import 'package:nousdeux/data/models/couple_model.dart';

void main() {
  test('fromJson + toEntity for a couple waiting for the partner', () {
    final e = CoupleModel.fromJson({
      'id': 'c1',
      'user1_id': 'u1',
      'user2_id': null,
      'pairing_code': 'ABC234',
      'created_at': '2026-03-01T08:00:00Z',
      'updated_at': null,
    }).toEntity();

    expect(e.id, 'c1');
    expect(e.user1Id, 'u1');
    expect(e.user2Id, isNull);
    expect(e.pairingCode, 'ABC234');
    expect(e.createdAt, DateTime.utc(2026, 3, 1, 8));
    expect(e.updatedAt, isNull);
    expect(e.isPaired, isFalse);
  });

  test('fromJson + toEntity for a paired couple', () {
    final e = CoupleModel.fromJson({
      'id': 'c1',
      'user1_id': 'u1',
      'user2_id': 'u2',
      'pairing_code': 'ABC234',
    }).toEntity();

    expect(e.user2Id, 'u2');
    expect(e.isPaired, isTrue);
    expect(e.createdAt, isNull);
  });
}
