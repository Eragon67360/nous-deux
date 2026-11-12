import 'package:nousdeux/core/utils/date_only.dart';
import 'package:nousdeux/domain/entities/couple_entity.dart';

class CoupleModel {
  CoupleModel({
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
  final DateTime? togetherSince;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory CoupleModel.fromJson(Map<String, dynamic> json) {
    return CoupleModel(
      id: json['id'] as String,
      user1Id: json['user1_id'] as String,
      user2Id: json['user2_id'] as String?,
      pairingCode: json['pairing_code'] as String?,
      togetherSince: json['together_since'] == null
          ? null
          : parseDay(json['together_since'] as Object),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  CoupleEntity toEntity() {
    return CoupleEntity(
      id: id,
      user1Id: user1Id,
      user2Id: user2Id,
      pairingCode: pairingCode,
      togetherSince: togetherSince,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
