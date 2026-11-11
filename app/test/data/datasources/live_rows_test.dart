import 'package:flutter_test/flutter_test.dart';

import 'package:nousdeux/data/datasources/live_rows.dart';

Row _item(String id, String text, {bool checked = false}) => {
  'id': id,
  'text': text,
  'checked': checked,
};

List<String> _texts(LiveRows live) => [
  for (final r in live.rows) '${r['text']}${r['checked'] == true ? '✓' : ''}',
];

void main() {
  test('a snapshot, then live inserts, updates and deletes', () {
    final live = LiveRows()
      ..startSnapshot()
      ..applySnapshot([_item('1', 'Pain')]);

    expect(live.upsert(_item('2', 'Lait')), isTrue);
    expect(live.upsert(_item('1', 'Pain', checked: true)), isTrue);
    expect(live.delete('2'), isTrue);

    expect(_texts(live), ['Pain✓']);
  });

  test("a delete for a row it doesn't hold changes nothing", () {
    // Deletes are heard for every couple; only ours count.
    final live = LiveRows()
      ..startSnapshot()
      ..applySnapshot([_item('1', 'Pain')]);

    expect(live.delete('other-couple-row'), isFalse);
    expect(_texts(live), ['Pain']);
  });

  test('changes during a load are replayed on top of the snapshot', () {
    final live = LiveRows()..startSnapshot();

    // Heard after subscribing, before the snapshot came back.
    expect(live.upsert(_item('2', 'Lait')), isFalse);
    expect(live.delete('1'), isFalse);
    expect(live.upsert(_item('3', 'Œufs')), isFalse);
    expect(live.upsert(_item('3', 'Œufs', checked: true)), isFalse);

    // The snapshot was read before the delete of 1 and the insert of 3.
    live.applySnapshot([_item('1', 'Pain'), _item('2', 'Lait')]);

    expect(_texts(live), ['Lait', 'Œufs✓']);
  });

  test('a new load drops changes held for the previous one', () {
    final live = LiveRows()
      ..startSnapshot()
      ..applySnapshot([_item('1', 'Pain')]);

    live.startSnapshot();
    live.upsert(
      _item('1', 'Pain', checked: true),
    ); // before the connection dropped
    live.startSnapshot(); // rejoined: this snapshot is newer than that change
    live.applySnapshot([_item('1', 'Pain')]);

    expect(_texts(live), ['Pain']);
  });
}
