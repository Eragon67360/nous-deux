import 'dart:convert';

import 'package:equatable/equatable.dart';

import 'package:nousdeux/core/utils/short_text.dart';

/// The longest state of one's own, in characters (the database agrees).
const int ownStateMaxLength = 30;

/// The most states one day's check-in holds (the database agrees).
const int checkinMaxStates = 12;

/// States one wrote in the daily check-in ("Besoin de chocolat"), offered
/// again the next days. Kept on this phone only, oldest first.
class OwnStates extends Equatable {
  const OwnStates(this.items);

  /// Reads what [encode] wrote; anything unreadable gives none.
  factory OwnStates.decode(String? source) {
    if (source == null) return const OwnStates([]);
    try {
      final raw = jsonDecode(source) as List<Object?>;
      var states = const OwnStates([]);
      for (final item in raw.whereType<String>()) {
        states = states.add(item);
      }
      return states;
    } catch (_) {
      return const OwnStates([]);
    }
  }

  /// How many are kept; adding more forgets the oldest.
  static const int maxSaved = 20;

  final List<String> items;

  String encode() => jsonEncode(items);

  /// Adds [text] once cleaned, unless it is empty or already there
  /// (whatever the case).
  OwnStates add(String text) {
    final clean = cleanStateText(text);
    if (clean.isEmpty || contains(clean)) return this;
    final list = [...items, clean];
    return OwnStates(
      list.length > maxSaved ? list.sublist(list.length - maxSaved) : list,
    );
  }

  OwnStates remove(String text) => OwnStates([
    for (final item in items)
      if (item.toLowerCase() != text.toLowerCase()) item,
  ]);

  bool contains(String text) =>
      items.any((item) => item.toLowerCase() == text.toLowerCase());

  @override
  List<Object?> get props => [items];
}

/// [text] as a state of one's own is stored (see [cleanShortText]).
String cleanStateText(String text) =>
    cleanShortText(text, maxLength: ownStateMaxLength);
