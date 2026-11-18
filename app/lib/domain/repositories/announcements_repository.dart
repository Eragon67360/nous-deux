import 'package:nousdeux/domain/entities/announcement_entity.dart';

abstract class AnnouncementsRepository {
  /// Every message the team sent, newest first. Throws when they can't load.
  Future<List<AnnouncementEntity>> sentAnnouncements();
}
