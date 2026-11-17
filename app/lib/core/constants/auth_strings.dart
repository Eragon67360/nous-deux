import 'package:nousdeux/core/l10n/l10n.dart';

/// Auth screen strings. Use lang 'fr' or 'en' (e.g. from deviceLanguageProvider).
String authTitle(String lang) => l10nFor(lang).authTitle;
String authSubtitle(String lang) => l10nFor(lang).authSubtitle;
String authOr(String lang) => l10nFor(lang).authOr;
String authPhoneLabel(String lang) => l10nFor(lang).authPhoneLabel;
String authPhoneHint(String lang) => l10nFor(lang).authPhoneHint;
String authSendCode(String lang) => l10nFor(lang).authSendCode;
String authContinueWithGoogle(String lang) =>
    l10nFor(lang).authContinueWithGoogle;
String authContinueWithApple(String lang) =>
    l10nFor(lang).authContinueWithApple;
String authWithEmail(String lang) => l10nFor(lang).authWithEmail;
String authErrorEnterPhone(String lang) => l10nFor(lang).authErrorEnterPhone;
String authErrorGeneric(String lang) => l10nFor(lang).authErrorGeneric;

String authVerifyTitle(String lang) => l10nFor(lang).authVerifyTitle;
String authVerifyInstructions(String lang, String phone) =>
    l10nFor(lang).authVerifyInstructions(phone);
String authVerifyCodeHint(String lang) => '123456';
String authVerifyButton(String lang) => l10nFor(lang).authVerifyButton;
String authVerifyErrorEnterCode(String lang) =>
    l10nFor(lang).authVerifyErrorEnterCode;
String authVerifyErrorInvalid(String lang) =>
    l10nFor(lang).authVerifyErrorInvalid;

String authEmailTitle(String lang) => l10nFor(lang).authEmailTitle;
String authEmailIntro(String lang) => l10nFor(lang).authEmailIntro;
String authEmailLabel(String lang) => l10nFor(lang).authEmailLabel;
String authPasswordLabel(String lang) => l10nFor(lang).authPasswordLabel;
String authEmailButton(String lang) => l10nFor(lang).authEmailButton;
String authEmailErrorEmpty(String lang) => l10nFor(lang).authEmailErrorEmpty;
String authEmailErrorWrong(String lang) => l10nFor(lang).authEmailErrorWrong;
