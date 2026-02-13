// Section IDs for the Period Guide: TOC, search, bookmarks, analytics.
// Use with language 'fr' or 'en' from profile.

import 'package:nousdeux/core/constants/period_education.dart';

/// Identifies each major section of the Period Guide for navigation and filtering.
enum PeriodGuideSection {
  tip,
  cycle,
  bodyMind,
  partnerSupport,
  communication,
  mythBusters,
  quickRef,
  faq,
  disclaimer,
}

/// Order of sections as shown in the Guide (used for TOC and scroll).
const List<PeriodGuideSection> periodGuideSectionOrder = [
  PeriodGuideSection.tip,
  PeriodGuideSection.cycle,
  PeriodGuideSection.bodyMind,
  PeriodGuideSection.partnerSupport,
  PeriodGuideSection.communication,
  PeriodGuideSection.mythBusters,
  PeriodGuideSection.quickRef,
  PeriodGuideSection.faq,
  PeriodGuideSection.disclaimer,
];

/// Topic category for filtering and "Partner path" (subset of sections).
enum PeriodGuideTopic {
  basics,
  bodyMind,
  support,
  myths,
  reference,
  safety,
}

/// Section → topic mapping for filtering.
const Map<PeriodGuideSection, PeriodGuideTopic> sectionTopic = {
  PeriodGuideSection.tip: PeriodGuideTopic.basics,
  PeriodGuideSection.cycle: PeriodGuideTopic.basics,
  PeriodGuideSection.bodyMind: PeriodGuideTopic.bodyMind,
  PeriodGuideSection.partnerSupport: PeriodGuideTopic.support,
  PeriodGuideSection.communication: PeriodGuideTopic.support,
  PeriodGuideSection.mythBusters: PeriodGuideTopic.myths,
  PeriodGuideSection.quickRef: PeriodGuideTopic.reference,
  PeriodGuideSection.faq: PeriodGuideTopic.reference,
  PeriodGuideSection.disclaimer: PeriodGuideTopic.safety,
};

/// Sections shown in "Partner focus" shortened path.
const Set<PeriodGuideSection> partnerPathSections = {
  PeriodGuideSection.tip,
  PeriodGuideSection.partnerSupport,
  PeriodGuideSection.communication,
  PeriodGuideSection.mythBusters,
  PeriodGuideSection.quickRef,
  PeriodGuideSection.faq,
  PeriodGuideSection.disclaimer,
};

String periodGuideSectionTitle(PeriodGuideSection section, String lang) {
  switch (section) {
    case PeriodGuideSection.tip:
      return tipOfTheDayTitle(lang);
    case PeriodGuideSection.cycle:
      return sectionCycleTitle(lang);
    case PeriodGuideSection.bodyMind:
      return sectionPhysicalEmotionalTitle(lang);
    case PeriodGuideSection.partnerSupport:
      return sectionPartnerSupportTitle(lang);
    case PeriodGuideSection.communication:
      return sectionCommunicationTitle(lang);
    case PeriodGuideSection.mythBusters:
      return sectionMythBustersTitle(lang);
    case PeriodGuideSection.quickRef:
      return sectionQuickRefTitle(lang);
    case PeriodGuideSection.faq:
      return sectionFaqTitle(lang);
    case PeriodGuideSection.disclaimer:
      return disclaimerTitle(lang);
  }
}

/// Searchable text for a section (title + key phrases). Used for search filter.
List<String> periodGuideSectionSearchableStrings(
  PeriodGuideSection section,
  String lang,
) {
  final title = periodGuideSectionTitle(section, lang);
  final extra = <String>[];
  switch (section) {
    case PeriodGuideSection.tip:
      extra.addAll([sectionCycleTitle(lang), sectionPartnerSupportTitle(lang)]);
      break;
    case PeriodGuideSection.cycle:
      extra.addAll([
        sectionCycleSubtitle(lang),
        sectionCycleIntro(lang),
        'menstrual',
        'phase',
        'ovulation',
        'luteal',
        'follicular',
        lang == 'fr' ? 'menstruel' : 'menstrual',
      ]);
      break;
    case PeriodGuideSection.bodyMind:
      extra.addAll([
        sectionPsychologicalTitle(lang),
        pmsDefinition(lang),
        pmddDefinition(lang),
        whenToSeekHelp(lang),
        'PMS',
        'PMDD',
      ]);
      break;
    case PeriodGuideSection.partnerSupport:
      extra.addAll([
        sectionPartnerSupportSubtitle(lang),
        partnerDoSay(lang),
        partnerDontSay(lang),
        comfortKitTitle(lang),
        lang == 'fr' ? 'soutien' : 'support',
      ]);
      break;
    case PeriodGuideSection.communication:
      extra.addAll([
        expressingNeedsTitle(lang),
        boundariesTitle(lang),
        planningTogetherTitle(lang),
        lang == 'fr' ? 'communiquer' : 'communication',
      ]);
      break;
    case PeriodGuideSection.mythBusters:
      extra.addAll([
        sectionMythBustersSubtitle(lang),
        lang == 'fr' ? 'mythe' : 'myth',
      ]);
      break;
    case PeriodGuideSection.quickRef:
      extra.addAll([sectionQuickRefSubtitle(lang), 'phase', 'résumé']);
      break;
    case PeriodGuideSection.faq:
      for (final f in faqList) {
        extra.add(f.question(lang));
        extra.add(f.answer(lang));
      }
      break;
    case PeriodGuideSection.disclaimer:
      extra.add(disclaimerBody(lang));
      break;
  }
  return [title, ...extra];
}

/// Sections that contain [query] (case-insensitive) in their searchable strings.
Set<PeriodGuideSection> periodGuideSectionsMatchingQuery(String query, String lang) {
  if (query.trim().isEmpty) return periodGuideSectionOrder.toSet();
  final q = query.trim().toLowerCase();
  return periodGuideSectionOrder
      .where((s) {
        final strings = periodGuideSectionSearchableStrings(s, lang);
        return strings.any((t) => t.toLowerCase().contains(q));
      })
      .toSet();
}
