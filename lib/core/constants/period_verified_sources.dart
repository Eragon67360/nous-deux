// Verified external sources for period education. Links open in external browser.
//
// LINK VALIDATION: Validate URLs periodically (e.g. manual check or CI job that
// GETs each url and expects 2xx or known redirect). Remove or mark broken
// sources; update this file when links change or become unavailable.

/// Platform for display (e.g. "Website", "YouTube").
enum VerifiedSourcePlatform {
  web,
  youtube,
  instagram,
  other,
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
      VerifiedSource(
        platform: VerifiedSourcePlatform.web,
        nameEn: 'NHS – Periods',
        nameFr: 'NHS – Règles',
        url: 'https://www.nhs.uk/conditions/periods/',
        topic: VerifiedSourceTopic.cycleBasics,
        credentialEn: 'NHS (UK)',
        credentialFr: 'NHS (Royaume-Uni)',
        summaryEn: 'Official NHS overview of periods and menstrual health.',
        summaryFr: 'Vue d’ensemble officielle du NHS sur les règles et la santé menstruelle.',
      ),
      VerifiedSource(
        platform: VerifiedSourcePlatform.web,
        nameEn: 'NHS Inform – Periods',
        nameFr: 'NHS Inform – Règles',
        url: 'https://www.nhsinform.scot/healthy-living/womens-health/girls-and-young-women-puberty-to-around-25/periods-and-menstrual-health/periods-menstruation/',
        topic: VerifiedSourceTopic.cycleBasics,
        credentialEn: 'NHS Scotland',
        credentialFr: 'NHS Écosse',
        summaryEn: 'Evidence-based information on periods and when to seek help.',
        summaryFr: 'Informations factuelles sur les règles et quand consulter.',
      ),
      VerifiedSource(
        platform: VerifiedSourcePlatform.web,
        nameEn: 'WHO – Menstrual health',
        nameFr: 'OMS – Santé menstruelle',
        url: 'https://www.who.int/news-room/questions-and-answers/item/menstruation-and-menstrual-health',
        topic: VerifiedSourceTopic.general,
        credentialEn: 'World Health Organization',
        credentialFr: 'Organisation mondiale de la santé',
        summaryEn: 'WHO guidance on menstrual health and when to seek care.',
        summaryFr: 'Recommandations OMS sur la santé menstruelle et les soins.',
      ),
      VerifiedSource(
        platform: VerifiedSourcePlatform.web,
        nameEn: 'Ameli – Rules and cycle',
        nameFr: 'Ameli – Règles et cycle',
        url: 'https://www.ameli.fr/assure/sante/themes/regles-comprendre-cycle-menstruel',
        topic: VerifiedSourceTopic.cycleBasics,
        credentialEn: 'French health insurance',
        credentialFr: 'Assurance maladie',
        summaryEn: 'French official health info on the menstrual cycle.',
        summaryFr: 'Info officielle sur le cycle menstruel.',
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
      VerifiedSource(
        platform: VerifiedSourcePlatform.web,
        nameEn: 'Cleveland Clinic – PMS',
        nameFr: 'Cleveland Clinic – SPM',
        url: 'https://my.clevelandclinic.org/health/diseases/24288-premenstrual-syndrome-pms',
        topic: VerifiedSourceTopic.pms,
        credentialEn: 'Cleveland Clinic',
        credentialFr: 'Cleveland Clinic',
        summaryEn: 'Medical overview of PMS and when to see a doctor.',
        summaryFr: 'Vue médicale du SPM et quand consulter.',
      ),
      VerifiedSource(
        platform: VerifiedSourcePlatform.web,
        nameEn: 'Mayo Clinic – Menstrual cycle',
        nameFr: 'Mayo Clinic – Cycle menstruel',
        url: 'https://www.mayoclinic.org/healthy-lifestyle/womens-health/in-depth/menstrual-cycle/art-20047186',
        topic: VerifiedSourceTopic.cycleBasics,
        credentialEn: 'Mayo Clinic',
        credentialFr: 'Mayo Clinic',
        summaryEn: 'How the menstrual cycle works and what’s normal.',
        summaryFr: 'Fonctionnement du cycle et ce qui est normal.',
      ),
    ];

/// Sources for a given topic (e.g. show in "When to seek help" or "Partner support").
List<VerifiedSource> sourcesForTopic(VerifiedSourceTopic topic) {
  return periodVerifiedSources.where((s) => s.topic == topic).toList();
}

/// Sources relevant to "when to seek help" (PMS + general).
List<VerifiedSource> get sourcesWhenToSeekHelp => periodVerifiedSources
    .where((s) =>
        s.topic == VerifiedSourceTopic.pms ||
        s.topic == VerifiedSourceTopic.whenToSeekHelp ||
        s.topic == VerifiedSourceTopic.general)
    .toList();

/// Sources relevant to partner support (partner support + general).
List<VerifiedSource> get sourcesPartnerSupport => periodVerifiedSources
    .where((s) =>
        s.topic == VerifiedSourceTopic.partnerSupport ||
        s.topic == VerifiedSourceTopic.general)
    .toList();
