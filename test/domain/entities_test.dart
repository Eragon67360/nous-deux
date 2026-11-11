import 'package:flutter_test/flutter_test.dart';

import 'package:nousdeux/core/errors/failures.dart';
import 'package:nousdeux/domain/entities/couple_entity.dart';
import 'package:nousdeux/domain/entities/location_sharing_entity.dart';
import 'package:nousdeux/domain/entities/period_log_entity.dart';
import 'package:nousdeux/domain/entities/profile_entity.dart';
import 'package:nousdeux/domain/entities/user_entity.dart';

void main() {
  group('CoupleEntity.isPaired', () {
    test('is false while waiting for the partner', () {
      const couple = CoupleEntity(id: 'c', user1Id: 'a', pairingCode: 'ABC234');
      expect(couple.isPaired, isFalse);
    });

    test('is false for an empty user2 id', () {
      const couple = CoupleEntity(id: 'c', user1Id: 'a', user2Id: '');
      expect(couple.isPaired, isFalse);
    });

    test('is true once user2 joined', () {
      const couple = CoupleEntity(id: 'c', user1Id: 'a', user2Id: 'b');
      expect(couple.isPaired, isTrue);
    });
  });

  group('ProfileEntity', () {
    test('defaults to French', () {
      const p = ProfileEntity(id: 'a', gender: 'woman');
      expect(p.language, 'fr');
    });

    test('hasPartner ignores null and empty partner ids', () {
      expect(const ProfileEntity(id: 'a', gender: 'woman').hasPartner, isFalse);
      expect(
        const ProfileEntity(id: 'a', gender: 'woman', partnerId: '').hasPartner,
        isFalse,
      );
      expect(
        const ProfileEntity(
          id: 'a',
          gender: 'woman',
          partnerId: 'b',
        ).hasPartner,
        isTrue,
      );
    });

    test('hasCompletedOnboarding follows onboardingCompletedAt', () {
      expect(
        const ProfileEntity(id: 'a', gender: 'woman').hasCompletedOnboarding,
        isFalse,
      );
      expect(
        ProfileEntity(
          id: 'a',
          gender: 'woman',
          onboardingCompletedAt: DateTime.utc(2026),
        ).hasCompletedOnboarding,
        isTrue,
      );
    });

    test('compares by value', () {
      expect(
        const ProfileEntity(id: 'a', gender: 'man', username: 'Alex'),
        const ProfileEntity(id: 'a', gender: 'man', username: 'Alex'),
      );
      expect(
        const ProfileEntity(id: 'a', gender: 'man', language: 'en'),
        isNot(const ProfileEntity(id: 'a', gender: 'man')),
      );
    });
  });

  group('LocationSharingEntity.hasPosition', () {
    LocationSharingEntity at(double? lat, double? lng) => LocationSharingEntity(
      userId: 'a',
      coupleId: 'c',
      isSharing: true,
      latitude: lat,
      longitude: lng,
    );

    test('needs both coordinates', () {
      expect(at(null, null).hasPosition, isFalse);
      expect(at(48.8, null).hasPosition, isFalse);
      expect(at(null, 2.3).hasPosition, isFalse);
      expect(at(48.8, 2.3).hasPosition, isTrue);
    });

    test('rejects non-finite coordinates', () {
      expect(at(double.nan, 2.3).hasPosition, isFalse);
      expect(at(48.8, double.infinity).hasPosition, isFalse);
    });

    test('0,0 is a real position', () {
      expect(at(0, 0).hasPosition, isTrue);
    });
  });

  test('PeriodLogEntity compares by value', () {
    final a = PeriodLogEntity(
      id: 'l',
      userId: 'u',
      coupleId: 'c',
      startDate: DateTime.utc(2026, 3, 1),
    );
    expect(
      a,
      PeriodLogEntity(
        id: 'l',
        userId: 'u',
        coupleId: 'c',
        startDate: DateTime.utc(2026, 3, 1),
      ),
    );
  });

  test('UserEntity compares by value', () {
    expect(
      const UserEntity(id: 'a', phone: '+33612345678'),
      const UserEntity(id: 'a', phone: '+33612345678'),
    );
  });

  group('Failure', () {
    test('carries an optional message', () {
      expect(const AuthFailure('nope').message, 'nope');
      expect(const ServerFailure().message, isNull);
    });

    test('compares by message', () {
      expect(const ServerFailure('x'), const ServerFailure('x'));
      expect(const ServerFailure('x'), isNot(const ServerFailure('y')));
    });
  });
}
