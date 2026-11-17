/// What the guide says in one language: the title of each chapter.
///
/// Each language is one file (`guide_en.dart`, `guide_fr.dart`, …) holding a
/// const [GuideText], listed in `guideTexts` (guide_chapters.dart). A language
/// that leaves out a title doesn't compile.
class GuideText {
  const GuideText({
    required this.cycleTitle,
    required this.bodyMindTitle,
    required this.supportTitle,
    required this.talkingTitle,
    required this.mythsTitle,
    required this.faqTitle,
    required this.sourcesTitle,
  });

  final String cycleTitle;
  final String bodyMindTitle;
  final String supportTitle;
  final String talkingTitle;
  final String mythsTitle;
  final String faqTitle;
  final String sourcesTitle;
}
