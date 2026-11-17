import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:nousdeux/core/l10n/app_languages.dart';

Map<String, dynamic> _arb(String lang) =>
    jsonDecode(File('lib/l10n/app_$lang.arb').readAsStringSync())
        as Map<String, dynamic>;

Set<String> _keys(Map<String, dynamic> arb) => {
  for (final key in arb.keys)
    if (!key.startsWith('@')) key,
};

void main() {
  final english = _arb('en');

  for (final lang in AppLanguages.supported) {
    test('$lang has every message and uses its placeholders', () {
      final arb = _arb(lang);

      expect(_keys(arb), _keys(english));
      // The template (English) declares each message's placeholders; every
      // language must use each one, as `{name}` or as `{name, plural, …}`.
      final missing = [
        for (final key in _keys(english))
          for (final name
              in ((english['@$key'] as Map?)?['placeholders'] as Map?)?.keys ??
                  const <String>[])
            if (!RegExp('\\{$name[,}]').hasMatch(arb[key] as String))
              '$key: {$name}',
      ];
      expect(missing, isEmpty);
    });
  }
}
