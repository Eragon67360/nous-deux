import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nousdeux/core/constants/nous_strings.dart';
import 'package:nousdeux/core/constants/period_reminder_prefs.dart';
import 'package:nousdeux/core/l10n/app_languages.dart';
import 'package:nousdeux/domain/entities/ping_entity.dart';
import 'package:nousdeux/domain/nous/note_words.dart';
import 'package:nousdeux/presentation/screens/nous/my_words_screen.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/test_app.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<void> pump(WidgetTester tester, {String lang = 'fr'}) async {
    useTallSurface(tester);
    await pumpScreen(
      tester,
      const MyWordsScreen(),
      deps: TestDeps(myProfile: profile(language: lang)),
    );
  }

  Future<NoteWords> saved() async => NoteWords.decode(
    (await SharedPreferences.getInstance()).getString(noteWordsKey),
  );

  Future<void> addWord(WidgetTester tester, String text) async {
    await tester.enterText(find.byType(TextField), text);
    await tester.tap(find.text(myWordsAdd('fr')));
    await tester.pumpAndSettle();
  }

  bool ticked(WidgetTester tester, String label) => tester
      .widget<Checkbox>(
        find.descendant(
          of: find.ancestor(of: find.text(label), matching: find.byType(Row)),
          matching: find.byType(Checkbox),
        ),
      )
      .value!;

  for (final lang in AppLanguages.supported) {
    testWidgets('[$lang] lists the five notes, all shown', (tester) async {
      await pump(tester, lang: lang);

      expect(find.text(myWordsTitle(lang)), findsOneWidget);
      expect(find.text(myWordsHelp(lang)), findsOneWidget);
      for (final kind in PingKind.presets) {
        expect(find.text(pingLabel(lang, kind)), findsOneWidget);
      }
      expect(
        tester.widgetList<Checkbox>(find.byType(Checkbox)).map((c) => c.value),
        everyElement(isTrue),
      );
    });
  }

  testWidgets('unticking a note hides it from Nous', (tester) async {
    await pump(tester);

    await tester.tap(find.text(pingLabel('fr', PingKind.goodNight)));
    await tester.pumpAndSettle();

    expect(ticked(tester, pingLabel('fr', PingKind.goodNight)), isFalse);
    expect(
      (await saved()).shown,
      isNot(contains(const NoteWord.preset(PingKind.goodNight))),
    );
  });

  testWidgets('words of one\'s own are added, shown while there is room', (
    tester,
  ) async {
    await pump(tester);

    await addWord(tester, 'Courage');
    await addWord(tester, 'Bonne journée');

    expect(ticked(tester, 'Courage'), isTrue);
    expect(ticked(tester, 'Bonne journée'), isFalse);
    expect((await saved()).shown, hasLength(6));

    // A seventh is refused, and said why.
    await tester.tap(find.text('Bonne journée'));
    await tester.pumpAndSettle();
    expect(find.text(myWordsFull('fr')), findsOneWidget);
    expect(ticked(tester, 'Bonne journée'), isFalse);
  });

  testWidgets('the same words are not added twice', (tester) async {
    await pump(tester);

    await addWord(tester, 'Courage');
    await addWord(tester, 'courage ');

    expect(find.text(myWordsAlready('fr')), findsOneWidget);
    expect((await saved()).entries, hasLength(6));
  });

  testWidgets('one\'s own words can be removed, the presets only hidden', (
    tester,
  ) async {
    await pump(tester);
    await addWord(tester, 'Courage');

    expect(find.byTooltip(myWordsRemove('fr', 'Bisou')), findsNothing);
    await tester.tap(find.byTooltip(myWordsRemove('fr', 'Courage')));
    await tester.pumpAndSettle();

    expect(find.text('Courage'), findsNothing);
    expect((await saved()).entries, hasLength(5));
  });

  testWidgets('dragging the handle changes the order', (tester) async {
    await pump(tester);
    final kiss = pingLabel('fr', PingKind.kiss);
    final handle = find.byTooltip(myWordsMove('fr', kiss));
    final first = tester.getCenter(
      find.text(pingLabel('fr', PingKind.thinkingOfYou)),
    );

    final start = tester.getCenter(handle);
    final gesture = await tester.startGesture(start);
    await tester.pump(const Duration(milliseconds: 100));
    // Small steps, like a finger, up past the first note.
    final distance = start.dy - first.dy + 20;
    for (var moved = 0.0; moved < distance; moved += 10) {
      await gesture.moveBy(const Offset(0, -10));
      await tester.pump(const Duration(milliseconds: 16));
    }
    await gesture.up();
    await tester.pumpAndSettle();

    expect((await saved()).shown.first, const NoteWord.preset(PingKind.kiss));
  });
}
