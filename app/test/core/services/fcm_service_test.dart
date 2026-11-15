import 'package:flutter_test/flutter_test.dart';

import 'package:nousdeux/core/services/fcm_service.dart';

void main() {
  test('waits until Apple hands out the push token', () async {
    final answers = [null, null, 'apns'];
    var calls = 0;
    final ready = await waitForApnsToken(
      () async => answers[calls++],
      interval: Duration.zero,
    );
    expect(ready, isTrue);
    expect(calls, 3);
  });

  test('gives up after the last try', () async {
    var calls = 0;
    final ready = await waitForApnsToken(
      () async {
        calls++;
        return null;
      },
      tries: 4,
      interval: Duration.zero,
    );
    expect(ready, isFalse);
    expect(calls, 4);
  });
}
