// Bilingual (FR/EN) educational content for the period tracking guide.
// Use with language 'fr' or 'en' from profile or local override.

// --- Screen & tab labels ---

String periodScreenTitle(String lang) => lang == 'fr' ? 'Règles' : 'Period';

String periodTabLogs(String lang) => lang == 'fr' ? 'Journal' : 'Logs';
String periodTabGuide(String lang) => lang == 'fr' ? 'Guide' : 'Guide';

String periodPartnerModeLabel(String lang) =>
    lang == 'fr' ? 'Vue partenaire' : 'Partner view';

// --- Section: Understanding the Menstrual Cycle ---

String sectionCycleTitle(String lang) => lang == 'fr'
    ? 'Comprendre le cycle menstruel'
    : 'Understanding the Menstrual Cycle';

String sectionCycleSubtitle(String lang) => lang == 'fr'
    ? 'Quatre phases, des hormones qui varient. Chaque cycle est unique.'
    : 'Four phases, changing hormones. Every cycle is unique.';

String sectionCycleIntro(String lang) => lang == 'fr'
    ? 'Un cycle dure en moyenne 28 jours, mais entre 21 et 35 jours est normal. Les hormones (œstrogène, progestérone) pilotent les phases et influencent le corps et l\'humeur.'
    : 'A cycle averages 28 days, but 21–35 days is normal. Hormones (estrogen, progesterone) drive the phases and affect body and mood.';

// Phase data for timeline and copy (day ranges approximate)
enum CyclePhase { menstrual, follicular, ovulation, luteal }

class PhaseData {
  const PhaseData({
    required this.nameFr,
    required this.nameEn,
    required this.dayRange,
    required this.descriptionFr,
    required this.descriptionEn,
    required this.hormoneHintFr,
    required this.hormoneHintEn,
    required this.physicalFr,
    required this.physicalEn,
    required this.emotionalFr,
    required this.emotionalEn,
  });
  final String nameFr, nameEn;
  final String dayRange;
  final String descriptionFr, descriptionEn;
  final String hormoneHintFr, hormoneHintEn;
  final List<String> physicalFr, physicalEn;
  final List<String> emotionalFr, emotionalEn;

  String name(String lang) => lang == 'fr' ? nameFr : nameEn;
  String description(String lang) =>
      lang == 'fr' ? descriptionFr : descriptionEn;
  String hormoneHint(String lang) =>
      lang == 'fr' ? hormoneHintFr : hormoneHintEn;
  List<String> physical(String lang) => lang == 'fr' ? physicalFr : physicalEn;
  List<String> emotional(String lang) =>
      lang == 'fr' ? emotionalFr : emotionalEn;
}

