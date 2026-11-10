import 'package:equatable/equatable.dart';

/// The five little notes one partner can send the other.
enum PingKind {
  thinkingOfYou('thinking_of_you'),
  goodNight('good_night'),
  onMyWay('on_my_way'),
  missYou('miss_you'),
  kiss('kiss');

  const PingKind(this.wire);

  /// The value stored in `couple_pings.kind`.
  final String wire;

  static PingKind? fromWire(String? value) {
    for (final kind in values) {
      if (kind.wire == value) return kind;
    }
    return null;
  }
}

/// The latest little note one person sent. Only one is kept per person.
class PingEntity extends Equatable {
  const PingEntity({
    required this.coupleId,
    required this.senderId,
    required this.kind,
    required this.sentAt,
  });

  final String coupleId;
  final String senderId;
  final PingKind kind;
  final DateTime sentAt;

  @override
  List<Object?> get props => [coupleId, senderId, kind, sentAt];
}
