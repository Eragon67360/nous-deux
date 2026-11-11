import 'package:nousdeux/core/errors/failures.dart';
import 'package:nousdeux/domain/entities/shared_list_entity.dart';

typedef ListResult = ({SharedListEntity? list, Failure? failure});

abstract class ListsRepository {
  /// The couple's lists, live. Empty when not paired.
  Stream<List<SharedListEntity>> watchLists();

  /// Every item of every list of the couple, live.
  Stream<List<ListItemEntity>> watchItems();

  Future<ListResult> createList({required String name, required ListIcon icon});
  Future<Failure?> renameList(String listId, String name);
  Future<Failure?> deleteList(String listId);

  Future<Failure?> addItem(String listId, String text);
  Future<Failure?> setChecked(String itemId, bool checked);
  Future<Failure?> deleteItem(String itemId);

  /// Removes every ticked item of the list.
  Future<Failure?> clearChecked(String listId);
}