const List<PhaseData> cyclePhasesData = [
  PhaseData(
    nameFr: 'Menstruation',
    nameEn: 'Menstrual',
    dayRange: '1–5',
    descriptionFr:
        'Les règles : la muqueuse utérine est évacuée. C\'est la phase la plus visible du cycle.',
    descriptionEn:
        'Your period: the uterine lining is shed. This is the most visible phase.',
    hormoneHintFr: 'Œstrogène et progestérone au plus bas.',
    hormoneHintEn: 'Estrogen and progesterone at their lowest.',
    physicalFr: [
      'Saignement',
      'Crampes possibles',
      'Fatigue',
      'Douleurs au dos ou à la tête',
    ],
    physicalEn: ['Bleeding', 'Possible cramps', 'Fatigue', 'Back or head pain'],
    emotionalFr: ['Besoin de repos', 'Parfois plus sensible', 'Envie de calme'],
    emotionalEn: ['Need for rest', 'Sometimes more sensitive', 'Craving calm'],
  ),
  PhaseData(
    nameFr: 'Folliculaire',
    nameEn: 'Follicular',
    dayRange: '6–12',
    descriptionFr:
        'Les follicules ovariens mûrissent. L\'œstrogène remonte, l\'énergie souvent aussi.',
    descriptionEn:
        'Ovarian follicles mature. Estrogen rises; energy often does too.',
    hormoneHintFr: 'Œstrogène en hausse.',
    hormoneHintEn: 'Estrogen rising.',
    physicalFr: [
      'Plus d\'énergie',
      'Peau souvent plus nette',
      'Endurance possible',
    ],
    physicalEn: ['More energy', 'Skin often clearer', 'Stamina may increase'],
    emotionalFr: [
      'Meilleure humeur',
      'Plus sociable',
      'Concentration facilitée',
    ],
    emotionalEn: ['Better mood', 'More sociable', 'Easier to focus'],
  ),
  PhaseData(
    nameFr: 'Ovulation',
    nameEn: 'Ovulation',
    dayRange: '13–15',
    descriptionFr:
        'Libération de l\'ovule. Pic d\'œstrogène ; beaucoup ressentent un pic d\'énergie et de libido.',
    descriptionEn:
        'Egg is released. Estrogen peaks; many feel a peak in energy and libido.',
    hormoneHintFr: 'Pic d\'œstrogène ; LH déclenche l\'ovulation.',
    hormoneHintEn: 'Estrogen peak; LH triggers ovulation.',
    physicalFr: [
      'Énergie élevée',
      'Libido souvent plus forte',
      'Glaires cervicales plus fluides',
    ],
    physicalEn: [
      'High energy',
      'Libido often higher',
      'More fluid cervical mucus',
    ],
    emotionalFr: ['Confiance', 'Ouverture aux autres', 'Optimisme'],
    emotionalEn: ['Confidence', 'Openness to others', 'Optimism'],
  ),
  PhaseData(
    nameFr: 'Lutérale',
    nameEn: 'Luteal',
    dayRange: '16–28',
    descriptionFr:
        'Après l\'ovulation, la progestérone monte. Cela peut entraîner fatigue et sensibilité émotionnelle avant les règles.',
    descriptionEn:
        'After ovulation, progesterone rises. This can cause fatigue and mood sensitivity before your period.',
    hormoneHintFr: 'Progestérone élevée, puis chute avant les règles.',
    hormoneHintEn: 'Progesterone high, then drops before period.',
    physicalFr: [
      'Fatigue possible',
      'Ballonnements',
      'Seins sensibles',
      'Fringales possibles',
    ],
    physicalEn: [
      'Possible fatigue',
      'Bloating',
      'Tender breasts',
      'Possible cravings',
    ],
    emotionalFr: [
      'Sensibilité émotionnelle',
      'PMS possible',
      'Besoin de réconfort',
    ],
    emotionalEn: ['Emotional sensitivity', 'PMS possible', 'Need for comfort'],
  ),
];

// --- Section: Physical & Emotional ---

String sectionPhysicalEmotionalTitle(String lang) => lang == 'fr'
    ? 'Corps et émotions au fil du cycle'
    : 'Physical & Emotional Changes Throughout the Cycle';

String sectionPhysicalEmotionalSubtitle(String lang) => lang == 'fr'
    ? 'Les symptômes et l\'humeur varient selon la phase. C\'est biologique et normal.'
    : 'Symptoms and mood vary by phase. This is biological and normal.';

// --- Psychological impact (PMS / PMDD) ---

String sectionPsychologicalTitle(String lang) =>
    lang == 'fr' ? 'Impact psychologique' : 'Psychological impact';

String sectionPsychologicalIntro(String lang) => lang == 'fr'
    ? 'Les changements d\'humeur avant et pendant les règles sont réels et liés aux hormones. Les valider aide à mieux vivre le cycle.'
    : 'Mood changes before and during your period are real and hormone-related. Validating them helps.';

String pmsDefinition(String lang) => lang == 'fr'
    ? 'PMS (syndrome prémenstruel) : symptômes physiques et émotionnels les jours avant les règles (fatigue, irritabilité, tristesse, ballonnements). Très courant.'
    : 'PMS (premenstrual syndrome): physical and emotional symptoms in the days before your period (fatigue, irritability, sadness, bloating). Very common.';

