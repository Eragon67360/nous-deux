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
   | `APPLE_CLIENT_IDS` | `app.nous-deux` (the iOS bundle id) | no |

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
- **iOS**, with bundle id `app.nous-deux` and team id `2Y57C77BK4`.
- **Android**, package `com.nousdeux.android`: one client per signing certificate, since each holds one SHA-1.
  - "Nous Deux Android (debug key)": local `flutter run` builds.
  - "Nous Deux Android (Play signing)": installs from Google Play, signed by Play App Signing (SHA-1 `CB:21:B5:E1:97:CB:61:C7:1F:E8:54:99:7C:52:A1:DC:5E:4E:14:50`). Added 2026-11-12.
  - "Nous Deux Android (upload key, GitHub APKs)": the APKs CI attaches to GitHub Releases, signed with the upload key (SHA-1 `1A:55:D4:4C:8D:E0:DE:47:6B:9F:DD:E7:AB:6A:5B:2E:A0:5B:3C:7E`). Added 2026-11-12.
  - Both fingerprints come from Play Console › Nous Deux › Test and release › App integrity › App signing.

Done on 2026-11-10 (the iOS client moved to `app.nous-deux` on 2026-11-11):
- Consent screen: External, in production, basic scopes only (no review needed), authorized domain `nous-deux.app`.
- Client ids: web `836600962251-ujn657…`, iOS `836600962251-gev8n6…`, Android `836600962251-74i064…` (debug key SHA-1 only for now).
- They're public identifiers. The web and iOS ids are the defaults in `app/lib/core/constants/app_constants.dart`; `app/ios/Runner/Info.plist` holds `GIDClientID` and the reversed iOS id as a URL scheme.

Still to do: add the Play app-signing SHA-1 to the Android client before a Play release. Play Console → Test and release → App integrity.

### 5. Apple Developer (Thomas)
The iOS app is `app.nous-deux` (the domain reversed) in the paid team `2Y57C77BK4`; Android keeps `com.nousdeux.android`. Registered on 2026-11-11 with **Sign in with Apple** on. The app declares it in `app/ios/Runner/Runner.entitlements`.

Why not `com.nousdeux.app`: Apple answers "not available". The project was first signed with the free Personal Team `2YPH2XA7AZ`, which most likely registered it in February. Only Apple Developer Support can release an ID from a free team.

To build for a device or use Sign in with Apple, Xcode needs the Apple ID that owns team `2Y57C77BK4` (**Xcode → Settings → Accounts**).

Still to do: one real Sign in with Apple, on an iPhone signed in to an Apple Account (a TestFlight build works). On 2026-11-11 the simulator couldn't sign in to an Apple Account: Apple took the password, then failed at the two-factor step. The App ID, the server setting and the app's nonce code are in place.

### 6. Firebase (Thomas)
- **iOS app:** "Nous Deux iOS" (`app.nous-deux`, app id `1:836600962251:ios:e48ad19409b909f70f4f4e`), added on 2026-11-11. The older iOS app "nousdeux (ios)" is registered for `com.nousdeux.app` and no longer used.
- **Service account:** in **Project settings → Service accounts**, use **Generate new private key**. Its JSON becomes `FIREBASE_SERVICE_ACCOUNT_JSON`, and the downloaded file is deleted once it's in Proton Pass.

### 7. Database and functions (Claude or Thomas, over SSH)
```bash
scripts/db-migrate.sh root@<server>       # applies and records every migration
scripts/deploy-functions.sh root@<server> # copies the push functions, restarts them
```

### 8. App configuration
- **Local:** in the gitignored `app/lib/core/config/supabase_keys.dart`, set `supabaseUrlLocal = 'https://api.nous-deux.app'` and the anon key.
- **CI:** set these GitHub secrets: `SUPABASE_URL`, `SUPABASE_ANON_KEY`. The Google client ids are public and built into `app/lib/core/constants/app_constants.dart`.

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

Set up on 2026-11-12 with Coolify 4.7.5. Both schedules live on the `supabase` service under **Backups**, and upload to the Hetzner bucket `nous-deux-backups` in Helsinki (`hel1`). The server is in `nbg1`, so losing one site doesn't lose both.

| What | Schedule (UTC) | File | Kept |
|---|---|---|---|
| Database `postgres` | `17 3 * * *` | `pg_dump --format=custom`, about 0.5 MB | 7 on the server, 14 in the bucket |
| Avatars (`volumes/storage`) | `27 3 * * *`, containers keep running | `.tar.gz` of the folder | 7 on the server, 14 in the bucket |

- **S3 access:** Coolify's S3 storage `hetzner-hel1-nous-deux-backups` (endpoint `https://hel1.your-objectstorage.com`, region `hel1`). The key is in Proton Pass, `Nous Deux / Backups S3`.
- **On the server:** `/data/coolify/backups/databases/…/pg-dump-postgres-<time>-<id>.dmp` and `/data/coolify/backups/volumes/…/directory-…storage-<time>.tar.gz`. **Executions** in Coolify lists every run with its size and a download button.
- **Checks:** Coolify fails a run only when the file is empty. The empty Supabase dumps reported upstream don't happen here: the image sets `POSTGRES_USER=supabase_admin`, which logs in on the local socket without a password. A good dump starts with `PGDMP`.
- **Retention:** after changing it, reopen the schedule to check. On 2026-11-12 the first save on the database schedule didn't stick (0 means keep everything).
- **Deleted accounts** stay in the backups for up to 14 days.
- **Not in a dump:**
  - `app.settings.jwt_exp` and `app.settings.push_webhook_secret`. A fresh deploy sets both at first boot from its environment.
  - `net._http_response`, pg_net's short-lived reply log.
  - The Vault key, `pgsodium_root.key` in the `supabase-db-config` volume. Vault is unused (`vault.secrets` is empty); before storing anything in it, copy that key to Proton Pass.

