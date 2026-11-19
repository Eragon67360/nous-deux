import 'package:nousdeux/domain/app_update.dart';

/// The update screen's row for one platform (`app_builds`).
abstract class AppBuildsRepository {
  /// [platform] is `ios` or `android`. Null when there is no row; a read
  /// that fails (no network, signed out) throws.
  Future<PublishedBuild?> published(String platform);
}
