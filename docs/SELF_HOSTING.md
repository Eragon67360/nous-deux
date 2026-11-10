# Self-hosted Supabase (Hetzner + Coolify)

Nous Deux runs on its own Supabase at `https://api.nous-deux.app`. That's a Hetzner server in Germany, managed by Coolify (`coolify.thomasmoserdev.com`). No US cloud provider holds the database.

The stack is defined in [`infra/supabase/compose.yml`](../infra/supabase/compose.yml). It's Coolify's Supabase template with newer images and fewer services. Secrets live in the Proton Pass vault **Nous Deux**; the repo never holds them.

## What runs

| Container | What it does | Public? |
|---|---|---|
| supabase-kong | Gateway. Routes `/auth/v1`, `/rest/v1`, `/realtime/v1`, `/storage/v1`, and Studio behind a password at `/` | yes, through Coolify's proxy |
| supabase-db | Postgres 17 | no |
| supabase-auth | Sign-in: phone code, Google and Apple ID tokens | via Kong |
| supabase-rest | PostgREST | via Kong |
| realtime-dev | Live changes | via Kong |
| supabase-storage | Avatars, stored on the server's disk | via Kong |
| supabase-meta | Database API for Studio | via Kong (service key) |
| supabase-studio | Admin dashboard | via Kong (password) |
| supabase-edge-functions | The two push functions | **no**: only the database calls them |

Left out on purpose:
- Logflare and Vector, so no request logs are kept.
- imgproxy, since avatars aren't resized.
- Supavisor, since nothing connects to Postgres from outside.
- MinIO, since storage writes to disk.

