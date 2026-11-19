# Update Screen Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** testers know when a newer build is out and get to it in one tap. A build too old to work tells them so and offers nothing else. Ships in build 30.

**Architecture:**
- **Server:** a public table `app_builds` holds one row per platform: the latest build sent to testers, the minimum build that still works, and a one-line note in FR and EN.
- **Recording builds:** the release jobs record their build through `record_app_build()`, a definer function that wants a dedicated token (`RELEASE_TOKEN`, a GitHub secret; only its SHA-256 is on the server).
- **Detection:**
  - The iPhone compares its build with the iOS row.
  - Android asks Google Play (in-app updates API), because the Play upload is a draft until Thomas promotes it. The note is shown only when Play's build is the one the row describes.
  - The minimum comes from the row on both platforms.
- **App:** a gate above the router shows the screen over the app once someone is signed in (signed-out callers read nothing in public, `98_hardening`). It checks at start, on sign-in and on each resume. « Mettre à jour » opens TestFlight or Google Play; nothing installs by itself. « Plus tard » hides it until the next day; the obligatory screen has no « Plus tard ».

**Tech Stack:** Postgres (RLS, definer function, built-in `sha256`), GitHub Actions + curl, Flutter (Riverpod, in_app_update 4.2.5, url_launcher, shared_preferences, gen-l10n).

**Spec:** the Claude Design board « Nous Deux · Mise à jour disponible », https://claude.ai/artifact/3Y7vUCaMBfXMQJbfsfrxES, boards 1 (Main) and 2 (Required), note « Décidé le 19 nov. »:
1. A screen at start-up (1). No line on the home screen.
2. « Plus tard »: it comes back the next day, as long as the app is out of date.
3. The obligatory minimum (2), for the rare builds that break older ones.
4. One short line on what changes, written for each release in FR and EN.
5. Each platform separately. Android: Google Play tells the app. iPhone: the server must know; the TestFlight job records it by itself (Thomas asked for automatic; recommendation (a), taken while he sleeps, 2026-11-19).

## Global Constraints

- **Branch:** `feature/update-screen` off `dev` (after the pill PR is merged there). Merge into `dev` only: **nothing on the server, no release, no token** until build 30 ships.
- **Look:** Carnet, Manrope, dark only, as drawn: gold capitals label, 32 px light title, thin rules, gold 56 px button with a 14 px radius.
- **Copy:** bilingual through ARB and `update_strings.dart`. Non-breaking space before « : ; ? ! ».
- **Privacy:** the app only reads a public table, and Play answers on the phone. Nothing about the person is sent or kept, so the privacy policy doesn't change.
- **Database:** no superuser-only statement. Dry-run scenario added.
- **Checks:** `dart format` on touched files, `dart analyze lib test`, full `flutter test`, the SQL dry run, the iOS simulator build.

## Review Focus

1. **Unknown installed build:** `PackageInfo` gives a non-number → no screen, never the obligatory one.
2. **Play unavailable:** a sideloaded or debug Android build, or no Play services → `checkForUpdate` throws → no "available" screen. The minimum still applies.
3. **Lower build recorded:** a re-run of an older job must not lower `latest_build` or replace its note.
4. **Missing secret or table:** the CI step must warn and leave the release green.
5. **Resume while the screen shows:** a re-check must not flash the screen away and back, and « Plus tard » taps must stick for the day.

## Files

- **Create:**
  - `supabase/migrations/20261119200000_app_builds.sql`
  - `supabase/tests/87_app_builds_scenario.sql`
  - `scripts/record-build.sh <platform>` (CI)
  - `scripts/app-builds.sh <host|local> [--min <platform> <build>] [--token]`
  - `app/release_note.json`
  - `app/lib/domain/app_update.dart` (`PublishedBuild`, `UpdateOffer`, `decideUpdate`)
  - `app/lib/data/repositories/app_builds_repository.dart`
  - `app/lib/core/services/store_links.dart` (Play check, store links)
  - `app/lib/presentation/providers/app_update_provider.dart`
  - `app/lib/presentation/screens/update/update_gate.dart`
  - `app/lib/core/constants/update_strings.dart`
