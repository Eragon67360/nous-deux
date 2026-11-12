import 'package:nousdeux/core/errors/failures.dart';
import 'package:nousdeux/domain/entities/cycle_checkin_entity.dart';

/// Daily check-ins and private notes for the Règles tab.
abstract class CycleRepository {
  /// Check-ins of the current couple the caller may read (theirs, and the
  /// partner's while shared), live.
  Stream<List<CycleCheckinEntity>> watchCheckins();

  /// Saves the caller's check-in for [day]. Nothing checked removes it.
  Future<Failure?> saveCheckin({
    required DateTime day,
    required List<String> symptoms,
    String? mood,
  });

  /// The caller's private note for [day].
  Future<String?> noteFor(DateTime day);

  /// Saves the caller's private note for [day]; blank removes it.
  Future<Failure?> saveNote(DateTime day, String note);

  /// Deletes all of the caller's cycle data (period dates, check-ins,
  /// notes): withdrawing consent.
  Future<Failure?> deleteAllMyData();
}
