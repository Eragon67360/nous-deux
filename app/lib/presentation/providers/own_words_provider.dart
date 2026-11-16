import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nousdeux/core/constants/period_reminder_prefs.dart';
import 'package:nousdeux/domain/cycle/own_states.dart';
import 'package:nousdeux/domain/nous/note_words.dart';

/// The notes offered on Nous and one's own saved ones, kept on this phone.
class NoteWordsController extends AsyncNotifier<NoteWords> {
  @override
  Future<NoteWords> build() async {
    final prefs = await SharedPreferences.getInstance();
    return NoteWords.decode(prefs.getString(noteWordsKey));
  }

  NoteWords get _current => state.valueOrNull ?? NoteWords.defaults();

  Future<void> _save(NoteWords words) async {
    state = AsyncData(words);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(noteWordsKey, words.encode());
  }

  /// Shows or hides the note at [index]; false when six already show.
  Future<bool> toggle(int index) async {
    final next = _current.toggle(index);
    if (next == null) return false;
    await _save(next);
    return true;
  }

  Future<void> move(int from, int to) => _save(_current.move(from, to));

  /// Saves words of one's own (see [NoteWords.add]).
  Future<void> add(String text) async {
    final next = _current.add(text);
    if (next != null) await _save(next);
  }

  Future<void> remove(NoteWord word) => _save(_current.remove(word));
}

final noteWordsProvider = AsyncNotifierProvider<NoteWordsController, NoteWords>(
  NoteWordsController.new,
);

/// One's own daily check-in states, kept on this phone.
class OwnStatesController extends AsyncNotifier<OwnStates> {
  @override
  Future<OwnStates> build() async {
    final prefs = await SharedPreferences.getInstance();
    return OwnStates.decode(prefs.getString(ownStatesKey));
  }

  OwnStates get _current => state.valueOrNull ?? const OwnStates([]);

  Future<void> _save(OwnStates states) async {
    state = AsyncData(states);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(ownStatesKey, states.encode());
  }

  Future<void> add(String text) => _save(_current.add(text));

  Future<void> remove(String text) => _save(_current.remove(text));

  /// Forgets them all, with the rest of one's cycle data.
  Future<void> clear() async {
    state = const AsyncData(OwnStates([]));
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(ownStatesKey);
  }
}

final ownStatesProvider = AsyncNotifierProvider<OwnStatesController, OwnStates>(
  OwnStatesController.new,
);
