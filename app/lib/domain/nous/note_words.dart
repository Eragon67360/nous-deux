import 'dart:convert';

import 'package:equatable/equatable.dart';

import 'package:nousdeux/core/utils/short_text.dart';
import 'package:nousdeux/domain/entities/ping_entity.dart';

/// One note that can be offered on Nous: a preset, or words of one's own.
class NoteWord extends Equatable {
  const NoteWord.preset(this.kind)
    : assert(kind != PingKind.custom),
      text = null;
  const NoteWord.own(String this.text) : kind = PingKind.custom;

  final PingKind kind;

  /// The words of one's own note; null for a preset.
  final String? text;

  bool get isOwn => kind == PingKind.custom;

  @override
  List<Object?> get props => [kind, text];
}

/// A [NoteWord] and whether it shows on Nous.
typedef NoteWordEntry = ({NoteWord word, bool shown});

/// The notes offered on Nous, in order, and one's own saved ones, which
/// live on this phone only. Every preset is always in the list, shown or
/// not; at most [maxShown] notes show at once.
class NoteWords extends Equatable {
  const NoteWords(this.entries);

  /// The five presets, all shown, as on a new phone.
  factory NoteWords.defaults() => NoteWords([
    for (final kind in PingKind.presets)
      (word: NoteWord.preset(kind), shown: true),
  ]);

  /// Reads what [encode] wrote. Anything unreadable gives the defaults; a
  /// preset missing from the saved list comes back at the end.
  factory NoteWords.decode(String? source) {
    if (source == null) return NoteWords.defaults();
    final List<Object?> raw;
    try {
      raw = jsonDecode(source) as List<Object?>;
    } catch (_) {
      return NoteWords.defaults();
    }
    final entries = <NoteWordEntry>[];
    for (final item in raw.whereType<Map<String, Object?>>()) {
      final shown = item['on'] == true;
      final text = cleanNoteText(item['t'] as String? ?? '');
      final kind = PingKind.fromWire(item['k'] as String?);
      final NoteWord? word = text.isNotEmpty
          ? NoteWord.own(text)
          : (kind != null && kind != PingKind.custom)
          ? NoteWord.preset(kind)
          : null;
      if (word == null || entries.any((e) => _same(e.word, word))) continue;
      entries.add((word: word, shown: shown));
    }
    var words = NoteWords(entries);
    for (final kind in PingKind.presets) {
      if (!entries.any((e) => e.word.kind == kind)) {
        words = NoteWords([
          ...words.entries,
          (word: NoteWord.preset(kind), shown: words.hasRoom),
        ]);
      }
    }
    return words;
  }

  static const int maxShown = 6;

  final List<NoteWordEntry> entries;

  /// The notes to show on Nous, in order.
  List<NoteWord> get shown => [
    for (final e in entries)
      if (e.shown) e.word,
  ];

  bool get hasRoom => shown.length < maxShown;

  String encode() => jsonEncode([
    for (final e in entries)
      {
        if (e.word.isOwn) 't': e.word.text else 'k': e.word.kind.wire,
        'on': e.shown,
      },
  ]);

  /// Shows or hides the note at [index]. Null when showing it would go
  /// past [maxShown].
  NoteWords? toggle(int index) {
    final entry = entries[index];
    if (!entry.shown && !hasRoom) return null;
    return NoteWords([
      for (final (i, e) in entries.indexed)
        i == index ? (word: e.word, shown: !e.shown) : e,
    ]);
  }

  /// Moves the note at [from] to [to], [to] counted before the move (as
  /// ReorderableListView reports it).
  NoteWords move(int from, int to) {
    final list = [...entries];
    final item = list.removeAt(from);
    list.insert(to > from ? to - 1 : to, item);
    return NoteWords(list);
  }

  /// Adds words of one's own at the end, shown when there is room, or
  /// shows them if they are already saved. Null when [text] is empty once
  /// cleaned. Words already saved (whatever the case) are not added twice.
  NoteWords? add(String text) {
    final clean = cleanNoteText(text);
    if (clean.isEmpty) return null;
    final word = NoteWord.own(clean);
    final at = entries.indexWhere((e) => _same(e.word, word));
    if (at >= 0) {
      final existing = entries[at];
      if (existing.shown || !hasRoom) return this;
      return toggle(at);
    }
    return NoteWords([...entries, (word: word, shown: hasRoom)]);
  }

  /// Whether [text] is already one of the saved words.
  bool contains(String text) {
    final word = NoteWord.own(cleanNoteText(text));
    return entries.any((e) => _same(e.word, word));
  }

  /// Removes words of one's own; presets stay (hide them instead).
  NoteWords remove(NoteWord word) {
    if (!word.isOwn) return this;
    return NoteWords([
      for (final e in entries)
        if (!_same(e.word, word)) e,
    ]);
  }

  static bool _same(NoteWord a, NoteWord b) => a.isOwn && b.isOwn
      ? a.text!.toLowerCase() == b.text!.toLowerCase()
      : a == b;

  @override
  List<Object?> get props => [entries];
}

/// [text] as a note can carry it (see [cleanShortText]).
String cleanNoteText(String text) =>
    cleanShortText(text, maxLength: noteTextMaxLength);
