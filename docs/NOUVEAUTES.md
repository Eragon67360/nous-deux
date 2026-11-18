# Nouveautés Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** The team can send a message to everyone who uses Nous Deux. The message arrives as a push and stays readable in a « Nouveautés » list in the app. This ships in build 29.

**Architecture:**
- **Messages:** each message is a JSON file in `announcements/` holding one title and body per app language.
- **Sending:** `scripts/announce.sh` posts the file over SSH to an internal edge function, `send-announcement`. The function checks the file, records it in `public.announcements` and pushes it through FCM in each person's app language (`profiles.language`).
- **Test first:** a `--test` run goes only to the team's accounts. Sending to everyone is refused until that test has passed with the same text.
- **App:** it reads the sent messages, keeps a last-read time and a push switch on the profile, and shows a gold dot on the avatar while something is unread.

**Tech Stack:** Postgres (RLS, column grants), Deno edge function (FCM HTTP v1), bash + jq + curl over SSH, Flutter (Riverpod, go_router, gen-l10n).

**Spec:** the Claude Design board « Nous Deux · Nouveautés », https://claude.ai/artifact/EzKNa4vi27pthceqqjYYRi (screens 1–4 and the note « Décidé le 18 nov. »). Thomas's decisions, copied here:
1. No line on the home screen. A gold dot on the avatar leads to Paramètres › Nouveautés.
2. Messages are signed « L'équipe Nous Deux » / "The Nous Deux team".
3. Someone who joins later sees the whole list, with no push for older messages.
4. The test send to the team's own accounts is mandatory before a send to everyone.
5. The push and the list follow the language chosen in the app. Every message exists in every app language (FR and EN today, ES once Spanish ships). The script refuses an incomplete file.

## Global Constraints

- Branch `feature/nouveautes` off `dev`, merged by PR. Release as build `0.3.6+29` (version stays 0.3.6).
- **App look:** Carnet style (thin lines, gold labels, large light text, no cards), Manrope only, dark only.
- **App copy:** every new string goes in `app_en.arb` and `app_fr.arb`, then `flutter gen-l10n`. It is exposed through `app/lib/core/constants/news_strings.dart`. French copy is gender-neutral.
- **The « Nouveautés de l'app » switch:** on by default for everyone, existing accounts included. Turning it off stops the push only; the list stays readable.
- **Message limits:** a title is 1–60 characters, a body 1–280. A message has exactly the server's languages (`LANGUAGES` in `supabase/functions/_shared/i18n/mod.ts`). The slug, which is the file name, matches `^\d{4}-\d{2}-\d{2}-[a-z0-9-]+$` and is sent at most once.
- **What a message holds:** no personal data. No tracking of opens. Per account the server stores the push choice and the last-read time; the language was already stored.
- **Privacy policy:** FR and EN change in this branch (`website/lib/dictionaries/{fr,en}.json`).
- **Secrets:** the push secret is read only inside the remote command and never printed.
- **Database changes:** the SQL dry run (`supabase/tests/README.md`) passes before `scripts/db-migrate.sh nous-deux`. The migration has no superuser-only statement.
- **Formatting:** `dart format` only the files touched. Use `dart analyze lib test`, not `flutter analyze`.

## Review Focus

- **Edited after its test:** the file changes after `--test`, then is sent. The send must be refused ("changed since the test") so nobody gets an untested text.
- **Sent twice:** the same file is sent twice, or two sends run at once. Exactly one push per person, and the second run refused.
- **Stale token:** a person whose token FCM reports as unregistered gets their `fcm_token` cleared. The send carries on for everyone else.
- **Language missing:** a person whose `profiles.language` has no text in the message gets English. The function must never send an empty title.
- **Unread for new accounts:** a new account must not see every old message as unread. The last-read time defaults to the account's creation, so the list is complete but undotted.

---

### Task 1: The database

**Files:**
- Create: `supabase/migrations/20261118100000_announcements.sql`
- Create: `supabase/tests/89_announcements_scenario.sql`
- Modify: `supabase/tests/README.md` (one paragraph on scenario 89)

