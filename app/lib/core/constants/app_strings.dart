import 'package:nousdeux/core/l10n/l10n.dart';

/// App-wide strings (splash, main shell, etc.). Use lang 'fr' or 'en'.
String appName(String lang) => 'Nous Deux';
String splashTagline(String lang) => l10nFor(lang).splashTagline;

String mainNoPartnerBubble(String lang) => l10nFor(lang).mainNoPartnerBubble;

String pairingCelebrationTitle(String lang) =>
    l10nFor(lang).pairingCelebrationTitle;

String pairingCelebrationBody(String lang) =>
    l10nFor(lang).pairingCelebrationBody;

String appSupabaseConfigMessage(String lang) =>
    l10nFor(lang).appSupabaseConfigMessage;

// Signed in, but the profile couldn't load (no network, server error).
String profileUnavailableTitle(String lang) =>
    l10nFor(lang).profileUnavailableTitle;

String profileUnavailableBody(String lang) =>
    l10nFor(lang).profileUnavailableBody;

String profileUnavailableRetry(String lang) =>
    l10nFor(lang).profileUnavailableRetry;
