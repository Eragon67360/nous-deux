# Supabase keys setup

## Keys in Supabase

The server is self-hosted ([SELF_HOSTING.md](SELF_HOSTING.md)): Coolify generates the keys, and they're kept in Proton Pass (`Nous Deux / Supabase`). There are three values:

| Key                           | Use in Flutter? | Where to use                                                                      |
| ----------------------------- | --------------- | --------------------------------------------------------------------------------- |
| **URL** (`https://api.nous-deux.app`) | Yes | This app (config) |
| **anon public** (`SERVICE_SUPABASEANON_KEY`) | Yes | This app; safe for the client |
| **service_role** (`SERVICE_SUPABASESERVICE_KEY`) | **No** | Never in the app. Only on the server (Edge Functions) |

The Flutter app only needs **URL** and **anon key**. The service_role key bypasses Row Level Security and must stay server-side.

## Configuring this project

### Option 1: Local file (dev)

1. Open `lib/core/config/supabase_keys.dart`.
2. Set `supabaseUrlLocal` to your Project URL and `supabaseAnonKeyLocal` to your **anon** (public) key.
3. To avoid committing real keys, you can add `lib/core/config/supabase_keys.dart` to `.gitignore` and keep a copy of the file only on your machine (or use Option 2 for production).

### Option 2: Dart define (CI / production)

In CI/production, the workflow creates `supabase_keys.dart` from the committed stub and passes `SUPABASE_URL` and `SUPABASE_ANON_KEY` via `--dart-define` (from secrets). The app uses those values; the stub file is only so the build can resolve the import.

To build or run locally with env only:

```bash
flutter run --dart-define=SUPABASE_URL=https://api.nous-deux.app --dart-define=SUPABASE_ANON_KEY=your_anon_key \
  --dart-define=GOOGLE_WEB_CLIENT_ID=… --dart-define=GOOGLE_IOS_CLIENT_ID=…
```

These take precedence over the local file.

### Where to use the service_role key

- **Studio** (`https://api.nous-deux.app`, behind its own password) already has access.
- **Edge Functions**: the server passes it as `SUPABASE_SERVICE_ROLE_KEY`.

Never put the service_role key in this Flutter project or in any client-side code.