**Interfaces:**
- Produces:
  - **`public.announcements`:** `id uuid pk default gen_random_uuid()`, `slug text unique not null` (with the slug check), `content jsonb not null` (`{"fr":{"title","body"},"en":{…}}`), `tested_at timestamptz`, `sent_at timestamptz`, `created_at timestamptz default now()`.
    - RLS on. `authenticated` may `SELECT (id, content, sent_at)` only where `sent_at IS NOT NULL`. `anon` gets nothing, and no client may write.
  - **`public.announcement_testers`:** `profile_id uuid pk references profiles on delete cascade`. RLS on, and no client access at all.
  - **`public.profiles`** gains:
    - `announcements_push boolean not null default true`;
    - `announcements_seen_at timestamptz not null default now()`.
    - Both get `GRANT INSERT, UPDATE` to `authenticated`, as in migration 20261117200000.

- [ ] **Step 1:** Write scenario 89 in the style of `93_calendar_follow_scenario.sql`. It must check:
  - **Reading:**
    - a signed-in person reads a sent message but not a draft (sent_at null);
    - a signed-out caller reads none;
    - nobody signed in or out can read `slug`, `tested_at` or `announcement_testers`.
  - **Writing:**
    - `authenticated` can't insert, update or delete `announcements`;
    - a person sets their own `announcements_push` and `announcements_seen_at` but not their partner's (0 rows).
  - **Defaults:**
    - a new profile has `announcements_push = true` and `announcements_seen_at` within a second of now();
    - deleting a profile removes its tester row.
- [ ] **Step 2:** Run the dry run without the migration. Expected: scenario 89 fails on the missing table.
- [ ] **Step 3:** Write the migration. Comment each part the way the other migrations do.
- [ ] **Step 4:** Run the full dry run. Expected: every scenario prints only its OK lines, and scenarios 92, 97 and 98 still pass (98 checks that anon gets nothing in public).
- [ ] **Step 5:** Commit `feat(db): announcements, testers and the app-news switch`.

### Task 2: FCM helpers

**Files:**
- Modify: `supabase/functions/_shared/fcm.ts`
- Create: `supabase/functions/_shared/fcm_test.ts`

**Interfaces:**
- Produces:
  - `isStaleToken(detail: string | undefined): boolean`. It is true for FCM's `UNREGISTERED` error, and for `INVALID_ARGUMENT` that names the registration token.
  - `sendPush` reuses one OAuth access token until 5 minutes before it expires, instead of fetching one per message. Its signature is unchanged.

- [ ] **Step 1:** Write the tests:
  - `isStaleToken` is true on a 404 `UNREGISTERED` body and on a 400 `INVALID_ARGUMENT` "registration token" body;
  - it is false on a 500, a quota error and `undefined`.
- [ ] **Step 2:** Run them in the Deno container (command in the `wake-partner-calendar/handler_test.ts` header, pointed at `_shared/`). Expected: they fail.
- [ ] **Step 3:** Implement both changes.
- [ ] **Step 4:** Run `_shared/` and every function's tests. Expected: all pass.
- [ ] **Step 5:** Commit `feat(functions): reuse the FCM access token, spot stale tokens`.

### Task 3: The `send-announcement` function

**Files:**
- Create:
  - `supabase/functions/send-announcement/handler.ts`;
  - `supabase/functions/send-announcement/handler_test.ts`;
  - `supabase/functions/send-announcement/index.ts`;
  - `supabase/functions/send-announcement/README.md`.
- Modify: `scripts/deploy-functions.sh` (add it to `functions`), `supabase/config.toml` (verify_jwt false like the others).

**Interfaces:**
- Consumes:
  - Task 1's tables;
  - `isStaleToken` and `sendPush` (Task 2);
  - `fromDatabase` and `json` (`_shared/database.ts`);
  - `LANGUAGES` (`_shared/i18n/mod.ts`).
