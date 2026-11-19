import 'package:nousdeux/core/l10n/l10n.dart';

// The update screen (docs/UPDATE_SCREEN.md): board 1, a newer build, and
// board 2, a build too old to work.

String updateLabel(String lang) => l10nFor(lang).updateLabel;
String updateTitle(String lang) => l10nFor(lang).updateTitle;
String updateBodyDefault(String lang) => l10nFor(lang).updateBodyDefault;
String updateYourVersion(String lang) => l10nFor(lang).updateYourVersion;
String updateLatestVersion(String lang) => l10nFor(lang).updateLatestVersion;
String updateBuild(String lang, int build) => l10nFor(lang).updateBuild(build);
String updateButton(String lang) => l10nFor(lang).updateButton;
String updateLater(String lang) => l10nFor(lang).updateLater;
String updateRequiredLabel(String lang) => l10nFor(lang).updateRequiredLabel;
String updateRequiredTitle(String lang) => l10nFor(lang).updateRequiredTitle;
String updateRequiredBody(String lang) => l10nFor(lang).updateRequiredBody;

/// « Ouvre TestFlight », « Ouvre Google Play ».
String updateOpens(String lang, {required bool isIos}) =>
    l10nFor(lang).updateOpens(isIos ? 'testflight' : 'play');
