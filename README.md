# Nous Deux

A privacy-focused couple's app (shared calendar, period tracking, optional location).

## Supabase setup

The app needs your Supabase **Project URL** and **anon (publishable) key** only. The **service_role (secret) key** must never be used in the app.

- **Local dev:** edit `lib/core/config/supabase_keys.dart` and set `supabaseUrlLocal` and `supabaseAnonKeyLocal`.
- **CI / production:** use `--dart-define=SUPABASE_URL=...` and `--dart-define=SUPABASE_ANON_KEY=...`.

See [docs/SUPABASE_KEYS.md](docs/SUPABASE_KEYS.md) for details.
