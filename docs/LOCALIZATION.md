# Localization plan

Goal: make a language a matter of files and translation, not code, while French and English stay exactly as they are today. Once this is done, adding Spanish, German or Portuguese means adding files, translating and reviewing, without touching screens, services or functions.

Written 2026-11-17. Nothing here is implemented yet.

## Where we start

**App (`app/`)**
- The UI text lives in 10 files, `lib/core/constants/*_strings.dart`, as functions like `settingsTitle(String lang) => lang == 'fr' ? 'Paramètres' : 'Settings'`. There are 477 such `lang == 'fr'` choices across 19 files, including three screens (`calendar_screen.dart`, `position_screen.dart`, `settings_screen.dart`) and the content files below.
- **Long content:** the cycle guide and tips (`guide_chapters.dart`, `period_education.dart`) use `fr ? … : …`, and `period_verified_sources.dart` has `nameFr`/`nameEn` and `summaryFr`/`summaryEn` fields. Each source also has a `locales` list, so sources are already chosen per country.
- **Which language:** `appLocaleProvider` uses the profile's language once signed in, else the phone's: French if the phone is in French, English otherwise. The list `[Locale('fr'), Locale('en')]` is written in both `main.dart` and `test/helpers/test_app.dart`.
- **Dates:** 22 places choose `'fr_FR'` or `'en_US'` by hand.
- **Local notifications:** the period reminder (`period_reminder_service.dart`) takes `lang` and calls the string functions.
- **Settings:** the language switch offers French and English.
- **Map:** place names come from `name:$lang` in `map_style.dart`, and OpenStreetMap carries most languages.
- **Tests:** 17 tests loop over `['fr', 'en']`.

**iOS:** `knownRegions` in the Xcode project is `en, Base` only. The 6 permission texts (`NS…UsageDescription`) in `Info.plist` exist in French only, and there is no `InfoPlist.strings`.

**Server (`supabase/`)**
- `profiles.language` is free text with default `'fr'` and no constraint.
- The push texts sit in each function: `BODIES: { fr, en }` in `notify-partner-ping` and in `notify-partner-period`.
- An unknown language falls back to **French**: `partner.language === "en" ? "en" : "fr"`.

**Website (`website/`)**: already built for more languages.
- **Languages:** they are listed once, in `lib/i18n.ts`, with one JSON dictionary per language (406 lines each).
- **Language detection:** `proxy.ts` reads `Accept-Language` and remembers the choice in a cookie.
- **hreflang:** `seo.ts` builds the hreflang links from the language list, with `x-default` set to English.
- **Gaps:**
  - The `Dictionary` type comes from `fr.json`, and `en.json` is only cast to it, so a key missing in English doesn't fail the build.
  - The Open Graph locale is a `fr ? fr_FR : en_US` choice.
  - `defaultLocale` is `'fr'`, so a German visitor gets French, while the app and `x-default` would give them English.

**Store images:** `app/store/play/render.py` and `app/store/appstore/render.py` hold their captions per language in Python dictionaries. The captures live in `website/public/screenshots/` (French) and `…/en/` (English), and are taken on the local stack in `~/perso/nous-deux/rehearsal/`.

## Decisions

These are settled here so the work doesn't stall on them. Each can be changed before its phase starts.

1. **English is the fallback everywhere.** A string, push text or page missing in a language shows in English. This changes two things: the server's fallback (French today) and the site's fallback for visitors whose browser accepts neither French nor English (French today). French and English users see no change.
2. **Thomas keeps writing French and English together, as now.** English is the reference that other languages are translated from, because translators for Spanish, German and Portuguese work best from it.
3. **The app uses Flutter's own system: `gen-l10n` with ARB files**, one per language (`app_en.arb` as the template, plus `app_fr.arb`). It handles plurals and gender with ICU syntax, and it's what Weblate and DeepL understand.
4. **Keys keep today's function names** (`settingsTitle`, `nousSend`, …), so the move is mechanical and reviewable.
5. **The language list lives in one place per project:** `AppLanguages` in the app, `locales` on the site, and a catalog on the server. Everything else (pickers, `supportedLocales`, test loops, hreflang) reads from it.
6. **`profiles.language` stays free text.** Adding a language then needs no migration. The app only writes supported codes, and the server falls back to English for anything else.

