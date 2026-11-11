# Nous Deux

A privacy-focused couple's app (shared calendar, period tracking, optional location).

## Supabase setup

The backend is a self-hosted Supabase at `https://api.nous-deux.app` (Hetzner, managed with Coolify). [docs/SELF_HOSTING.md](../docs/SELF_HOSTING.md) covers the server, migrations, push functions, backups and upgrades.

The app needs the **URL** and **anon (publishable) key** only. The **service_role (secret) key** must never be used in the app.

- **Local dev:** edit `lib/core/config/supabase_keys.dart` and set `supabaseUrlLocal` and `supabaseAnonKeyLocal`.
- **CI / production:** the pipeline provides a keys file from the stub and supplies `SUPABASE_URL` and `SUPABASE_ANON_KEY` via `--dart-define`; no local `supabase_keys.dart` is required in the repo.

See [docs/SUPABASE_KEYS.md](docs/SUPABASE_KEYS.md) for details.
