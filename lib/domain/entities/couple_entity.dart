import 'package:equatable/equatable.dart';

class CoupleEntity extends Equatable {
  const CoupleEntity({
    required this.id,
    required this.user1Id,
    this.user2Id,
    this.pairingCode,
    this.togetherSince,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String user1Id;
  final String? user2Id;
  final String? pairingCode;

  /// Start of the relationship (a calendar day). Null until paired.
  final DateTime? togetherSince;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isPaired => user2Id != null && user2Id!.isNotEmpty;

  @override
  List<Object?> get props => [
    id,
    user1Id,
    user2Id,
    pairingCode,
    togetherSince,
    createdAt,
    updatedAt,
  ];
}