## Phase 1: one language list and real locales (app, small)

1. **Add `lib/core/l10n/app_languages.dart`:**
   - the codes `['fr', 'en']` and their names in their own language (« Français », "English");
   - the phone-to-app rule: use the phone's language if supported, else English;
   - the date-locale helper (`fr` → `fr_FR`, `en` → `en_US`).
2. **Make everything read the list:** `main.dart`'s `supportedLocales`, `appLocaleProvider`, `deviceLanguageProvider`, the settings language picker (built from the list) and `test_app.dart`.
3. **Replace the 22 hand-picked date locales** with the helper.
4. **Make the 17 test loops** iterate over `AppLanguages.supported`.

Done when no `'fr_FR'`, `'en_US'` or `['fr', 'en']` literal is left outside `app_languages.dart`, and the tests pass unchanged.

## Phase 2: UI strings to ARB (app, large but mechanical)

1. **Set up gen-l10n:**
   - add `l10n.yaml` (`arb-dir: lib/l10n`, `template-arb-file: app_en.arb`, `output-dir: lib/l10n/generated`, `untranslated-messages-file`) and `generate: true` in `pubspec.yaml`;
   - commit the generated code, and have CI check it's up to date.
2. **Write a safety net before touching anything:** a test that calls every string function in both languages with sample arguments and writes the results to a snapshot file (`test/l10n/strings_snapshot.json`). After the move, the same test must produce the same file byte for byte. That proves nothing changed, apostrophes and non-breaking spaces included.
3. **Write a one-off codemod script:**
   - It reads each `*_strings.dart`, turns every `name(String lang, …) => lang == 'fr' ? A : B` into an ARB entry with typed placeholders, and rewrites the body as `l10nFor(lang).name(…)`.
   - `l10nFor(lang)` is `lookupAppLocalizations(Locale(lang))`, so it works outside widgets (the notification service), and no call site changes in this PR.
4. **Hand-convert what the script can't:**
   - **Functions that switch on enums** (`pingLabel`, `pingReceivedTitle`, symptom and mood labels) become ICU `select` messages.
   - **Counts** (`nousDaysUnit`, « jour/jours ») become ICU `plural` messages.
   - **Functions that build dates** keep their logic in Dart and take only their words from ARB.
5. **Typography goes inside the translations:** the non-breaking space before « : », « » versus “ ” versus „ ".
6. **Optional, later:** move call sites from `nousSend(lang)` to `context.l10n.nousSend` area by area, then delete the wrappers. This isn't needed for adding languages.

Done when `grep "lang == 'fr'" lib/core/constants/*_strings.dart` finds nothing, the snapshot is identical, and `flutter test` and `dart analyze` are clean.

## Phase 3: long content per language (app)

The guide chapters, the weekly tips and the source descriptions are paragraphs, not UI strings, so they don't belong in ARB files.

1. **Split by language:** `guide_fr.dart` and `guide_en.dart` (same for the education content) implement one interface, so a language is a file and the compiler checks it's complete.
2. **Source text:** `VerifiedSource` gets `Map<String, String>` for its name and summary, instead of `nameFr`/`nameEn`. The `locales` field stays as it is.
3. **A test checks** that every supported language has every chapter, section and tip.

Done when no `fr ?` is left in the content files, and the guide reads the same in both languages.

## Phase 4: iOS system texts

1. **Add `fr` to `knownRegions`.**
2. **Add `fr.lproj/InfoPlist.strings` and `en.lproj/InfoPlist.strings`** for the 6 permission texts, plus `CFBundleLocalizations = [fr, en]`. iOS then shows the permission prompts in the phone's language, and the App Store lists the app's languages correctly.
3. **Check on the simulator** that the location prompt appears in both languages.