- **Modify:**
  - `app/lib/main.dart` (builder)
  - `app/lib/l10n/app_{en,fr}.arb`
  - `app/test/helpers/{test_app,fakes}.dart`
  - `.github/workflows/{ios-testflight,android-build-release}.yml`
  - `CLAUDE.md` (release step), `supabase/tests/README.md`

---

### Task 1: The table, the recording function and the scripts

**Interfaces — produces:**
- `public.app_builds(platform text pk in ('android','ios'), latest_build int ≥ 0, min_build int ≥ 0, note jsonb object, updated_at)`, seeded with both rows. Readable by `authenticated` (SELECT of those four columns), writable by nobody but `postgres`/`service_role`.
- `private.release_token(only boolean pk, token_sha256 bytea)`: no grants.
- `public.record_app_build(p_platform text, p_build int, p_note jsonb, p_token text) returns void`, definer, `search_path = ''`, EXECUTE to `anon` only:
  - It raises 42501 unless `sha256(convert_to(p_token,'UTF8'))` matches.
  - It raises 22023 on a bad platform, a build < 1 or a note that isn't an object.
  - It sets `latest_build = greatest(...)`, and `note` only when `p_build >= latest_build`.

- [ ] Scenario `87_app_builds_scenario.sql`, run before the migration exists (fails):
  - anon reads nothing, and its UPDATE and INSERT are refused;
  - a wrong token is refused;
  - the right token records ios 30 with its note;
  - recording ios 29 afterwards keeps 30 and its note;
  - `'web'` is refused;
  - authenticated can't execute the function.
- [ ] The migration; the dry run passes all scenarios.
- [ ] `scripts/record-build.sh <platform>`:
  - reads the number after `+` in `app/pubspec.yaml` and `app/release_note.json`;
  - POSTs `{p_platform,p_build,p_note,p_token}` to `$SUPABASE_URL/rest/v1/rpc/record_app_build` with the `apikey` header, sending the body on stdin with jq;
  - without `RELEASE_TOKEN` it prints `::warning::` and exits 0.
- [ ] `scripts/app-builds.sh`:
  - no flag: prints the two rows;
  - `--min ios 31`: sets the minimum;
  - `--token`: makes 32 random bytes, stores only their SHA-256 (hashed here, sent as hex) and sets the repo secret `RELEASE_TOKEN` through `gh secret set` on stdin.
- [ ] End to end on the rehearsal stack (`local`): `--token` without the gh step (`--no-gh`), then `record-build.sh ios` with the local URL and keys → the row reads 29 and the note. A wrong token gives HTTP 4xx and the script exits 1.
- [ ] Commit.

### Task 2: The release jobs record their build

- [ ] **iOS:** after `Run fastlane`, only when `BUILD == 'true'`, add a step "Tell older builds about this one". It runs `../scripts/record-build.sh ios` with `SUPABASE_URL`, `SUPABASE_ANON_KEY` and `RELEASE_TOKEN` from secrets, and `continue-on-error: true`.
- [ ] **Android:** the same after "Upload to Google Play", with `android`.
- [ ] `app/release_note.json` for build 30:
  - fr: « Le build 30 apporte le suivi de la pilule et « Envoyer un retour » dans Paramètres. »
  - en: "Build 30 brings pill tracking and “Send feedback” in Settings."
- [ ] CLAUDE.md release bullet: write `app/release_note.json` with the build number; set the token once with `scripts/app-builds.sh nous-deux --token`; raise the minimum only for a build that breaks older ones.
- [ ] `actionlint`, if installed, or a YAML parse of both files. Commit.

### Task 3: The decision

**Interfaces — produces** (`app/lib/domain/app_update.dart`):
- `class PublishedBuild { int latestBuild; int minBuild; Map<String,String> note; }` and `PublishedBuild.fromRow(Map)`.
- `sealed class UpdateOffer`, with:
  - `UpdateAvailable(installed, latest, note?)`;
  - `UpdateRequired(installed)`.
