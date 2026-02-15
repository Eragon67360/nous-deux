/// Period guide UI strings (TOC, search, cards). Use lang 'fr' or 'en'.
String periodTocLabel(String lang) =>
    lang == 'fr' ? 'Sommaire du guide' : 'Guide table of contents';
String periodTocTitle(String lang) =>
    lang == 'fr' ? 'Sommaire' : 'Table of contents';
String periodTocGoTo(String lang) => lang == 'fr' ? 'Aller à' : 'Go to';

String periodLearnMore(String lang) =>
    lang == 'fr' ? 'En savoir plus' : 'Learn more';
String periodSaved(String lang) => lang == 'fr' ? 'Enregistrés' : 'Saved';
String periodSearchHint(String lang) =>
    lang == 'fr' ? 'Rechercher dans le guide…' : 'Search in guide…';
String periodSearchResultsTitle(String lang) =>
    lang == 'fr'
        ? 'Sections correspondant à votre recherche'
        : 'Sections matching your search';
String periodSaveSection(String lang) =>
    lang == 'fr' ? 'Enregistrer cette section' : 'Save this section';
String periodRemoveFromSaved(String lang) =>
    lang == 'fr' ? 'Retirer des enregistrés' : 'Remove from saved';
String periodCouldNotOpenLink(String lang) =>
    lang == 'fr' ? 'Impossible d\'ouvrir le lien' : 'Could not open link';
String periodPhysical(String lang) =>
    lang == 'fr' ? 'Physique' : 'Physical';
String periodEmotional(String lang) =>
    lang == 'fr' ? 'Émotionnel' : 'Emotional';