## Phase 5: server texts

1. **Move the push texts** of `notify-partner-ping` and `notify-partner-period` into `supabase/functions/_shared/i18n/{fr,en}.json`, with a small `t(lang, key, params)` that falls back to English. « Votre partenaire » / "Your partner" goes into the catalog too.
2. **Deploy with `scripts/deploy-functions.sh`.** A test on the function code checks that every language has every key.

## Phase 6: website hardening

1. **Check every dictionary against the full shape.** For example, a typed `const dictionaries: Record<Locale, () => Promise<Dictionary>>` without the `as` cast, or a test that compares keys. A key missing in any language then fails `tsc`.
2. **Open Graph locales:** a table (`fr: fr_FR`, `en: en_US`) instead of the ternary in `seo.ts`.
3. **Unmatched visitors get English** (decision 1): set `defaultLocale` to `'en'` for negotiation only. Visitors whose browser asks for French still get French, and the cookie still wins.
4. **The privacy policy names its legal version:** add a line saying which language prevails, the French one, as the publisher is in France.

## Phase 7: store copy and captures

1. **Move the render scripts' captions** into `app/store/copy/{fr,en}.json`, one file per language that both scripts read.
2. **Give the local stack's seed** (`~/perso/nous-deux/rehearsal/`) one data file per language: the couple's events, lists and notes. A new language's captures are then the same script with another file.
3. **Optionally move the French captures** to `website/public/screenshots/fr/`, the same layout as `en/`, and update `lib/screenshots.ts`.

## Phase 8: before the third language (not part of this plan)

Not needed while only French and English exist:
- **Weblate**, self-hosted on Coolify, connected to the repository; it reads ARB and JSON;
- **DeepL** drafts, then a native speaker's review per language;
- **a glossary:** « Nous », « Petits mots », « Règles », « Mes mots »;
- **a tone choice per language:** tú, du, você;
- **a release rule:** French and English must be complete, other languages may fall back to English.

## Adding a language once this is done

1. Add its code: `AppLanguages`, `website/lib/i18n.ts`, the server catalog.
2. `app_xx.arb`, `guide_xx.dart` and the other content files, `xx.lproj/InfoPlist.strings` and `knownRegions`.
3. `website/lib/dictionaries/xx.json`, including the translated privacy policy.
4. `supabase/functions/_shared/i18n/xx.json`, then deploy the functions.
5. The store listings (Play and App Store) and `app/store/copy/xx.json`; the seed file and captures.
6. The tests run every language automatically. Also check the longest one (German is about 30% longer than English) on a 320-point phone.

**Pseudo-language for testing (optional):** a debug-only language whose strings are English stretched by 40% with accents (« [Ŝéñð ñöţé ····] »). Running the app in it shows at a glance every hard-coded string and every layout that breaks with long text.

## Order, PRs and release

| PR | Phase | Size | Visible change |
| --- | --- | --- | --- |
| 1 | Language list, date locales, test loops | small | none |
| 2 | Snapshot test, then gen-l10n and codemod | large | none (snapshot identical) |
| 3 | Long content per language | medium | none |
| 4 | iOS `InfoPlist.strings`, `knownRegions` | small | iOS permission prompts follow the phone's language |
| 5 | Server push catalog, English fallback | small | pushes to an unknown language arrive in English |
| 6 | Website dictionary check, Open Graph table, English for unmatched visitors | small | visitors with neither French nor English see English |
| 7 | Store copy files, seed per language | small | none |

PRs 1–4 change the app, so they ship together in the next app release (raise the build number). PR 5 needs a function deploy. PR 6 ships with the next site release. PR 7 is tooling.

**Risks**
- **The codemod gets escaping wrong** (apostrophes, ` `, `$` interpolation). The snapshot test catches it before merge.
- **Generated code drifts from the ARB files.** CI regenerates and compares.
- **The guide's restructuring breaks a chapter.** The completeness test and a read-through of both languages cover it.