- Produces: `handleAnnouncement(req: Request, deps: Deps): Promise<Response>`.
  - **Request:** a POST with `x-webhook-secret` and a body `{ action: "test" | "preview" | "send", slug, content }`.
  - **Answers:** always 200 JSON, except 403 without the secret.
    - `test` → `{ ok: true, sent, failed }`;
    - `preview` → `{ ok: true, recipients, opted_out }`;
    - `send` → `{ ok: true, sent, failed, stale_removed }`;
    - any refusal → `{ ok: false, error }`, where `error` is one of `bad_request`, `bad_slug`, `missing_language:<xx>`, `unknown_language:<xx>`, `title_too_long:<xx>`, `empty:<xx>`, `body_too_long:<xx>`, `already_sent`, `not_tested`, `changed_since_test` or `no_testers`.
  - **`Deps`** (all database work, so the handler is testable with fakes):
    - `findBySlug(slug)` → `{ content, tested_at, sent_at } | null`;
    - `saveTested(slug, content)`, an upsert with `tested_at = now()`;
    - `markSent(slug)` → `id | null`. It runs `UPDATE … SET sent_at = now() WHERE slug = $1 AND sent_at IS NULL RETURNING id`, so the database decides who wins a race.
    - `testers()` and `recipients()` → `{ token, language }[]`. `recipients()` covers `fcm_token IS NOT NULL AND announcements_push`.
    - `optedOutCount()` → number;
    - `clearToken(token)`;
    - `sendPush(token, title, body, data)`.
  - **Push data:** `{ type: "announcement", id }`, where `id` is the row id (`"test"` for a test send).
- Rules:
  - **Same text:** compare content with a canonical JSON stringify (sorted keys).
  - **Language:** the text is `content[language] ?? content.en`.
  - **Sending:** pushes go out 20 at a time.
  - **Stale tokens:** when `isStaleToken`, call `clearToken`.
  - **Logs:** they never contain a token or FCM's error body.

- [ ] **Step 1:** Write `handler_test.ts` with a fake `Deps`. One test each:
  - 403 without the secret;
  - each validation error (a missing `en`, an extra `de`, a 61-character title, an empty body, a bad slug);
  - `test` with no testers → `no_testers`;
  - `test` sends only to testers and saves the test;
  - `test` after a send → `already_sent`;
  - `preview` before a test → `not_tested`;
  - `preview` with edited content → `changed_since_test`;
  - `preview` counts recipients and opt-outs;
  - `send` pushes once per recipient, in their language, with English for `language: "es"`;
  - `send` clears a stale token and counts it;
  - a second `send` → `already_sent` with no push;
  - the push data carries `type` and `id`.
- [ ] **Step 2:** Run it. Expected: it fails, since `handler.ts` doesn't exist yet.
- [ ] **Step 3:** Implement `handler.ts`, then `index.ts`, which wires the Deps to supabase-js with the service role (the same pattern as `wake-partner-calendar/index.ts`).
- [ ] **Step 4:** Run all function tests. Expected: they pass.
- [ ] **Step 5:** Commit `feat(functions): send-announcement`.

### Task 4: `scripts/announce.sh` and the messages folder

**Files:**
- Create: `scripts/announce.sh`, `announcements/README.md`
- Modify: `CLAUDE.md` (one line: how to send a message)

**Interfaces:**
- Consumes: Task 3's request and answers.
- Produces: `scripts/announce.sh <ssh-host|local> announcements/<slug>.json [--test]`.
  - **Finding the function:** it finds the `supabase-edge-functions` container the way `deploy-functions.sh` does. It reads `PUSH_WEBHOOK_SECRET` with `docker exec … printenv` inside the remote command, then curls `http://<container ip>:9000/send-announcement`. The secret never reaches this Mac.
  - **Checking the file:** with jq, before any call. The JSON must parse, and the slug comes from the file name.
  - **Output:**
    - **`--test`:** prints « Envoi test aux comptes de l'équipe : envoyés N, échecs F. Rien n'est enregistré dans Nouveautés. »
    - **Without `--test`:** a preview first, with each language's title and the start of its body (60 characters), plus « Destinataires : N comptes avec push, M ont coupé « Nouveautés ». ». Then it asks « Tapez ENVOYER pour envoyer à tout le monde : ». Anything else exits 1 with nothing sent. After the send it prints « Envoyés : N · échecs : F · jetons périmés retirés : K ».
    - **Refusals:** a function refusal prints in French and exits 1.

