import 'package:flutter_test/flutter_test.dart';

import 'package:nousdeux/domain/app_update.dart';

const _note = {'fr': 'Le suivi de la pilule.', 'en': 'Pill tracking.'};
final _now = DateTime(2026, 11, 19, 9);

UpdateOffer? decide({
  int? installed = 29,
  PublishedBuild? published = const PublishedBuild(
    latestBuild: 30,
    minBuild: 0,
    note: _note,
  ),
  int? playBuild,
  bool isIos = true,
  String lang = 'fr',
  String? laterDay,
  DateTime? now,
}) => decideUpdate(
  installed: installed,
  published: published,
  playBuild: playBuild,
  isIos: isIos,
  lang: lang,
  laterDay: laterDay,
  now: now ?? _now,
);

void main() {
  group('iPhone', () {
    test('a newer build on the server is offered, with its line', () {
      expect(
        decide(),
        const UpdateAvailable(
          installed: 29,
          latest: 30,
          note: 'Le suivi de la pilule.',
        ),
      );
    });

    test('up to date, or ahead of the server: nothing', () {
      expect(decide(installed: 30), isNull);
      expect(decide(installed: 31), isNull);
    });

    test('Play is not asked', () {
      expect(decide(installed: 30, playBuild: 40), isNull);
    });

    test('no row (no network): nothing', () {
      expect(decide(published: null), isNull);
    });
  });

  group('Android', () {
    test('Play decides, whatever the server says', () {
      expect(decide(isIos: false, playBuild: null), isNull);
      expect(decide(isIos: false, playBuild: 29), isNull);
      expect(
        decide(
          isIos: false,
          playBuild: 31,
          published: const PublishedBuild(latestBuild: 29, minBuild: 0),
        ),
        const UpdateAvailable(installed: 29, latest: 31),
      );
    });

    test('the line only when the row describes the build Play offers', () {
      expect(
        decide(isIos: false, playBuild: 30),
        const UpdateAvailable(
          installed: 29,
          latest: 30,
          note: 'Le suivi de la pilule.',
        ),
      );
      expect(
        decide(isIos: false, playBuild: 31),
        const UpdateAvailable(installed: 29, latest: 31),
      );
    });
  });

  test('an unknown installed build: nothing, not even the minimum', () {
    expect(
      decide(
        installed: null,
        published: const PublishedBuild(latestBuild: 40, minBuild: 40),
      ),
      isNull,
    );
  });

  test('older than the minimum: required, even after « Plus tard »', () {
    const published = PublishedBuild(latestBuild: 31, minBuild: 30);
    expect(
      decide(published: published, laterDay: '2026-11-19'),
      const UpdateRequired(installed: 29),
    );
    expect(
      decide(isIos: false, playBuild: null, published: published),
      const UpdateRequired(installed: 29),
    );
    expect(decide(installed: 30, published: published), isA<UpdateAvailable>());
  });

  test('« Plus tard » hides it for the day, the next day it is back', () {
    expect(decide(laterDay: '2026-11-19'), isNull);
    expect(decide(laterDay: '2026-11-18'), isA<UpdateAvailable>());
    expect(
      decide(laterDay: '2026-11-19', now: DateTime(2026, 11, 20, 0, 1)),
      isA<UpdateAvailable>(),
    );
  });

  test('the line in the app language, else English, else none', () {
    expect((decide(lang: 'en') as UpdateAvailable).note, 'Pill tracking.');
    expect((decide(lang: 'es') as UpdateAvailable).note, 'Pill tracking.');
    expect(
      (decide(
                published: const PublishedBuild(
                  latestBuild: 30,
                  minBuild: 0,
                  note: {'fr': 'Seulement en français.'},
                ),
                lang: 'es',
              )
              as UpdateAvailable)
          .note,
      isNull,
    );
  });

  test('a malformed row reads as nothing to offer', () {
    final row = PublishedBuild.fromRow({
      'latest_build': '30',
      'min_build': null,
      'note': {'fr': 3, 'en': '  ', 'de': 'Neu.'},
    });
    expect(row.latestBuild, 0);
    expect(row.minBuild, 0);
    expect(row.note, {'de': 'Neu.'});
    expect(PublishedBuild.fromRow({'note': 'une ligne'}).note, isEmpty);
  });
}
