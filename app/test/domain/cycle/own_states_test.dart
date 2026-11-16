import 'package:flutter_test/flutter_test.dart';

import 'package:nousdeux/domain/cycle/own_states.dart';

void main() {
  test('states are cleaned, kept once whatever the case, and read back', () {
    final states = const OwnStates([])
        .add('  Besoin de\nchocolat ')
        .add('besoin de chocolat')
        .add('')
        .add('Jambes lourdes');
    expect(states.items, ['Besoin de chocolat', 'Jambes lourdes']);
    expect(OwnStates.decode(states.encode()), states);
    expect(states.contains('JAMBES LOURDES'), isTrue);
  });

  test('a state is at most 30 characters', () {
    expect(const OwnStates([]).add('x' * 35).items.single, 'x' * 30);
  });

  test('removing ignores the case', () {
    final states = const OwnStates(['Besoin de chocolat']);
    expect(states.remove('besoin de CHOCOLAT').items, isEmpty);
  });

  test('the oldest are forgotten past twenty', () {
    var states = const OwnStates([]);
    for (var i = 0; i < 22; i++) {
      states = states.add('État $i');
    }
    expect(states.items, hasLength(OwnStates.maxSaved));
    expect(states.items.first, 'État 2');
    expect(states.items.last, 'État 21');
  });

  test('unreadable storage gives none', () {
    expect(OwnStates.decode(null).items, isEmpty);
    expect(OwnStates.decode('{').items, isEmpty);
    expect(OwnStates.decode('[1, "Fatigue"]').items, ['Fatigue']);
  });
}
