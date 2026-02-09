import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:nous_deux/core/errors/failures.dart';
import 'package:nous_deux/data/datasources/calendar_remote_datasource.dart';
import 'package:nous_deux/data/datasources/pairing_remote_datasource.dart';
import 'package:nous_deux/domain/entities/calendar_event_entity.dart';
import 'package:nous_deux/domain/repositories/calendar_repository.dart';

class CalendarRepositoryImpl implements CalendarRepository {
  CalendarRepositoryImpl({
    CalendarRemoteDatasource? calendarDs,
    PairingRemoteDatasource? pairingDs,
  })  : _calendar = calendarDs ?? CalendarRemoteDatasource(),
        _pairing = pairingDs ?? PairingRemoteDatasource();

  final CalendarRemoteDatasource _calendar;
  final PairingRemoteDatasource _pairing;

  Future<String?> _getCoupleId() async {
    final couple = await _pairing.getMyCouple();
    return couple?.id;
  }

  @override
  Stream<List<CalendarEventEntity>> watchEvents() async* {
    final coupleId = await _getCoupleId();
    if (coupleId == null) {
      yield [];
      return;
    }
    yield* _calendar.watchEvents(coupleId).map((list) => list.map((e) => e.toEntity()).toList());
  }

  @override
  Future<CalendarEventsResult> getEvents({
    required DateTime start,
    required DateTime end,
  }) async {
    try {
      final coupleId = await _getCoupleId();
      if (coupleId == null) {
        return (events: <CalendarEventEntity>[], failure: null);
      }
      final list = await _calendar.getEvents(coupleId: coupleId, start: start, end: end);
      return (events: list.map((e) => e.toEntity()).toList(), failure: null);
    } on PostgrestException catch (e) {
      return (events: <CalendarEventEntity>[], failure: ServerFailure(e.message));
    } catch (e) {
      return (events: <CalendarEventEntity>[], failure: UnknownFailure(e.toString()));
    }
  }

  @override
  Future<CalendarEventResult> createEvent({
    required String title,
    String? description,
    required DateTime startTime,
    DateTime? endTime,
  }) async {
    try {
      final coupleId = await _getCoupleId();
      if (coupleId == null) return (event: null, failure: const AuthFailure('No couple'));
      final model = await _calendar.create(
        coupleId: coupleId,
        title: title,
        description: description,
        startTime: startTime,
        endTime: endTime,
      );
      return (event: model.toEntity(), failure: null);
    } on PostgrestException catch (e) {
      return (event: null, failure: ServerFailure(e.message));
    } catch (e) {
      return (event: null, failure: UnknownFailure(e.toString()));
    }
  }

  @override
  Future<CalendarEventResult> updateEvent({
    required String id,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    try {
      final model = await _calendar.update(
        id: id,
        title: title,
        description: description,
        startTime: startTime,
        endTime: endTime,
      );
      return (event: model.toEntity(), failure: null);
    } on PostgrestException catch (e) {
      return (event: null, failure: ServerFailure(e.message));
    } catch (e) {
      return (event: null, failure: UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Failure?> deleteEvent(String id) async {
    try {
      await _calendar.delete(id);
      return null;
    } on PostgrestException catch (e) {
      return ServerFailure(e.message);
    } catch (e) {
      return UnknownFailure(e.toString());
    }
  }
}
