# Nous Deux

One repo for the couples app and its website, sharing one Supabase backend.

- `app/`: Flutter app (Riverpod, go_router, Supabase). Run `flutter` and `dart` commands from `app/`.
- `website/`: Next.js site, FR/EN. Run `npm` commands from `website/`.
- `supabase/` (migrations, push functions, SQL dry run), `infra/` (server stack), `docs/SELF_HOSTING.md`, `scripts/`: the self-hosted backend at `https://api.nous-deux.app`. Run `scripts/*.sh` from the repo root.

## Working here

- Git: feature branches off `dev`. Commit, push, open PRs and merge only when Thomas asks.
- A change to what the app stores or shares also changes the privacy policy in `website/lib/dictionaries/{fr,en}.json`; update both in the same branch.
- Copy is bilingual everywhere: app strings are `lang == 'fr' ? … : …` functions in `app/lib/core/constants/*_strings.dart`, site copy is in the dictionaries.
- Database changes: a new file in `supabase/migrations/`, then the dry run in `supabase/tests/README.md` with a scenario for the new rules. Applying it to the server (`scripts/db-migrate.sh`) is Thomas's call, migration by migration.
- Secrets live in the Proton Pass vault "Nous Deux". Read them only inside a command, and keep them out of output, files and commits. Locally the app reads the gitignored `app/lib/core/config/supabase_keys.dart` and `mapbox_keys.dart`; copy the `*_stub.dart` files when they are missing.
- Format only the files you touch (`dart format <files>`): much of the code predates the formatter.
- App look: the "Carnet" style (thin lines, no cards, gold labels, large light numbers), Manrope only, dark only. Shared pieces are in `app/lib/presentation/widgets/notebook.dart` and `app/lib/presentation/theme/app_theme.dart`.
- iOS simulator builds on Xcode 27 need the arm64 workaround: from `app/ios`, `xcodebuild -workspace Runner.xcworkspace -scheme Runner -configuration Debug -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' -derivedDataPath ../build/ios-dd ARCHS=arm64 ONLY_ACTIVE_ARCH=YES build`.
