import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:url_launcher/url_launcher.dart';

/// TestFlight on the app's page, then the public beta link when TestFlight
/// isn't installed.
final testFlightLinks = [
  Uri.parse('itms-beta://beta.itunes.apple.com/v1/app/6835108447'),
  Uri.parse('https://testflight.apple.com/join/kScrT3Sk'),
];

/// Google Play on the app's page, then the same page on the web.
final playStoreLinks = [
  Uri.parse('market://details?id=com.nousdeux.android'),
  Uri.parse(
    'https://play.google.com/store/apps/details?id=com.nousdeux.android',
  ),
];

/// Asks Google Play which build it offers this phone: null when none, off
/// Android, or when Play can't answer (an app not installed from Play).
final playUpdateCheckProvider = Provider<Future<int?> Function()>(
  (ref) => () async {
    if (defaultTargetPlatform != TargetPlatform.android) return null;
    try {
      final info = await InAppUpdate.checkForUpdate();
      return info.updateAvailability == UpdateAvailability.updateAvailable
          ? info.availableVersionCode
          : null;
    } catch (_) {
      return null;
    }
  },
);

/// Opens a link in the app that handles it; false when none can.
final openExternalLinkProvider = Provider<Future<bool> Function(Uri)>(
  (ref) => (uri) async {
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  },
);

/// Opens TestFlight or Google Play, trying each link in turn.
Future<bool> openStore(
  Future<bool> Function(Uri) open, {
  required bool isIos,
}) async {
  for (final link in isIos ? testFlightLinks : playStoreLinks) {
    if (await open(link)) return true;
  }
  return false;
}
