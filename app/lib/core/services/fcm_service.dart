import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nousdeux/domain/entities/ping_entity.dart';
import 'package:nousdeux/presentation/providers/auth_provider.dart';
import 'package:nousdeux/presentation/providers/profile_provider.dart';

/// A little note someone opened by tapping its notification.
typedef OpenedNote = ({PingKind kind, DateTime sentAt});

/// The note a push announces, read from its data (`type`, `kind`, `sent_at`,
/// set by the notify-partner-ping function), or null for any other push.
OpenedNote? openedNoteFrom(Map<String, dynamic> data) {
  if (data['type'] != 'ping') return null;
  final kind = PingKind.fromWire(data['kind'] as String?);
  final sentAt = DateTime.tryParse(data['sent_at'] as String? ?? '');
  if (kind == null || sentAt == null) return null;
  return (kind: kind, sentAt: sentAt.toLocal());
}

/// What a tapped notification opens.
sealed class OpenedPush {
  const OpenedPush();
}

/// A little note from the partner: the Nous tab shows it full screen.
final class OpenedNotePush extends OpenedPush {
  const OpenedNotePush(this.note);

  final OpenedNote note;
}

/// A message from the team (send-announcement): Paramètres › Nouveautés.
/// Not const, so two taps are two events.
final class OpenedAnnouncementPush extends OpenedPush {
  OpenedAnnouncementPush(this.id);

  /// The message's id, or "test" for a test send.
  final String id;
}

/// What the push with [data] opens, or null when it opens nothing in
/// particular.
OpenedPush? openedPushFrom(Map<String, dynamic> data) {
  if (data['type'] == 'announcement') {
    return OpenedAnnouncementPush(data['id'] as String? ?? '');
  }
  final note = openedNoteFrom(data);
  return note == null ? null : OpenedNotePush(note);
}

/// Pushes opened from their notification: the one that launched the app,
/// then each one tapped while the app runs in the background. One stream for
/// every kind, because Firebase hands out the launch notification only once.
/// Ends at once when Firebase isn't set up.
Stream<OpenedPush> openedPushes() async* {
  try {
    final launch = await FirebaseMessaging.instance.getInitialMessage();
    final first = launch == null ? null : openedPushFrom(launch.data);
    if (first != null) yield first;
    await for (final message in FirebaseMessaging.onMessageOpenedApp) {
      final push = openedPushFrom(message.data);
      if (push != null) yield push;
    }
  } catch (_) {
    // Firebase not configured; there are no notifications to open.
  }
}

/// [openedPushes], injectable so tests can tap a notification.
final openedPushesProvider = StreamProvider<OpenedPush>(
  (ref) => openedPushes(),
);

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
