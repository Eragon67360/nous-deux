/// One phase of the cycle, as the guide describes it.
typedef PhaseText = ({
  String name,
  String description,
  String hormoneHint,
  List<String> physical,
  List<String> emotional,
});

/// A phrase to avoid, and what to say instead.
typedef CommunicationText = ({String avoid, String tryInstead});

/// A common belief, and what is true.
typedef MythText = ({String myth, String fact});

/// A quick reference card: a phase and how to help during it.
typedef QuickRefText = ({String title, List<String> bullets});

/// A frequent question and its answer.
typedef FaqText = ({String question, String answer});

/// The cycle education content in one language: the guide's paragraphs, the
/// four phases, the tips, the myths and the FAQ. Short UI labels (the
/// period log's, the mood and symptom names) are in the ARB files.
///
/// Each language is one file (`education_en.dart`, `education_fr.dart`, …)
/// holding a const [EducationText], listed in `educationTexts`
/// (period_education.dart). A language that leaves out a text doesn't
/// compile. Lists have the same number of entries in every language, in the
/// same order (test/l10n/content_completeness_test.dart).
class EducationText {
  const EducationText({
    required this.sectionCycleTitle,
    required this.sectionCycleSubtitle,
    required this.sectionCycleIntro,
    required this.menstrual,
    required this.follicular,
    required this.ovulation,
    required this.luteal,
    required this.sectionQuickRefTitle,
    required this.quickRefCards,
    required this.sectionPhysicalEmotionalTitle,
    required this.sectionPhysicalEmotionalSubtitle,
    required this.sectionPsychologicalTitle,
    required this.sectionPsychologicalIntro,
    required this.pmsDefinition,
    required this.pmddDefinition,
    required this.whenToSeekHelp,
    required this.sectionPartnerSupportSubtitle,
    required this.sectionPartnerSupportIntro,
    required this.partnerDoSay,
    required this.partnerDontSay,
    required this.comfortKitTitle,
    required this.comfortKitBody,
    required this.sectionCommunicationSubtitle,
    required this.communicationTemplates,
    required this.expressingNeedsTitle,
    required this.expressingNeedsBody,
    required this.boundariesTitle,
    required this.boundariesBody,
    required this.planningTogetherTitle,
    required this.planningTogetherBody,
    required this.sectionMythBustersSubtitle,
    required this.mythBusters,
    required this.faq,
    required this.disclaimerTitle,
    required this.disclaimerBody,
  });

  // --- Understanding the cycle ---
  final String sectionCycleTitle;
  final String sectionCycleSubtitle;
  final String sectionCycleIntro;
  final PhaseText menstrual;
  final PhaseText follicular;
  final PhaseText ovulation;
  final PhaseText luteal;
  final String sectionQuickRefTitle;
  final List<QuickRefText> quickRefCards;

  // --- Body and mood ---
  final String sectionPhysicalEmotionalTitle;
  final String sectionPhysicalEmotionalSubtitle;
  final String sectionPsychologicalTitle;
  final String sectionPsychologicalIntro;
  final String pmsDefinition;
  final String pmddDefinition;
  final String whenToSeekHelp;

  // --- How partners can support ---
  final String sectionPartnerSupportSubtitle;
  final String sectionPartnerSupportIntro;
  final String partnerDoSay;
  final String partnerDontSay;
  final String comfortKitTitle;
  final String comfortKitBody;

  // --- Talking about it ---
  final String sectionCommunicationSubtitle;
  final List<CommunicationText> communicationTemplates;
  final String expressingNeedsTitle;
  final String expressingNeedsBody;
  final String boundariesTitle;
  final String boundariesBody;
  final String planningTogetherTitle;
  final String planningTogetherBody;

  // --- Myths and FAQ ---
  final String sectionMythBustersSubtitle;
  final List<MythText> mythBusters;
  final List<FaqText> faq;

  // --- Sources and limits ---
  final String disclaimerTitle;
  final String disclaimerBody;
}
