import 'package:flutter_test/flutter_test.dart';

import 'package:nousdeux/core/constants/content/education_text.dart';
import 'package:nousdeux/core/constants/content/guide_text.dart';
import 'package:nousdeux/core/constants/guide_chapters.dart';
import 'package:nousdeux/core/constants/period_education.dart';
import 'package:nousdeux/core/constants/period_options.dart';
import 'package:nousdeux/core/constants/period_verified_sources.dart';
import 'package:nousdeux/core/l10n/app_languages.dart';

/// Every language the app speaks has the whole guide, its education content
/// and its sources in its own words, so nothing falls back to English.
///
/// The compiler already makes each language file fill every field of
/// [GuideText] and [EducationText]. This checks what it can't see: that the
/// language has its files, as many templates, myths, cards and questions as
/// English, a label for every mood and symptom, every source's text, and no
/// blank text.
void main() {
  final english = educationTexts[AppLanguages.fallback]!;

  for (final lang in AppLanguages.supported) {
    group(lang, () {
      test('has a guide file with every chapter title', () {
        expect(guideTexts, contains(lang), reason: 'no guide file');
        for (final chapter in GuideChapter.values) {
          expect(
            guideChapterTitle(chapter, lang).trim(),
            isNotEmpty,
            reason: chapter.name,
          );
        }
      });

      test('has an education file with every section, phase and tip', () {
        expect(educationTexts, contains(lang), reason: 'no education file');
        final text = educationTexts[lang]!;

        for (final (name, items, inEnglish) in [
          (
            'communicationTemplates',
            text.communicationTemplates,
            english.communicationTemplates,
          ),
          ('mythBusters', text.mythBusters, english.mythBusters),
          ('quickRefCards', text.quickRefCards, english.quickRefCards),
          ('faq', text.faq, english.faq),
        ]) {
          expect(items, hasLength(inEnglish.length), reason: name);
        }
        for (final phase in cyclePhasesData) {
          expect(phase.physical(lang), isNotEmpty, reason: phase.phase.name);
          expect(phase.emotional(lang), isNotEmpty, reason: phase.phase.name);
        }
        for (final (i, line) in _educationTexts(lang).indexed) {
          expect(line.trim(), isNotEmpty, reason: 'text #$i is blank');
        }
      });

      test('has every source\'s name, credential and summary', () {
        for (final s in periodVerifiedSources) {
          for (final (field, text) in [
            ('names', s.names),
            ('credentials', s.credentials),
            ('summaries', s.summaries),
          ]) {
            expect(
              text[lang]?.trim(),
              allOf(isNotNull, isNotEmpty),
              reason: '${s.url} $field',
            );
          }
        }
        for (final platform in VerifiedSourcePlatform.values) {
          expect(
            platform.labels[lang]?.trim(),
            allOf(isNotNull, isNotEmpty),
            reason: '${platform.name} label',
          );
        }
      });
    });
  }
}

/// Every text of the education content in [lang], read through the
/// functions the screens call.
List<String> _educationTexts(String lang) => [
  periodScreenTitle(lang),
  sectionCycleTitle(lang),
  sectionCycleSubtitle(lang),
  sectionCycleIntro(lang),
  for (final p in cyclePhasesData) ...[
    p.name(lang),
    p.description(lang),
    p.hormoneHint(lang),
    ...p.physical(lang),
    ...p.emotional(lang),
  ],
  sectionPhysicalEmotionalTitle(lang),
  sectionPhysicalEmotionalSubtitle(lang),
  sectionPsychologicalTitle(lang),
  sectionPsychologicalIntro(lang),
  pmsDefinition(lang),
  pmddDefinition(lang),
  whenToSeekHelp(lang),
  sectionPartnerSupportSubtitle(lang),
  sectionPartnerSupportIntro(lang),
  partnerDoSay(lang),
  partnerDontSay(lang),
  comfortKitTitle(lang),
  comfortKitBody(lang),
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
  sectionMythBustersSubtitle(lang),
  for (final m in mythBustersList) ...[m.myth(lang), m.fact(lang)],
  sectionQuickRefTitle(lang),
  for (final c in quickRefCards) ...[c.title(lang), ...c.bullets(lang)],
  for (final f in faqList) ...[f.question(lang), f.answer(lang)],
  disclaimerTitle(lang),
  disclaimerBody(lang),
  periodLogNew(lang),
  periodLogEdit(lang),
  periodDeleteConfirmTitle(lang),
  periodCancel(lang),
  periodDelete(lang),
  periodSave(lang),
  periodStartDate(lang),
  periodEndDate(lang),
  periodReminderNotificationTitle(lang),
  periodReminderNotificationBody(lang),
  for (final v in periodMoods) periodMoodOptionLabel(v, lang),
  for (final v in periodSymptoms) periodSymptomOptionLabel(v, lang),
];
