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
        'https://www.nhsinform.scot/illnesses-and-conditions/sexual-and-reproductive/the-menstrual-cycle',
    topic: VerifiedSourceTopic.cycleBasics,
    credentialEn: 'NHS Scotland',
    credentialFr: 'NHS Écosse',
    summaryEn: 'Evidence-based information on periods and when to seek help.',
    summaryFr: 'Informations factuelles sur les règles et quand consulter.',
  ),
  VerifiedSource(
    platform: VerifiedSourcePlatform.web,
    nameEn: 'Ameli – Rules and cycle',
    nameFr: 'Ameli – Règles et cycle',
    url:
        'https://www.ameli.fr/assure/sante/themes/regles-comprendre-cycle-menstruel',
    topic: VerifiedSourceTopic.cycleBasics,
    credentialEn: 'French health insurance',
    credentialFr: 'Assurance maladie',
    summaryEn: 'French official health info on the menstrual cycle.',
    summaryFr: 'Info officielle sur le cycle menstruel.',
  ),
  VerifiedSource(
    platform: VerifiedSourcePlatform.web,
    nameEn: 'Mayo Clinic – Menstrual cycle',
    nameFr: 'Mayo Clinic – Cycle menstruel',
    url:
        'https://www.mayoclinic.org/healthy-lifestyle/womens-health/in-depth/menstrual-cycle/art-20047186',
    topic: VerifiedSourceTopic.cycleBasics,
    credentialEn: 'Mayo Clinic',
    credentialFr: 'Mayo Clinic',
    summaryEn: 'How the menstrual cycle works and what’s normal.',
    summaryFr: 'Fonctionnement du cycle et ce qui est normal.',
  ),

  // --- GENERAL & EDUCATION ---
  VerifiedSource(
    platform: VerifiedSourcePlatform.web,
    nameEn: 'WHO – Menstrual Health',
    nameFr: 'OMS – Santé menstruelle',
    // Updated to the stable Fact Sheet URL (replaces broken Q&A link)
    url:
        'https://www.who.int/news-room/fact-sheets/detail/menstruation-and-menstrual-health',
    topic: VerifiedSourceTopic.general,
    credentialEn: 'World Health Organization',
    credentialFr: 'Organisation mondiale de la santé',
    summaryEn: 'Key facts and global standards on menstrual health.',
    summaryFr: 'Faits clés et normes mondiales sur la santé menstruelle.',
  ),
  VerifiedSource(
    platform: VerifiedSourcePlatform.web,
    nameEn: 'UNICEF – Menstrual Hygiene',
    nameFr: 'UNICEF – Hygiène menstruelle',
    url: 'https://www.unicef.org/wash/menstrual-hygiene',
    topic: VerifiedSourceTopic.general,
    credentialEn: 'UNICEF',
    credentialFr: 'UNICEF',
    summaryEn: 'Global guide on menstruation dignity and education.',
    summaryFr: 'Guide mondial sur la dignité et l’éducation menstruelle.',
  ),
  VerifiedSource(
    platform: VerifiedSourcePlatform.instagram,
    nameEn: 'Gynae Geek',
    nameFr: 'Gynae Geek',
    url: 'https://www.instagram.com/gynaegeek/',
    topic: VerifiedSourceTopic.general,
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
    url:
        'https://www.lil-lets.com/uk/wellbeing/menstruation/a-guys-guide-to-periods/',
    topic: VerifiedSourceTopic.partnerSupport,
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
        'https://flo.health/menstrual-cycle/health/period/helping-girlfriend-on-period',
    topic: VerifiedSourceTopic.partnerSupport,
    credentialEn: 'Flo Health',
    credentialFr: 'Flo Health',
    summaryEn:
        'Practical tips on how to support a partner during their period.',
    summaryFr:
        'Conseils pratiques pour soutenir sa partenaire pendant ses règles.',
  ),
  VerifiedSource(
    platform: VerifiedSourcePlatform.web,
    nameEn: 'Planned Parenthood – Sexual Health',
    nameFr: 'Planned Parenthood – Santé sexuelle',
    url:
        'https://www.plannedparenthood.org/learn/health-and-wellness/menstruation',
    topic: VerifiedSourceTopic.partnerSupport,
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
        'https://my.clevelandclinic.org/health/diseases/24288-premenstrual-syndrome-pms',
    topic: VerifiedSourceTopic.pms,
    credentialEn: 'Cleveland Clinic',
    credentialFr: 'Cleveland Clinic',
    summaryEn: 'Medical overview of PMS and when to see a doctor.',
    summaryFr: 'Vue médicale du SPM et quand consulter.',
  ),
];

/// Sources for a given topic (e.g. show in "When to seek help" or "Partner support").
List<VerifiedSource> sourcesForTopic(VerifiedSourceTopic topic) {
  return periodVerifiedSources.where((s) => s.topic == topic).toList();
}

/// Sources relevant to "when to seek help" (PMS + general).
List<VerifiedSource> get sourcesWhenToSeekHelp => periodVerifiedSources
    .where(
      (s) =>
          s.topic == VerifiedSourceTopic.pms ||
          s.topic == VerifiedSourceTopic.whenToSeekHelp ||
          s.topic == VerifiedSourceTopic.general,
    )
    .toList();

/// Sources relevant to partner support (partner support + general).
List<VerifiedSource> get sourcesPartnerSupport => periodVerifiedSources
    .where(
      (s) =>
          s.topic == VerifiedSourceTopic.partnerSupport ||
          s.topic == VerifiedSourceTopic.general,
    )
    .toList();
