import 'package:flutter_test/flutter_test.dart';

import 'package:nousdeux/core/constants/period_education.dart';
import 'package:nousdeux/core/constants/cycle_strings.dart';
import 'package:nousdeux/core/constants/guide_chapters.dart';
import 'package:nousdeux/core/constants/period_options.dart';
import 'package:nousdeux/core/constants/period_verified_sources.dart';

void main() {
  group('guideChaptersMatching', () {
    test('an empty or blank query matches every chapter, in order', () {
      expect(guideChaptersMatching('', 'fr'), GuideChapter.values);
      expect(guideChaptersMatching('   ', 'en'), GuideChapter.values);
    });

    test('matches chapter titles, ignoring case and surrounding spaces', () {
      final title = guideChapterTitle(GuideChapter.faq, 'en');
      expect(
        guideChaptersMatching('  ${title.toUpperCase()} ', 'en'),
        contains(GuideChapter.faq),
      );
    });

    test('matches what a chapter says, not only its title', () {
      expect(
        guideChaptersMatching('PMDD', 'fr'),
        contains(GuideChapter.bodyMind),
      );
      expect(
        guideChaptersMatching('ovulation', 'en'),
        contains(GuideChapter.cycle),
      );
      expect(
        guideChaptersMatching('bouillotte', 'fr'),
        contains(GuideChapter.support),
      );
    });

    test('returns nothing for gibberish', () {
      expect(guideChaptersMatching('zzqxw', 'fr'), isEmpty);
    });
  });

  test('every chapter has a title in both languages', () {
    for (final chapter in GuideChapter.values) {
      expect(guideChapterTitle(chapter, 'fr'), isNotEmpty);
      expect(guideChapterTitle(chapter, 'en'), isNotEmpty);
    }
  });

  test('the FAQ says notes stay private and sharing is a choice', () {
    final answer = faqList
        .firstWhere((f) => f.question('fr').contains('partenaire'))
        .answer('fr');
    expect(answer, contains('privées'));
    expect(answer, isNot(contains('sont partagées au sein du couple')));
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
    });

    test('every option has a label in both languages', () {
      for (final value in [...periodMoods, ...periodSymptoms]) {
        final fr = periodMoods.contains(value)
            ? periodMoodOptionLabel(value, 'fr')
            : periodSymptomOptionLabel(value, 'fr');
        final en = periodMoods.contains(value)
            ? periodMoodOptionLabel(value, 'en')
            : periodSymptomOptionLabel(value, 'en');
        expect(fr, isNot(value));
        expect(en, isNot(value));
      }
    });
  });

  test('every cycle phase has a label and tips in both languages', () {
    for (final phase in CyclePhase.values) {
      for (final lang in ['fr', 'en']) {
        expect(cyclePhaseLabel(lang, phase), isNotEmpty);
        expect(cycleSelfTip(lang, phase), isNotEmpty);
        expect(cyclePartnerTips(lang, phase), hasLength(3));
      }
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
