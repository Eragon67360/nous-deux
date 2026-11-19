/// What the update screen knows and decides (docs/UPDATE_SCREEN.md).
library;

/// One platform's row of `app_builds`: the latest build sent to testers,
/// the oldest that still works, and one line on what the latest changes.
class PublishedBuild {
  const PublishedBuild({
    required this.latestBuild,
    required this.minBuild,
    this.note = const {},
  });

  /// A row as the server sends it; anything malformed reads as 0 or empty.
  factory PublishedBuild.fromRow(Map<String, dynamic> row) {
    final rawNote = row['note'];
    return PublishedBuild(
      latestBuild: _int(row['latest_build']),
      minBuild: _int(row['min_build']),
      note: {
        if (rawNote is Map)
          for (final e in rawNote.entries)
            if (e.key is String &&
                e.value is String &&
                (e.value as String).trim().isNotEmpty)
              e.key as String: (e.value as String).trim(),
      },
    );
  }

  final int latestBuild;
  final int minBuild;

  /// Language code → the line.
  final Map<String, String> note;

  static int _int(Object? v) => v is int ? v : (v is num ? v.toInt() : 0);
}

/// The screen to show over the app.
sealed class UpdateOffer {
  const UpdateOffer(this.installed);

  /// The build this phone runs.
  final int installed;
}

/// A newer build is out; « Plus tard » hides it until the next day.
final class UpdateAvailable extends UpdateOffer {
  const UpdateAvailable({
    required int installed,
    required this.latest,
    this.note,
  }) : super(installed);

  final int latest;

  /// The line on what changes, in the app's language; null when unknown.
  final String? note;

  @override
  bool operator ==(Object other) =>
      other is UpdateAvailable &&
      other.installed == installed &&
      other.latest == latest &&
      other.note == note;

  @override
  int get hashCode => Object.hash(installed, latest, note);
}

/// This build no longer works: no « Plus tard ».
final class UpdateRequired extends UpdateOffer {
  const UpdateRequired({required int installed}) : super(installed);

  @override
  bool operator ==(Object other) =>
      other is UpdateRequired && other.installed == installed;

  @override
  int get hashCode => installed.hashCode;
}

/// The day « Plus tard » was tapped, as stored: `2026-11-19`.
String updateDay(DateTime now) =>
    '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

/// What to show, if anything.
///
/// - [installed]: this phone's build, null when unknown (then nothing).
/// - [published]: this platform's row, null when it can't be read.
/// - [playBuild]: on Android, the build Google Play offers this phone.
/// - [laterDay]: the day « Plus tard » was last tapped ([updateDay]).
UpdateOffer? decideUpdate({
  required int? installed,
  required PublishedBuild? published,
  required int? playBuild,
  required bool isIos,
  required String lang,
  required String? laterDay,
  required DateTime now,
}) {
  if (installed == null) return null;
  if (published != null && installed < published.minBuild) {
    return UpdateRequired(installed: installed);
  }
  // iPhone: TestFlight doesn't tell the app, the server does. Android: the
  // Play upload is a draft until it is released, so Play decides.
  final latest = isIos ? published?.latestBuild : playBuild;
  if (latest == null || latest <= installed) return null;
  if (laterDay == updateDay(now)) return null;
  final note = published != null && published.latestBuild == latest
      ? published.note[lang] ?? published.note['en']
      : null;
  return UpdateAvailable(installed: installed, latest: latest, note: note);
}
