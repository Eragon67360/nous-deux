import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:nousdeux/data/models/announcement_model.dart';
import 'package:nousdeux/domain/entities/announcement_entity.dart';
import 'package:nousdeux/domain/repositories/announcements_repository.dart';

class AnnouncementsRepositoryImpl implements AnnouncementsRepository {
  @override
  Future<List<AnnouncementEntity>> sentAnnouncements() async {
    // The database only answers sent messages (RLS); drafts never reach here.
    final rows = await Supabase.instance.client
        .from('announcements')
        .select('id, content, sent_at')
        .order('sent_at', ascending: false);
    return [for (final row in rows) ?announcementFromRow(row)];
  }
}
