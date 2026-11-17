import 'package:nousdeux/core/errors/failures.dart';
import 'package:nousdeux/core/l10n/l10n.dart';

/// Pairing screen strings. Use lang 'fr' or 'en'.
String pairingInviteTitle(String lang) => l10nFor(lang).pairingInviteTitle;
String pairingIntro(String lang) => l10nFor(lang).pairingIntro;
String pairingGenerateCode(String lang) => l10nFor(lang).pairingGenerateCode;
String pairingScanQrPrompt(String lang) => l10nFor(lang).pairingScanQrPrompt;
String pairingOrEnterCode(String lang) => l10nFor(lang).pairingOrEnterCode;
String pairingAlreadyHaveCode(String lang) =>
    l10nFor(lang).pairingAlreadyHaveCode;
String pairingJoinWithCode(String lang) => l10nFor(lang).pairingJoinWithCode;
String pairingScanQr(String lang) => l10nFor(lang).pairingScanQr;
String pairingAlreadyPaired(String lang) => l10nFor(lang).pairingAlreadyPaired;
String pairingError(String lang) => l10nFor(lang).pairingError;

String pairingJoinTitle(String lang) => l10nFor(lang).pairingJoinTitle;
String pairingJoinInstructions(String lang) =>
    l10nFor(lang).pairingJoinInstructions;
String pairingJoinCodeLabel(String lang) => l10nFor(lang).pairingJoinCodeLabel;
String pairingJoinCodeHint(String lang) => 'ABC123';
String pairingJoinButton(String lang) => l10nFor(lang).pairingJoinButton;
String pairingJoinErrorCode(String lang) => l10nFor(lang).pairingJoinErrorCode;
String pairingJoinErrorUsed(String lang) => l10nFor(lang).pairingJoinErrorUsed;
String pairingJoinErrorOwnCode(String lang) =>
    l10nFor(lang).pairingJoinErrorOwnCode;
String pairingJoinErrorInvalid(String lang) =>
    l10nFor(lang).pairingJoinErrorInvalid;
String pairingJoinErrorAlreadyPaired(String lang) =>
    l10nFor(lang).pairingJoinErrorAlreadyPaired;
String pairingJoinErrorTooManyAttempts(String lang) =>
    l10nFor(lang).pairingJoinErrorTooManyAttempts;

/// What to tell the person when joining failed.
String pairingJoinError(Failure failure, String lang) => switch (failure) {
  PairingFailure(problem: PairingProblem.codeUsed) => pairingJoinErrorUsed(
    lang,
  ),
  PairingFailure(problem: PairingProblem.ownCode) => pairingJoinErrorOwnCode(
    lang,
  ),
  PairingFailure(problem: PairingProblem.alreadyPaired) =>
    pairingJoinErrorAlreadyPaired(lang),
  PairingFailure(problem: PairingProblem.tooManyAttempts) =>
    pairingJoinErrorTooManyAttempts(lang),
  PairingFailure() => pairingJoinErrorInvalid(lang),
  _ => failure.message ?? pairingJoinErrorInvalid(lang),
};

String pairingScanTitle(String lang) => l10nFor(lang).pairingScanTitle;
String pairingScanConnecting(String lang) =>
    l10nFor(lang).pairingScanConnecting;