String pmddDefinition(String lang) => lang == 'fr'
    ? 'PMDD (trouble dysphorique prémenstruel) : forme plus sévère, avec impact important sur l\'humeur et la vie quotidienne. Moins fréquent, mais à prendre au sérieux.'
    : 'PMDD (premenstrual dysphoric disorder): a more severe form, with a major impact on mood and daily life. Less common but serious.';

String whenToSeekHelp(String lang) => lang == 'fr'
    ? 'Consulter un professionnel si : symptômes très invalidants, idées noires, conflits répétés, ou si vous avez des doutes.'
    : 'See a healthcare provider if: symptoms are very disabling, dark thoughts, repeated conflict, or if you have any doubts.';

// --- Section: How Partners Can Support ---

String sectionPartnerSupportTitle(String lang) => lang == 'fr'
    ? 'Comment le partenaire peut soutenir'
    : 'How Partners Can Support';

String sectionPartnerSupportSubtitle(String lang) => lang == 'fr'
    ? 'Actions concrètes et attitudes qui aident, phase par phase.'
    : 'Practical actions and attitudes that help, phase by phase.';

String sectionPartnerSupportIntro(String lang) => lang == 'fr'
    ? 'Chaque personne est différente. L\'idéal est d\'en parler ensemble : ce qui fait du bien, les limites, et ce qu\'il vaut mieux éviter.'
    : 'Everyone is different. The best approach is to talk together: what helps, boundaries, and what to avoid.';

String partnerDoSay(String lang) => lang == 'fr'
    ? 'À dire : « Comment tu te sens ? », « Tu veux que je te prépare quelque chose ? », « Je suis là si tu as besoin. »'
    : 'Say: "How are you feeling?", "Want me to get you something?", "I\'m here if you need me."';

String partnerDontSay(String lang) => lang == 'fr'
    ? 'À éviter : « C\'est encore tes règles ? », « Tu exagères », ou minimiser la douleur.'
    : 'Avoid: "Is it that time of the month?", "You\'re overreacting," or downplaying pain.';

String comfortKitTitle(String lang) => lang == 'fr'
    ? 'Créer un « kit confort » ensemble'
    : 'Creating a "period comfort kit" together';

String comfortKitBody(String lang) => lang == 'fr'
    ? 'Par exemple : bouillotte, tisane, snacks préférés, antidouleur si OK pour elle/lui, couverture. À adapter selon les préférences.'
    : 'E.g. heat pack, herbal tea, favorite snacks, pain relief if they\'re okay with it, blanket. Adapt to their preferences.';

// --- Section: Communication Guide ---

String sectionCommunicationTitle(String lang) =>
    lang == 'fr' ? 'Guide de communication' : 'Communication Guide';

String sectionCommunicationSubtitle(String lang) => lang == 'fr'
    ? 'Formuler les questions et le soutien avec respect.'
    : 'Asking and supporting with respect.';

class CommunicationTemplate {
  const CommunicationTemplate({
    required this.avoidFr,
    required this.avoidEn,
    required this.tryFr,
    required this.tryEn,
  });
  final String avoidFr, avoidEn, tryFr, tryEn;
  String avoid(String lang) => lang == 'fr' ? avoidFr : avoidEn;
  String tryInstead(String lang) => lang == 'fr' ? tryFr : tryEn;
}

List<CommunicationTemplate> get communicationTemplates => [
  CommunicationTemplate(
    avoidFr: 'C\'est encore tes règles ?',
    avoidEn: 'Is it that time of the month?',
    tryFr: 'Comment tu te sens aujourd\'hui ? Tu as besoin de quelque chose ?',
    tryEn:
        'How are you feeling today? Is there anything I can do to support you?',
  ),
  CommunicationTemplate(
    avoidFr: 'Tu exagères.',
    avoidEn: 'You\'re overreacting.',
    tryFr: 'Je vois que c\'est difficile. Je suis là.',
    tryEn: 'I see this is hard. I\'m here for you.',
  ),
  CommunicationTemplate(
    avoidFr: 'C\'est dans ta tête.',
    avoidEn: 'It\'s all in your head.',
    tryFr: 'Tes symptômes sont réels. On peut en parler.',
    tryEn: 'Your symptoms are real. We can talk about it.',
  ),
  CommunicationTemplate(
    avoidFr: 'Dépêche-toi, on a des trucs à faire.',
    avoidEn: 'Hurry up, we have things to do.',
    tryFr: 'On peut décaler / alléger si tu préfères.',
    tryEn: 'We can reschedule or take it easy if you prefer.',
  ),
];

