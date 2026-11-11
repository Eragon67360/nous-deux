import 'package:nousdeux/core/constants/period_education.dart';
import 'package:nousdeux/core/constants/period_verified_sources.dart';

/// The guide's chapters, in reading order.
enum GuideChapter { cycle, bodyMind, support, talking, myths, faq, sources }

String guideChapterTitle(GuideChapter chapter, String lang) {
  final fr = lang == 'fr';
  return switch (chapter) {
    GuideChapter.cycle => fr ? 'Le cycle en 4 phases' : 'The cycle in 4 phases',
    GuideChapter.bodyMind => fr ? 'Corps et humeur' : 'Body and mood',
    GuideChapter.support =>
      fr ? 'Soutenir sans s\'imposer' : 'Supporting without taking over',
    GuideChapter.talking => fr ? 'En parler à deux' : 'Talking about it',
    GuideChapter.myths => fr ? 'Idées reçues' : 'Myths',
    GuideChapter.faq => fr ? 'Questions fréquentes' : 'Common questions',
    GuideChapter.sources => fr ? 'Sources et limites' : 'Sources and limits',
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
