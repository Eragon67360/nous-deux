import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nousdeux/core/constants/news_strings.dart';
import 'package:nousdeux/domain/entities/announcement_entity.dart';
import 'package:nousdeux/presentation/screens/settings/announcements_screen.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/test_app.dart';

final _older = AnnouncementEntity(
  id: 'older',
  sentAt: DateTime.utc(2026, 11, 17, 9),
  texts: {
    'fr': (title: 'Nous Deux parle anglais', body: 'Paramètres › Langue.'),
    'en': (title: 'Nous Deux speaks English', body: 'Settings › Language.'),
  },
);
final _newer = AnnouncementEntity(
  id: 'newer',
  sentAt: DateTime.utc(2026, 11, 20, 18),
  texts: {
    'fr': (title: 'Les listes partagées sont là', body: 'Courses, sorties.'),
    'en': (title: 'Shared lists are here', body: 'Groceries, date ideas.'),
  },
);

TestDeps _deps({
  String lang = 'fr',
  List<AnnouncementEntity>? messages,
  DateTime? seenAt,
}) => TestDeps(
  myProfile: profile(
    language: lang,
    announcementsSeenAt: seenAt ?? DateTime.utc(2026, 11, 18),
  ),
  announcements: messages ?? [_older, _newer],
);

void main() {
  testWidgets('lists the messages newest first, in the profile language', (
    tester,
  ) async {
    await pumpScreen(tester, const AnnouncementsScreen(), deps: _deps());

    expect(find.text(newsTitle('fr')), findsOneWidget);
    final newer = find.text('Les listes partagées sont là');
    final older = find.text('Nous Deux parle anglais');
    expect(newer, findsOneWidget);
    expect(older, findsOneWidget);
    expect(tester.getTopLeft(newer).dy, lessThan(tester.getTopLeft(older).dy));
    expect(find.text('Courses, sorties.'), findsOneWidget);
    expect(find.text(newsSignature('fr')), findsNWidgets(2));
    expect(find.text('20 NOV.'), findsOneWidget);
    expect(find.text('17 NOV.'), findsOneWidget);
  });

  testWidgets('in English, with the English texts', (tester) async {
    await pumpScreen(
      tester,
      const AnnouncementsScreen(),
      deps: _deps(lang: 'en'),
      locale: 'en',
    );

    expect(find.text(newsTitle('en')), findsOneWidget);
    expect(find.text('Shared lists are here'), findsOneWidget);
    expect(find.text(newsSignature('en')), findsNWidgets(2));
  });

  testWidgets('a dot marks what was unread when the list opened, '
      'and opening marks it read', (tester) async {
    final deps = _deps();
    await pumpScreen(tester, const AnnouncementsScreen(), deps: deps);

    expect(find.byKey(const ValueKey('unread-newer')), findsOneWidget);
    expect(find.byKey(const ValueKey('unread-older')), findsNothing);
    expect(deps.profiles.seenCalls, [_newer.sentAt]);

    // The dot stays while the list is open, though it's read now.
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('unread-newer')), findsOneWidget);
    expect(deps.profiles.seenCalls, hasLength(1));
  });

  testWidgets('nothing new: no dot and nothing written', (tester) async {
    final deps = _deps(seenAt: DateTime.utc(2026, 11, 21));
    await pumpScreen(tester, const AnnouncementsScreen(), deps: deps);

    expect(find.byKey(const ValueKey('unread-newer')), findsNothing);
    expect(deps.profiles.seenCalls, isEmpty);
  });

  testWidgets('no message yet', (tester) async {
    await pumpScreen(
      tester,
      const AnnouncementsScreen(),
      deps: _deps(messages: const []),
    );

    expect(find.text(newsEmpty('fr')), findsOneWidget);
  });

  testWidgets('messages that can\'t load say so', (tester) async {
    final deps = _deps()..announcements.error = Exception('offline');
    await pumpScreen(tester, const AnnouncementsScreen(), deps: deps);

    expect(find.text(newsLoadFailed('fr')), findsOneWidget);
    expect(deps.profiles.seenCalls, isEmpty);
  });
}
