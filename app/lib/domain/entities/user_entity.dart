import 'package:equatable/equatable.dart';

/// Represents the currently authenticated user (from Supabase Auth).
class UserEntity extends Equatable {
  const UserEntity({
    required this.id,
    this.phone,
    this.email,
  });

  final String id;
  final String? phone;
  final String? email;

  @override
  List<Object?> get props => [id, phone, email];
}
