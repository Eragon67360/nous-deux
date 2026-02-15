/// Auth screen strings. Use lang 'fr' or 'en' (e.g. from deviceLanguageProvider).
String authTitle(String lang) =>
    lang == 'fr' ? 'Nous Deux' : 'Nous Deux';
String authSubtitle(String lang) =>
    lang == 'fr' ? 'Connectez-vous pour continuer' : 'Sign in to continue';
String authPhoneLabel(String lang) =>
    lang == 'fr' ? 'Numéro de téléphone' : 'Phone number';
String authPhoneHint(String lang) =>
    lang == 'fr' ? '+33 6 12 34 56 78' : '+1 234 567 8900';
String authSendCode(String lang) =>
    lang == 'fr' ? 'Envoyer le code' : 'Send code';
String authContinueWithGoogle(String lang) =>
    lang == 'fr' ? 'Continuer avec Google' : 'Continue with Google';
String authContinueWithApple(String lang) =>
    lang == 'fr' ? 'Continuer avec Apple' : 'Continue with Apple';
String authErrorEnterPhone(String lang) =>
    lang == 'fr' ? 'Entrez votre numéro' : 'Enter your phone number';
String authErrorGeneric(String lang) =>
    lang == 'fr' ? 'Erreur' : 'Error';

String authVerifyTitle(String lang) =>
    lang == 'fr' ? 'Vérification' : 'Verification';
String authVerifyInstructions(String lang, String phone) =>
    lang == 'fr' ? 'Entrez le code envoyé au $phone' : 'Enter the code sent to $phone';
String authVerifyCodeLabel(String lang) =>
    lang == 'fr' ? 'Code' : 'Code';
String authVerifyCodeHint(String lang) => '123456';
String authVerifyButton(String lang) =>
    lang == 'fr' ? 'Vérifier' : 'Verify';
String authVerifyErrorEnterCode(String lang) =>
    lang == 'fr' ? 'Entrez le code reçu' : 'Enter the code you received';
String authVerifyErrorInvalid(String lang) =>
    lang == 'fr' ? 'Code invalide' : 'Invalid code';
