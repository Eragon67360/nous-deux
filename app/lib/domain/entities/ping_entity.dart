import 'package:equatable/equatable.dart';

/// What a little note says: one of five preset words, or [custom], a few
/// words of one's own carried in the note's text.
enum PingKind {
  thinkingOfYou('thinking_of_you'),
  goodNight('good_night'),
  onMyWay('on_my_way'),
  missYou('miss_you'),
  kiss('kiss'),
  custom('custom');

  const PingKind(this.wire);

  /// The value stored in `couple_pings.kind`.
  final String wire;

  /// The five preset notes, in the order the app first shows them.
  static const List<PingKind> presets = [
    thinkingOfYou,
    goodNight,
    onMyWay,
    missYou,
    kiss,
  ];

  static PingKind? fromWire(String? value) {
    for (final kind in values) {
      if (kind.wire == value) return kind;
    }
    return null;
  }
}

/// The longest note of one's own, in characters (the database agrees).
const int noteTextMaxLength = 40;

/// The latest little note one person sent. Only one is kept per person.
class PingEntity extends Equatable {
  const PingEntity({
    required this.coupleId,
    required this.senderId,
    required this.kind,
    required this.sentAt,
    this.text,
  }) : assert((kind == PingKind.custom) == (text != null));

  final String coupleId;
  final String senderId;
  final PingKind kind;
  final DateTime sentAt;

  /// The words of a [PingKind.custom] note; null for a preset one.
  final String? text;

  @override
  List<Object?> get props => [coupleId, senderId, kind, sentAt, text];
}
