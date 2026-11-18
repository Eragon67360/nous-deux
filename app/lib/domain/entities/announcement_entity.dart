import 'package:equatable/equatable.dart';

/// A message's title and body in one language.
typedef AnnouncementTexts = ({String title, String body});

/// A message from the team to everyone, listed in Paramètres › Nouveautés
/// (docs/NOUVEAUTES.md).
class AnnouncementEntity extends Equatable {
  /// [texts] holds at least one language.
  const AnnouncementEntity({
    required this.id,
    required this.sentAt,
    required this.texts,
  });

  final String id;
  final DateTime sentAt;

  /// Title and body per language code.
  final Map<String, AnnouncementTexts> texts;

  /// The texts in [lang], else in English, else in the first language there is.
  AnnouncementTexts textFor(String lang) =>
      texts[lang] ?? texts['en'] ?? texts.values.first;

  @override
  List<Object?> get props => [id, sentAt, texts];
}
