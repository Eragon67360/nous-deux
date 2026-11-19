import 'package:nousdeux/domain/app_update.dart';

/// The update screen's row for one platform (`app_builds`).
abstract class AppBuildsRepository {
  /// [platform] is `ios` or `android`. Null when it can't be read (signed
  /// out, no network, an error).
  Future<PublishedBuild?> published(String platform);
}
