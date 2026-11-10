import 'package:flutter_test/flutter_test.dart';

import 'package:nousdeux/data/models/calendar_event_model.dart';

void main() {
  final fullJson = <String, dynamic>{
    'id': 'e1',
    'couple_id': 'c1',
    'title': 'Dîner',
    'description': 'Chez Paul',
    'start_time': '2026-03-14T19:30:00.000Z',
    'end_time': '2026-03-14T22:00:00.000Z',
    'created_by': 'u1',
    'created_at': '2026-03-01T08:00:00.000Z',
    'updated_at': '2026-03-02T08:00:00.000Z',
  };

  group('CalendarEventModel.fromJson', () {
    test('reads every column', () {
      final m = CalendarEventModel.fromJson(fullJson);
      expect(m.id, 'e1');
      expect(m.coupleId, 'c1');
      expect(m.title, 'Dîner');
      expect(m.description, 'Chez Paul');
      expect(m.startTime, DateTime.utc(2026, 3, 14, 19, 30));
      expect(m.endTime, DateTime.utc(2026, 3, 14, 22));
      expect(m.createdBy, 'u1');
      expect(m.createdAt, DateTime.utc(2026, 3, 1, 8));
      expect(m.updatedAt, DateTime.utc(2026, 3, 2, 8));
    });

    test('accepts null optional columns', () {
      final m = CalendarEventModel.fromJson({
        'id': 'e1',
        'couple_id': 'c1',
        'title': 'Dîner',
        'description': null,
        'start_time': '2026-03-14T19:30:00Z',
        'end_time': null,
        'created_by': 'u1',
      });
      expect(m.description, isNull);
      expect(m.endTime, isNull);
      expect(m.createdAt, isNull);
      expect(m.updatedAt, isNull);
    });

    test('keeps Postgres timestamptz offsets as the same instant', () {
      final m = CalendarEventModel.fromJson({
        ...fullJson,
        'start_time': '2026-03-14T20:30:00+01:00',
      });
      expect(
        m.startTime.isAtSameMomentAs(DateTime.utc(2026, 3, 14, 19, 30)),
        isTrue,
      );
    });
  });

  test('toJson writes snake_case ISO-8601 columns and round-trips', () {
    final m = CalendarEventModel.fromJson(fullJson);
    final json = m.toJson();
    expect(json, {
      'id': 'e1',
      'couple_id': 'c1',
      'title': 'Dîner',
      'description': 'Chez Paul',
      'start_time': '2026-03-14T19:30:00.000Z',
      'end_time': '2026-03-14T22:00:00.000Z',
      'created_by': 'u1',
      'created_at': '2026-03-01T08:00:00.000Z',
      'updated_at': '2026-03-02T08:00:00.000Z',
    });
    expect(CalendarEventModel.fromJson(json).toJson(), json);
  });

  test('toJson writes nulls for missing optional values', () {
    final json = CalendarEventModel(
      id: 'e1',
      coupleId: 'c1',
      title: 'T',
      startTime: DateTime.utc(2026),
      createdBy: 'u1',
    ).toJson();
    expect(json['description'], isNull);
    expect(json['end_time'], isNull);
    expect(json['created_at'], isNull);
    expect(json['updated_at'], isNull);
  });

  test('toEntity copies every field', () {
    final e = CalendarEventModel.fromJson(fullJson).toEntity();
    expect(e.id, 'e1');
    expect(e.coupleId, 'c1');
    expect(e.title, 'Dîner');
    expect(e.description, 'Chez Paul');
    expect(e.startTime, DateTime.utc(2026, 3, 14, 19, 30));
    expect(e.endTime, DateTime.utc(2026, 3, 14, 22));
    expect(e.createdBy, 'u1');
    expect(e.createdAt, DateTime.utc(2026, 3, 1, 8));
    expect(e.updatedAt, DateTime.utc(2026, 3, 2, 8));
  });
}
