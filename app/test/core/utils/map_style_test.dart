import 'package:flutter_test/flutter_test.dart';

import 'package:nousdeux/core/utils/map_style.dart';

/// The label expression OpenFreeMap's Liberty and Dark styles use.
const _openFreeMapLabel = [
  'case',
  ['has', 'name:nonlatin'],
  [
    'concat',
    ['get', 'name:latin'],
    '\n',
    ['get', 'name:nonlatin'],
  ],
  [
    'coalesce',
    ['get', 'name_en'],
    ['get', 'name'],
  ],
];

Map<String, dynamic> _style() => {
  'version': 8,
  'name': 'Liberty',
  'layers': [
    {'id': 'background', 'type': 'background'},
    {
      'id': 'label_city',
      'type': 'symbol',
      'layout': {'text-field': _openFreeMapLabel, 'text-size': 14},
    },
    {
      'id': 'road_shield',
      'type': 'symbol',
      'layout': {
        'text-field': [
          'to-string',
          ['get', 'ref'],
        ],
      },
    },
  ],
};

void main() {
  test('the two looks use the OpenFreeMap styles', () {
    expect(
      mapStyleUrl(MapLook.day),
      'https://tiles.openfreemap.org/styles/liberty',
    );
    expect(
      mapStyleUrl(MapLook.night),
      'https://tiles.openfreemap.org/styles/dark',
    );
  });

  test('in French, places use their French name, then their local one', () {
    final layers = localizeMapLabels(_style(), 'fr')['layers'] as List;
    final city = layers[1] as Map;

    expect((city['layout'] as Map)['text-field'], [
      'case',
      ['has', 'name:nonlatin'],
      [
        'concat',
        ['get', 'name:latin'],
        '\n',
        ['get', 'name:nonlatin'],
      ],
      [
        'coalesce',
        ['get', 'name:fr'],
        ['get', 'name'],
      ],
    ]);
    expect((city['layout'] as Map)['text-size'], 14);
  });

  test('road numbers and layers without labels are left alone', () {
    final layers = localizeMapLabels(_style(), 'fr')['layers'] as List;

    expect(layers[0], {'id': 'background', 'type': 'background'});
    expect(((layers[2] as Map)['layout'] as Map)['text-field'], [
      'to-string',
      ['get', 'ref'],
    ]);
  });

  test('English keeps the style as it is', () {
    final style = _style();
    expect(localizeMapLabels(style, 'en'), same(style));
  });

  test('the original style is not modified', () {
    final style = _style();
    localizeMapLabels(style, 'fr');

    final city = (style['layers'] as List)[1] as Map;
    expect(((city['layout'] as Map)['text-field'] as List).last, [
      'coalesce',
      ['get', 'name_en'],
      ['get', 'name'],
    ]);
  });
}
