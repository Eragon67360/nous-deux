import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:nousdeux/core/errors/failures.dart';
import 'package:nousdeux/data/datasources/lists_remote_datasource.dart';
import 'package:nousdeux/data/datasources/pairing_remote_datasource.dart';
import 'package:nousdeux/domain/entities/shared_list_entity.dart';
import 'package:nousdeux/domain/repositories/lists_repository.dart';

class ListsRepositoryImpl implements ListsRepository {
  ListsRepositoryImpl({
    ListsRemoteDatasource? lists,
    PairingRemoteDatasource? pairing,
  }) : _lists = lists ?? ListsRemoteDatasource(),
       _pairing = pairing ?? PairingRemoteDatasource();

  final ListsRemoteDatasource _lists;
  final PairingRemoteDatasource _pairing;

  Future<String?> _pairedCoupleId() async {
    final couple = await _pairing.getMyCouple();
    if (couple == null || couple.user2Id == null) return null;
    return couple.id;
  }

  @override
  Stream<List<SharedListEntity>> watchLists() async* {
    final coupleId = await _pairedCoupleId();
    if (coupleId == null) {
      yield const [];
      return;
    }
    yield* _lists.watchLists(coupleId);
  }

  @override
  Stream<List<ListItemEntity>> watchItems() async* {
    final coupleId = await _pairedCoupleId();
    if (coupleId == null) {
      yield const [];
      return;
    }
    yield* _lists.watchItems(coupleId);
  }

  @override
  Future<ListResult> createList({
    required String name,
    required ListIcon icon,
  }) async {
    try {
      final coupleId = await _pairedCoupleId();
      if (coupleId == null) {
        return (list: null, failure: const NotFoundFailure('Not paired'));
      }
      final list = await _lists.createList(
        coupleId: coupleId,
        name: name.trim(),
        icon: icon,
      );
      return (list: list, failure: null);
    } catch (e) {
      return (list: null, failure: _failure(e));
    }
  }

  @override
  Future<Failure?> renameList(String listId, String name) =>
      _guard(() => _lists.renameList(listId, name.trim()));

  @override
  Future<Failure?> deleteList(String listId) =>
      _guard(() => _lists.deleteList(listId));

  @override
  Future<Failure?> addItem(String listId, String text) => _guard(() async {
    final coupleId = await _pairedCoupleId();
    if (coupleId == null) throw const NotFoundFailure('Not paired');
    await _lists.addItem(coupleId: coupleId, listId: listId, text: text.trim());
  });

  @override
  Future<Failure?> setChecked(String itemId, bool checked) =>
      _guard(() => _lists.setChecked(itemId, checked));

  @override
  Future<Failure?> deleteItem(String itemId) =>
      _guard(() => _lists.deleteItem(itemId));

  @override
  Future<Failure?> clearChecked(String listId) =>
      _guard(() => _lists.clearChecked(listId));

  Future<Failure?> _guard(Future<void> Function() action) async {
    try {
      await action();
      return null;
    } catch (e) {
      return _failure(e);
    }
  }

  Failure _failure(Object e) => switch (e) {
    Failure f => f,
    PostgrestException(:final message) => ServerFailure(message),
    _ => UnknownFailure(e.toString()),
  };
}
