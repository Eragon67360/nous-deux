import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:nousdeux/domain/app_update.dart';
import 'package:nousdeux/domain/repositories/app_builds_repository.dart';

class AppBuildsRepositoryImpl implements AppBuildsRepository {
  @override
  Future<PublishedBuild?> published(String platform) async {
    try {
      final row = await Supabase.instance.client
          .from('app_builds')
          .select('latest_build, min_build, note')
          .eq('platform', platform)
          .maybeSingle();
      return row == null ? null : PublishedBuild.fromRow(row);
    } catch (_) {
      // Best effort: no screen rather than a wrong one.
      return null;
    }
  }
}
