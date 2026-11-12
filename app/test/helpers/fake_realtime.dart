import 'package:supabase_flutter/supabase_flutter.dart';

/// Hands out [FakeRealtimeChannel]s in place of Supabase Realtime.
/// Plug [open] into `realtimeChannelFactoryProvider`.
class FakeRealtime {
  final channels = <FakeRealtimeChannel>[];

  RealtimeChannel open(String name) {
    final channel = FakeRealtimeChannel(name);
    channels.add(channel);
    return channel;
  }

  FakeRealtimeChannel named(String name) =>
      channels.lastWhere((c) => c.name == name);
}

/// Records what a widget subscribed to and lets the test push a change.
class FakeRealtimeChannel implements RealtimeChannel {
  FakeRealtimeChannel(this.name);

  final String name;
  PostgresChangeEvent? event;
  String? table;
  PostgresChangeFilter? filter;
  void Function(PostgresChangePayload payload)? _callback;
  bool subscribed = false;
  bool unsubscribed = false;

  @override
  RealtimeChannel onPostgresChanges({
    required PostgresChangeEvent event,
    String? schema,
    String? table,
    PostgresChangeFilter? filter,
    required void Function(PostgresChangePayload payload) callback,
  }) {
    this.event = event;
    this.table = table;
    this.filter = filter;
    _callback = callback;
    return this;
  }

  @override
  RealtimeChannel subscribe([
    void Function(RealtimeSubscribeStatus status, Object? error)? callback,
    Duration? timeout,
  ]) {
    subscribed = true;
    return this;
  }

  @override
  Future<String> unsubscribe([Duration? timeout]) async {
    unsubscribed = true;
    return 'ok';
  }

  /// Delivers an UPDATE with [newRecord] to the subscribed callback.
  void emitUpdate(Map<String, dynamic> newRecord) {
    _callback!(
      PostgresChangePayload(
        schema: 'public',
        table: table ?? '',
        commitTimestamp: DateTime.utc(2026, 1, 1),
        eventType: PostgresChangeEvent.update,
        newRecord: newRecord,
        oldRecord: const {},
        errors: null,
      ),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
