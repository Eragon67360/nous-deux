import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nousdeux/domain/entities/announcement_entity.dart';
import 'package:nousdeux/presentation/providers/announcements_provider.dart';
import 'package:nousdeux/presentation/providers/auth_provider.dart';
import 'package:nousdeux/presentation/providers/profile_provider.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/test_app.dart';

AnnouncementEntity message(String id, DateTime sentAt) => AnnouncementEntity(
  id: id,
  sentAt: sentAt,
  texts: {'fr': (title: 'Titre $id', body: 'Texte $id')},
);

final older = message('older', DateTime.utc(2026, 11, 17, 9));
final newer = message('newer', DateTime.utc(2026, 11, 20, 18));

Future<ProviderContainer> _container(TestDeps deps) async {
  final c = ProviderContainer(overrides: deps.overrides);
  addTearDown(c.dispose);
  await c.read(currentUserProvider.future);
  await c.read(myProfileProvider.future);
  return c;
}

TestDeps _deps({DateTime? seenAt, List<AnnouncementEntity>? messages}) =>
    TestDeps(
      myProfile: profile(announcementsSeenAt: seenAt),
      announcements: messages ?? [older, newer],
    );

Future<int> _unread(ProviderContainer c) async {
  await c.read(announcementsProvider.future);
  return c.read(unreadAnnouncementsCountProvider);
}

void main() {
  test('the messages come newest first', () async {
    final c = await _container(_deps(messages: [older, newer]));
    final list = await c.read(announcementsProvider.future);
    expect(list.map((a) => a.id), ['newer', 'older']);
  });

  test('unread: what was sent after the list was last opened', () async {
    expect(
      await _unread(await _container(_deps(seenAt: DateTime.utc(2026, 11, 1)))),
      2,
    );
    expect(
      await _unread(
        await _container(_deps(seenAt: DateTime.utc(2026, 11, 18))),
      ),
      1,
    );
    expect(
      await _unread(
        await _container(_deps(seenAt: DateTime.utc(2026, 11, 21))),
      ),
      0,
    );
  });

  test('nothing is unread without a last-read time', () async {
    expect(await _unread(await _container(_deps())), 0);
  });

  test('nothing is unread when the messages can\'t load', () async {
    final deps = _deps(seenAt: DateTime.utc(2026, 11, 1))
      ..announcements.error = Exception('offline');
    final c = await _container(deps);
    await expectLater(c.read(announcementsProvider.future), throwsException);
    expect(c.read(unreadAnnouncementsCountProvider), 0);
  });

  test(
    'marking read stores the newest message\'s time, not the phone\'s',
    () async {
      final deps = _deps(seenAt: DateTime.utc(2026, 11, 1));
      final c = await _container(deps);
      await c.read(announcementsProvider.future);
      await c.read(markAnnouncementsReadProvider)();
      expect(deps.profiles.seenCalls, [newer.sentAt]);
      // Once the profile has reloaded, nothing is unread.
      await c.read(myProfileProvider.future);
      expect(await _unread(c), 0);
    },
  );

  test('marking read with nothing newer writes nothing', () async {
    final deps = _deps(seenAt: DateTime.utc(2026, 11, 21));
    final c = await _container(deps);
    await c.read(announcementsProvider.future);
    await c.read(markAnnouncementsReadProvider)();
    expect(deps.profiles.seenCalls, isEmpty);
  });
}
