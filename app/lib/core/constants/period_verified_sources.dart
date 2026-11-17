// Verified external sources for period education. Links open in external browser.
//
// LINK VALIDATION: Validate URLs periodically (e.g. manual check or CI job that
// GETs each url and expects 2xx or known redirect). Remove or mark broken
// sources; update this file when links change or become unavailable.
//
// LANGUAGES: each text is a map from language code to text. English is
// required and is what a language without its own text reads; every language
// in AppLanguages.supported has every text
// (test/l10n/content_completeness_test.dart).

import 'package:nousdeux/core/l10n/app_languages.dart';

/// [text] in [lang], or in English when it has none in [lang].
String _inLanguage(Map<String, String> text, String lang) =>
    text[lang] ?? text[AppLanguages.fallback]!;

/// Platform for display (e.g. "Website", "YouTube").
enum VerifiedSourcePlatform {
  web({'en': 'Website', 'fr': 'Site web'}),
  youtube({'en': 'YouTube', 'fr': 'YouTube'}),
  instagram({'en': 'Instagram', 'fr': 'Instagram'}),
  other({'en': 'External link', 'fr': 'Lien externe'});

  const VerifiedSourcePlatform(this.labels);

  /// What the platform is called, by language code.
  final Map<String, String> labels;
}

/// Topic for filtering sources by section.
enum VerifiedSourceTopic {
  cycleBasics,
  pms,
  partnerSupport,
  whenToSeekHelp,
  general,
}

class VerifiedSource {
  const VerifiedSource({
    required this.platform,
    required this.names,
    required this.url,
    required this.topic,
    required this.locales,
    required this.credentials,
    required this.summaries,
  });

  final VerifiedSourcePlatform platform;

  /// The source's name, by language code.
  final Map<String, String> names;
  final String url;
  final VerifiedSourceTopic topic;

  /// Language(s) of the content at [url] (e.g. ['en'], ['fr'], or ['en', 'fr']).
  final List<String> locales;

  /// Who stands behind it, by language code.
  final Map<String, String> credentials;

  /// What it covers, by language code.
  final Map<String, String> summaries;

  String name(String lang) => _inLanguage(names, lang);
  String credential(String lang) => _inLanguage(credentials, lang);
  String summary(String lang) => _inLanguage(summaries, lang);

  String platformLabel(String lang) => _inLanguage(platform.labels, lang);
}

