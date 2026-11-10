import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Opens a Supabase Realtime channel by name.
///
/// Read through a provider rather than calling `Supabase.instance.client`
/// directly so widget tests (where Supabase is never initialized) can hand
/// out a fake channel.
final realtimeChannelFactoryProvider =
    Provider<RealtimeChannel Function(String name)>(
      (ref) =>
          (name) => Supabase.instance.client.channel(name),
    );
