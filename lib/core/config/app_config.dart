import 'package:nous_deux/core/constants/app_constants.dart';
import 'package:nous_deux/core/config/supabase_keys.dart' as keys;

/// Runtime Supabase configuration.
///
/// Priority:
/// 1. --dart-define=SUPABASE_URL=...,SUPABASE_ANON_KEY=... (CI/production)
/// 2. Local [supabase_keys.dart] (edit for local dev; only put the anon/publishable key there)
///
/// Use only the **anon (publishable)** key in this app. The **service_role (secret)** key
/// must never be in the client — use it only in Supabase Dashboard, Edge Functions, or a backend.
class AppConfig {
  AppConfig._();

  static String get supabaseUrl {
    const fromEnv = AppConstants.supabaseUrl;
    if (fromEnv.isNotEmpty) return fromEnv;
    return keys.supabaseUrlLocal;
  }

  static String get supabaseAnonKey {
    const fromEnv = AppConstants.supabaseAnonKey;
    if (fromEnv.isNotEmpty) return fromEnv;
    return keys.supabaseAnonKeyLocal;
  }

  static bool get isSupabaseConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
