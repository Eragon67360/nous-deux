// Placeholder for Period Guide analytics. Replace with real analytics (e.g. Firebase, Mixpanel)
// when ready. Used for: section views, external link clicks, feedback, learning path completion.

import 'package:nousdeux/core/constants/period_guide_sections.dart';
import 'package:nousdeux/core/constants/period_verified_sources.dart';

/// No-op analytics for the Period Guide. Replace implementation to track:
/// - Guide tab open rate, time spent in Guide
/// - Section visibility / scroll depth
/// - External source click-through per source
/// - "Was this useful?" feedback
/// - Learning path completion
abstract final class PeriodGuideAnalytics {
  PeriodGuideAnalytics._();

  /// Call when user scrolls to or opens a section (e.g. via TOC tap).
  static void recordSectionView(PeriodGuideSection section) {
    // TODO: send to analytics backend
  }

  /// Call when user taps an external "Learn more" link.
  static void recordExternalLinkClick(VerifiedSource source) {
    // TODO: send to analytics backend
  }

  /// Call when user submits "Was this useful?" (thumbs up/down).
  static void recordGuideFeedback({required bool useful, String? comment}) {
    // TODO: send to analytics backend
  }

  /// Call when user completes the learning path (all sections read).
  static void recordLearningPathCompleted() {
    // TODO: send to analytics backend
  }
}