- `UpdateOffer? decideUpdate({required int? installed, PublishedBuild? published, int? playBuild, required bool isIos, required String lang, String? laterDay, required DateTime now})`:
  - `installed == null` → null.
  - `installed < minBuild` → required, whatever `laterDay` says.
  - latest = iOS ? `published.latestBuild` : `playBuild`; `latest <= installed` → null.
  - `laterDay == yyyy-MM-dd(now)` → null.
  - The note in `lang`, falling back to `en`. It's given only when `published.latestBuild == latest`.

- [ ] Tests in `test/domain/app_update_test.dart`, one per rule above. Then:
  - Android ignores the server's latest;
  - iOS ignores Play;
  - « Plus tard » yesterday shows again;
  - malformed rows (missing note, non-string values) parse to an empty note.
- [ ] Implement. Commit.

### Task 4: Data, providers and the gate

**Interfaces — produces:**
- `AppBuildsRepository.published(String platform) → Future<PublishedBuild?>` (null on any error), with `appBuildsRepositoryProvider`.
- `playUpdateBuildProvider`: `FutureProvider<int?>`. On Android, `InAppUpdate.checkForUpdate()` gives `availableVersionCode` when `updateAvailability == updateAvailable`, else null; errors give null. Elsewhere null.
- `updateLaterDayKey = 'update_later_day'` (SharedPreferences).
- `updateOfferProvider`: `FutureProvider<UpdateOffer?>`, using `appBuildProvider`, `clockProvider`, the profile's language (else the device's) and `isIosProvider` (a `Provider<bool>` from `Platform.isIOS`, overridable).
- `openStoreProvider`: `Provider<Future<bool> Function(Uri)>`.
- Store links:
  - iOS: `itms-beta://beta.itunes.apple.com/v1/app/6835108447`, falling back to `https://testflight.apple.com/join/kScrT3Sk`.
  - Android: `market://details?id=com.nousdeux.android`, falling back to `https://play.google.com/store/apps/details?id=com.nousdeux.android`.
- `UpdateGate({required Widget child})` is a ConsumerStatefulWidget and a WidgetsBindingObserver:
  - It invalidates `updateOfferProvider` on resume.
  - It keeps the last shown offer while a re-check loads.
  - It stacks `UpdateScreen(offer)` over the child inside a `Material`.

- [ ] Widget tests (`test/presentation/screens/update/update_gate_test.dart`, `TestDeps` with `appBuilds`, `playBuild`, `isIos`, `installedBuild`):
  - an available update shows the FR texts, both builds and the note;
  - « Plus tard » hides it and saves today, and the next day it shows again;
  - « Mettre à jour » on iOS opens the TestFlight link, and on Android the Play link;
  - obligatory: no « Plus tard », and the body from the board;
  - up to date: no screen;
  - a resume re-check keeps the screen on.
- [ ] ARB strings (FR, EN), `flutter gen-l10n`, `update_strings.dart`; refresh the strings snapshot.
- [ ] Wire it in `main.dart`: `builder: (context, child) => _FcmRegistration(child: UpdateGate(child: child))`.
- [ ] `TestDeps` defaults to "nothing published", so the existing tests stay green.
- [ ] `flutter pub add in_app_update:^4.2.5`. Then the debug APK and the iOS simulator build.
- [ ] Commit.

### Task 5: On the simulator, then merge

- [ ] On the rehearsal stack, `ios.latest_build` = 30 with a note, and the installed build is 29:
  - the screen shows at start;
  - « Plus tard » hides it, and a relaunch keeps it hidden;
  - after changing the saved day, it comes back;
  - « Mettre à jour » opens the TestFlight fallback in Safari (TestFlight isn't on the simulator).
- [ ] With `min_build` = 30, the obligatory screen shows and nothing else can be reached.
- [ ] Reset the rehearsal rows to 0. Fresh review on the most capable model, then one fix pass. PR into `dev`, merge.