Pinned versions are in the compose file; see [Upgrades](#upgrades).

## One-time setup

Each step names who does it. Thomas does the console clicks. Claude may run the SSH steps on the **empty** database only.

### 1. Hetzner (Thomas)
1. **Server.** In Hetzner Cloud, create a project "Nous Deux" with a server:
   - Type CX33 (4 vCPU / 8 GB), or CAX21 on Arm.
   - Location `nbg1` or `fsn1`, Ubuntu 24.04.
   - Add your Mac's SSH key.
2. **Firewall** on the server: allow 22/tcp, 80/tcp and 443/tcp in, nothing else.
3. **Object Storage.** Create a bucket `nous-deux-backups` in another location (e.g. `hel1`), and an access key for it. Store the key in Proton Pass as `Nous Deux / Backups S3`.

### 2. DNS (Thomas)
At the `nous-deux.app` registrar, point `api` at the server with an `A` record (IPv4) and an `AAAA` record (IPv6). `.app` is HTTPS-only; Coolify gets the certificate from Let's Encrypt.

### 3. Coolify (Thomas)
1. **Servers → Add.** Paste the server's IP, add the key Coolify shows to the server's `~/.ssh/authorized_keys`, then validate. Coolify installs Docker.
2. **Projects → New** "Nous Deux", environment `production`. Then **+ New → Docker Compose (empty)** on that server, and paste `infra/supabase/compose.yml`.
3. **Domain:** on the `supabase-kong` component, set `https://api.nous-deux.app:8000`.
4. **Environment variables** to set by hand. Coolify generates every `SERVICE_*` value itself.

   | Variable | Value | Secret |
   |---|---|---|
   | `FIREBASE_SERVICE_ACCOUNT_JSON` | The Firebase service-account JSON, on one line (step 6) | yes |
   | `SMS_TEST_OTP` | `447700900001:<code>,447700900002:<code>`: fictional UK numbers with fixed codes, for tests | yes |
   | `GOOGLE_ENABLED` | `true` | no |
   | `GOOGLE_CLIENT_IDS` | Web client id first, then iOS and Android, comma-separated (step 4) | no |
   | `APPLE_ENABLED` | `true` | no |
   | `APPLE_CLIENT_IDS` | `com.nousdeux.android` (the iOS bundle id) | no |

   Optional, with defaults:
   - `SITE_URL`: `https://nous-deux.app`.
   - `ADDITIONAL_REDIRECT_URLS`: `nousdeux://login-callback`.
   - `JWT_EXPIRY`: `3600`.
   - `SMS_PROVIDER`: real SMS is a later step. Until then only the test numbers can sign in by phone.

5. **Deploy.** Then copy into Proton Pass, item `Nous Deux / Supabase`:
   - `SERVICE_PASSWORD_JWT`, `SERVICE_PASSWORD_POSTGRES`, `SERVICE_SUPABASEANON_KEY` (the app's anon key), `SERVICE_SUPABASESERVICE_KEY`.
   - `SERVICE_USER_ADMIN` and `SERVICE_PASSWORD_ADMIN` (the Studio login).
   - `SERVICE_PASSWORD_64_PUSHWEBHOOK`.

   The push secret is copied into the database at first boot. Changing it later needs the [rotation steps](#rotate-the-push-secret).

### 4. Google Cloud (Thomas)
In the Google Cloud project behind Firebase `nous-deux-7bf2f`, go to **APIs & Services → Credentials** and create three OAuth client ids:
- **Web application.** Its id is the `serverClientId` the auth server checks, so it goes first in `GOOGLE_CLIENT_IDS`.
- **iOS**, with bundle id `com.nousdeux.android`.
- **Android**, with package `com.nousdeux.android` and the SHA-1 of the debug key and the release key.

Then, in the app repo:
- `ios/Runner/Info.plist` gains `GIDClientID` (the iOS id) and a URL scheme with the iOS id reversed (`com.googleusercontent.apps.…`).
- Builds pass `--dart-define=GOOGLE_WEB_CLIENT_ID=… --dart-define=GOOGLE_IOS_CLIENT_ID=…`.
- CI reads the GitHub secret `GOOGLE_WEB_CLIENT_ID`.

### 5. Apple Developer (Thomas)
Under **Certificates, IDs & Profiles → Identifiers → `com.nousdeux.android`**, enable **Sign in with Apple**. The app already declares it in `ios/Runner/Runner.entitlements`.

### 6. Firebase (Thomas)
In **Project settings → Service accounts**, use **Generate new private key**. Its JSON becomes `FIREBASE_SERVICE_ACCOUNT_JSON`, and the downloaded file is deleted once it's in Proton Pass.

### 7. Database and functions (Claude or Thomas, over SSH)
```bash
scripts/db-migrate.sh root@<server>       # applies and records every migration
scripts/deploy-functions.sh root@<server> # copies the push functions, restarts them
```

### 8. App configuration
- **Local:** in the gitignored `lib/core/config/supabase_keys.dart`, set `supabaseUrlLocal = 'https://api.nous-deux.app'` and the anon key.
- **CI:** set these GitHub secrets: `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `GOOGLE_WEB_CLIENT_ID`.

### 9. Check
```bash
cd infra/supabase && npm ci
SUPABASE_URL=https://api.nous-deux.app SUPABASE_ANON_KEY=<anon key> \
SMOKE_PHONES=447700900001:<code>,447700900002:<code> npm run smoke
```
The smoke test signs in the two test numbers, pairs them, checks a live delete, uploads an avatar, sends a note and leaves the couple.

Wait a minute between runs: a number can ask for a code once every 60 seconds. A number that isn't in `SMS_TEST_OTP` gets "Unable to get SMS provider" until a real SMS provider is set; nothing is sent.

To check that the note reached its function:
```bash
ssh root@<server> "docker exec \$(docker ps -qf name=^supabase-db) psql -U postgres -t -c \
  \"select status_code, content from net._http_response order by created desc limit 3\""
```
Expect `200` with `partner has no fcm_token`. The test accounts have no phone token, so the function stops just before sending.

## Day to day

- **New migration:** add the file under `supabase/migrations/`, run the SQL dry run (`supabase/tests/README.md`), then `scripts/db-migrate.sh root@<server>`. With `--list`, it only shows what's pending.
- **Push function change:** `scripts/deploy-functions.sh root@<server>`.
- **Test numbers:** edit `SMS_TEST_OTP` in Coolify and redeploy the service.
- **Studio:** open `https://api.nous-deux.app` and log in with `SERVICE_USER_ADMIN` / `SERVICE_PASSWORD_ADMIN`. Apply schema changes as migration files, not in Studio's SQL editor.

### Rotate the push secret
1. Change `SERVICE_PASSWORD_64_PUSHWEBHOOK` in Coolify and redeploy. The functions get the new value.
2. Give the database the same value:
   ```bash
   ssh root@<server> 'db=$(docker ps --format "{{.Names}}" | grep ^supabase-db); fn=$(docker ps --format "{{.Names}}" | grep ^supabase-edge-functions); \
     docker exec $db psql -U postgres -v s="$(docker exec $fn printenv PUSH_WEBHOOK_SECRET)" \
     -c "ALTER DATABASE postgres SET \"app.settings.push_webhook_secret\" TO :'"'"'s'"'"'"'
   ```
   The value never leaves the server.
3. Update Proton Pass.

## Backups

- **Database.** In Coolify, open the `supabase-db` component, then **Backups**:
  - S3 destination: the Hetzner bucket, endpoint `https://<location>.your-objectstorage.com`.
  - Schedule: daily at 03:17.
  - Keep 14.
  - Run one by hand, then check its size: an open Coolify issue reports empty Supabase dumps.
- **Avatars.** Back up the storage volume (`volumes/storage` in the service folder) to the same bucket, as a Coolify volume backup.
- **Restore test** (do it once now, then after every upgrade): download the latest dump, restore it into a throwaway `supabase/postgres` container, and compare row counts of `profiles`, `couples` and `calendar_events` with the server.

## Upgrades

Coolify never updates a compose service by itself. To upgrade:
1. Take a backup.
2. Change one image tag in `infra/supabase/compose.yml`, following upstream's `docker/docker-compose.yml` and its CHANGELOG.
3. Paste the file into Coolify and redeploy.
4. Run the smoke test.
5. Commit.

Watch for:
- **Postgres major versions:** follow upstream's upgrade guide; a tag change isn't enough.
- **Storage:** some versions add one-way migrations.
- **pg_net:** at first boot, `99-pg-net-access.sql` keeps `net.http_post` to `postgres`, `supabase_functions_admin` and `service_role`; the image grants it to every role. After a pg_net upgrade, check it still does:
  ```sql
  select proacl from pg_proc where proname = 'http_post';
  ```
  The result must not contain `=X`, which would mean PUBLIC can call it again.
- **GoTrue:** its log shows deprecation notices for `GOTRUE_JWT_DEFAULT_GROUP_NAME`. Keep the setting anyway: without it, new users get an empty role and every database call fails (found in the rehearsal).

Versions pinned (2026-11-11, upstream self-hosted v0.8.4). The whole file was rehearsed locally with Docker before the first deploy: a fresh boot, every migration, the functions and the smoke test.

| Image | Version |
|---|---|
| supabase/postgres | 17.6.1.136 |
| supabase/gotrue | v2.197.0 |
| postgrest/postgrest | v14.18 |
| supabase/realtime | v2.148.3 |
| supabase/storage-api | v1.89.12 |
| supabase/postgres-meta | v0.100.0 |
| supabase/edge-runtime | v1.77.9 |
| supabase/studio | 2026.11.02-sha-a05e7ec |
| kong/kong | 3.9.1 (upstream moved to Envoy; Kong is still supported) |

## Troubleshooting

- **No push arrives.**
  - Check `net._http_response` (above). A 403 means the database and the functions have different secrets.
  - A `couple not found` or `no partner` answer is data.
  - `FCM error` shows in `docker logs` of the functions container.
- **Sign-in with Google fails with "audience".** `GOOGLE_CLIENT_IDS` must contain the client id the app requested the token for. On Android that's the web client id.
- **Live updates stop.** Restart `realtime-dev`. Its container name must stay `realtime-dev.supabase-realtime`.
