import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nousdeux/core/constants/guide_chapters.dart';
import 'package:nousdeux/core/constants/period_reminder_prefs.dart';

/// Guide chapters opened on this device.
final guideReadProvider =
    AsyncNotifierProvider<GuideReadNotifier, Set<GuideChapter>>(
      GuideReadNotifier.new,
    );

class GuideReadNotifier extends AsyncNotifier<Set<GuideChapter>> {
  @override
  Future<Set<GuideChapter>> build() async {
    final prefs = await SharedPreferences.getInstance();
    final names = prefs.getStringList(guideReadChaptersKey) ?? const [];
    return {
      for (final c in GuideChapter.values)
        if (names.contains(c.name)) c,
    };
  }

  Future<void> markRead(GuideChapter chapter) async {
    final read = await future;
    if (read.contains(chapter)) return;
    final next = {...read, chapter};
    state = AsyncData(next);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(guideReadChaptersKey, [
      for (final c in next) c.name,
    ]);
  }
}
