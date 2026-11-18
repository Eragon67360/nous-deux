import 'package:flutter_test/flutter_test.dart';

import 'package:nousdeux/core/services/fcm_service.dart';
import 'package:nousdeux/domain/entities/ping_entity.dart';

void main() {
  test('waits until Apple hands out the push token', () async {
    final answers = [null, null, 'apns'];
    var calls = 0;
    final ready = await waitForApnsToken(
      () async => answers[calls++],
      interval: Duration.zero,
    );
    expect(ready, isTrue);
    expect(calls, 3);
  });

  test('gives up after the last try', () async {
    var calls = 0;
    final ready = await waitForApnsToken(
      () async {
        calls++;
        return null;
      },
      tries: 4,
      interval: Duration.zero,
    );
    expect(ready, isFalse);
    expect(calls, 4);
  });

  group('the note a tapped push announces', () {
    test('reads the kind and time notify-partner-ping sends', () {
      final note = openedNoteFrom({
        'type': 'ping',
        'kind': 'miss_you',
        'sent_at': '2026-11-16T18:30:00+00:00',
      });
      expect(note?.kind, PingKind.missYou);
      expect(note?.sentAt, DateTime.utc(2026, 11, 16, 18, 30).toLocal());
    });

    test('ignores other pushes, unknown kinds and broken times', () {
      expect(openedNoteFrom({'type': 'period'}), isNull);
      expect(
        openedNoteFrom({
          'type': 'ping',
          'kind': 'hug',
          'sent_at': '2026-11-16',
        }),
        isNull,
      );
      expect(
        openedNoteFrom({'type': 'ping', 'kind': 'kiss', 'sent_at': 'soon'}),
        isNull,
      );
      expect(openedNoteFrom(const {}), isNull);
    });
  });

  group('what a tapped push opens', () {
    test('a message from the team opens Nouveautés', () {
      final push = openedPushFrom({'type': 'announcement', 'id': 'a1'});
      expect(push, isA<OpenedAnnouncementPush>());
      expect((push as OpenedAnnouncementPush).id, 'a1');
    });

    test('a little note still opens the note', () {
      final push = openedPushFrom({
        'type': 'ping',
        'kind': 'kiss',
        'sent_at': '2026-11-16T18:30:00+00:00',
      });
      expect(push, isA<OpenedNotePush>());
      expect((push as OpenedNotePush).note.kind, PingKind.kiss);
    });

    test('anything else opens nothing', () {
      expect(openedPushFrom({'type': 'period'}), isNull);
      expect(openedPushFrom({'type': 'calendar_sync'}), isNull);
      expect(openedPushFrom(const {}), isNull);
    });
  });
}
