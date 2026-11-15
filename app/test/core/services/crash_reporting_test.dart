import 'package:flutter_test/flutter_test.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'package:nousdeux/core/services/crash_reporting.dart';

void main() {
  group('scrubText', () {
    test('drops URL query strings, where filters and keys travel', () {
      expect(
        scrubText(
          'GET https://api.nous-deux.app/rest/v1/profiles?id=eq.42&name=eq.Camille failed',
        ),
        'GET https://api.nous-deux.app/rest/v1/profiles?[query] failed',
      );
      expect(
        scrubText('wss://api.nous-deux.app/realtime/v1/websocket?apikey=abc'),
        'wss://api.nous-deux.app/realtime/v1/websocket?[query]',
      );
    });

    test('redacts tokens, emails, ids, phone numbers and coordinates', () {
      // Shaped like a JWT for the pattern, but not a decodable one, so secret
      // scanners don't flag the fixture.
      expect(
        scrubText('Bearer eyJfakeheader.fakepayload.fakesig expired'),
        'Bearer [token] expired',
      );
      expect(
        scrubText('User camille.martin+test@example.fr already registered'),
        'User [email] already registered',
      );
      expect(
        scrubText(
          'Key (user_id)=(1b4e28ba-2fa1-11d2-883f-0016d3cca427) already exists.',
        ),
        'Key (user_id)=([id]) already exists.',
      );
      expect(
        scrubText('No account for +33 6 12 34 56 78'),
        'No account for [phone]',
      );
      expect(
        scrubText('Bad position 45.774512, 4.829013'),
        'Bad position [number], [number]',
      );
    });

    test('keeps dates, times and short numbers readable', () {
      const text =
          'RenderFlex overflowed by 42.5 pixels on 2026-11-15 at 10:31:29';
      expect(scrubText(text), text);
    });
  });

  group('scrubEvent', () {
    SentryEvent eventWithEverything() => SentryEvent(
      user: SentryUser(id: 'install-id', ipAddress: '1.2.3.4'),
      serverName: 'Camilles-iPhone',
      request: SentryRequest(url: 'https://api.nous-deux.app/rest/v1/notes'),
      exceptions: [
        SentryException(
          type: 'PostgrestException',
          value: 'duplicate key for camille@example.fr',
        ),
      ],
      message: SentryMessage(
        'Failed for camille@example.fr',
        template: 'Failed for %s',
        params: ['camille@example.fr'],
      ),
      contexts:
          Contexts(
              device: SentryDevice.fromJson({
                'id': 'install-id',
                'name': "Camille's iPhone",
                'boot_time': '2026-11-15T08:00:00.000Z',
                'model': 'iPhone17,2',
                'family': 'iOS',
              }),
            )
            ..['flutter_error_details'] = {
              'context': 'thrown while building Text("+33 6 12 34 56 78")',
              'library': 'widgets library',
            },
      breadcrumbs: [
        Breadcrumb(category: 'app.lifecycle', data: {'state': 'resumed'}),
        Breadcrumb(category: 'http', data: {'url': 'https://x?id=1'}),
      ],
    );

    test('removes who the user is and which phone it is', () {
      final event = scrubEvent(eventWithEverything(), Hint())!;

      expect(event.user, isNull);
      expect(event.serverName, isNull);
      expect(event.request, isNull);
      final device = event.contexts.device!.toJson();
      expect(device.containsKey('id'), isFalse);
      expect(device.containsKey('name'), isFalse);
      expect(device.containsKey('boot_time'), isFalse);
      expect(device['model'], 'iPhone17,2');
      expect(device['family'], 'iOS');
    });

    test('scrubs error texts and keeps only lifecycle breadcrumbs', () {
      final event = scrubEvent(eventWithEverything(), Hint())!;

      expect(event.exceptions!.single.value, 'duplicate key for [email]');
      expect(event.message!.formatted, 'Failed for [email]');
      expect(event.message!.params, isNull);
      expect(
        (event.contexts['flutter_error_details'] as Map)['context'],
        'thrown while building Text("[phone]")',
      );
      expect(event.breadcrumbs!.map((b) => b.category), ['app.lifecycle']);
    });
  });

  group('keepBreadcrumb', () {
    test('keeps the app going to the background and back', () {
      final crumb = Breadcrumb(category: 'app.lifecycle');
      expect(keepBreadcrumb(crumb, Hint()), same(crumb));
    });

    test('drops logs, navigation, network and taps', () {
      for (final category in ['console', 'navigation', 'http', 'ui.click']) {
        expect(
          keepBreadcrumb(Breadcrumb(category: category), Hint()),
          isNull,
          reason: category,
        );
      }
      expect(
        keepBreadcrumb(Breadcrumb(message: 'no category'), Hint()),
        isNull,
      );
    });
  });

  test('reporting is off unless the build passes SENTRY_DSN', () {
    expect(isCrashReportingEnabled, isFalse);
  });
}
