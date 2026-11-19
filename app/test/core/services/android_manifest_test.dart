import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Scheduled notifications (the period and pill reminders) only fire on
/// Android when the app declares flutter_local_notifications' receivers:
/// the plugin's own manifest doesn't. Without the boot receiver they are
/// lost when the phone restarts, and without the action receiver the
/// notification's buttons do nothing.
void main() {
  final manifest = File(
    'android/app/src/main/AndroidManifest.xml',
  ).readAsStringSync();

  for (final receiver in [
    'com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver',
    'com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver',
    'com.dexterous.flutterlocalnotifications.ActionBroadcastReceiver',
  ]) {
    test('declares $receiver', () {
      expect(manifest, contains('android:name="$receiver"'));
    });
  }

  test('reschedules after a restart', () {
    expect(
      manifest,
      contains('android:name="android.permission.RECEIVE_BOOT_COMPLETED"'),
    );
    expect(manifest, contains('android.intent.action.BOOT_COMPLETED'));
    expect(manifest, contains('android.intent.action.MY_PACKAGE_REPLACED'));
  });
}
