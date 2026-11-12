// Verified external sources for period education. Links open in external browser.
//
// LINK VALIDATION: Validate URLs periodically (e.g. manual check or CI job that
// GETs each url and expects 2xx or known redirect). Remove or mark broken
// sources; update this file when links change or become unavailable.

/// Platform for display (e.g. "Website", "YouTube").
enum VerifiedSourcePlatform { web, youtube, instagram, other }

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
    required this.nameEn,
    required this.nameFr,
    required this.url,
    required this.topic,
    required this.locales,
    required this.credentialEn,
    required this.credentialFr,
    required this.summaryEn,
    required this.summaryFr,
  });

  final VerifiedSourcePlatform platform;
  final String nameEn;
  final String nameFr;
  final String url;
  final VerifiedSourceTopic topic;
  /// Language(s) of the content at [url] (e.g. ['en'], ['fr'], or ['en', 'fr']).
  final List<String> locales;

  final String credentialEn;
  final String credentialFr;
  final String summaryEn;
  final String summaryFr;

  String name(String lang) => lang == 'fr' ? nameFr : nameEn;
  String credential(String lang) => lang == 'fr' ? credentialFr : credentialEn;
  String summary(String lang) => lang == 'fr' ? summaryFr : summaryEn;

  String platformLabel(String lang) {
    switch (platform) {
      case VerifiedSourcePlatform.web:
        return lang == 'fr' ? 'Site web' : 'Website';
      case VerifiedSourcePlatform.youtube:
        return 'YouTube';
      case VerifiedSourcePlatform.instagram:
        return 'Instagram';
      case VerifiedSourcePlatform.other:
        return lang == 'fr' ? 'Lien externe' : 'External link';
    }
  }
}

