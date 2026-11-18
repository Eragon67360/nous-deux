import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:nousdeux/core/l10n/l10n.dart';

/// Where « Envoyer un retour » writes: the same address as the website's
/// beta page.
const feedbackEmail = 'thomas-moser@orange.fr';

/// The mail « Envoyer un retour » opens, to [feedbackEmail]. The subject
/// names the build and the kind of phone, so a report says which version
/// it is about; the person writes the rest and sends it from their own mail
/// app. Nothing else goes with it.
Uri feedbackMailUri({
  required String lang,
  required String build,
  required bool isIos,
}) {
  final subject = l10nFor(
    lang,
  ).feedbackSubject(build, isIos ? 'iPhone' : 'Android');
  // Encoded by hand: queryParameters would turn spaces into "+", which some
  // mail apps show as is.
  return Uri.parse(
    'mailto:$feedbackEmail?subject=${Uri.encodeComponent(subject)}',
  );
}

/// This app's build number (pubspec's `+29`).
final appBuildProvider = FutureProvider<String>(
  (ref) async => (await PackageInfo.fromPlatform()).buildNumber,
);

/// Opens a mailto link; false when the phone has no mail app.
final openMailProvider = Provider<Future<bool> Function(Uri)>(
  (ref) => launchUrl,
);
