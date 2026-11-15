import 'dart:async';

import 'package:sentry_flutter/sentry_flutter.dart';

import 'package:nousdeux/core/constants/app_constants.dart';

/// Crash and error reports, sent to the self-hosted GlitchTip
/// (`infra/glitchtip/`) when the build passes `--dart-define=SENTRY_DSN=…`.
/// Without it, the default for local builds, nothing is set up or sent.
bool get isCrashReportingEnabled => AppConstants.sentryDsn.isNotEmpty;

/// Runs [appRunner] with crash reporting when it is enabled, so errors
/// thrown while the app starts are reported too.
Future<void> runWithCrashReporting(FutureOr<void> Function() appRunner) async {
  if (!isCrashReportingEnabled) {
    await appRunner();
    return;
  }
  await SentryFlutter.init(_configure, appRunner: appRunner);
}

/// A report holds the error, its stack trace, the app version and the
/// phone's model, system, language and time zone. It never says who the user
/// is: no account id, phone number, email, IP address or location, no
/// screenshot, and no trail of what they did beyond the app going to the
/// background and back. The privacy policy describes the same contents.
void _configure(SentryFlutterOptions options) {
  options
    ..dsn = AppConstants.sentryDsn
    ..sendDefaultPii = false
    ..attachScreenshot = false
    ..attachViewHierarchy = false
    // Session tracking sends a per-install id with every app start.
    ..enableAutoSessionTracking = false
    // Debug logs and native taps, screens and system events could carry
    // personal data; only lifecycle breadcrumbs are kept.
    ..enablePrintBreadcrumbs = false
    ..enableAutoNativeBreadcrumbs = false
    ..enableAppLifecycleBreadcrumbs = true
    ..beforeBreadcrumb = keepBreadcrumb
    ..beforeSend = scrubEvent;
}

const _keptBreadcrumbCategories = {'app.lifecycle'};

/// Keeps only breadcrumbs that can't hold personal data.
Breadcrumb? keepBreadcrumb(Breadcrumb? breadcrumb, Hint hint) =>
    _keptBreadcrumbCategories.contains(breadcrumb?.category)
    ? breadcrumb
    : null;

/// Removes who the user is from an event and scrubs its error texts.
///
/// Native SDKs fill in a random installation id as the user and device id,
/// and the device's name; they are dropped here. This runs for every error
/// raised in Dart. Crashes inside native code are sent by the native SDK
/// without passing through here; GlitchTip filters their ids and boot time
/// on arrival (`infra/glitchtip/compose.yml`).
SentryEvent? scrubEvent(SentryEvent event, Hint hint) {
  event
    ..user = null
    ..request = null
    ..serverName = null;

  final device = event.contexts.device;
  if (device != null) {
    event.contexts.device = SentryDevice.fromJson(
      device.toJson()
        ..remove('id')
        ..remove('name')
        ..remove('boot_time'),
    );
  }

  for (final exception in event.exceptions ?? const <SentryException>[]) {
    final value = exception.value;
    if (value != null) exception.value = scrubText(value);
  }

  final message = event.message;
  if (message != null) {
    message
      ..formatted = scrubText(message.formatted)
      ..template = null
      ..params = null;
  }

  final details = event.contexts['flutter_error_details'];
  if (details is Map) {
    event.contexts['flutter_error_details'] = {
      for (final entry in details.entries)
        entry.key: entry.value is String
            ? scrubText(entry.value as String)
            : entry.value,
    };
  }

  event.breadcrumbs = event.breadcrumbs
      ?.where((b) => keepBreadcrumb(b, hint) != null)
      .toList();
  return event;
}

final _urlQuery = RegExp(r'((?:https?|wss?)://[^\s?#"]+)\?[^\s#"]+');
final _redactions = [
  (RegExp(r'eyJ[\w-]+\.[\w-]+\.[\w-]*'), '[token]'),
  (RegExp(r'[\w.+-]+@[\w-]+(?:\.[\w-]+)+'), '[email]'),
  (RegExp(r'\b[0-9a-fA-F]{8}-(?:[0-9a-fA-F]{4}-){3}[0-9a-fA-F]{12}\b'), '[id]'),
  (RegExp(r'\+\d[\d .-]{6,}\d'), '[phone]'),
  // Coordinates, and any other number with four or more decimals.
  (RegExp(r'-?\b\d{1,3}\.\d{4,}\b'), '[number]'),
];

/// Redacts what an error text may carry about a person: URL query strings,
/// tokens, emails, database ids, phone numbers and coordinates.
String scrubText(String text) {
  var scrubbed = text.replaceAllMapped(_urlQuery, (m) => '${m[1]}?[query]');
  for (final (pattern, replacement) in _redactions) {
    scrubbed = scrubbed.replaceAll(pattern, replacement);
  }
  return scrubbed;
}
