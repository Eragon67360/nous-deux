// Educational content for the period tracking guide, and the period log's
// labels. The words live in one file per language (content/education_en.dart,
// content/education_fr.dart, …); these functions pick the reader's language
// and fall back to English.

import 'package:nousdeux/core/constants/content/education_en.dart';
import 'package:nousdeux/core/constants/content/education_fr.dart';
import 'package:nousdeux/core/constants/content/education_text.dart';
import 'package:nousdeux/core/l10n/app_languages.dart';

/// The education content in each language the app speaks, by language code.
/// A new language adds its file here (test/l10n/content_completeness_test.dart
/// checks every language in [AppLanguages.supported] has one).
const Map<String, EducationText> educationTexts = {
  'fr': educationFr,
  'en': educationEn,
};

/// The education content in [lang], or in English when [lang] has no file.
EducationText educationTextFor(String lang) =>
    educationTexts[lang] ?? educationTexts[AppLanguages.fallback]!;

/// English, whose lists every other language follows entry for entry.
EducationText get _reference => educationTexts[AppLanguages.fallback]!;

// --- Screen & tab labels ---

String periodScreenTitle(String lang) =>
    educationTextFor(lang).periodScreenTitle;

// --- Section: Understanding the Menstrual Cycle ---

String sectionCycleTitle(String lang) =>
    educationTextFor(lang).sectionCycleTitle;

String sectionCycleSubtitle(String lang) =>
    educationTextFor(lang).sectionCycleSubtitle;

String sectionCycleIntro(String lang) =>
    educationTextFor(lang).sectionCycleIntro;

// Phase data for timeline and copy (day ranges approximate)
enum CyclePhase { menstrual, follicular, ovulation, luteal }

class PhaseData {
  const PhaseData(this.phase, this.dayRange);

  final CyclePhase phase;
  final String dayRange;

  PhaseText _text(String lang) {
    final text = educationTextFor(lang);
    return switch (phase) {
      CyclePhase.menstrual => text.menstrual,
      CyclePhase.follicular => text.follicular,
      CyclePhase.ovulation => text.ovulation,
      CyclePhase.luteal => text.luteal,
    };
  }

  String name(String lang) => _text(lang).name;
  String description(String lang) => _text(lang).description;
  String hormoneHint(String lang) => _text(lang).hormoneHint;
  List<String> physical(String lang) => _text(lang).physical;
  List<String> emotional(String lang) => _text(lang).emotional;
}

const List<PhaseData> cyclePhasesData = [
  PhaseData(CyclePhase.menstrual, '1–5'),
  PhaseData(CyclePhase.follicular, '6–12'),
  PhaseData(CyclePhase.ovulation, '13–15'),
  PhaseData(CyclePhase.luteal, '16–28'),
];

// --- Section: Physical & Emotional ---

String sectionPhysicalEmotionalTitle(String lang) =>
    educationTextFor(lang).sectionPhysicalEmotionalTitle;

String sectionPhysicalEmotionalSubtitle(String lang) =>
    educationTextFor(lang).sectionPhysicalEmotionalSubtitle;

// --- Psychological impact (PMS / PMDD) ---

String sectionPsychologicalTitle(String lang) =>
    educationTextFor(lang).sectionPsychologicalTitle;

String sectionPsychologicalIntro(String lang) =>
    educationTextFor(lang).sectionPsychologicalIntro;

String pmsDefinition(String lang) => educationTextFor(lang).pmsDefinition;

String pmddDefinition(String lang) => educationTextFor(lang).pmddDefinition;

String whenToSeekHelp(String lang) => educationTextFor(lang).whenToSeekHelp;

// --- Section: How Partners Can Support ---

String sectionPartnerSupportSubtitle(String lang) =>
    educationTextFor(lang).sectionPartnerSupportSubtitle;

String sectionPartnerSupportIntro(String lang) =>
    educationTextFor(lang).sectionPartnerSupportIntro;

String partnerDoSay(String lang) => educationTextFor(lang).partnerDoSay;

String partnerDontSay(String lang) => educationTextFor(lang).partnerDontSay;

String comfortKitTitle(String lang) => educationTextFor(lang).comfortKitTitle;

String comfortKitBody(String lang) => educationTextFor(lang).comfortKitBody;

// --- Section: Communication Guide ---

