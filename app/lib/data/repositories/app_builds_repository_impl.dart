import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:nousdeux/domain/app_update.dart';
import 'package:nousdeux/domain/repositories/app_builds_repository.dart';

class AppBuildsRepositoryImpl implements AppBuildsRepository {
  AppBuildsRepositoryImpl([SupabaseClient? client]) : _given = client;

  final SupabaseClient? _given;

  SupabaseClient get _client => _given ?? Supabase.instance.client;

  @override
  Future<PublishedBuild?> published(String platform) async {
    // A read error throws: the screen then keeps its last answer, where
    // "none" would take it away.
    final row = await _client
        .from('app_builds')
        .select('latest_build, min_build, note')
        .eq('platform', platform)
        .maybeSingle();
    return row == null ? null : PublishedBuild.fromRow(row);
  }
}
