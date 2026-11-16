import 'package:nousdeux/domain/entities/ping_entity.dart';

/// A row of `couple_pings`.
class PingModel {
  const PingModel({
    required this.coupleId,
    required this.senderId,
    required this.kind,
    required this.sentAt,
    this.text,
  });

  final String coupleId;
  final String senderId;
  final PingKind kind;
  final DateTime sentAt;
  final String? text;

  /// Returns null for a kind this app version does not know, and for a
  /// note of one's own without its words.
  static PingModel? fromJson(Map<String, dynamic> json) {
    final kind = PingKind.fromWire(json['kind'] as String?);
    if (kind == null) return null;
    final text = (json['text'] as String?)?.trim();
    if (kind == PingKind.custom && (text == null || text.isEmpty)) return null;
    return PingModel(
      coupleId: json['couple_id'] as String,
      senderId: json['sender_id'] as String,
      kind: kind,
      sentAt: DateTime.parse(json['sent_at'] as String).toLocal(),
      text: kind == PingKind.custom ? text : null,
    );
  }

  PingEntity toEntity() => PingEntity(
    coupleId: coupleId,
    senderId: senderId,
    kind: kind,
    sentAt: sentAt,
    text: text,
  );
}
