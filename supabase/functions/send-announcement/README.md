# send-announcement

Sends a message from the team to everyone who uses the app (docs/NOUVEAUTES.md). Only `scripts/announce.sh` calls it, on the server's internal network, with the `x-webhook-secret` header (`PUSH_WEBHOOK_SECRET`). Kong doesn't route `/functions/v1` publicly.

- **Request:** `POST {"action": "test" | "preview" | "send", "slug": "2026-11-20-listes", "content": {"fr": {"title", "body"}, "en": {…}}}`.
- **Checks:**
  - **Languages:** exactly the server's languages (`_shared/i18n/mod.ts`), each with a title of 1–60 characters and a body of 1–280.
  - **Slug:** the file's name, `YYYY-MM-DD-words`.
- **`test`:** pushes to the accounts in `announcement_testers` and saves the message as a draft (`tested_at`), which no one else reads. It answers `{ok, sent, failed}`.
- **`preview`:** answers `{ok, recipients, opted_out}`.
- **`send`:** sets `sent_at` (only once, even when two runs race) and pushes to everyone with a token and app-news pushes on, in `profiles.language`, falling back to English. It answers `{ok, sent, failed, stale_removed}`. Tokens FCM calls unregistered or invalid are cleared.
- **Before preview and send:** a test of the same text must have run, or the answer is `{ok: false, error}`: `not_tested`, `changed_since_test` or `already_sent`.
- **Push data:** `{type: "announcement", id}`, which the app opens on Paramètres › Nouveautés.

Tests: `handler_test.ts` (the command is at its top).
