import 'package:flutter_test/flutter_test.dart';

import 'package:nousdeux/core/constants/period_education.dart';
import 'package:nousdeux/core/constants/period_guide_sections.dart';
import 'package:nousdeux/core/constants/period_options.dart';
import 'package:nousdeux/core/constants/period_verified_sources.dart';

void main() {
  group('periodGuideSectionsMatchingQuery', () {
    test('an empty or blank query matches every section', () {
      expect(
        periodGuideSectionsMatchingQuery('', 'fr'),
        periodGuideSectionOrder.toSet(),
      );
      expect(
        periodGuideSectionsMatchingQuery('   ', 'en'),
        periodGuideSectionOrder.toSet(),
      );
    });

    test('matches section titles, ignoring case and surrounding spaces', () {
      final title = periodGuideSectionTitle(PeriodGuideSection.faq, 'en');
      expect(
        periodGuideSectionsMatchingQuery('  ${title.toUpperCase()} ', 'en'),
        contains(PeriodGuideSection.faq),
      );
    });

    test('matches key phrases beyond the title', () {
      expect(
        periodGuideSectionsMatchingQuery('PMDD', 'fr'),
        contains(PeriodGuideSection.bodyMind),
      );
      expect(
        periodGuideSectionsMatchingQuery('ovulation', 'en'),
        contains(PeriodGuideSection.cycle),
      );
    });

    test('returns nothing for gibberish', () {
      expect(periodGuideSectionsMatchingQuery('zzqxw', 'fr'), isEmpty);
    });
  });

  test('every guide section has a title in both languages', () {
    for (final section in periodGuideSectionOrder) {
      expect(periodGuideSectionTitle(section, 'fr'), isNotEmpty);
      expect(periodGuideSectionTitle(section, 'en'), isNotEmpty);
    }
    expect(periodGuideSectionOrder.toSet(), PeriodGuideSection.values.toSet());
  });

  test('the partner path is a subset of the guide', () {
    expect(
      periodGuideSectionOrder.toSet().containsAll(partnerPathSections),
      isTrue,
    );
  });

  group('mood and symptom labels', () {
    test('translate stored values', () {
      expect(periodMoodOptionLabel('tired', 'fr'), 'Fatigué(e)');
      expect(periodMoodOptionLabel('tired', 'en'), 'Tired');
      expect(periodSymptomOptionLabel('headache', 'fr'), 'Maux de tête');
      expect(periodSymptomOptionLabel('headache', 'en'), 'Headache');
    });

    test('fall back to the raw value when unknown', () {
      expect(periodMoodOptionLabel('ecstatic', 'en'), 'ecstatic');
      expect(periodSymptomOptionLabel('hiccups', 'fr'), 'hiccups');
      expect(periodMoodLabel('ecstatic'), 'ecstatic');
      expect(periodSymptomLabel('hiccups'), 'hiccups');
    });

    test('legacy French-only helpers', () {
      expect(periodMoodLabel(null), '');
      expect(periodMoodLabel(''), '');
      expect(periodMoodLabel('good'), 'Bien');
      expect(periodSymptomLabel('cramps'), 'Crampes');
    });

    test('every option has a label in both languages', () {
      for (final o in periodMoodOptions) {
        expect(periodMoodOptionLabel(o.value, 'en'), isNot(o.value));
        expect(periodMoodOptionLabel(o.value, 'fr'), o.label);
      }
      for (final o in periodSymptomOptions) {
        expect(periodSymptomOptionLabel(o.value, 'en'), isNot(o.value));
        expect(periodSymptomOptionLabel(o.value, 'fr'), o.label);
      }
    });
  });

  test('every cycle phase has a tip in both languages', () {
    for (final phase in CyclePhase.values) {
      expect(phaseTipFor(phase).get('fr'), isNotEmpty);
      expect(phaseTipFor(phase).get('en'), isNotEmpty);
    }
    expect(cyclePhasesData, hasLength(CyclePhase.values.length));
  });

  group('verified sources', () {
    test('are all https links', () {
      for (final s in periodVerifiedSources) {
        expect(Uri.parse(s.url).scheme, 'https', reason: s.url);
      }
    });

    test(
      'filtering by language keeps sources in that language or unscoped',
      () {
        for (final lang in ['fr', 'en']) {
          final sources = periodVerifiedSourcesForLang(lang);
          expect(sources, isNotEmpty);
          for (final s in sources) {
            expect(s.locales.isEmpty || s.locales.contains(lang), isTrue);
          }
        }
      },
    );

    test('topic filters only return matching topics', () {
      for (final s in sourcesForTopic(VerifiedSourceTopic.pms, 'en')) {
        expect(s.topic, VerifiedSourceTopic.pms);
      }
      for (final s in sourcesWhenToSeekHelp('en')) {
        expect(
          s.topic,
          isIn([
            VerifiedSourceTopic.pms,
            VerifiedSourceTopic.whenToSeekHelp,
            VerifiedSourceTopic.general,
          ]),
        );
      }
      for (final s in sourcesPartnerSupport('fr')) {
        expect(
          s.topic,
          isIn([
            VerifiedSourceTopic.partnerSupport,
            VerifiedSourceTopic.general,
          ]),
        );
      }
    });

    test('platform labels', () {
      VerifiedSource on(VerifiedSourcePlatform p) => VerifiedSource(
        platform: p,
        nameEn: 'n',
        nameFr: 'n',
        url: 'https://example.test',
        topic: VerifiedSourceTopic.general,
        locales: const [],
        credentialEn: 'c',
        credentialFr: 'c',
        summaryEn: 's',
        summaryFr: 's',
      );
      expect(on(VerifiedSourcePlatform.web).platformLabel('fr'), 'Site web');
      expect(on(VerifiedSourcePlatform.web).platformLabel('en'), 'Website');
      expect(on(VerifiedSourcePlatform.youtube).platformLabel('fr'), 'YouTube');
      expect(
        on(VerifiedSourcePlatform.other).platformLabel('en'),
        'External link',
      );
    });
  });
}
