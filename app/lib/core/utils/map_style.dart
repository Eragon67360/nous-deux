/// Map styles for the Position screen: OpenFreeMap's free vector tiles, built
/// from OpenStreetMap, with no key and no tracking.
library;

/// Day: a colourful street map. Night: a dark one.
enum MapLook { day, night }

/// The OpenFreeMap style for [look].
String mapStyleUrl(MapLook look) =>
    'https://tiles.openfreemap.org/styles/${look == MapLook.day ? 'liberty' : 'dark'}';

/// Shows place names in [lang] (`fr`, `en`) where OpenStreetMap has one.
///
/// The OpenFreeMap styles label places with their English name (`name_en`)
/// and fall back to the local one. For French, every `["get", "name_en"]` in a
/// label becomes `["get", "name:fr"]`, so a place without a French name keeps
/// its local name. Other labels (road numbers, house numbers) are untouched.
/// Returns a new style; [style] is not modified.
Map<String, dynamic> localizeMapLabels(
  Map<String, dynamic> style,
  String lang,
) {
  if (lang == 'en') return style;
  final key = 'name:$lang';
  final layers = <dynamic>[];
  for (final layer in (style['layers'] as List? ?? const [])) {
    final layout = layer is Map ? layer['layout'] : null;
    if (layout is Map && layout.containsKey('text-field')) {
      layers.add({
        ...layer as Map<String, dynamic>,
        'layout': {
          ...layout as Map<String, dynamic>,
          'text-field': _replaceNameEn(layout['text-field'], key),
        },
      });
    } else {
      layers.add(layer);
    }
  }
  return {...style, 'layers': layers};
}

dynamic _replaceNameEn(dynamic expression, String key) {
  if (expression is List) {
    if (expression.length == 2 &&
        expression[0] == 'get' &&
        expression[1] == 'name_en') {
      return ['get', key];
    }
    return [for (final part in expression) _replaceNameEn(part, key)];
  }
  return expression;
}
