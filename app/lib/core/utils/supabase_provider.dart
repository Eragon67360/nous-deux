import 'package:supabase_flutter/supabase_flutter.dart';

/// Provides the Supabase client for dependency injection.
/// Call [Supabase.initialize] in main() before using.
SupabaseClient get supabaseClient => Supabase.instance.client;
