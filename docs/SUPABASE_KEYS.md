# Supabase keys setup

## Keys in Supabase

In **Project Settings → API** you have:

| Key                           | Use in Flutter? | Where to use                                                                      |
| ----------------------------- | --------------- | --------------------------------------------------------------------------------- |
| **Project URL**               | Yes             | This app (config)                                                                 |
| **anon public** (publishable) | Yes             | This app — safe for client                                                        |
| **service_role** (secret)     | **No**          | Never in the app. Only in Supabase Dashboard, Edge Functions, or a backend server |

The Flutter app only needs **URL** and **anon key**. The service_role key bypasses Row Level Security and must stay server-side.

## Configuring this project

### Option 1: Local file (dev)

1. Open `lib/core/config/supabase_keys.dart`.
2. Set `supabaseUrlLocal` to your Project URL and `supabaseAnonKeyLocal` to your **anon** (public) key.
3. To avoid committing real keys, you can add `lib/core/config/supabase_keys.dart` to `.gitignore` and keep a copy of the file only on your machine (or use Option 2 for production).

### Option 2: Dart define (CI / production)

Build or run with:

```bash
flutter run --dart-define=SUPABASE_URL=https://YOUR_REF.supabase.co --dart-define=SUPABASE_ANON_KEY=your_anon_key
```

These take precedence over the local file.

### Where to use the service_role key

- **Supabase Dashboard**: already has access; no need to paste it in the app.
- **Edge Functions**: use `Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')` in Supabase-hosted functions.
- **Your own backend**: store in env vars, never in the client.

Never put the service_role key in this Flutter project or in any client-side code.