String expressingNeedsTitle(String lang) =>
    lang == 'fr' ? 'Exprimer ses besoins' : 'Expressing needs';

String expressingNeedsBody(String lang) => lang == 'fr'
    ? 'La personne qui a ses règles peut dire : « J\'ai besoin de repos », « J\'aimerais qu\'on reste à la maison », « Pas de dispute aujourd\'hui si possible ». Le partenaire peut proposer des options sans forcer.'
    : 'The person on their period can say: "I need rest," "I\'d like to stay in," "Let\'s avoid arguments today if possible." The partner can offer options without pushing.';

String boundariesTitle(String lang) => lang == 'fr'
    ? 'Poser des limites avec respect'
    : 'Setting boundaries respectfully';

String boundariesBody(String lang) => lang == 'fr'
    ? 'Les deux peuvent fixer des limites : « J\'ai besoin d\'un moment seul », « On en reparle ce soir ». Écouter et ne pas prendre pour un rejet.'
    : 'Both can set boundaries: "I need some time alone," "Let\'s talk about it tonight." Listen and don\'t take it as rejection.';

String planningTogetherTitle(String lang) =>
    lang == 'fr' ? 'Planifier ensemble' : 'Planning around the cycle together';

String planningTogetherBody(String lang) => lang == 'fr'
    ? 'Connaître les grandes phases aide à planifier : sorties, charge de travail, moments de récupération. Sans que le cycle dicte tout, il peut être pris en compte.'
    : 'Knowing the main phases helps with planning: outings, workload, recovery time. The cycle doesn\'t have to rule everything, but it can be part of the picture.';

// --- Section: Myth Busters ---

String sectionMythBustersTitle(String lang) =>
    lang == 'fr' ? 'Idées reçues' : 'Myth Busters';

String sectionMythBustersSubtitle(String lang) =>
    lang == 'fr' ? 'Démêler le vrai du faux.' : 'Separating fact from fiction.';

class MythBuster {
  const MythBuster({
    required this.mythFr,
    required this.mythEn,
    required this.factFr,
    required this.factEn,
  });
  final String mythFr, mythEn, factFr, factEn;
  String myth(String lang) => lang == 'fr' ? mythFr : mythEn;
  String fact(String lang) => lang == 'fr' ? factFr : factEn;
}

List<MythBuster> get mythBustersList => [
  MythBuster(
    mythFr: 'Les règles, c\'est « juste » des crampes.',
    mythEn: 'Period pain is "just" cramps.',
    factFr:
        'Les douleurs peuvent inclure le dos, la tête, les seins, les troubles digestifs. Ces symptômes sont réels et méritent attention et soins.',
    factEn:
        'Period pain can include back pain, headaches, breast tenderness, and digestive issues. These symptoms are valid and deserve care.',
  ),
  MythBuster(
    mythFr: 'C\'est psychologique / elle exagère.',
    mythEn: 'It\'s psychological / they\'re exaggerating.',
    factFr:
        'Les changements sont liés aux hormones. La sensibilité et la fatigue sont biologiques. Les invalider aggrave souvent le mal-être.',
    factEn:
        'Changes are hormone-related. Sensitivity and fatigue are biological. Invalidating them often makes things worse.',
  ),
  MythBuster(
    mythFr: 'Toutes les femmes ont le même cycle.',
    mythEn: 'Everyone has the same cycle.',
    factFr:
        'Chaque cycle est différent (durée, intensité, symptômes). Ce qui est normal pour une personne ne l\'est pas forcément pour une autre.',
    factEn:
        'Every cycle is different (length, intensity, symptoms). What\'s normal for one person may not be for another.',
  ),
  MythBuster(
    mythFr: 'On ne peut rien faire pour aider.',
    mythEn: 'There\'s nothing you can do to help.',
    factFr:
        'Écouter, proposer du réconfort, alléger les tâches et éviter les remarques blessantes font une vraie différence.',
    factEn:
        'Listening, offering comfort, easing tasks, and avoiding hurtful comments make a real difference.',
  ),
];