### Restore the database

This works on the same server or on a fresh deploy. For a fresh deploy, do One-time setup 1 to 3 with the values from Proton Pass, run `scripts/deploy-functions.sh`, and skip `db-migrate.sh`: the dump holds the schema. Let the new stack come up healthy once before restoring, because Realtime creates its database role when it starts.

1. Put the dump on the server as `/root/restore.dmp`, from Coolify's download button or from `/data/coolify/backups`.
2. Stop the services that use the database:
   ```bash
   docker ps --format '{{.Names}}' | grep -E '^(supabase-(kong|auth|rest|storage|meta|studio|edge-functions)|realtime-dev)-' > /root/stopped.txt
   xargs docker stop < /root/stopped.txt
   ```
3. Restore. It should finish without errors.
   ```bash
   db=$(docker ps --format '{{.Names}}' | grep ^supabase-db)
   docker cp /root/restore.dmp $db:/tmp/restore.dmp
   docker exec $db pg_restore -U supabase_admin -d postgres --clean --if-exists /tmp/restore.dmp
   ```
4. Put the grants back. `pg_restore` recreates every table, Supabase's default privileges then give `anon` everything on it, and the dump only adds grants back: the migrations' `REVOKE`s are lost. Reset our two schemas, then replay the dump's own grants:
   ```bash
   docker exec $db psql -U supabase_admin -d postgres -v ON_ERROR_STOP=1 -c "
     REVOKE ALL ON ALL TABLES    IN SCHEMA public, private FROM anon, authenticated, service_role;
     REVOKE ALL ON ALL SEQUENCES IN SCHEMA public, private FROM anon, authenticated, service_role;
     REVOKE ALL ON ALL FUNCTIONS IN SCHEMA public, private FROM anon, authenticated, service_role;"
   docker exec $db sh -c 'pg_restore -l /tmp/restore.dmp | grep -E "^[0-9]+; [0-9]+ [0-9]+ ACL (public|private) " > /tmp/acl.list \
     && pg_restore -U supabase_admin -d postgres -L /tmp/acl.list /tmp/restore.dmp'
   docker exec $db psql -U supabase_admin -d postgres -tAc "select relacl from pg_class where oid = 'public.cycle_notes'::regclass"
   ```
   The last command's output must not mention `anon`.
5. Clean up, start the services, then run the smoke test ([step 9](#9-check)):
   ```bash
   docker exec $db rm /tmp/restore.dmp /tmp/acl.list && rm /root/restore.dmp
   xargs docker start < /root/stopped.txt
   ```

On the same server, objects created after the dump (a newer migration, say) aren't dropped. If that matters, restore onto a fresh deploy.

### Restore the avatars

Restore the database first, since `storage.objects` lists the files. Then, with the archive at `/root/storage.tar.gz`:
```bash
dir=$(ls -d /data/coolify/services/*/volumes/storage)
st=$(docker ps --format '{{.Names}}' | grep ^supabase-storage)
docker stop $st && tar -xzf /root/storage.tar.gz -C "$dir" && docker start $st
```
Paths in the archive are relative to the folder (`./stub/…`). Not yet tried with real files: the folder was empty on 2026-11-12.

### Restore test

Run it after every Postgres or Supabase upgrade, and once there are real avatars. Always on the Mac, never on the server.

1. Fetch the latest dump and start a throwaway database. The plain image lacks two roles that the server gets from the compose file and from Realtime, so create them first:
   ```bash
   mkdir -m 700 ~/restore-test
   scp "root@<server>:$(ssh root@<server> 'ls -t /data/coolify/backups/databases/*/*/*.dmp | head -1')" ~/restore-test/restore.dmp
   docker run -d --name nd-restore-check -e POSTGRES_PASSWORD=$(openssl rand -hex 16) \
     supabase/postgres:17.6.1.136 postgres -c config_file=/etc/postgresql/postgresql.conf
   # Wait until this says "accepting connections" twice in a row (it restarts once after init):
   docker exec nd-restore-check pg_isready -h 127.0.0.1
   docker exec nd-restore-check psql -U supabase_admin -d postgres -c "
     create role supabase_functions_admin noinherit createrole login noreplication;
     create role supabase_realtime_admin noinherit nologin noreplication;"
   ```
2. Run steps 3 and 4 of [Restore the database](#restore-the-database) with `db=nd-restore-check` and `docker cp ~/restore-test/restore.dmp`.
3. Count the rows of every table, locally and on the server (add `-e PGOPTIONS='-c default_transaction_read_only=on'` to the server's `docker exec`), and compare. Only `net._http_response` may differ.
   ```sql
   select n.nspname || '.' || c.relname,
          (xpath('/row/c/text()', query_to_xml(format('select count(*) as c from %I.%I', n.nspname, c.relname), false, true, '')))[1]::text::int
   from pg_class c join pg_namespace n on n.oid = c.relnamespace
   where c.relkind in ('r', 'p') and n.nspname not in ('pg_catalog', 'information_schema') and n.nspname !~ '^pg_'
   order by 1;
   ```
4. Delete everything, since the dump holds real health data: `docker rm -f nd-restore-check && rm -rf ~/restore-test`.

Last run: 2026-11-12, on the first Coolify dump. The restore had no errors, and all 68 tables had the server's row counts except `net._http_response`. Owners, grants, RLS flags and the 24 policies matched the server. Without step 4, `anon` had every right on `cycle_notes`, `cycle_checkins`, `shared_lists`, `shared_list_items` and `couple_pings`.

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
