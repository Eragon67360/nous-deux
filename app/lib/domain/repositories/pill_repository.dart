import 'package:nousdeux/core/errors/failures.dart';
import 'package:nousdeux/domain/entities/pill_entities.dart';

abstract class PillRepository {
  /// My settings, or null when I don't track a pill.
  Future<PillSettings?> mySettings();

  /// Starts tracking (the database records the consent) or changes it.
  Future<Failure?> saveSettings(PillSettings settings);

  /// My days from [from] on.
  Future<List<PillIntake>> myIntakes({required DateTime from});

  Future<Failure?> markTaken(DateTime day, DateTime at);

  Future<Failure?> markMissed(DateTime day);

  /// Forgets what was noted for [day].
  Future<Failure?> unmark(DateTime day);

  /// « Arrêter le suivi »: deletes my settings and history.
  Future<Failure?> stopTracking();

  /// What my partner shares about [day]'s pill.
  Future<PartnerPillToday> partnerToday(DateTime day);
}
