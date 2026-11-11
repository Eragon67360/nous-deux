import 'package:equatable/equatable.dart';

/// The icon a list is shown with.
enum ListIcon {
  list,
  cart,
  star,
  home,
  gift;

  static ListIcon fromWire(String? value) =>
      ListIcon.values.firstWhere((i) => i.name == value, orElse: () => ListIcon.list);
}

class SharedListEntity extends Equatable {
  const SharedListEntity({
    required this.id,
    required this.coupleId,
    required this.name,
    required this.icon,
    this.createdBy,
    this.createdAt,
  });

  final String id;
  final String coupleId;
  final String name;
  final ListIcon icon;

  /// Null once its creator's account is deleted.
  final String? createdBy;
  final DateTime? createdAt;

  @override
  List<Object?> get props => [id, coupleId, name, icon, createdBy, createdAt];
}

class ListItemEntity extends Equatable {
  const ListItemEntity({
    required this.id,
    required this.listId,
    required this.text,
    required this.checked,
    required this.addedBy,
    this.createdAt,
  });

  final String id;
  final String listId;
  final String text;
  final bool checked;
  final String addedBy;
  final DateTime? createdAt;

  @override
  List<Object?> get props => [id, listId, text, checked, addedBy, createdAt];
}

/// Items to buy or do first (oldest first), then the ticked ones.
List<ListItemEntity> orderItems(Iterable<ListItemEntity> items) {
  int byDate(ListItemEntity a, ListItemEntity b) {
    final da = a.createdAt, db = b.createdAt;
    if (da == null || db == null) return a.id.compareTo(b.id);
    return da.compareTo(db);
  }

  final open = items.where((i) => !i.checked).toList()..sort(byDate);
  final done = items.where((i) => i.checked).toList()..sort(byDate);
  return [...open, ...done];
}
