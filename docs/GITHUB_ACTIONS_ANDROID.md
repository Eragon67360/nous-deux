# GitHub Actions: Android Build and Release

This guide explains what you need to add and configure so the **Android Build and Release** workflow runs successfully on every push to `main`.

## What the workflow does

- Triggers on push to `main` when relevant paths change (`lib/`, `android/`, `pubspec.yaml`, etc.). Skips if the commit message contains `[skip ci]`.
- Resolves version from `pubspec.yaml` (and appends a build number for the release tag).
- Builds a signed release App Bundle (AAB) with Supabase config injected via `--dart-define`.
- Uploads the AAB to Google Play (internal track, draft).
- Generates a universal APK from the AAB (via bundletool).
- Creates a GitHub Release with the AAB and APK attached.

## 1. GitHub repository secrets

Add these in **Settings → Secrets and variables → Actions**:

| Secret                         | Description                                                        |
| ------------------------------ | ------------------------------------------------------------------ |
| `SUPABASE_URL`                 | Your Supabase project URL (e.g. `https://xxxx.supabase.co`).       |
| `SUPABASE_ANON_KEY`            | Supabase anon (public) key. Same as in `docs/SUPABASE_KEYS.md`.    |
| `ANDROID_KEYSTORE_BASE64`      | Your upload keystore file, **base64-encoded** (see below).         |
| `ANDROID_KEY_ALIAS`            | Key alias used when creating the keystore.                         |
| `ANDROID_KEY_PASSWORD`         | Password for the key.                                              |
| `ANDROID_KEYSTORE_PASSWORD`    | Password for the keystore.                                         |
| `ANDROID_SERVICE_ACCOUNT_JSON` | Full JSON content of the Google Play service account (for upload). |

### Creating and encoding the keystore

If you don’t have an upload keystore yet:

```bash
keytool -genkey -v -keystore upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Then encode it for the secret:

```bash
base64 -i upload-keystore.jks | pbcopy   # macOS; paste into ANDROID_KEYSTORE_BASE64
# or
base64 -w0 upload-keystore.jks           # Linux
```

Use the same alias and passwords you set in the secret (`ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD`, `ANDROID_KEYSTORE_PASSWORD`).

## 2. Google Play Console setup (for upload)

1. In Google Play Console, go to **Setup → API access** and link or create a service account with access to your app.
2. Grant the service account at least **Release to production, exclude devices, and use Play App Signing** (or the permissions needed for your internal track).
3. Create a JSON key for that service account and paste the **entire JSON** into the `ANDROID_SERVICE_ACCOUNT_JSON` secret.

The workflow uploads to the **internal** track as a **draft**; you can change `track` and `status` in `.github/workflows/android-build-release.yml` if you want (e.g. `track: internal` / `status: completed`).

## 3. What’s already implemented in the repo

- **Workflow file**: `.github/workflows/android-build-release.yml` — builds on `main`, creates keystore from secrets, builds AAB with dart-define, uploads to Play, generates APK, creates a GitHub Release.
- **Android signing**: `android/app/build.gradle.kts` reads `android/key.properties` when present (CI creates it from secrets). If the file is missing, release falls back to debug signing so `flutter run --release` still works locally.
- **Supabase in build**: The app uses `String.fromEnvironment('SUPABASE_URL'|'SUPABASE_ANON_KEY')`. The workflow passes these via `--dart-define` so no `.env` file is required in CI.

## 4. Optional: disable Google Play upload

If you only want builds and GitHub Releases (no Play upload), remove or comment out the **Upload to Google Play** step in `.github/workflows/android-build-release.yml`. You can keep the rest (build AAB, generate APK, rename, create GitHub Release). In that case you don’t need `ANDROID_SERVICE_ACCOUNT_JSON`.

## 5. Version and release tags

- **Version** is read from `version` in `pubspec.yaml` (e.g. `0.1.0`). The workflow appends `+<run_number>` for the release tag if there’s no `+` in the version (e.g. `0.1.0+1`, `0.1.0+2`).
- **Release tag** format: `android/v<version>` (e.g. `android/v0.1.0+1`).
- To bump the version users see, update `version` in `pubspec.yaml` and push to `main`.

## 6. Checklist before first run

- [ ] All secrets above are set in the repo (including keystore base64 and Play service account JSON if you use Play upload).
- [ ] Upload keystore alias and passwords match what you use locally and in the secrets.
- [ ] Package name in Google Play matches `com.nousdeux.android` (see `android/app/build.gradle.kts`).
- [ ] Commit message for the push does not contain `[skip ci]` if you want the workflow to run.

After that, a push to `main` that touches the paths defined in the workflow will trigger the job. Check the **Actions** tab for logs and the **Releases** page for the created build artifacts.
