import 'package:nousdeux/domain/entities/ping_entity.dart';

/// A row of `couple_pings`.
class PingModel {
  const PingModel({
    required this.coupleId,
    required this.senderId,
    required this.kind,
    required this.sentAt,
  });

  final String coupleId;
  final String senderId;
  final PingKind kind;
  final DateTime sentAt;

  /// Returns null for a kind this app version does not know.
  static PingModel? fromJson(Map<String, dynamic> json) {
    final kind = PingKind.fromWire(json['kind'] as String?);
    if (kind == null) return null;
    return PingModel(
      coupleId: json['couple_id'] as String,
      senderId: json['sender_id'] as String,
      kind: kind,
      sentAt: DateTime.parse(json['sent_at'] as String).toLocal(),
    );
  }

  PingEntity toEntity() => PingEntity(
    coupleId: coupleId,
    senderId: senderId,
    kind: kind,
    sentAt: sentAt,
  );
}
