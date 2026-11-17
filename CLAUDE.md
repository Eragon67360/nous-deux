# Nous Deux

One repo for the couples app and its website, sharing one Supabase backend.

- `app/`: Flutter app (Riverpod, go_router, Supabase). Run `flutter` and `dart` commands from `app/`.
- `website/`: Next.js site, FR/EN. Run `npm` commands from `website/`.
- `supabase/` (migrations, push functions, SQL dry run), `infra/` (server stack), `docs/SELF_HOSTING.md`, `scripts/`: the self-hosted backend at `https://api.nous-deux.app`. Run `scripts/*.sh` from the repo root.

## Working here

- Git: feature branches off `dev`, merged by PR once its checks pass; then tell Thomas what landed. A release is a `dev` → `main` PR. When it touches `app/`, the push to `main` builds the app and uploads it to Play's internal track as a draft, so raise the build number in `app/pubspec.yaml` first (`0.3.6+25` → `0.3.6+26`): Play takes each build number once. The version stays `0.3.6` until 1.0.0: on TestFlight the first build of a new version waits for a full beta review, later builds of the same version usually don't (Thomas, 2026-11-16).
- A change to what the app stores or shares also changes the privacy policy in `website/lib/dictionaries/{fr,en}.json`; update both in the same branch.
- Copy is bilingual everywhere: app strings are `lang == 'fr' ? … : …` functions in `app/lib/core/constants/*_strings.dart`, site copy is in the dictionaries. The app's language list and date locales are in `app/lib/core/l10n/app_languages.dart` (`AppLanguages.dateLocale(lang)`, `AppLanguages.supported`); the plan for more languages is `docs/LOCALIZATION.md`.
- Database changes: a new file in `supabase/migrations/`, then the dry run in `supabase/tests/README.md` with a scenario for the new rules. Once it passes and the change is merged, apply it with `scripts/db-migrate.sh nous-deux` (the server's SSH alias) and report it. Ask Thomas first only for a migration that deletes or rewrites existing data.
- Secrets live in the Proton Pass vault "Nous Deux". Read them only inside a command, and keep them out of output, files and commits. Locally the app reads the gitignored `app/lib/core/config/supabase_keys.dart`; copy `supabase_keys_stub.dart` when it is missing. The map (MapLibre with OpenFreeMap tiles) needs no key.
- Format only the files you touch (`dart format <files>`): much of the code predates the formatter.
- App look: the "Carnet" style (thin lines, no cards, gold labels, large light numbers), Manrope only, dark only. Shared pieces are in `app/lib/presentation/widgets/notebook.dart` and `app/lib/presentation/theme/app_theme.dart`.
- iOS simulator builds on Xcode 27 need the arm64 workaround: from `app/ios`, `xcodebuild -workspace Runner.xcworkspace -scheme Runner -configuration Debug -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' -derivedDataPath ../build/ios-dd ARCHS=arm64 ONLY_ACTIVE_ARCH=YES build`.
