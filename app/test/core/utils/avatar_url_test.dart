import 'package:flutter_test/flutter_test.dart';

import 'package:nousdeux/core/utils/avatar_url.dart';

void main() {
  const api = 'https://api.nous-deux.app';
  const own =
      '$api/storage/v1/object/public/avatars/00000000-0000-0000-0000-000000000001/avatar.jpg';

  test('keeps a URL in this backend\'s avatars bucket', () {
    expect(trustedAvatarUrl(own, apiUrl: api), own);
    expect(trustedAvatarUrl(own, apiUrl: '$api/'), own);
  });

  test('drops anything else', () {
    for (final url in [
      'https://evil.example/a.jpg',
      'https://api.nous-deux.app.evil.example/storage/v1/object/public/avatars/x/a.jpg',
      'http://api.nous-deux.app/storage/v1/object/public/avatars/x/a.jpg',
      '$api/storage/v1/object/public/other/x/a.jpg',
      '$api/storage/v1/object/public/avatars/../other/a.jpg',
    ]) {
      expect(trustedAvatarUrl(url, apiUrl: api), isNull, reason: url);
    }
  });

  test('without a configured backend, nothing is trusted', () {
    expect(trustedAvatarUrl(own, apiUrl: ''), isNull);
    expect(trustedAvatarUrl(null, apiUrl: api), isNull);
  });
}