- [ ] **Step 1:** Try it on the rehearsal stack (`~/perso/nous-deux/rehearsal`).
  1. Apply Task 1 with `scripts/db-migrate.sh local` and copy the functions into its functions container.
  2. Add Alex as a tester.
  3. Run, in order: `--test` (expect sent 0, failed 0, since Alex has no token), a preview, a wrong confirmation (expect nothing sent), `ENVOYER`, and a second send (expect « déjà envoyé »).
  4. Edit the file after a test (expect « modifié depuis l'essai »).
  5. Remove `en` (expect « langue manquante : en »).
- [ ] **Step 2:** Write `announcements/README.md`: the format, the rules, and the 3 commands.
- [ ] **Step 3:** Commit `feat(scripts): announce.sh sends a message to everyone`.

### Task 5: App data

**Files:**
- Modify:
  - `app/lib/domain/entities/profile_entity.dart`;
  - `app/lib/data/models/profile_model.dart`;
  - the profile repository (interface + `profile_repository_impl.dart`).
- Create:
  - `app/lib/domain/entities/announcement_entity.dart`;
  - `app/lib/data/repositories/announcements_repository.dart`;
  - `app/lib/presentation/providers/announcements_provider.dart`.
- Test: `app/test/data/announcement_entity_test.dart`, `app/test/presentation/providers/announcements_provider_test.dart`.

**Interfaces:**
- Produces:
  - **The message:** `AnnouncementEntity { String id; DateTime sentAt; Map<String, ({String title, String body})> texts; ({String title, String body}) textFor(String lang) }`. `textFor` falls back to `en`, then to the first language present. It comes from `AnnouncementEntity.fromJson(Map)`.
  - **Profile fields:** `ProfileEntity.announcementsPush` (bool, default true when the column is missing) and `ProfileEntity.announcementsSeenAt` (DateTime?).
  - **Profile repository:**
    - `setAnnouncementsPush(bool)`;
    - `markAnnouncementsSeen()`, which writes `announcements_seen_at = now()` (UTC, client clock) and refreshes `myProfileProvider`.
  - **Providers:**
    - `announcementsProvider`, a `FutureProvider<List<AnnouncementEntity>>` with the newest first;
    - `unreadAnnouncementsCountProvider` (`Provider<int>`), the messages whose `sentAt` is after `announcementsSeenAt`. It is 0 while loading or on error.

- [ ] **Step 1:** Write the tests:
  - `fromJson` with fr and en;
  - `textFor('es')` → English;
  - `textFor` when only `fr` is present;
  - the unread count with seen-at before, between and after two messages;
  - the count is 0 on error;
  - the profile model reads both new columns and defaults when they're missing (older rows in tests).
- [ ] **Step 2:** Run `flutter test` on those files. Expected: they fail.
- [ ] **Step 3:** Implement them.
- [ ] **Step 4:** Run them. Expected: they pass.
- [ ] **Step 5:** Commit `feat(app): announcements data and unread count`.

### Task 6: App screens

**Files:**
- Create:
  - `app/lib/presentation/screens/settings/announcements_screen.dart`;
  - `app/lib/core/constants/news_strings.dart`.
- Modify:
  - `app/lib/l10n/app_en.arb`, `app/lib/l10n/app_fr.arb` (+ the generated files);
  - `app/lib/core/utils/app_routes.dart` + `app_router.dart` (route `/settings/news`, `AppRoutes.settingsNews`);
  - `app/lib/presentation/screens/settings/settings_screen.dart`;
  - `app/lib/presentation/screens/nous/nous_screen.dart` (`_AvatarButton` gets `bool unread`).
- Test:
  - `app/test/presentation/screens/announcements_screen_test.dart`;
  - additions to the settings and Nous screen tests;
  - the strings snapshot refreshed.

**Interfaces:**
- Consumes: Task 5's providers and repository methods.
- Strings (en / fr):

| Key | en | fr |
| --- | --- | --- |
| `newsTitle` | What's new | Nouveautés |
| `newsSignature` | The Nous Deux team | L'équipe Nous Deux |
| `newsUnread` (plural `count`) | {count} unread | {count} non lue / {count} non lues |
| `newsEmpty` | Nothing new yet. | Rien de nouveau pour l'instant. |
| `settingsNewsPush` | App news | Nouveautés de l'app |
| `settingsNewsPushSubtitle` | New features and messages from the Nous Deux team. | Les nouvelles fonctions et les messages de l'équipe Nous Deux. |
| `newsAvatarUnread` (plural `count`) | Settings, {count} new message / Settings, {count} new messages | Réglages, {count} nouveauté / Réglages, {count} nouveautés |

- **Screen 2: the list.**
  - Title « Nouveautés ».
  - **Each article:** a gold uppercase date label (`d MMM` in `AppLanguages.dateLocale(lang)`), a 7 px gold dot when it was unread on opening, the title in 21 light, the body in 15, and the signature in 13 muted. A line goes between articles.
  - **Order:** newest first.
  - **Empty state:** `newsEmpty`.
  - **Marking read:** it remembers `announcementsSeenAt` when opened, then calls `markAnnouncementsSeen()` once.
- **Screen 3: Settings.**
  - **About group:** a « Nouveautés » row after « À propos », with a gold dot and `newsUnread` when the count is above 0. It opens `/settings/news`.
  - **Notifications group:** a switch `settingsNewsPush` with its subtitle, bound to `announcementsPush`.
- **Nous home:** a 9 px gold dot with a 2 px background ring at the avatar's top right while the count is above 0. The tooltip and semantics use `newsAvatarUnread`.

- [ ] **Step 1:** Write the widget tests:
  - **The list:** it shows two messages newest first in the profile language, with a dot only on the one sent after seen-at; it calls `markAnnouncementsSeen` once; it shows the empty state.
  - **Settings:** the row shows « 1 non lue » and opens the route; the switch writes `setAnnouncementsPush(false)`.
  - **Nous:** the avatar has the dot and its semantics label only when the count is above 0.
- [ ] **Step 2:** Run them. Expected: they fail.
- [ ] **Step 3:** Add the ARB strings, run `flutter gen-l10n`, implement, then `dart format` the touched files.
- [ ] **Step 4:** Run `flutter test` (the whole suite, with `UPDATE_STRINGS_SNAPSHOT=1` once for the new keys, then without) and `dart analyze lib test`. Expected: all green and no issues.
- [ ] **Step 5:** Commit `feat(app): the Nouveautés list, its settings and the avatar dot`.

### Task 7: Tapping the push opens Nouveautés

**Files:**
- Modify:
  - `app/lib/core/services/fcm_service.dart`;
  - `app/lib/presentation/screens/main/main_shell_screen.dart`;
  - `app/lib/presentation/providers/announcements_provider.dart` (refresh).
- Test: `app/test/core/services/fcm_service_test.dart` (or the existing test of `openedNoteFrom`), and the main shell test.

**Interfaces:**
- Produces:
  - **Parsing:** `sealed class OpenedPush`, with `OpenedNotePush(OpenedNote note)` and `OpenedAnnouncementPush()`. `openedPushFrom(Map<String, dynamic> data) → OpenedPush?`. The existing `openedNoteFrom` is kept and used inside it.
  - **Taps:** `openedPushesProvider` replaces `openedNotesProvider`. There's one stream, because `getInitialMessage()` only answers once.
  - **Main shell:** an announcement tap invalidates `announcementsProvider` and pushes `AppRoutes.settingsNews`.
  - **Refresh:** `announcementsProvider` is also invalidated when the app resumes.

- [ ] **Step 1:** Write the tests:
  - `openedPushFrom({type: announcement, id: x})` → `OpenedAnnouncementPush`;
  - a ping still parses as before;
  - an unknown type → null;
  - the main shell, given a fake stream with an announcement, lands on the Nouveautés screen.
- [ ] **Step 2:** Run them. Expected: they fail.
- [ ] **Step 3:** Implement.
- [ ] **Step 4:** Run the whole suite and analyze. Expected: green.
- [ ] **Step 5:** Commit `feat(app): a tapped app-news push opens Nouveautés`.

### Task 8: Privacy policy, docs, build 29

**Files:**
- Modify:
  - `website/lib/dictionaries/fr.json`, `website/lib/dictionaries/en.json` (the data stored section);
  - `docs/SELF_HOSTING.md` (the function list, if it names them);
  - `app/pubspec.yaml` (`0.3.6+29`).

- [ ] **Step 1:** Add to the policy, in both languages, matching the existing wording:
  - the team sends occasional messages about the app;
  - per account the server keeps whether app-news pushes are on and when the list was last opened;
  - messages hold no personal data, and opens aren't tracked.
- [ ] **Step 2:** Run `npm run build` (or the dictionary check) from `website/`. Expected: it passes.
- [ ] **Step 3:** Raise the build to `0.3.6+29` and commit `docs: privacy policy for app news; chore(app): build 29`.

## After the tasks

1. Final review of the branch.
2. Open the PR into `dev` and merge it once checks pass.
3. Deploy:
   - `scripts/db-migrate.sh nous-deux`;
   - `scripts/deploy-functions.sh nous-deux`;
   - add Thomas's account to `announcement_testers`.
4. Release PR `dev` → `main` for build 29.

The first message to everyone is sent only with Thomas's go-ahead.
