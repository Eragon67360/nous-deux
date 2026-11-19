import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nousdeux/core/services/store_links.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('de.ffuf.in_app_update/methods');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  Map<String, Object?> info(int availability, int? versionCode) => {
    'updateAvailability': availability,
    'immediateAllowed': true,
    'flexibleAllowed': true,
    'availableVersionCode': versionCode,
    'installStatus': 0,
    'packageName': 'com.nousdeux.android',
    'updatePriority': 0,
  };

  Future<int?> ask() {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    return c.read(playUpdateCheckProvider)();
  }

  setUp(() => debugDefaultTargetPlatformOverride = TargetPlatform.android);
  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    messenger.setMockMethodCallHandler(channel, null);
  });

  test('Google Play offering a build gives its number', () async {
    messenger.setMockMethodCallHandler(channel, (_) async => info(2, 30));
    expect(await ask(), 30);
  });

  test('nothing offered, or an unknown answer, gives none', () async {
    messenger.setMockMethodCallHandler(channel, (_) async => info(1, 30));
    expect(await ask(), isNull);
    messenger.setMockMethodCallHandler(channel, (_) async => info(0, null));
    expect(await ask(), isNull);
  });

  test('Play failing (not installed from Play) is an error, not "none"', () {
    messenger.setMockMethodCallHandler(
      channel,
      (_) async => throw PlatformException(code: 'ERROR_APP_NOT_OWNED'),
    );
    expect(ask(), throwsA(isA<PlatformException>()));
  });

  test('off Android, Play is not asked', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    var asked = false;
    messenger.setMockMethodCallHandler(channel, (_) async {
      asked = true;
      return info(2, 30);
    });
    expect(await ask(), isNull);
    expect(asked, isFalse);
  });
}
