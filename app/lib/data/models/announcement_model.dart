import 'package:nousdeux/domain/entities/announcement_entity.dart';

/// A row of `announcements` (`id, content, sent_at`) as a message, or null
/// when it has no send time or no language with both a title and a body.
AnnouncementEntity? announcementFromRow(Map<String, dynamic> row) {
  final sentAt = DateTime.tryParse(row['sent_at'] as String? ?? '');
  final content = row['content'];
  if (sentAt == null || content is! Map) return null;
  final texts = <String, AnnouncementTexts>{};
  for (final MapEntry(:key, :value) in content.entries) {
    if (key is! String || value is! Map) continue;
    final title = value['title'];
    final body = value['body'];
    if (title is String && body is String) {
      texts[key] = (title: title, body: body);
    }
  }
  if (texts.isEmpty) return null;
  return AnnouncementEntity(
    id: row['id'] as String,
    sentAt: sentAt,
    texts: texts,
  );
}