String sectionCommunicationSubtitle(String lang) =>
    educationTextFor(lang).sectionCommunicationSubtitle;

/// The [index]th template, in any language.
class CommunicationTemplate {
  const CommunicationTemplate._(this.index);

  final int index;

  CommunicationText _text(String lang) =>
      educationTextFor(lang).communicationTemplates[index];

  String avoid(String lang) => _text(lang).avoid;
  String tryInstead(String lang) => _text(lang).tryInstead;
}

List<CommunicationTemplate> get communicationTemplates => [
  for (var i = 0; i < _reference.communicationTemplates.length; i++)
    CommunicationTemplate._(i),
];

String expressingNeedsTitle(String lang) =>
    educationTextFor(lang).expressingNeedsTitle;

String expressingNeedsBody(String lang) =>
    educationTextFor(lang).expressingNeedsBody;

String boundariesTitle(String lang) => educationTextFor(lang).boundariesTitle;

String boundariesBody(String lang) => educationTextFor(lang).boundariesBody;

String planningTogetherTitle(String lang) =>
    educationTextFor(lang).planningTogetherTitle;

String planningTogetherBody(String lang) =>
    educationTextFor(lang).planningTogetherBody;

// --- Section: Myth Busters ---

String sectionMythBustersSubtitle(String lang) =>
    educationTextFor(lang).sectionMythBustersSubtitle;

/// The [index]th myth, in any language.
class MythBuster {
  const MythBuster._(this.index);

  final int index;

  MythText _text(String lang) => educationTextFor(lang).mythBusters[index];

  String myth(String lang) => _text(lang).myth;
  String fact(String lang) => _text(lang).fact;
}

List<MythBuster> get mythBustersList => [
  for (var i = 0; i < _reference.mythBusters.length; i++) MythBuster._(i),
];

// --- Section: Quick Reference Cards ---

String sectionQuickRefTitle(String lang) =>
    educationTextFor(lang).sectionQuickRefTitle;

/// The [index]th quick reference card, in any language.
class QuickRefCard {
  const QuickRefCard._(this.index);

  final int index;

  QuickRefText _text(String lang) =>
      educationTextFor(lang).quickRefCards[index];

  String title(String lang) => _text(lang).title;
  List<String> bullets(String lang) => _text(lang).bullets;
}

List<QuickRefCard> get quickRefCards => [
  for (var i = 0; i < _reference.quickRefCards.length; i++) QuickRefCard._(i),
];

// --- Section: FAQ ---

/// The [index]th question, in any language.
class FaqItem {
  const FaqItem._(this.index);

  final int index;

  FaqText _text(String lang) => educationTextFor(lang).faq[index];

  String question(String lang) => _text(lang).question;
  String answer(String lang) => _text(lang).answer;
}

List<FaqItem> get faqList => [
  for (var i = 0; i < _reference.faq.length; i++) FaqItem._(i),
];

// --- Disclaimer ---

String disclaimerTitle(String lang) => educationTextFor(lang).disclaimerTitle;

String disclaimerBody(String lang) => educationTextFor(lang).disclaimerBody;

// --- Period log form & list strings ---

String periodLogNew(String lang) => educationTextFor(lang).periodLogNew;
String periodLogEdit(String lang) => educationTextFor(lang).periodLogEdit;
String periodDeleteConfirmTitle(String lang) =>
    educationTextFor(lang).periodDeleteConfirmTitle;
String periodCancel(String lang) => educationTextFor(lang).periodCancel;
String periodDelete(String lang) => educationTextFor(lang).periodDelete;
String periodSave(String lang) => educationTextFor(lang).periodSave;
String periodStartDate(String lang) => educationTextFor(lang).periodStartDate;
String periodEndDate(String lang) => educationTextFor(lang).periodEndDate;

// Partner reminder (the evening before)
String periodReminderNotificationTitle(String lang) =>
    educationTextFor(lang).periodReminderNotificationTitle;
String periodReminderNotificationBody(String lang) =>
    educationTextFor(lang).periodReminderNotificationBody;

// Mood/symptom labels by language (value is same in DB)
String periodMoodOptionLabel(String value, String lang) =>
    educationTextFor(lang).moodLabels[value] ?? value;

String periodSymptomOptionLabel(String value, String lang) =>
    educationTextFor(lang).symptomLabels[value] ?? value;
