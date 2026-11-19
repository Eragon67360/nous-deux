import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// A tapped local notification: its payload, and the button's id when a
/// button was tapped rather than the notification itself.
typedef NotificationTap = ({String? payload, String? actionId});

/// Where a local notification goes on Android; each is a channel people can
/// silence on its own in the phone's settings.
enum LocalChannel {
  periodReminder(
    'period_reminder',
    'Period reminder',
    "The evening before the partner's period",
  ),
  pillReminder('pill_reminder', 'Daily reminder', 'The daily reminder you set');

  const LocalChannel(this.id, this.name, this.description);

  final String id;
  final String name;
  final String description;
}

/// A button on a notification. On iOS the buttons come from the category
/// registered at start ([LocalNotifications.schedule]'s `iosCategory`).
class LocalAction {
  const LocalAction(this.id, this.label, {required this.opensApp});

  final String id;
  final String label;

  /// Opens the app (it needs it, e.g. to save something); otherwise the
  /// button is handled without opening it.
  final bool opensApp;
}

/// Notifications this phone shows at a set moment (the reminders). The
/// moments are in the phone's time zone, so a reminder at 21:00 stays at
/// 21:00 when the clocks change.
abstract class LocalNotifications {
  Future<void> schedule({
    required int id,
    required tz.TZDateTime at,
    required LocalChannel channel,
    required String title,
    required String body,
    String? payload,
    String? iosCategory,
    List<LocalAction> actions = const [],
  });

  Future<void> cancel(int id);

  /// Cancels every id from [from] to [to], both included.
  Future<void> cancelRange(int from, int to);

  /// Taps on a notification or its buttons while the app runs.
  Stream<NotificationTap> get taps;

  /// The tap that launched the app, once: it came before anyone listened to
  /// [taps].
  NotificationTap? takeLaunchTap();
}

/// Loads the time zone database and sets `tz.local` to the phone's zone.
/// Without it `tz.local` is UTC.
Future<void> initLocalTimeZone() async {
  tz_data.initializeTimeZones();
  try {
    final zone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(zone.identifier));
  } catch (_) {
    // An unknown zone name: keep UTC rather than failing the start.
  }
}

/// [LocalNotifications] on flutter_local_notifications.
class PluginLocalNotifications implements LocalNotifications {
  PluginLocalNotifications._(this._plugin);

  final FlutterLocalNotificationsPlugin _plugin;
  final _taps = StreamController<NotificationTap>.broadcast();
  NotificationTap? _launchTap;

  @override
  NotificationTap? takeLaunchTap() {
    final t = _launchTap;
    _launchTap = null;
    return t;
  }

  /// Starts the plugin once: the phone's zone, the Android channels, the iOS
  /// [categories] (their buttons), and the handlers. A button that doesn't
  /// open the app goes to [backgroundHandler], a top-level function marked
  /// `@pragma('vm:entry-point')`.
  static Future<PluginLocalNotifications> start({
    List<DarwinNotificationCategory> categories = const [],
    DidReceiveBackgroundNotificationResponseCallback? backgroundHandler,
  }) async {
    final self = PluginLocalNotifications._(FlutterLocalNotificationsPlugin());
    await initLocalTimeZone();
    // Don't prompt at launch, before the person has seen the app. iOS shares
    // one notification permission per app: registerFcmToken asks for it right
    // after sign-in, which also covers these local reminders.
    final darwin = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      notificationCategories: categories,
    );
    await self._plugin.initialize(
      InitializationSettings(
        android: const AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: darwin,
      ),
      onDidReceiveNotificationResponse: (r) =>
          self._taps.add((payload: r.payload, actionId: r.actionId)),
      onDidReceiveBackgroundNotificationResponse: backgroundHandler,
    );
    final android = self._plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    for (final c in LocalChannel.values) {
      await android?.createNotificationChannel(
        AndroidNotificationChannel(
          c.id,
          c.name,
          description: c.description,
          importance: Importance.high,
        ),
      );
    }
    final launch = await self._plugin.getNotificationAppLaunchDetails();
    final opened = launch?.notificationResponse;
    if (launch?.didNotificationLaunchApp == true && opened != null) {
      // Kept for the shell, which asks once it is up.
      self._launchTap = (payload: opened.payload, actionId: opened.actionId);
    }
    return self;
  }

  /// A bare scheduler for a notification button handled without the app
  /// (another isolate): the phone's zone and the plugin, no handlers.
  static Future<PluginLocalNotifications> forBackground() async {
    final self = PluginLocalNotifications._(FlutterLocalNotificationsPlugin());
    await initLocalTimeZone();
    await self._plugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
    return self;
  }

  @override
  Stream<NotificationTap> get taps => _taps.stream;

  @override
  Future<void> schedule({
    required int id,
    required tz.TZDateTime at,
    required LocalChannel channel,
    required String title,
    required String body,
    String? payload,
    String? iosCategory,
    List<LocalAction> actions = const [],
  }) {
    return _plugin.zonedSchedule(
      id,
      title,
      body,
      at,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          importance: Importance.high,
          priority: Priority.high,
          actions: [
            for (final a in actions)
              AndroidNotificationAction(
                a.id,
                a.label,
                showsUserInterface: a.opensApp,
                cancelNotification: true,
              ),
          ],
        ),
        iOS: DarwinNotificationDetails(categoryIdentifier: iosCategory),
      ),
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  @override
  Future<void> cancel(int id) => _plugin.cancel(id);

  @override
  Future<void> cancelRange(int from, int to) async {
    final pending = await _plugin.pendingNotificationRequests();
    for (final p in pending) {
      if (p.id >= from && p.id <= to) await _plugin.cancel(p.id);
    }
  }
}

/// A scheduler that does nothing: before [localNotificationsProvider] is
/// given the real one, and where notifications aren't available.
class NoLocalNotifications implements LocalNotifications {
  const NoLocalNotifications();

  @override
  Future<void> schedule({
    required int id,
    required tz.TZDateTime at,
    required LocalChannel channel,
    required String title,
    required String body,
    String? payload,
    String? iosCategory,
    List<LocalAction> actions = const [],
  }) async {}

  @override
  Future<void> cancel(int id) async {}

  @override
  Future<void> cancelRange(int from, int to) async {}

  @override
  Stream<NotificationTap> get taps => const Stream.empty();

  @override
  NotificationTap? takeLaunchTap() => null;
}

/// The phone's scheduler. main.dart overrides it with the started plugin;
/// tests override it with a fake.
final localNotificationsProvider = Provider<LocalNotifications>(
  (ref) => const NoLocalNotifications(),
);

/// The phone's zone (IANA name), read again when the app comes back: a
/// phone that travelled plans its reminders in its new zone.
final localZoneProvider = StateProvider<String>((ref) {
  try {
    return tz.local.name;
  } catch (_) {
    return 'UTC';
  }
});
