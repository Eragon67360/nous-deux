import 'package:flutter_test/flutter_test.dart';

import 'package:nousdeux/data/models/period_log_model.dart';

void main() {
  Map<String, dynamic> row({
    Object? start = '2026-03-01',
    Object? end = '2026-03-05',
    Object? symptoms = const ['cramps', 'headache'],
  }) => {
    'id': 'l1',
    'user_id': 'u1',
    'couple_id': 'c1',
    'start_date': start,
    'end_date': end,
    'mood': 'tired',
    'symptoms': symptoms,
    'notes': 'Couch day',
    'created_at': '2026-03-01T08:00:00.000Z',
    'updated_at': '2026-03-02T08:00:00.000Z',
  };

  group('PeriodLogModel.fromJson', () {
    test('reads Postgres DATE columns as local calendar days', () {
      final m = PeriodLogModel.fromJson(row());
      expect(m.startDate, DateTime(2026, 3, 1));
      expect(m.startDate.isUtc, isFalse);
      expect(m.endDate, DateTime(2026, 3, 5));
      expect(m.mood, 'tired');
      expect(m.symptoms, ['cramps', 'headache']);
      expect(m.notes, 'Couch day');
      expect(m.createdAt, DateTime.utc(2026, 3, 1, 8));
      expect(m.updatedAt, DateTime.utc(2026, 3, 2, 8));
    });

    test('reduces full timestamps to the UTC calendar day', () {
      final m = PeriodLogModel.fromJson(
        row(start: '2026-03-01T10:00:00Z', end: '2026-03-05T23:30:00Z'),
      );
      expect(m.startDate, DateTime(2026, 3, 1));
      expect(m.endDate, DateTime(2026, 3, 5));
    });

    test('accepts a null end date and null symptoms', () {
      final m = PeriodLogModel.fromJson(row(end: null, symptoms: null));
      expect(m.endDate, isNull);
      expect(m.symptoms, isEmpty);
    });
  });

  group('PeriodLogModel.toJson', () {
    test('writes dates as YYYY-MM-DD and timestamps as UTC ISO-8601', () {
      final json = PeriodLogModel.fromJson(row()).toJson();
      expect(json, {
        'id': 'l1',
        'user_id': 'u1',
        'couple_id': 'c1',
        'start_date': '2026-03-01',
        'end_date': '2026-03-05',
        'mood': 'tired',
        'symptoms': ['cramps', 'headache'],
        'notes': 'Couch day',
        'created_at': '2026-03-01T08:00:00.000Z',
        'updated_at': '2026-03-02T08:00:00.000Z',
      });
    });

    test(
      'uses the local calendar day of a local date (what the form sends)',
      () {
        final json = PeriodLogModel(
          id: 'l1',
          userId: 'u1',
          coupleId: 'c1',
          startDate: DateTime(2026, 1, 9),
          endDate: null,
        ).toJson();
        expect(json['start_date'], '2026-01-09');
        expect(json['end_date'], isNull);
        expect(json['symptoms'], isEmpty);
      },
    );

    test('round-trips through fromJson', () {
      final json = PeriodLogModel.fromJson(row()).toJson();
      expect(PeriodLogModel.fromJson(json).toJson(), json);
    });
  });

  test('toEntity copies fields and freezes the symptom list', () {
    final e = PeriodLogModel.fromJson(row()).toEntity();
    expect(e.id, 'l1');
    expect(e.userId, 'u1');
    expect(e.coupleId, 'c1');
    expect(e.startDate, DateTime(2026, 3, 1));
    expect(e.endDate, DateTime(2026, 3, 5));
    expect(e.symptoms, ['cramps', 'headache']);
    expect(() => e.symptoms.add('acne'), throwsUnsupportedError);
  });
}
