import 'package:nousdeux/core/constants/content/education_text.dart';

/// The cycle education content in English, the reference other languages
/// are translated from.
const educationEn = EducationText(
  // --- Understanding the cycle ---
  sectionCycleTitle: 'Understanding the Menstrual Cycle',
  sectionCycleSubtitle:
      'Four phases, changing hormones. Every cycle is unique.',
  sectionCycleIntro:
      'A cycle averages 28 days, but 21–35 days is normal. Hormones (estrogen, progesterone) drive the phases and affect body and mood.',
  menstrual: (
    name: 'Menstrual',
    description:
        'Your period: the uterine lining is shed. This is the most visible phase.',
    hormoneHint: 'Estrogen and progesterone at their lowest.',
    physical: ['Bleeding', 'Possible cramps', 'Fatigue', 'Back or head pain'],
    emotional: ['Need for rest', 'Sometimes more sensitive', 'Craving calm'],
  ),
  follicular: (
    name: 'Follicular',
    description:
        'Ovarian follicles mature. Estrogen rises; energy often does too.',
    hormoneHint: 'Estrogen rising.',
    physical: ['More energy', 'Skin often clearer', 'Stamina may increase'],
    emotional: ['Better mood', 'More sociable', 'Easier to focus'],
  ),
  ovulation: (
    name: 'Ovulation',
    description:
        'Egg is released. Estrogen peaks; many feel a peak in energy and libido.',
    hormoneHint: 'Estrogen peak; LH triggers ovulation.',
    physical: [
      'High energy',
      'Libido often higher',
      'More fluid cervical mucus',
    ],
    emotional: ['Confidence', 'Openness to others', 'Optimism'],
  ),
  luteal: (
    name: 'Luteal',
    description:
        'After ovulation, progesterone rises. This can cause fatigue and mood sensitivity before your period.',
    hormoneHint: 'Progesterone high, then drops before period.',
    physical: [
      'Possible fatigue',
      'Bloating',
      'Tender breasts',
      'Possible cravings',
    ],
    emotional: ['Emotional sensitivity', 'PMS possible', 'Need for comfort'],
  ),
  sectionQuickRefTitle: 'Quick Reference Cards',
  quickRefCards: [
    (
      title: 'Menstrual (day 1–5)',
      bullets: ['Period, possible fatigue', 'Support: rest, heat, no pressure'],
    ),
    (
      title: 'Follicular (day 6–12)',
      bullets: [
        'More energy, mood often better',
        'Good time for projects and outings',
      ],
    ),
    (
      title: 'Ovulation (day 13–15)',
      bullets: ['Peak energy and libido', 'Respect their pace if needed'],
    ),
    (
      title: 'Luteal (day 16–28)',
      bullets: [
        'Progesterone up → fatigue, sensitivity',
        'Support: listen, comfort, share tasks',
      ],
    ),
  ],

  // --- Body and mood ---
  sectionPhysicalEmotionalTitle:
      'Physical & Emotional Changes Throughout the Cycle',
  sectionPhysicalEmotionalSubtitle:
      'Symptoms and mood vary by phase. This is biological and normal.',
  sectionPsychologicalTitle: 'Psychological impact',
  sectionPsychologicalIntro:
      'Mood changes before and during your period are real and hormone-related. Validating them helps.',
  pmsDefinition:
      'PMS (premenstrual syndrome): physical and emotional symptoms in the days before your period (fatigue, irritability, sadness, bloating). Very common.',
  pmddDefinition:
      'PMDD (premenstrual dysphoric disorder): a more severe form, with a major impact on mood and daily life. Less common but serious.',
  whenToSeekHelp:
      'See a healthcare provider if: symptoms are very disabling, dark thoughts, repeated conflict, or if you have any doubts.',

  // --- How partners can support ---
  sectionPartnerSupportSubtitle:
      'Practical actions and attitudes that help, phase by phase.',
  sectionPartnerSupportIntro:
      'Everyone is different. The best approach is to talk together: what helps, boundaries, and what to avoid.',
  partnerDoSay:
      'Say: "How are you feeling?", "Want me to get you something?", "I\'m here if you need me."',
  partnerDontSay:
      'Avoid: "Is it that time of the month?", "You\'re overreacting," or downplaying pain.',
  comfortKitTitle: 'Creating a "period comfort kit" together',
  comfortKitBody:
      'E.g. heat pack, herbal tea, favorite snacks, pain relief if they\'re okay with it, blanket. Adapt to their preferences.',

  // --- Talking about it ---
  sectionCommunicationSubtitle: 'Asking and supporting with respect.',
  communicationTemplates: [
    (
      avoid: 'Is it that time of the month?',
      tryInstead:
          'How are you feeling today? Is there anything I can do to support you?',
    ),
    (
      avoid: 'You\'re overreacting.',
      tryInstead: 'I see this is hard. I\'m here for you.',
    ),
    (
      avoid: 'It\'s all in your head.',
      tryInstead: 'Your symptoms are real. We can talk about it.',
    ),
    (
      avoid: 'Hurry up, we have things to do.',
      tryInstead: 'We can reschedule or take it easy if you prefer.',
    ),
  ],
  expressingNeedsTitle: 'Expressing needs',
  expressingNeedsBody:
      'The person on their period can say: "I need rest," "I\'d like to stay in," "Let\'s avoid arguments today if possible." The partner can offer options without pushing.',
  boundariesTitle: 'Setting boundaries respectfully',
  boundariesBody:
      'Both can set boundaries: "I need some time alone," "Let\'s talk about it tonight." Listen and don\'t take it as rejection.',
  planningTogetherTitle: 'Planning around the cycle together',
  planningTogetherBody:
      'Knowing the main phases helps with planning: outings, workload, recovery time. The cycle doesn\'t have to rule everything, but it can be part of the picture.',

  // --- Myths and FAQ ---
  sectionMythBustersSubtitle: 'Separating fact from fiction.',
  mythBusters: [
    (
      myth: 'Period pain is "just" cramps.',
      fact:
          'Period pain can include back pain, headaches, breast tenderness, and digestive issues. These symptoms are valid and deserve care.',
    ),
    (
      myth: 'It\'s psychological / they\'re exaggerating.',
      fact:
          'Changes are hormone-related. Sensitivity and fatigue are biological. Invalidating them often makes things worse.',
    ),
    (
      myth: 'Everyone has the same cycle.',
      fact:
          'Every cycle is different (length, intensity, symptoms). What\'s normal for one person may not be for another.',
    ),
    (
      myth: 'There\'s nothing you can do to help.',
      fact:
          'Listening, offering comfort, easing tasks, and avoiding hurtful comments make a real difference.',
    ),
  ],
  faq: [
    (
      question: 'What is PMS?',
      answer:
          'Premenstrual syndrome includes physical and emotional symptoms in the days before your period (fatigue, irritability, bloating, etc.). It\'s common and varies from person to person.',
    ),
    (
      question: 'How do I know if it\'s PMS or something else?',
      answer:
          'If symptoms come back in a cycle before your period and ease after, it\'s often cycle-related. When in doubt or if it greatly affects your life, a healthcare provider can help.',
    ),
    (
      question: 'Can my partner see my entries?',
      answer:
          'You choose. In Period, "What … sees" has two switches: your cycle (day, phase, expected date) and how you feel each day. Your notes always stay private: nobody else can read them.',
    ),
    (
      question: 'Do periods really make you more irritable?',
      answer:
          'Hormones (especially the drop in progesterone before your period) can increase sensitivity and reactivity. It\'s not an "excuse": it\'s physiological. Support and understanding help.',
    ),
  ],

  // --- Sources and limits ---
  disclaimerTitle: 'Disclaimer',
  disclaimerBody:
      'This content is for educational purposes only and is not medical advice. For any health question or personal decision, please consult a healthcare provider.',
);