/// Curated list of verified sources. Validate URLs before release.
List<VerifiedSource> get periodVerifiedSources => [
  // --- CYCLE BASICS ---
  VerifiedSource(
    platform: VerifiedSourcePlatform.web,
    names: {'en': 'NHS – Periods', 'fr': 'NHS – Règles'},
    url: 'https://www.nhs.uk/conditions/periods/',
    topic: VerifiedSourceTopic.cycleBasics,
    locales: ['en'],
    credentials: {'en': 'NHS (UK)', 'fr': 'NHS (Royaume-Uni)'},
    summaries: {
      'en': 'Official NHS overview of periods and menstrual health.',
      'fr': 'Vue d’ensemble officielle du NHS sur les règles.',
    },
  ),
  VerifiedSource(
    platform: VerifiedSourcePlatform.web,
    names: {
      'en': 'NHS Inform – The Menstrual Cycle',
      'fr': 'NHS Inform – Le cycle menstruel',
    },
    url:
        'https://www.nhsinform.scot/healthy-living/womens-health/girls-and-young-women-puberty-to-around-25/periods-and-menstrual-health/periods-menstruation',
    topic: VerifiedSourceTopic.cycleBasics,
    locales: ['en'],
    credentials: {'en': 'NHS Scotland', 'fr': 'NHS Écosse'},
    summaries: {
      'en': 'Evidence-based information on periods and when to seek help.',
      'fr': 'Informations factuelles sur les règles et quand consulter.',
    },
  ),
  VerifiedSource(
    platform: VerifiedSourcePlatform.web,
    names: {
      'en': 'Mayo Clinic – Menstrual cycle',
      'fr': 'Mayo Clinic – Cycle menstruel',
    },
    url:
        'https://www.mayoclinic.org/healthy-lifestyle/womens-health/in-depth/menstrual-cycle/art-20047186',
    topic: VerifiedSourceTopic.cycleBasics,
    locales: ['en'],
    credentials: {'en': 'Mayo Clinic', 'fr': 'Mayo Clinic'},
    summaries: {
      'en': 'How the menstrual cycle works and what’s normal.',
      'fr': 'Fonctionnement du cycle et ce qui est normal.',
    },
  ),
  // --- CYCLE BASICS (French) ---
  VerifiedSource(
    platform: VerifiedSourcePlatform.web,
    names: {
      'en': 'Lumni – How periods work',
      'fr': 'Lumni – Les règles, comment ça marche ?',
    },
    url: 'https://www.lumni.fr/video/les-regles-comment-ca-marche',
    topic: VerifiedSourceTopic.cycleBasics,
    locales: ['fr'],
    credentials: {'en': 'France Télévisions', 'fr': 'France Télévisions'},
    summaries: {
      'en': 'Short video on periods and the menstrual cycle.',
      'fr':
          'Vidéo courte sur les règles et le cycle menstruel (Dr Jimmy Mohamed).',
    },
  ),
  VerifiedSource(
    platform: VerifiedSourcePlatform.web,
    names: {
      'en': 'Ministry of Health – Reproductive health',
      'fr': 'Ministère de la Santé – Santé reproductive',
    },
    url:
        'https://sante.gouv.fr/prevention-en-sante/preserver-sa-sante/sante-sexuelle-et-reproductive/article/sante-reproductive',
    topic: VerifiedSourceTopic.cycleBasics,
    locales: ['fr'],
    credentials: {
      'en': 'French Ministry of Health',
      'fr': 'Ministère de la Santé',
    },
    summaries: {
      'en': 'Official French info on reproductive and sexual health.',
      'fr': 'Info officielle sur la santé sexuelle et reproductive.',
    },
  ),
  VerifiedSource(
    platform: VerifiedSourcePlatform.youtube,
    names: {
      'en': 'Dr. Jen Gunter – Science of menstruation',
      'fr': 'Dr. Jen Gunter – Science des règles',
    },
    url: 'https://www.youtube.com/watch?v=QYdYpKc9icQ',
    topic: VerifiedSourceTopic.cycleBasics,
    locales: ['en'],
    credentials: {
      'en': 'OB-GYN, evidence-based',
      'fr': 'Gynécologue, factuelle',
    },
    summaries: {
      'en': 'Evidence-based 10‑minute overview; debunks common myths.',
      'fr':
          'Vue d’ensemble factuelle d’environ 10 min ; démêle mythes et réalités.',
    },
  ),

  // --- GENERAL & EDUCATION ---
  VerifiedSource(
    platform: VerifiedSourcePlatform.web,
    names: {'en': 'WHO – Menstrual Health', 'fr': 'OMS – Santé menstruelle'},
    url:
        'https://www.who.int/europe/news-room/15-08-2024-menstrual-health-is-a-fundamental-human-right',
    topic: VerifiedSourceTopic.general,
    locales: ['en'],
    credentials: {
      'en': 'World Health Organization',
      'fr': 'Organisation mondiale de la santé',
    },
    summaries: {
      'en': 'WHO Europe on menstrual health as a human right and key facts.',
      'fr': 'OMS Europe : santé menstruelle comme droit fondamental.',
    },
  ),
  VerifiedSource(
    platform: VerifiedSourcePlatform.web,
    names: {
      'en': 'UNFPA – Menstruations FAQ',
      'fr': 'UNFPA – Menstruations, questions fréquentes',
    },
    url: 'https://www.unfpa.org/fr/menstruations-questions-frequemment-posees',
    topic: VerifiedSourceTopic.general,
    locales: ['fr'],
    credentials: {'en': 'UNFPA', 'fr': 'UNFPA'},
    summaries: {
      'en': 'Comprehensive FAQ on menstruation and rights (French).',
      'fr': 'FAQ complète sur les règles, le cycle, le SPM et les droits.',
    },
  ),
  VerifiedSource(
    platform: VerifiedSourcePlatform.web,
    names: {
      'en': 'UNICEF – Menstrual Hygiene',
      'fr': 'UNICEF – Hygiène menstruelle',
    },
    url: 'https://www.unicef.org/wash/menstrual-hygiene',
    topic: VerifiedSourceTopic.general,
    locales: ['en'],
    credentials: {'en': 'UNICEF', 'fr': 'UNICEF'},
    summaries: {
      'en': 'Global guide on menstruation dignity and education.',
      'fr': 'Guide mondial sur la dignité et l’éducation menstruelle.',
    },
  ),
  VerifiedSource(
    platform: VerifiedSourcePlatform.youtube,
    names: {
      'en': 'Plan International France – Menstrual health',
      'fr': 'Plan International France – Santé menstruelle',
    },
    url: 'https://www.youtube.com/watch?v=obbIteVnxUw',
    topic: VerifiedSourceTopic.general,
    locales: ['fr'],
    credentials: {
      'en': 'Plan International France',
      'fr': 'Plan International France',
    },
    summaries: {
      'en': 'Video: what is menstrual health? (French).',
      'fr': 'Vidéo : c’est quoi la santé menstruelle ?',
    },
  ),
  VerifiedSource(
    platform: VerifiedSourcePlatform.instagram,
    names: {'en': 'Gynae Geek', 'fr': 'Gynae Geek'},
    url: 'https://www.instagram.com/gynaegeek/',
    topic: VerifiedSourceTopic.general,
    locales: ['en'],
    credentials: {
      'en': 'Evidence-based gynaecology',
      'fr': 'Gynécologie factuelle',
    },
    summaries: {
      'en': 'Evidence-based cycle and menstrual content.',
      'fr': 'Contenu cycle et règles basé sur les preuves.',
    },
  ),

  // --- PARTNER SUPPORT ---
  VerifiedSource(
    platform: VerifiedSourcePlatform.web,
    names: {
      'en': 'Lil-Lets – A Guy’s Guide',
      'fr': 'Lil-Lets – Guide pour les hommes',
    },
    url: 'https://www.lil-lets.com/za/en/hub/a-guys-guide-to-periods/',
    topic: VerifiedSourceTopic.partnerSupport,
    locales: ['en'],
    credentials: {'en': 'Lil-Lets (UK)', 'fr': 'Lil-Lets (Royaume-Uni)'},
    summaries: {
      'en': 'A simple, no-nonsense guide to periods specifically for men.',
      'fr': 'Un guide simple et direct sur les règles, conçu pour les hommes.',
    },
  ),
  VerifiedSource(
    platform: VerifiedSourcePlatform.web,
    names: {
      'en': 'Flo – Helping your partner',
      'fr': 'Flo – Aider sa partenaire',
    },
    url:
        'https://help.flo.health/hc/en-us/articles/19871961988116-What-is-Flo-for-Partners',
    topic: VerifiedSourceTopic.partnerSupport,
    locales: ['en'],
    credentials: {'en': 'Flo Health', 'fr': 'Flo Health'},
    summaries: {
      'en': 'Flo for Partners: share your cycle with your partner.',
      'fr': 'Flo for Partners : partager son suivi avec son partenaire.',
    },
  ),
  VerifiedSource(
    platform: VerifiedSourcePlatform.web,
    names: {
      'en': 'Planned Parenthood – Sexual Health',
      'fr': 'Planned Parenthood – Santé sexuelle',
    },
    url:
        'https://www.plannedparenthood.org/learn/health-and-wellness/menstruation',
    topic: VerifiedSourceTopic.partnerSupport,
    locales: ['en'],
    credentials: {'en': 'Planned Parenthood', 'fr': 'Planned Parenthood'},
    summaries: {
      'en': 'Comprehensive guide to menstruation and relationships.',
      'fr': 'Guide complet sur la menstruation et les relations.',
    },
  ),

  // --- PMS & MEDICAL ---
  VerifiedSource(
    platform: VerifiedSourcePlatform.web,
    names: {'en': 'Cleveland Clinic – PMS', 'fr': 'Cleveland Clinic – SPM'},
    url:
        'https://my.clevelandclinic.org/health/diseases/24288-pms-premenstrual-syndrome',
    topic: VerifiedSourceTopic.pms,
    locales: ['en'],
    credentials: {'en': 'Cleveland Clinic', 'fr': 'Cleveland Clinic'},
    summaries: {
      'en': 'Medical overview of PMS and when to see a doctor.',
      'fr': 'Vue médicale du SPM et quand consulter.',
    },
  ),
];

