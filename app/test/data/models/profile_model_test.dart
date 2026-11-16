import 'package:flutter_test/flutter_test.dart';

import 'package:nousdeux/data/models/profile_model.dart';
import 'package:nousdeux/domain/entities/profile_entity.dart';

void main() {
  final fullJson = <String, dynamic>{
    'id': 'u1',
    'username': 'Camille',
    'gender': 'woman',
    'partner_id': 'u2',
    'language': 'en',
    // Tests have no backend URL configured, so no avatar URL is trusted
    // (see avatar_url_test.dart).
    'avatar_url': null,
    'fcm_token': 'tok',
    'onboarding_completed_at': '2026-03-01T08:00:00.000Z',
    'created_at': '2026-02-01T08:00:00.000Z',
    'updated_at': '2026-03-02T08:00:00.000Z',
  };

  test('fromJson reads every column', () {
    final m = ProfileModel.fromJson(fullJson);
    expect(m.id, 'u1');
    expect(m.username, 'Camille');
    expect(m.gender, 'woman');
    expect(m.partnerId, 'u2');
    expect(m.language, 'en');
    expect(m.avatarUrl, isNull);
    expect(m.fcmToken, 'tok');
    expect(m.onboardingCompletedAt, DateTime.utc(2026, 3, 1, 8));
    expect(m.createdAt, DateTime.utc(2026, 2, 1, 8));
    expect(m.updatedAt, DateTime.utc(2026, 3, 2, 8));
  });

  test('fromJson drops an avatar URL outside this backend', () {
    final m = ProfileModel.fromJson({
      'id': 'u1',
      'avatar_url': 'https://example.test/a.jpg',
    });
    expect(m.avatarUrl, isNull);
  });

  test('fromJson defaults gender to woman and language to fr', () {
    final m = ProfileModel.fromJson({'id': 'u1'});
    expect(m.gender, 'woman');
    expect(m.language, 'fr');
    expect(m.username, isNull);
    expect(m.partnerId, isNull);
    expect(m.onboardingCompletedAt, isNull);
  });

  test('toJson round-trips', () {
    final json = ProfileModel.fromJson(fullJson).toJson();
    expect(json, fullJson);
  });

  test('toEntity drops the FCM token and keeps the rest', () {
    final e = ProfileModel.fromJson(fullJson).toEntity();
    expect(
      e,
      ProfileEntity(
        id: 'u1',
        username: 'Camille',
        gender: 'woman',
        partnerId: 'u2',
        language: 'en',
        onboardingCompletedAt: DateTime.utc(2026, 3, 1, 8),
        createdAt: DateTime.utc(2026, 2, 1, 8),
        updatedAt: DateTime.utc(2026, 3, 2, 8),
      ),
    );
    expect(e.hasPartner, isTrue);
    expect(e.hasCompletedOnboarding, isTrue);
  });

  test('fromEntity -> toEntity is lossless and has no FCM token', () {
    final entity = ProfileModel.fromJson(fullJson).toEntity();
    final model = ProfileModel.fromEntity(entity);
    expect(model.fcmToken, isNull);
    expect(model.toEntity(), entity);
  });
}
