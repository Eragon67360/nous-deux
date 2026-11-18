import 'package:flutter_test/flutter_test.dart';

import 'package:nousdeux/data/models/announcement_model.dart';

void main() {
  final row = <String, dynamic>{
    'id': 'a1',
    'sent_at': '2026-11-20T17:30:00.000Z',
    'content': {
      'fr': {'title': 'Les listes partagées sont là', 'body': 'Courses.'},
      'en': {'title': 'Shared lists are here', 'body': 'Groceries.'},
    },
  };

  test('a row becomes a message with its texts per language', () {
    final a = announcementFromRow(row)!;
    expect(a.id, 'a1');
    expect(a.sentAt, DateTime.utc(2026, 11, 20, 17, 30));
    expect(a.textFor('fr'), (
      title: 'Les listes partagées sont là',
      body: 'Courses.',
    ));
    expect(a.textFor('en').title, 'Shared lists are here');
  });

  test('a language the message lacks reads in English', () {
    expect(
      announcementFromRow(row)!.textFor('es').title,
      'Shared lists are here',
    );
  });

  test('without English, the first language there is', () {
    final a = announcementFromRow({
      ...row,
      'content': {
        'fr': {'title': 'Merci', 'body': 'Chaque retour compte.'},
      },
    })!;
    expect(a.textFor('es').title, 'Merci');
  });

  test('a language with a missing title or body is left out', () {
    final a = announcementFromRow({
      ...row,
      'content': {
        'fr': {'title': 'Merci'},
        'en': {'title': 'Thanks', 'body': 'Every bit of feedback counts.'},
      },
    })!;
    expect(a.textFor('fr').title, 'Thanks');
  });

  test('a row with no usable text, or not sent, is no message', () {
    expect(
      announcementFromRow({...row, 'content': <String, dynamic>{}}),
      isNull,
    );
    expect(announcementFromRow({...row, 'content': 'oops'}), isNull);
    expect(announcementFromRow({...row, 'sent_at': null}), isNull);
  });
}