// --- Section: Quick Reference Cards ---

String sectionQuickRefTitle(String lang) =>
    lang == 'fr' ? 'Aide-mémoire' : 'Quick Reference Cards';

String sectionQuickRefSubtitle(String lang) =>
    lang == 'fr' ? 'Résumé par phase.' : 'Summary by phase.';

class QuickRefCard {
  const QuickRefCard({
    required this.titleFr,
    required this.titleEn,
    required this.bulletsFr,
    required this.bulletsEn,
  });
  final String titleFr, titleEn;
  final List<String> bulletsFr, bulletsEn;
  String title(String lang) => lang == 'fr' ? titleFr : titleEn;
  List<String> bullets(String lang) => lang == 'fr' ? bulletsFr : bulletsEn;
}

List<QuickRefCard> get quickRefCards => [
  QuickRefCard(
    titleFr: 'Menstruation (j1–5)',
    titleEn: 'Menstrual (day 1–5)',
    bulletsFr: [
      'Règles, fatigue possible',
      'Soutien : repos, chaleur, pas de pression',
    ],
    bulletsEn: ['Period, possible fatigue', 'Support: rest, heat, no pressure'],
  ),
  QuickRefCard(
    titleFr: 'Folliculaire (j6–12)',
    titleEn: 'Follicular (day 6–12)',
    bulletsFr: [
      'Plus d\'énergie, humeur souvent bonne',
      'Idéal pour projets et sorties',
    ],
    bulletsEn: [
      'More energy, mood often better',
      'Good time for projects and outings',
    ],
  ),
  QuickRefCard(
    titleFr: 'Ovulation (j13–15)',
    titleEn: 'Ovulation (day 13–15)',
    bulletsFr: ['Pic d\'énergie et de libido', 'Respecter le rythme si besoin'],
    bulletsEn: ['Peak energy and libido', 'Respect their pace if needed'],
  ),
  QuickRefCard(
    titleFr: 'Lutérale (j16–28)',
    titleEn: 'Luteal (day 16–28)',
    bulletsFr: [
      'Progestérone haute → fatigue, sensibilité',
      'Soutien : écoute, réconfort, partage des tâches',
    ],
    bulletsEn: [
      'Progesterone up → fatigue, sensitivity',
      'Support: listen, comfort, share tasks',
    ],
  ),
];

// --- Section: FAQ ---

String sectionFaqTitle(String lang) =>
    lang == 'fr' ? 'Questions fréquentes' : 'FAQ';

class FaqItem {
  const FaqItem({
    required this.questionFr,
    required this.questionEn,
    required this.answerFr,
    required this.answerEn,
  });
  final String questionFr, questionEn, answerFr, answerEn;
  String question(String lang) => lang == 'fr' ? questionFr : questionEn;
  String answer(String lang) => lang == 'fr' ? answerFr : answerEn;
}

