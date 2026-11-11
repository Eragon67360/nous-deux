import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

typedef Row = Map<String, dynamic>;

/// One couple's rows of a table, from a snapshot plus Realtime changes.
///
/// Changes that arrive while a snapshot loads are held, then replayed on top
/// of it. Each carries the row's full new state (or its id, for a delete),
/// so replaying one the snapshot already includes changes nothing.
class LiveRows {
  final _rows = <String, Row>{};
  List<void Function()>? _held;

  List<Row> get rows => List.unmodifiable(_rows.values);

  /// Starts a new snapshot. Changes held for an earlier one are dropped:
  /// this snapshot is taken later, so it already has them.
  void startSnapshot() => _held = [];

  void applySnapshot(Iterable<Row> snapshot) {
    _rows.clear();
    for (final row in snapshot) {
      final id = row['id'];
      if (id is String) _rows[id] = row;
    }
    final held = _held ?? const [];
    _held = null;
    for (final change in held) {
      change();
    }
  }

  /// Whether [rows] changed (never while a snapshot loads).
  bool upsert(Row row) {
    final id = row['id'];
    if (id is! String) return false;
    if (_held case final held?) {
      held.add(() => _rows[id] = row);
      return false;
    }
    _rows[id] = row;
    return true;
  }

  /// Whether [rows] changed (never while a snapshot loads). Ids this couple
  /// doesn't hold are ignored.
  bool delete(Object? id) {
    if (_held case final held?) {
      held.add(() => _rows.remove(id));
      return false;
    }
    return _rows.remove(id) != null;
  }
}

var _channelSeq = 0;

/// [table] rows for [coupleId], live, deletes included.
///
/// Supabase's `.stream()` filtered by couple never hears about deletes:
/// Realtime can't filter DELETE events (they carry only the primary key), so
/// a filtered subscription drops them. Here inserts and updates are filtered
/// by couple, deletes are heard for the whole table, and only ids held here
/// are removed. Every (re)subscription reloads the snapshot, so a dropped
/// connection catches up.
Stream<List<Row>> watchCoupleRows(
  SupabaseClient client, {
  required String table,
  required String coupleId,
}) {
  final live = LiveRows();
  RealtimeChannel? channel;
  var generation = 0;
  var loaded = false;
  late final StreamController<List<Row>> out;

  // Once rows are on screen, a dropped connection only means a short wait:
  // the client rejoins and reloads. Before that, the error is the answer.
  void fail(Object error, [StackTrace? stack]) {
    if (!loaded && !out.isClosed) out.addError(error, stack);
  }

  void emit() {
    if (!out.isClosed) out.add(live.rows);
  }

  Future<void> load() async {
    final mine = ++generation;
    live.startSnapshot();
    try {
      final data = await client.from(table).select().eq('couple_id', coupleId);
      if (mine != generation) return; // a newer load is on its way
      live.applySnapshot(data);
      loaded = true;
      emit();
    } catch (e, s) {
      if (mine != generation) return;
      live.applySnapshot(live.rows);
      fail(e, s);
    }
  }

  final byCouple = PostgresChangeFilter(
    type: PostgresChangeFilterType.eq,
    column: 'couple_id',
    value: coupleId,
  );

  out = StreamController<List<Row>>(
    onListen: () {
      channel = client
          .channel('$table:$coupleId:${_channelSeq++}')
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: table,
            filter: byCouple,
            callback: (p) {
              if (live.upsert(p.newRecord)) emit();
            },
          )
          .onPostgresChanges(
            event: PostgresChangeEvent.update,
            schema: 'public',
            table: table,
            filter: byCouple,
            callback: (p) {
              if (live.upsert(p.newRecord)) emit();
            },
          )
          .onPostgresChanges(
            event: PostgresChangeEvent.delete,
            schema: 'public',
            table: table,
            callback: (p) {
              if (live.delete(p.oldRecord['id'])) emit();
            },
          )
          .subscribe((status, error) {
            switch (status) {
              case RealtimeSubscribeStatus.subscribed:
                load();
              case RealtimeSubscribeStatus.channelError:
              case RealtimeSubscribeStatus.timedOut:
                fail(error ?? StateError('Realtime: $status'));
              case RealtimeSubscribeStatus.closed:
                break;
            }
          });
    },
    onCancel: () async {
      final open = channel;
      channel = null;
      if (open != null) await client.removeChannel(open);
    },
  );
  return out.stream;
}
