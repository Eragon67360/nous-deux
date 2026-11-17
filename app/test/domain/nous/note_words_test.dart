import 'package:flutter_test/flutter_test.dart';

import 'package:nousdeux/domain/entities/ping_entity.dart';
import 'package:nousdeux/domain/nous/note_words.dart';

void main() {
  const kiss = NoteWord.preset(PingKind.kiss);

  test('a new phone shows the five presets, in order', () {
    final words = NoteWords.defaults();
    expect(words.shown, [
      for (final kind in PingKind.presets) NoteWord.preset(kind),
    ]);
    expect(NoteWords.decode(null), words);
  });

  test('what is saved reads back the same', () {
    final words = NoteWords.defaults()
        .add('Bonne journée')!
        .toggle(1)!
        .move(5, 0);
    expect(NoteWords.decode(words.encode()), words);
    expect(words.shown.first, const NoteWord.own('Bonne journée'));
    expect(
      words.shown,
      isNot(contains(const NoteWord.preset(PingKind.goodNight))),
    );
  });

  test('unreadable storage gives the defaults; missing presets come back', () {
    expect(NoteWords.decode('not json'), NoteWords.defaults());
    expect(NoteWords.decode('{"a":1}'), NoteWords.defaults());

    final words = NoteWords.decode(
      '[{"t":"Courage","on":true},{"k":"kiss","on":false},{"k":"hug","on":true}]',
    );
    expect(words.entries.first, (
      word: const NoteWord.own('Courage'),
      shown: true,
    ));
    expect(words.entries[1], (word: kiss, shown: false));
    // Every preset is there exactly once; the unknown "hug" is dropped.
    for (final kind in PingKind.presets) {
      expect(words.entries.where((e) => e.word.kind == kind), hasLength(1));
    }
    expect(words.entries, hasLength(6));
  });

  test('six notes show at most', () {
    var words = NoteWords.defaults().add('Un')!;
    expect(words.shown, hasLength(6));

    words = words.add('Deux')!;
    expect(words.shown, hasLength(6));
    expect(words.entries.last, (
      word: const NoteWord.own('Deux'),
      shown: false,
    ));
    expect(words.toggle(words.entries.length - 1), isNull);

    words = words.toggle(0)!.toggle(words.entries.length - 1)!;
    expect(words.shown, hasLength(6));
    expect(words.shown.last, const NoteWord.own('Deux'));
  });

  test('words are cleaned, kept once whatever the case, never empty', () {
    final words = NoteWords.defaults().toggle(0)!.add('  Bonne\n journée  ')!;
    expect(words.entries.last.word, const NoteWord.own('Bonne journée'));
    expect(words.contains('BONNE JOURNÉE'), isTrue);
    expect(words.add('bonne journée'), words);
    expect(NoteWords.defaults().add('   '), isNull);
  });

  test('saving words that are hidden shows them again', () {
    final hidden = NoteWords.defaults().toggle(0)!.add('Courage')!.toggle(5)!;
    expect(hidden.shown, isNot(contains(const NoteWord.own('Courage'))));
    expect(
      hidden.add('courage')!.shown,
      contains(const NoteWord.own('Courage')),
    );
  });

  test('one can remove words of one\'s own, not a preset', () {
    final words = NoteWords.defaults().toggle(0)!.add('Courage')!;
    expect(words.remove(const NoteWord.own('courage')).entries, hasLength(5));
    expect(words.remove(kiss), words);
  });

  test('a move counts the target before the move, like the list widget', () {
    final words = NoteWords.defaults();
    expect(words.move(0, 2).shown.take(2).map((w) => w.kind), [
      PingKind.goodNight,
      PingKind.thinkingOfYou,
    ]);
    expect(words.move(4, 0).shown.first.kind, PingKind.kiss);
  });

  test('a note is at most 40 characters, counted like the database', () {
    expect(cleanNoteText('a' * 45), 'a' * 40);
    // 41 code points: the last emoji is cut, never half of it.
    final emoji = '${'a' * 39}😘😘';
    expect(cleanNoteText(emoji).runes.length, 40);
    expect(cleanNoteText('Bisou\u0000 doux'), 'Bisou doux');
  });
}