/// Sources whose content is in [lang]. Empty [locales] = show in all languages.
List<VerifiedSource> periodVerifiedSourcesForLang(String lang) {
  return periodVerifiedSources
      .where((s) => s.locales.isEmpty || s.locales.contains(lang))
      .toList();
}

/// Sources for a given topic in the given language.
List<VerifiedSource> sourcesForTopic(VerifiedSourceTopic topic, String lang) {
  return periodVerifiedSourcesForLang(
    lang,
  ).where((s) => s.topic == topic).toList();
}

/// Sources relevant to "when to seek help" (PMS + general), in the given language.
List<VerifiedSource> sourcesWhenToSeekHelp(String lang) {
  return periodVerifiedSourcesForLang(lang)
      .where(
        (s) =>
            s.topic == VerifiedSourceTopic.pms ||
            s.topic == VerifiedSourceTopic.whenToSeekHelp ||
            s.topic == VerifiedSourceTopic.general,
      )
      .toList();
}

/// Sources relevant to partner support (partner support + general), in the given language.
List<VerifiedSource> sourcesPartnerSupport(String lang) {
  return periodVerifiedSourcesForLang(lang)
      .where(
        (s) =>
            s.topic == VerifiedSourceTopic.partnerSupport ||
            s.topic == VerifiedSourceTopic.general,
      )
      .toList();
}
