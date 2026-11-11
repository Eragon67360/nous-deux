import 'package:flutter_test/flutter_test.dart';

import 'package:nousdeux/domain/entities/shared_list_entity.dart';

ListItemEntity _item(String id, int minute, {bool checked = false}) => ListItemEntity(
  id: id,
  listId: 'l1',
  text: id,
  checked: checked,
  addedBy: 'u1',
  createdAt: DateTime(2026, 11, 10, 18, minute),
);

void main() {
  test('open items first in the order they were added, then ticked ones', () {
    final ordered = orderItems([
      _item('milk', 3, checked: true),
      _item('bread', 2),
      _item('eggs', 5, checked: true),
      _item('tomatoes', 1),
    ]);
    expect(ordered.map((i) => i.id), ['tomatoes', 'bread', 'milk', 'eggs']);
  });

  test('unknown icons fall back to the plain list icon', () {
    expect(ListIcon.fromWire('cart'), ListIcon.cart);
    expect(ListIcon.fromWire('rocket'), ListIcon.list);
    expect(ListIcon.fromWire(null), ListIcon.list);
  });
}
