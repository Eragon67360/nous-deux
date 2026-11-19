import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nousdeux/core/services/local_time_zone.dart';
import 'package:timezone/timezone.dart' as tz;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('flutter_timezone');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  tearDown(() {
    messenger.setMockMethodCallHandler(channel, null);
    tz.setLocalLocation(tz.getLocation('Europe/Paris'));
  });

  test('keeps the current zone while it asks the phone again', () async {
    // On resume the pill reminders are planned while the phone answers:
    // they must not see UTC in between.
    final answer = Completer<Object?>();
    messenger.setMockMethodCallHandler(channel, (_) => answer.future);
    tz.setLocalLocation(tz.getLocation('Europe/Paris'));

    final reading = initLocalTimeZone();
    await Future<void>.delayed(Duration.zero);
    expect(tz.local.name, 'Europe/Paris');

    answer.complete({'identifier': 'Europe/Berlin'});
    await reading;
    expect(tz.local.name, 'Europe/Berlin');
  });

  test('keeps the current zone when the phone gives an unknown one', () async {
    messenger.setMockMethodCallHandler(
      channel,
      (_) async => {'identifier': 'Mars/Olympus'},
    );
    tz.setLocalLocation(tz.getLocation('Europe/Paris'));

    await initLocalTimeZone();
    expect(tz.local.name, 'Europe/Paris');
  });
}