List<FaqItem> get faqList => [
  FaqItem(
    questionFr: 'Qu\'est-ce que le SPM ?',
    questionEn: 'What is PMS?',
    answerFr:
        'Le syndrome prémenstruel regroupe des symptômes physiques et émotionnels dans les jours avant les règles (fatigue, irritabilité, ballonnements, etc.). C\'est courant et variable d\'une personne à l\'autre.',
    answerEn:
        'Premenstrual syndrome includes physical and emotional symptoms in the days before your period (fatigue, irritability, bloating, etc.). It\'s common and varies from person to person.',
  ),
  FaqItem(
    questionFr: 'Comment savoir si c\'est du SPM ou autre chose ?',
    questionEn: 'How do I know if it\'s PMS or something else?',
    answerFr:
        'Si les symptômes reviennent de façon cyclique avant les règles et s\'atténuent après, c\'est souvent lié au cycle. En cas de doute ou si ça impacte beaucoup la vie, un professionnel peut aider.',
    answerEn:
        'If symptoms come back in a cycle before your period and ease after, it\'s often cycle-related. When in doubt or if it greatly affects your life, a healthcare provider can help.',
  ),
  FaqItem(
    questionFr: 'Mon partenaire peut-il voir mes entrées ?',
    questionEn: 'Can my partner see my entries?',
    answerFr:
        'Dans cette app, les entrées de cycle sont partagées au sein du couple. Chacun peut voir les logs de l\'autre pour mieux se coordonner et s\'entraider. La confidentialité reste importante : parlez-en ensemble.',
    answerEn:
        'In this app, cycle entries are shared within the couple. Each can see the other\'s logs to coordinate and support. Privacy still matters: talk about it together.',
  ),
  FaqItem(
    questionFr: 'Les règles rendent-elles vraiment plus irritable ?',
    questionEn: 'Do periods really make you more irritable?',
    answerFr:
        'Les hormones (notamment la chute de progestérone avant les règles) peuvent augmenter la sensibilité et la réactivité. Ce n\'est pas une « excuse » : c\'est physiologique. Le soutien et la compréhension aident.',
    answerEn:
        'Hormones (especially the drop in progesterone before your period) can increase sensitivity and reactivity. It\'s not an "excuse"—it\'s physiological. Support and understanding help.',
  ),
];

// --- Disclaimer ---

String disclaimerTitle(String lang) =>
    lang == 'fr' ? 'Avertissement' : 'Disclaimer';

String disclaimerBody(String lang) => lang == 'fr'
    ? 'Ce contenu est à but informatif uniquement et ne constitue pas un avis médical. Pour toute question de santé ou décision personnelle, consultez un professionnel de santé.'
    : 'This content is for educational purposes only and is not medical advice. For any health question or personal decision, please consult a healthcare provider.';

// --- Tip of the day (phase-based) ---

String tipOfTheDayTitle(String lang) =>
    lang == 'fr' ? 'Conseil du jour' : 'Tip of the day';

String tipFallback(String lang) => lang == 'fr'
    ? 'Chaque cycle est unique. Notez vos symptômes pour mieux les partager avec votre partenaire ou un professionnel.'
    : 'Every cycle is unique. Track your symptoms to share better with your partner or a healthcare provider.';

class PhaseTip {
  const PhaseTip({required this.fr, required this.en});
  final String fr, en;
  String get(String lang) => lang == 'fr' ? fr : en;
}

Map<CyclePhase, PhaseTip> get phaseTips => {
  CyclePhase.menstrual: PhaseTip(
    fr: 'Repos et chaleur aident souvent. Proposez une bouillotte ou une tisane.',
    en: 'Rest and heat often help. Offer a heat pack or herbal tea.',
  ),
  CyclePhase.follicular: PhaseTip(
    fr: 'C\'est souvent une phase avec plus d\'énergie. Bon moment pour des activités à deux.',
    en: 'This is often a higher-energy phase. Good time for activities together.',
  ),
  CyclePhase.ovulation: PhaseTip(
    fr: 'Beaucoup ressentent un pic d\'énergie. Respectez le rythme de chacun.',
    en: 'Many feel an energy peak. Respect each other\'s pace.',
  ),
  CyclePhase.luteal: PhaseTip(
    fr: 'La progestérone peut causer fatigue et sensibilité. Écoute et réconfort font la différence.',
    en: 'Progesterone can cause fatigue and sensitivity. Listening and comfort make a difference.',
  ),
};

PhaseTip phaseTipFor(CyclePhase phase) =>
    phaseTips[phase] ?? PhaseTip(fr: tipFallback('fr'), en: tipFallback('en'));

// --- Period log form & list strings (for bilingual UI) ---

