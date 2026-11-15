import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nousdeux/presentation/providers/auth_provider.dart';
import 'package:nousdeux/presentation/providers/profile_provider.dart';

/// Registers FCM token with the profile when the user is signed in.
/// Call once when the app has ref (e.g. from a ConsumerStatefulWidget).
Future<void> registerFcmToken(WidgetRef ref) async {
  final user = ref.read(currentUserProvider).valueOrNull;
  if (user == null) return;
  try {
    final messaging = FirebaseMessaging.instance;
    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.denied) return;
    // Keep listening for token refresh (e.g. app reinstall). On iOS this is
    // also where the token arrives if Apple's push token comes late.
    messaging.onTokenRefresh.listen((newToken) async {
      await ref.read(profileRepositoryProvider).updateFcmToken(newToken);
    });
    // On iOS, FCM has no token until Apple has given the app its push token,
    // which can take a moment after the permission prompt; asking before
    // that throws.
    if (defaultTargetPlatform == TargetPlatform.iOS &&
        !await waitForApnsToken(messaging.getAPNSToken)) {
      return;
    }
    final token = await messaging.getToken();
    if (token != null) {
      await ref.read(profileRepositoryProvider).updateFcmToken(token);
    }
  } catch (_) {
    // Firebase not configured or permission error; app works without push.
  }
}

/// Asks for Apple's push token once a second, up to [tries] times.
@visibleForTesting
Future<bool> waitForApnsToken(
  Future<String?> Function() apnsToken, {
  int tries = 10,
  Duration interval = const Duration(seconds: 1),
}) async {
  for (var i = 0; i < tries; i++) {
    if (await apnsToken() != null) return true;
    if (i < tries - 1) await Future<void>.delayed(interval);
  }
  return false;
}
