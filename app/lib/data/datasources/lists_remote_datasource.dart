import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:nousdeux/data/datasources/live_rows.dart';
import 'package:nousdeux/domain/entities/shared_list_entity.dart';

class ListsRemoteDatasource {
  ListsRemoteDatasource([SupabaseClient? client])
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;
  static const _lists = 'shared_lists';
  static const _items = 'shared_list_items';

  /// The couple's lists, oldest first, live (deletes included).
  Stream<List<SharedListEntity>> watchLists(String coupleId) {
    return watchCoupleRows(
      _client,
      table: _lists,
      coupleId: coupleId,
    ).map((rows) => rows.map(listFromJson).toList()..sort(_oldestFirst));
  }

  /// Every item of the couple's lists, live (deletes included).
  Stream<List<ListItemEntity>> watchItems(String coupleId) {
    return watchCoupleRows(
      _client,
      table: _items,
      coupleId: coupleId,
    ).map((rows) => rows.map(itemFromJson).toList());
  }

  static int _oldestFirst(SharedListEntity a, SharedListEntity b) {
    final da = a.createdAt, db = b.createdAt;
    if (da == null || db == null) return a.id.compareTo(b.id);
    return da.compareTo(db);
  }

  /// `created_by` is set by the database from the signed-in user.
  Future<SharedListEntity> createList({
    required String coupleId,
    required String name,
    required ListIcon icon,
  }) async {
    final res = await _client
        .from(_lists)
        .insert({'couple_id': coupleId, 'name': name, 'icon': icon.name})
        .select()
        .single();
    return listFromJson(Map<String, dynamic>.from(res));
  }

  Future<void> renameList(String listId, String name) =>
      _client.from(_lists).update({'name': name}).eq('id', listId);

  Future<void> deleteList(String listId) =>
      _client.from(_lists).delete().eq('id', listId);

  /// `couple_id` and `added_by` are filled in by the database.
  Future<void> addItem({
    required String coupleId,
    required String listId,
    required String text,
  }) => _client.from(_items).insert({
    'list_id': listId,
    'couple_id': coupleId,
    'text': text,
  });

  Future<void> setChecked(String itemId, bool checked) =>
      _client.from(_items).update({'checked': checked}).eq('id', itemId);

  Future<void> deleteItem(String itemId) =>
      _client.from(_items).delete().eq('id', itemId);

  Future<void> clearChecked(String listId) =>
      _client.from(_items).delete().eq('list_id', listId).eq('checked', true);

  static SharedListEntity listFromJson(Map<String, dynamic> json) =>
      SharedListEntity(
        id: json['id'] as String,
        coupleId: json['couple_id'] as String,
        name: json['name'] as String,
        icon: ListIcon.fromWire(json['icon'] as String?),
        createdBy: json['created_by'] as String?,
        createdAt: json['created_at'] == null
            ? null
            : DateTime.parse(json['created_at'] as String),
      );

  static ListItemEntity itemFromJson(Map<String, dynamic> json) =>
      ListItemEntity(
        id: json['id'] as String,
        listId: json['list_id'] as String,
        text: json['text'] as String,
        checked: json['checked'] as bool? ?? false,
        addedBy: json['added_by'] as String,
        createdAt: json['created_at'] == null
            ? null
            : DateTime.parse(json['created_at'] as String),
      );
}
