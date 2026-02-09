import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
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
    final token = await messaging.getToken();
    if (token != null) {
      await ref.read(profileRepositoryProvider).updateFcmToken(token);
    }
    // Keep listening for token refresh (e.g. app reinstall).
    messaging.onTokenRefresh.listen((newToken) async {
      await ref.read(profileRepositoryProvider).updateFcmToken(newToken);
    });
  } catch (_) {
    // Firebase not configured or permission error; app works without push.
  }
}
