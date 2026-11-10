/// Auth screen strings. Use lang 'fr' or 'en' (e.g. from deviceLanguageProvider).
String authTitle(String lang) =>
    lang == 'fr' ? 'Nous Deux' : 'Nous Deux';
String authSubtitle(String lang) => lang == 'fr'
    ? "Un espace rien qu'à vous deux."
    : 'A space for just the two of you.';
String authOr(String lang) => lang == 'fr' ? 'ou' : 'or';
String authPhoneLabel(String lang) =>
    lang == 'fr' ? 'Numéro de téléphone' : 'Phone number';
String authPhoneHint(String lang) =>
    lang == 'fr' ? '06 12 34 56 78' : '+1 234 567 8900';
String authSendCode(String lang) =>
    lang == 'fr' ? 'Recevoir un code par SMS' : 'Text me a code';
String authContinueWithGoogle(String lang) =>
    lang == 'fr' ? 'Continuer avec Google' : 'Continue with Google';
String authContinueWithApple(String lang) =>
    lang == 'fr' ? 'Continuer avec Apple' : 'Continue with Apple';
String authErrorEnterPhone(String lang) => lang == 'fr'
    ? 'Indiquez votre numéro de téléphone.'
    : 'Enter your phone number.';
String authErrorGeneric(String lang) => lang == 'fr'
    ? "La connexion n'a pas abouti. Réessayez."
    : "Couldn't sign you in. Try again.";

String authVerifyTitle(String lang) =>
    lang == 'fr' ? 'Code reçu par SMS' : 'Check your texts';
String authVerifyInstructions(String lang, String phone) => lang == 'fr'
    ? 'Saisissez le code à 6 chiffres envoyé au $phone.'
    : 'Enter the 6-digit code we sent to $phone.';
String authVerifyCodeHint(String lang) => '123456';
String authVerifyButton(String lang) =>
    lang == 'fr' ? 'Valider' : 'Confirm';
String authVerifyErrorEnterCode(String lang) => lang == 'fr'
    ? 'Saisissez le code reçu par SMS.'
    : 'Enter the code from the text message.';
String authVerifyErrorInvalid(String lang) => lang == 'fr'
    ? 'Ce code ne fonctionne pas. Vérifiez-le, ou revenez en arrière pour en recevoir un autre.'
    : "That code didn't work. Check it, or go back to get a new one.";
