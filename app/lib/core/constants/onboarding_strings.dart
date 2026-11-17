/// Onboarding screen strings. Use lang 'fr' or 'en'.
String onboardingTitle(String lang) =>
    lang == 'fr' ? 'Présentez-vous' : 'Introduce yourself';
String onboardingSubtitle(String lang) => lang == 'fr'
    ? 'Votre partenaire verra ce prénom. Vous pourrez le changer plus tard dans les réglages.'
    : 'Your partner will see this name. You can change it later in Settings.';
String onboardingDisplayNameLabel(String lang) =>
    lang == 'fr' ? 'Prénom ou surnom' : 'Name or nickname';
String onboardingDisplayNameHint(String lang) =>
    lang == 'fr' ? 'Camille' : 'Alex';
String onboardingLanguageLabel(String lang) =>
    lang == 'fr' ? 'Langue' : 'Language';
String onboardingContinue(String lang) =>
    lang == 'fr' ? 'Continuer' : 'Continue';
String onboardingErrorDisplayName(String lang) => lang == 'fr'
    ? 'Indiquez le prénom que votre partenaire verra.'
    : 'Add the name your partner will see.';
String onboardingErrorGeneric(String lang) => lang == 'fr'
    ? "L'enregistrement n'a pas abouti. Réessayez."
    : "Couldn't save that. Try again.";
