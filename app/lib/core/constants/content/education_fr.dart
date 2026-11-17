import 'package:nousdeux/core/constants/content/education_text.dart';

/// The cycle education content in French.
const educationFr = EducationText(
  periodScreenTitle: 'Règles',

  // --- Understanding the cycle ---
  sectionCycleTitle: 'Comprendre le cycle menstruel',
  sectionCycleSubtitle:
      'Quatre phases, des hormones qui varient. Chaque cycle est unique.',
  sectionCycleIntro:
      'Un cycle dure en moyenne 28 jours, mais entre 21 et 35 jours est normal. Les hormones (œstrogène, progestérone) pilotent les phases et influencent le corps et l\'humeur.',
  menstrual: (
    name: 'Menstruation',
    description:
        'Les règles : la muqueuse utérine est évacuée. C\'est la phase la plus visible du cycle.',
    hormoneHint: 'Œstrogène et progestérone au plus bas.',
    physical: [
      'Saignement',
      'Crampes possibles',
      'Fatigue',
      'Douleurs au dos ou à la tête',
    ],
    emotional: ['Besoin de repos', 'Parfois plus sensible', 'Envie de calme'],
  ),
  follicular: (
    name: 'Folliculaire',
    description:
        'Les follicules ovariens mûrissent. L\'œstrogène remonte, l\'énergie souvent aussi.',
    hormoneHint: 'Œstrogène en hausse.',
    physical: [
      'Plus d\'énergie',
      'Peau souvent plus nette',
      'Endurance possible',
    ],
    emotional: ['Meilleure humeur', 'Plus sociable', 'Concentration facilitée'],
  ),
  ovulation: (
    name: 'Ovulation',
    description:
        'Libération de l\'ovule. Pic d\'œstrogène ; beaucoup ressentent un pic d\'énergie et de libido.',
    hormoneHint: 'Pic d\'œstrogène ; LH déclenche l\'ovulation.',
    physical: [
      'Énergie élevée',
      'Libido souvent plus forte',
      'Glaires cervicales plus fluides',
    ],
    emotional: ['Confiance', 'Ouverture aux autres', 'Optimisme'],
  ),
  luteal: (
    name: 'Lutéale',
    description:
        'Après l\'ovulation, la progestérone monte. Cela peut entraîner fatigue et sensibilité émotionnelle avant les règles.',
    hormoneHint: 'Progestérone élevée, puis chute avant les règles.',
    physical: [
      'Fatigue possible',
      'Ballonnements',
      'Seins sensibles',
      'Fringales possibles',
    ],
    emotional: [
      'Sensibilité émotionnelle',
      'PMS possible',
      'Besoin de réconfort',
    ],
  ),
  sectionQuickRefTitle: 'Aide-mémoire',
  quickRefCards: [
    (
      title: 'Menstruation (j1–5)',
      bullets: [
        'Règles, fatigue possible',
        'Soutien : repos, chaleur, pas de pression',
      ],
    ),
    (
      title: 'Folliculaire (j6–12)',
      bullets: [
        'Plus d\'énergie, humeur souvent bonne',
        'Idéal pour projets et sorties',
      ],
    ),
    (
      title: 'Ovulation (j13–15)',
      bullets: ['Pic d\'énergie et de libido', 'Respecter le rythme si besoin'],
    ),
    (
      title: 'Lutéale (j16–28)',
      bullets: [
        'Progestérone haute → fatigue, sensibilité',
        'Soutien : écoute, réconfort, partage des tâches',
      ],
    ),
  ],

  // --- Body and mood ---
  sectionPhysicalEmotionalTitle: 'Corps et émotions au fil du cycle',
  sectionPhysicalEmotionalSubtitle:
      'Les symptômes et l\'humeur varient selon la phase. C\'est biologique et normal.',
  sectionPsychologicalTitle: 'Impact psychologique',
  sectionPsychologicalIntro:
      'Les changements d\'humeur avant et pendant les règles sont réels et liés aux hormones. Les valider aide à mieux vivre le cycle.',
  pmsDefinition:
      'PMS (syndrome prémenstruel) : symptômes physiques et émotionnels les jours avant les règles (fatigue, irritabilité, tristesse, ballonnements). Très courant.',
  pmddDefinition:
      'PMDD (trouble dysphorique prémenstruel) : forme plus sévère, avec impact important sur l\'humeur et la vie quotidienne. Moins fréquent, mais à prendre au sérieux.',
  whenToSeekHelp:
      'Consulter un professionnel si : symptômes très invalidants, idées noires, conflits répétés, ou si vous avez des doutes.',

  // --- How partners can support ---
  sectionPartnerSupportSubtitle:
      'Actions concrètes et attitudes qui aident, phase par phase.',
  sectionPartnerSupportIntro:
      'Chaque personne est différente. L\'idéal est d\'en parler ensemble : ce qui fait du bien, les limites, et ce qu\'il vaut mieux éviter.',
  partnerDoSay:
      'À dire : « Comment tu te sens ? », « Tu veux que je te prépare quelque chose ? », « Je suis là si tu as besoin. »',
  partnerDontSay:
      'À éviter : « C\'est encore tes règles ? », « Tu exagères », ou minimiser la douleur.',
  comfortKitTitle: 'Créer un « kit confort » ensemble',
  comfortKitBody:
      'Par exemple : bouillotte, tisane, snacks préférés, antidouleur si OK pour elle/lui, couverture. À adapter selon les préférences.',

  // --- Talking about it ---
  sectionCommunicationSubtitle:
      'Formuler les questions et le soutien avec respect.',
  communicationTemplates: [
    (
      avoid: 'C\'est encore tes règles ?',
      tryInstead:
          'Comment tu te sens aujourd\'hui ? Tu as besoin de quelque chose ?',
    ),
    (
      avoid: 'Tu exagères.',
      tryInstead: 'Je vois que c\'est difficile. Je suis là.',
    ),
    (
      avoid: 'C\'est dans ta tête.',
      tryInstead: 'Tes symptômes sont réels. On peut en parler.',
    ),
    (
      avoid: 'Dépêche-toi, on a des trucs à faire.',
      tryInstead: 'On peut décaler / alléger si tu préfères.',
    ),
  ],
  expressingNeedsTitle: 'Exprimer ses besoins',
  expressingNeedsBody:
      'La personne qui a ses règles peut dire : « J\'ai besoin de repos », « J\'aimerais qu\'on reste à la maison », « Pas de dispute aujourd\'hui si possible ». Le partenaire peut proposer des options sans forcer.',
  boundariesTitle: 'Poser des limites avec respect',
  boundariesBody:
      'Les deux peuvent fixer des limites : « J\'ai besoin d\'un moment seul », « On en reparle ce soir ». Écouter et ne pas prendre pour un rejet.',
  planningTogetherTitle: 'Planifier ensemble',
  planningTogetherBody:
      'Connaître les grandes phases aide à planifier : sorties, charge de travail, moments de récupération. Sans que le cycle dicte tout, il peut être pris en compte.',

  // --- Myths and FAQ ---
  sectionMythBustersSubtitle: 'Démêler le vrai du faux.',
  mythBusters: [
    (
      myth: 'Les règles, c\'est « juste » des crampes.',
      fact:
          'Les douleurs peuvent inclure le dos, la tête, les seins, les troubles digestifs. Ces symptômes sont réels et méritent attention et soins.',
    ),
    (
      myth: 'C\'est psychologique / elle exagère.',
      fact:
          'Les changements sont liés aux hormones. La sensibilité et la fatigue sont biologiques. Les invalider aggrave souvent le mal-être.',
    ),
    (
      myth: 'Toutes les femmes ont le même cycle.',
      fact:
          'Chaque cycle est différent (durée, intensité, symptômes). Ce qui est normal pour une personne ne l\'est pas forcément pour une autre.',
    ),
    (
      myth: 'On ne peut rien faire pour aider.',
      fact:
          'Écouter, proposer du réconfort, alléger les tâches et éviter les remarques blessantes font une vraie différence.',
    ),
  ],
  faq: [
    (
      question: 'Qu\'est-ce que le SPM ?',
      answer:
          'Le syndrome prémenstruel regroupe des symptômes physiques et émotionnels dans les jours avant les règles (fatigue, irritabilité, ballonnements, etc.). C\'est courant et variable d\'une personne à l\'autre.',
    ),
    (
      question: 'Comment savoir si c\'est du SPM ou autre chose ?',
      answer:
          'Si les symptômes reviennent de façon cyclique avant les règles et s\'atténuent après, c\'est souvent lié au cycle. En cas de doute ou si ça impacte beaucoup la vie, un professionnel peut aider.',
    ),
    (
      question: 'Mon partenaire peut-il voir mes entrées ?',
      answer:
          'C\'est vous qui choisissez. Dans Règles, « Ce que … voit » a deux interrupteurs : votre cycle (jour, phase, date prévue) et votre ressenti du jour. Vos notes restent toujours privées : personne d\'autre ne peut les lire.',
    ),
    (
      question: 'Les règles rendent-elles vraiment plus irritable ?',
      answer:
          'Les hormones (notamment la chute de progestérone avant les règles) peuvent augmenter la sensibilité et la réactivité. Ce n\'est pas une « excuse » : c\'est physiologique. Le soutien et la compréhension aident.',
    ),
  ],

  // --- Sources and limits ---
  disclaimerTitle: 'Avertissement',
  disclaimerBody:
      'Ce contenu est à but informatif uniquement et ne constitue pas un avis médical. Pour toute question de santé ou décision personnelle, consultez un professionnel de santé.',

  // --- Period log and reminder ---
  periodLogNew: 'Nouvel enregistrement',
  periodLogEdit: 'Modifier l\'enregistrement',
  periodDeleteConfirmTitle: 'Supprimer cet enregistrement ?',
  periodCancel: 'Annuler',
  periodDelete: 'Supprimer',
  periodSave: 'Enregistrer',
  periodStartDate: 'Date de début',
  periodEndDate: 'Date de fin (optionnel)',
  periodReminderNotificationTitle: 'Règles prévues demain',
  periodReminderNotificationBody:
      "D'après son cycle, les règles de votre partenaire devraient commencer demain.",
  moodLabels: {
    'good': 'Bien',
    'tired': 'Fatigué(e)',
    'anxious': 'Anxieux(se)',
    'irritable': 'Irrité(e)',
  },
  symptomLabels: {
    'cramps': 'Crampes',
    'headache': 'Maux de tête',
    'acne': 'Acné',
    'pain': 'Douleurs',
    'bloating': 'Ballonnements',
  },
);