/// Curated list of verified sources. Validate URLs before release.
List<VerifiedSource> get periodVerifiedSources => [
  // --- CYCLE BASICS ---
  VerifiedSource(
    platform: VerifiedSourcePlatform.web,
    nameEn: 'NHS – Periods',
    nameFr: 'NHS – Règles',
    url: 'https://www.nhs.uk/conditions/periods/',
    topic: VerifiedSourceTopic.cycleBasics,
    locales: ['en'],
    credentialEn: 'NHS (UK)',
    credentialFr: 'NHS (Royaume-Uni)',
    summaryEn: 'Official NHS overview of periods and menstrual health.',
    summaryFr: 'Vue d’ensemble officielle du NHS sur les règles.',
  ),
  VerifiedSource(
    platform: VerifiedSourcePlatform.web,
    nameEn: 'NHS Inform – The Menstrual Cycle',
    nameFr: 'NHS Inform – Le cycle menstruel',
    url:
        'https://www.nhsinform.scot/healthy-living/womens-health/girls-and-young-women-puberty-to-around-25/periods-and-menstrual-health/periods-menstruation',
    topic: VerifiedSourceTopic.cycleBasics,
    locales: ['en'],
    credentialEn: 'NHS Scotland',
    credentialFr: 'NHS Écosse',
    summaryEn: 'Evidence-based information on periods and when to seek help.',
    summaryFr: 'Informations factuelles sur les règles et quand consulter.',
  ),
  VerifiedSource(
    platform: VerifiedSourcePlatform.web,
    nameEn: 'Mayo Clinic – Menstrual cycle',
    nameFr: 'Mayo Clinic – Cycle menstruel',
    url:
        'https://www.mayoclinic.org/healthy-lifestyle/womens-health/in-depth/menstrual-cycle/art-20047186',
    topic: VerifiedSourceTopic.cycleBasics,
    locales: ['en'],
    credentialEn: 'Mayo Clinic',
    credentialFr: 'Mayo Clinic',
    summaryEn: 'How the menstrual cycle works and what’s normal.',
    summaryFr: 'Fonctionnement du cycle et ce qui est normal.',
  ),
  // --- CYCLE BASICS (French) ---
  VerifiedSource(
    platform: VerifiedSourcePlatform.web,
    nameEn: 'Lumni – How periods work',
    nameFr: 'Lumni – Les règles, comment ça marche ?',
    url: 'https://www.lumni.fr/video/les-regles-comment-ca-marche',
    topic: VerifiedSourceTopic.cycleBasics,
    locales: ['fr'],
    credentialEn: 'France Télévisions',
    credentialFr: 'France Télévisions',
    summaryEn: 'Short video on periods and the menstrual cycle.',
    summaryFr: 'Vidéo courte sur les règles et le cycle menstruel (Dr Jimmy Mohamed).',
  ),
  VerifiedSource(
    platform: VerifiedSourcePlatform.web,
    nameEn: 'Ministry of Health – Reproductive health',
    nameFr: 'Ministère de la Santé – Santé reproductive',
    url:
        'https://sante.gouv.fr/prevention-en-sante/preserver-sa-sante/sante-sexuelle-et-reproductive/article/sante-reproductive',
    topic: VerifiedSourceTopic.cycleBasics,
    locales: ['fr'],
    credentialEn: 'French Ministry of Health',
    credentialFr: 'Ministère de la Santé',
    summaryEn: 'Official French info on reproductive and sexual health.',
    summaryFr: 'Info officielle sur la santé sexuelle et reproductive.',
  ),
  VerifiedSource(
    platform: VerifiedSourcePlatform.web,
    nameEn: 'Le Fil Rouge – Menstrual cycle',
    nameFr: 'Le Fil Rouge – Cycle menstruel',
    url: 'https://rqasf.qc.ca/lefilrouge/menstrual-cycle/',
    topic: VerifiedSourceTopic.cycleBasics,
    locales: ['en'],
    credentialEn: 'RQASF (Quebec)',
    credentialFr: 'RQASF (Québec)',
    summaryEn: 'Phases of the menstrual cycle and lifestyle tips.',
    summaryFr: 'Phases du cycle et conseils pour le quotidien.',
  ),
  VerifiedSource(
    platform: VerifiedSourcePlatform.youtube,
    nameEn: 'Dr. Jen Gunter – Science of menstruation',
    nameFr: 'Dr. Jen Gunter – Science des règles',
    url: 'https://www.youtube.com/watch?v=QYdYpKc9icQ',
    topic: VerifiedSourceTopic.cycleBasics,
    locales: ['en'],
    credentialEn: 'OB-GYN, evidence-based',
    credentialFr: 'Gynécologue, factuelle',
    summaryEn: 'Evidence-based 10‑minute overview; debunks common myths.',
    summaryFr: 'Vue d’ensemble factuelle d’environ 10 min ; démêle mythes et réalités.',
  ),

  // --- GENERAL & EDUCATION ---
  VerifiedSource(
    platform: VerifiedSourcePlatform.web,
    nameEn: 'WHO – Menstrual Health',
    nameFr: 'OMS – Santé menstruelle',
    url:
        'https://www.who.int/europe/news-room/15-08-2024-menstrual-health-is-a-fundamental-human-right',
    topic: VerifiedSourceTopic.general,
    locales: ['en'],
    credentialEn: 'World Health Organization',
    credentialFr: 'Organisation mondiale de la santé',
    summaryEn: 'WHO Europe on menstrual health as a human right and key facts.',
    summaryFr: 'OMS Europe : santé menstruelle comme droit fondamental.',
  ),
  VerifiedSource(
    platform: VerifiedSourcePlatform.web,
    nameEn: 'UNFPA – Menstruations FAQ',
    nameFr: 'UNFPA – Menstruations, questions fréquentes',
    url: 'https://www.unfpa.org/fr/menstruations-questions-frequemment-posees',
    topic: VerifiedSourceTopic.general,
    locales: ['fr'],
    credentialEn: 'UNFPA',
    credentialFr: 'UNFPA',
    summaryEn: 'Comprehensive FAQ on menstruation and rights (French).',
    summaryFr: 'FAQ complète sur les règles, le cycle, le SPM et les droits.',
  ),
  VerifiedSource(
    platform: VerifiedSourcePlatform.web,
    nameEn: 'UNICEF – Menstrual Hygiene',
    nameFr: 'UNICEF – Hygiène menstruelle',
    url: 'https://www.unicef.org/wash/menstrual-hygiene',
    topic: VerifiedSourceTopic.general,
    locales: ['en'],
    credentialEn: 'UNICEF',
    credentialFr: 'UNICEF',
    summaryEn: 'Global guide on menstruation dignity and education.',
    summaryFr: 'Guide mondial sur la dignité et l’éducation menstruelle.',
  ),
  VerifiedSource(
    platform: VerifiedSourcePlatform.youtube,
    nameEn: 'Plan International France – Menstrual health',
    nameFr: 'Plan International France – Santé menstruelle',
    url: 'https://www.youtube.com/watch?v=obbIteVnxUw',
    topic: VerifiedSourceTopic.general,
    locales: ['fr'],
    credentialEn: 'Plan International France',
    credentialFr: 'Plan International France',
    summaryEn: 'Video: what is menstrual health? (French).',
    summaryFr: 'Vidéo : c’est quoi la santé menstruelle ?',
  ),
  VerifiedSource(
    platform: VerifiedSourcePlatform.instagram,
    nameEn: 'Gynae Geek',
    nameFr: 'Gynae Geek',
    url: 'https://www.instagram.com/gynaegeek/',
    topic: VerifiedSourceTopic.general,
    locales: ['en'],
    credentialEn: 'Evidence-based gynaecology',
    credentialFr: 'Gynécologie factuelle',
    summaryEn: 'Evidence-based cycle and menstrual content.',
    summaryFr: 'Contenu cycle et règles basé sur les preuves.',
  ),

  // --- PARTNER SUPPORT ---
  VerifiedSource(
    platform: VerifiedSourcePlatform.web,
    nameEn: 'Lil-Lets – A Guy’s Guide',
    nameFr: 'Lil-Lets – Guide pour les hommes',
    url: 'https://www.lil-lets.com/za/en/hub/a-guys-guide-to-periods/',
    topic: VerifiedSourceTopic.partnerSupport,
    locales: ['en'],
    credentialEn: 'Lil-Lets (UK)',
    credentialFr: 'Lil-Lets (Royaume-Uni)',
    summaryEn: 'A simple, no-nonsense guide to periods specifically for men.',
    summaryFr:
        'Un guide simple et direct sur les règles, conçu pour les hommes.',
  ),
  VerifiedSource(
    platform: VerifiedSourcePlatform.web,
    nameEn: 'Flo – Helping your partner',
    nameFr: 'Flo – Aider sa partenaire',
    url:
        'https://help.flo.health/hc/en-us/articles/19871961988116-What-is-Flo-for-Partners',
    topic: VerifiedSourceTopic.partnerSupport,
    locales: ['en'],
    credentialEn: 'Flo Health',
    credentialFr: 'Flo Health',
    summaryEn: 'Flo for Partners: share your cycle with your partner.',
    summaryFr: 'Flo for Partners : partager son suivi avec son partenaire.',
  ),
  VerifiedSource(
    platform: VerifiedSourcePlatform.web,
    nameEn: 'Planned Parenthood – Sexual Health',
    nameFr: 'Planned Parenthood – Santé sexuelle',
    url:
        'https://www.plannedparenthood.org/learn/health-and-wellness/menstruation',
    topic: VerifiedSourceTopic.partnerSupport,
    locales: ['en'],
    credentialEn: 'Planned Parenthood',
    credentialFr: 'Planned Parenthood',
    summaryEn: 'Comprehensive guide to menstruation and relationships.',
    summaryFr: 'Guide complet sur la menstruation et les relations.',
  ),

  // --- PMS & MEDICAL ---
  VerifiedSource(
    platform: VerifiedSourcePlatform.web,
    nameEn: 'Cleveland Clinic – PMS',
    nameFr: 'Cleveland Clinic – SPM',
    url:
        'https://my.clevelandclinic.org/health/diseases/24288-pms-premenstrual-syndrome',
    topic: VerifiedSourceTopic.pms,
    locales: ['en'],
    credentialEn: 'Cleveland Clinic',
    credentialFr: 'Cleveland Clinic',
    summaryEn: 'Medical overview of PMS and when to see a doctor.',
    summaryFr: 'Vue médicale du SPM et quand consulter.',
  ),
];

/// Sources whose content is in [lang]. Empty [locales] = show in all languages.
List<VerifiedSource> periodVerifiedSourcesForLang(String lang) {
  return periodVerifiedSources
      .where((s) =>
          s.locales.isEmpty || s.locales.contains(lang))
      .toList();
}

/// Sources for a given topic in the given language.
List<VerifiedSource> sourcesForTopic(
    VerifiedSourceTopic topic, String lang) {
  return periodVerifiedSourcesForLang(lang)
      .where((s) => s.topic == topic)
      .toList();
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
