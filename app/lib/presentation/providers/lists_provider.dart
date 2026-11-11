import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nousdeux/data/repositories/lists_repository_impl.dart';
import 'package:nousdeux/domain/entities/shared_list_entity.dart';
import 'package:nousdeux/domain/repositories/lists_repository.dart';
import 'package:nousdeux/presentation/providers/pairing_provider.dart';

final listsRepositoryProvider = Provider<ListsRepository>((ref) {
  return ListsRepositoryImpl();
});

/// The couple's lists, oldest first, live.
final sharedListsProvider = StreamProvider<List<SharedListEntity>>((ref) {
  final couple = ref.watch(myCoupleProvider).valueOrNull;
  if (couple == null || !couple.isPaired) return Stream.value(const []);
  return ref.watch(listsRepositoryProvider).watchLists();
});

/// Every item of every list, live.
final allListItemsProvider = StreamProvider<List<ListItemEntity>>((ref) {
  final couple = ref.watch(myCoupleProvider).valueOrNull;
  if (couple == null || !couple.isPaired) return Stream.value(const []);
  return ref.watch(listsRepositoryProvider).watchItems();
});

/// One list's items: open ones first, then the ticked ones.
final listItemsProvider = Provider.family<List<ListItemEntity>, String>((
  ref,
  listId,
) {
  final items = ref.watch(allListItemsProvider).valueOrNull ?? const [];
  return orderItems(items.where((i) => i.listId == listId));
});

/// How many items are left and how many there are in total.
final listCountsProvider = Provider.family<({int open, int total}), String>((
  ref,
  listId,
) {
  final items = ref.watch(listItemsProvider(listId));
  return (open: items.where((i) => !i.checked).length, total: items.length);
});