String periodLogNew(String lang) =>
    lang == 'fr' ? 'Nouvel enregistrement' : 'New entry';
String periodLogEdit(String lang) =>
    lang == 'fr' ? 'Modifier l\'enregistrement' : 'Edit entry';
String periodEmptyMessage(String lang) =>
    lang == 'fr' ? 'Aucun enregistrement' : 'No entries';
String periodEmptySecondary(String lang) => lang == 'fr'
    ? 'Appuyez sur + pour ajouter un enregistrement'
    : 'Tap + to add an entry';
String periodTipsCardTitle(String lang) => lang == 'fr' ? 'Conseils' : 'Tips';
String periodDeleteConfirmTitle(String lang) =>
    lang == 'fr' ? 'Supprimer cet enregistrement ?' : 'Delete this entry?';
String periodCancel(String lang) => lang == 'fr' ? 'Annuler' : 'Cancel';
String periodDelete(String lang) => lang == 'fr' ? 'Supprimer' : 'Delete';
String periodSave(String lang) => lang == 'fr' ? 'Enregistrer' : 'Save';
String periodMe(String lang) => lang == 'fr' ? 'Moi' : 'Me';
String periodPartner(String lang) => lang == 'fr' ? 'Partenaire' : 'Partner';
String periodStartDate(String lang) =>
    lang == 'fr' ? 'Date de début' : 'Start date';
String periodEndDate(String lang) =>
    lang == 'fr' ? 'Date de fin (optionnel)' : 'End date (optional)';
String periodMoodLabelForm(String lang) => lang == 'fr' ? 'Humeur' : 'Mood';
String periodSymptomsLabel(String lang) =>
    lang == 'fr' ? 'Symptômes (optionnel)' : 'Symptoms (optional)';
String periodNotesLabel(String lang) =>
    lang == 'fr' ? 'Notes (optionnel)' : 'Notes (optional)';
String periodErrorLoad(String lang) =>
    lang == 'fr' ? 'Erreur de chargement' : 'Load error';

// Partner reminder (PMS week)
String periodReminderSwitchTitle(String lang) => lang == 'fr'
    ? 'Me rappeler la semaine du SPM du partenaire'
    : 'Remind me when partner\'s PMS week is coming';
String periodReminderEstimated(String lang) =>
    lang == 'fr' ? 'Estimé : ' : 'Estimated: ';
String periodReminderNoDate(String lang) => lang == 'fr'
    ? 'Ajoutez des entrées de règles pour estimer la date.'
    : 'Add period entries to estimate the date.';
String periodReminderNotificationTitle(String lang) =>
    lang == 'fr' ? 'Semaine SPM à venir' : 'PMS week coming up';
String periodReminderNotificationBody(String lang) => lang == 'fr'
    ? 'La semaine du SPM de votre partenaire pourrait commencer. Pensez à un peu plus d\'écoute et de réconfort.'
    : 'Your partner\'s PMS week may be starting. Consider extra support and comfort.';

// Mood/symptom labels by language (value is same in DB)
String periodMoodOptionLabel(String value, String lang) {
  const mapFr = {
    'good': 'Bien',
    'tired': 'Fatigué(e)',
    'anxious': 'Anxieux(se)',
    'irritable': 'Irrité(e)',
  };
  const mapEn = {
    'good': 'Good',
    'tired': 'Tired',
    'anxious': 'Anxious',
    'irritable': 'Irritable',
  };
  final m = lang == 'fr' ? mapFr : mapEn;
  return m[value] ?? value;
}

String periodSymptomOptionLabel(String value, String lang) {
  const mapFr = {
    'cramps': 'Crampes',
    'headache': 'Maux de tête',
    'acne': 'Acné',
    'pain': 'Douleurs',
    'bloating': 'Ballonnements',
  };
  const mapEn = {
    'cramps': 'Cramps',
    'headache': 'Headache',
    'acne': 'Acne',
    'pain': 'Pain',
    'bloating': 'Bloating',
  };
  final m = lang == 'fr' ? mapFr : mapEn;
  return m[value] ?? value;
}
