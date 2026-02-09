import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nous_deux/data/repositories/pairing_repository_impl.dart';
import 'package:nous_deux/domain/entities/couple_entity.dart';
import 'package:nous_deux/domain/repositories/pairing_repository.dart';
import 'package:nous_deux/presentation/providers/auth_provider.dart';

final pairingRepositoryProvider = Provider<PairingRepository>((ref) {
  return PairingRepositoryImpl();
});

/// Current user's couple (if any). Refresh after create/join.
final myCoupleProvider = FutureProvider<CoupleEntity?>((ref) async {
  final user = ref.watch(currentUserProvider).valueOrNull;
  if (user == null) return null;
  final repo = ref.watch(pairingRepositoryProvider);
  final result = await repo.getMyCouple();
  return result.failure != null ? null : result.couple;
});
