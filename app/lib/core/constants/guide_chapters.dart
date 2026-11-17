import 'package:nousdeux/core/constants/content/guide_en.dart';
import 'package:nousdeux/core/constants/content/guide_fr.dart';
import 'package:nousdeux/core/constants/content/guide_text.dart';
import 'package:nousdeux/core/constants/period_education.dart';
import 'package:nousdeux/core/constants/period_verified_sources.dart';
import 'package:nousdeux/core/l10n/app_languages.dart';

/// The guide's chapters, in reading order.
enum GuideChapter { cycle, bodyMind, support, talking, myths, faq, sources }

/// The guide in each language the app speaks, by language code. A new
/// language adds its file here (test/l10n/content_completeness_test.dart
/// checks every language in [AppLanguages.supported] has one).
const Map<String, GuideText> guideTexts = {'fr': guideFr, 'en': guideEn};

/// The guide in [lang], or in English when [lang] has no guide file.
GuideText guideTextFor(String lang) =>
    guideTexts[lang] ?? guideTexts[AppLanguages.fallback]!;

String guideChapterTitle(GuideChapter chapter, String lang) {
  final text = guideTextFor(lang);
  return switch (chapter) {
    GuideChapter.cycle => text.cycleTitle,
    GuideChapter.bodyMind => text.bodyMindTitle,
    GuideChapter.support => text.supportTitle,
    GuideChapter.talking => text.talkingTitle,
    GuideChapter.myths => text.mythsTitle,
    GuideChapter.faq => text.faqTitle,
    GuideChapter.sources => text.sourcesTitle,
  };
}

/// Everything a search may match in a chapter.
List<String> _searchable(GuideChapter chapter, String lang) => [
  guideChapterTitle(chapter, lang),
  ...switch (chapter) {
    GuideChapter.cycle => [
      sectionCycleTitle(lang),
      sectionCycleSubtitle(lang),
      sectionCycleIntro(lang),
      sectionQuickRefTitle(lang),
      for (final p in cyclePhasesData) ...[
        p.name(lang),
        p.description(lang),
        p.hormoneHint(lang),
        ...p.physical(lang),
        ...p.emotional(lang),
      ],
      for (final c in quickRefCards) ...[c.title(lang), ...c.bullets(lang)],
    ],
    GuideChapter.bodyMind => [
      sectionPhysicalEmotionalTitle(lang),
      sectionPhysicalEmotionalSubtitle(lang),
      sectionPsychologicalIntro(lang),
      pmsDefinition(lang),
      pmddDefinition(lang),
      whenToSeekHelp(lang),
      'PMS',
      'PMDD',
    ],
    GuideChapter.support => [
      sectionPartnerSupportSubtitle(lang),
      sectionPartnerSupportIntro(lang),
      partnerDoSay(lang),
      partnerDontSay(lang),
      comfortKitTitle(lang),
      comfortKitBody(lang),
    ],
    GuideChapter.talking => [
      sectionCommunicationSubtitle(lang),
      for (final t in communicationTemplates) ...[
        t.avoid(lang),
        t.tryInstead(lang),
      ],
      expressingNeedsTitle(lang),
      expressingNeedsBody(lang),
      boundariesTitle(lang),
      boundariesBody(lang),
      planningTogetherTitle(lang),
      planningTogetherBody(lang),
    ],
    GuideChapter.myths => [
      sectionMythBustersSubtitle(lang),
      for (final m in mythBustersList) ...[m.myth(lang), m.fact(lang)],
    ],
    GuideChapter.faq => [
      for (final f in faqList) ...[f.question(lang), f.answer(lang)],
    ],
    GuideChapter.sources => [
      disclaimerTitle(lang),
      disclaimerBody(lang),
      for (final s in periodVerifiedSourcesForLang(lang)) ...[
        s.name(lang),
        s.credential(lang),
      ],
    ],
  },
];

/// Chapters that mention [query] (case-insensitive), in reading order.
List<GuideChapter> guideChaptersMatching(String query, String lang) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return GuideChapter.values;
  return [
    for (final c in GuideChapter.values)
      if (_searchable(c, lang).any((t) => t.toLowerCase().contains(q))) c,
  ];
}
