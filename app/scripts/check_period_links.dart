// ignore_for_file: avoid_print
// Link-check script for period verified sources and app info URLs.
// Run from app/: dart run scripts/check_period_links.dart
// Exit code 0 = all non-allowlisted URLs OK; 1 = at least one broken.

import 'dart:io';

/// Built-in allowlist (manual check only; often 403 in CI).
const _builtinAllowlist = ['instagram.com', 'ameli.fr'];

const _timeout = Duration(seconds: 20);

// Matches URLs in Dart string literals (single- or double-quoted).
final _urlRegex = RegExp(
  r'https?://[^\s'
  '"]+',
);

void main(List<String> args) async {
  final root = args.isNotEmpty ? args[0] : '.';
  final allowlistPatterns = _loadAllowlist(root);
  final files = [
    '$root/lib/core/constants/period_verified_sources.dart',
    '$root/lib/presentation/screens/settings/app_info_screen.dart',
  ];

  final urls = <String>{};
  for (final path in files) {
    final file = File(path);
    if (!file.existsSync()) {
      print('Warning: $path not found, skipping.');
      continue;
    }
    final content = file.readAsStringSync();
    for (final m in _urlRegex.allMatches(content)) {
      final url = _normalizeUrl(m.group(0)!);
      if (url != null && !_isPlaceholder(url)) urls.add(url);
    }
  }

  if (urls.isEmpty) {
    print('No URLs found.');
    exit(0);
  }

  final allowlisted = urls
      .where((u) => _isAllowlisted(u, allowlistPatterns))
      .toList();
  final toCheck = urls
      .where((u) => !_isAllowlisted(u, allowlistPatterns))
      .toList();

  for (final u in allowlisted) {
    print('Skipped (allowlist): $u');
  }

  print('Checking ${toCheck.length} URL(s)...');
  final failures = <String>[];
  final client = HttpClient()..connectionTimeout = _timeout;
  try {
    for (final url in toCheck) {
      final problem = await _checkUrl(client, url);
      if (problem == null) {
        print('OK: $url');
      } else {
        print('FAIL ($problem): $url');
        failures.add(url);
      }
    }
  } finally {
    client.close(force: true);
  }

  if (failures.isNotEmpty) {
    print('');
    print('${failures.length} link(s) failed. Fix or allowlist them.');
    exit(1);
  }
  print('');
  print('All links OK.');
  exit(0);
}

String? _normalizeUrl(String s) {
  s = s.trim();
  // Trim trailing quote/punctuation that might have been captured by regex
  while (s.length > 1 &&
      (s.endsWith("'") ||
          s.endsWith('"') ||
          s.endsWith(')') ||
          s.endsWith('.') ||
          s.endsWith(',') ||
          s.endsWith(';'))) {
    s = s.substring(0, s.length - 1);
  }
  return s.isEmpty ? null : s;
}

bool _isPlaceholder(String url) {
  return url.contains('YOUR_PROJECT_REF') ||
      url.contains('supabase.co') && url.contains('YOUR');
}

List<String> _loadAllowlist(String root) {
  final patterns = List<String>.from(_builtinAllowlist);
  final file = File('$root/scripts/linkcheck-allowlist.txt');
  if (file.existsSync()) {
    for (final line in file.readAsLinesSync()) {
      final t = line.trim();
      if (t.isNotEmpty && !t.startsWith('#')) patterns.add(t);
    }
  }
  return patterns;
}

bool _isAllowlisted(String url, List<String> patterns) {
  return patterns.any((p) => url.contains(p));
}

/// Null when the URL answers 2xx, otherwise why it failed.
Future<String?> _checkUrl(HttpClient client, String urlString) async {
  try {
    final uri = Uri.parse(urlString);
    var code = await _status(client.headUrl(uri));
    // Some servers refuse HEAD; ask with GET instead.
    if (code == 405 || code == 501) code = await _status(client.getUrl(uri));
    return code >= 200 && code < 300 ? null : 'HTTP $code';
  } catch (e) {
    return e.runtimeType.toString();
  }
}

Future<int> _status(Future<HttpClientRequest> request) async {
  final opened = await request.timeout(_timeout);
  final response = await opened.close().timeout(_timeout);
  await response.drain<void>();
  return response.statusCode;
}
