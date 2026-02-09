import 'package:equatable/equatable.dart';

class CoupleEntity extends Equatable {
  const CoupleEntity({
    required this.id,
    required this.user1Id,
    this.user2Id,
    this.pairingCode,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String user1Id;
  final String? user2Id;
  final String? pairingCode;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isPaired => user2Id != null && user2Id!.isNotEmpty;

  @override
  List<Object?> get props => [id, user1Id, user2Id, pairingCode, createdAt, updatedAt];
}
