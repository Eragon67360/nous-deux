# Calendar Sync Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** the events of a phone calendar a person chooses to follow appear in the couple's Nous Deux calendar and stay up to date (changes, moves and deletions follow) without importing again.

**Architecture:** each phone syncs only its own calendar, since no phone can read another's. One Dart routine compares the followed calendars with the person's synced events on the server, keyed per occurrence, and applies the difference. It runs when the app opens or resumes and when the calendar tab opens. On Android a WorkManager content-URI trigger also runs it when the phone calendar changes. On iPhone a silent push, sent when the partner opens the calendar tab, runs it in the background when iOS allows.

**Tech Stack:** Flutter (Riverpod, `device_calendar` 4.3.3, `firebase_messaging` 16.7.1, `supabase_flutter` 2.12.0, `crypto`), Kotlin WorkManager, self-hosted Supabase (Postgres triggers, `pg_net`, Deno edge functions), FCM HTTP v1.

**Spec:** the Decisions section below, agreed with Thomas on 2026-11-17.

**Status (2026-11-17):** Tasks 1–6 are done (#128–#131 and the PR for Tasks 5–6): followed calendars sync when the app opens or resumes, and opening the calendar asks to wake the partner's phone. Thomas picked follow screen A (with B's « Nous » tip) and calendar B. Tasks 0, 7 and 8 (background sync) wait for a Galaxy S25 on adb and an iPhone.

## Where we start

- **Import is a one-time copy.** `calendar_import_screen.dart` reads a chosen phone calendar over a date range (30 days back to 30 days ahead by default) and calls `createEvent` for each event (title, description, start, end). Nothing links the copy to its source: re-importing duplicates, and changes in the phone calendar never follow.
- **The shared calendar is already live.** `calendar_events` is in the Realtime publication, and `calendarEventsProvider` streams it, so a partner with the calendar open sees new rows at once.
- **Rules on `calendar_events`:** both members can do anything (`Couple members can manage calendar events`), and `calendar_events_keep_author` keeps `created_by`. Events go with the couple (`ON DELETE CASCADE`), which is how leaving and account deletion clear them.
- **Pushes:** `private.notify_push(<function>)` posts a row to an internal function with the shared secret, the function sends through `_shared/fcm.ts` `sendPush()` (always a visible notification). iOS already has `UIBackgroundModes: remote-notification`; the app has no background message handler.
- **Platform limits (checked 2026-11-17):**
  - **iOS:** EventKit can't wake an app when the calendar changes; background refresh runs when iOS decides. A background push (`content-available`) can wake the app, at low priority, throttled (Apple advises at most two or three an hour), never after the person swiped the app away. [EventKit](https://developer.apple.com/documentation/eventkit/updating-with-notifications)
  - **Android:** WorkManager can run one-time work when a content URI changes (`Constraints.Builder.addContentUriTrigger`). [Docs](https://developer.android.com/reference/kotlin/androidx/work/Constraints.ContentUriTrigger). One report says re-enqueuing from the worker stops after a few runs. [Issue](https://issuetracker.google.com/issues/79550068) Nobody confirms it for the calendar provider: Task 0 checks it.
  - **`device_calendar`** gives each event a per-phone `eventId` and `calendarId`, not the calendar's own UID, so an event can't be matched across phones.
  - The Samsung release-build bug where phone calendars showed none was fixed in #103.

## Decisions

These are settled so the work doesn't stall. Each can be changed before its task starts.

1. **Each phone syncs its own calendars.** No shared Google calendar, no server access to Google or Outlook accounts, nothing new in the store review.
2. **Following replaces importing.** The Import screen becomes « Agenda du téléphone » / "Phone calendar": a switch per phone calendar. Events imported before stay as ordinary events.
3. **Window:** from 30 days ago to 183 days ahead. Synced events that started before the window are history and stay.
4. **Copied fields:** title, start, end, nothing else (no description, place or guests). Titles are cut to 200 characters (`AppConstants.eventTitleMaxLength`); events without a title are skipped, as import does today.
5. **Synced events are read-only in Nous Deux**, for both partners, and say « Depuis l'agenda de Camille » / "From Camille's calendar". They're changed in the phone calendar. Only the countdown switch (`is_countdown`) stays editable, by either partner.
6. **Unfollowing a calendar removes its events from the window** at the next sync. Turning following off for every calendar removes them all.
7. **One syncing phone per person.** The phone that turns following on writes its install id to `profiles.calendar_sync_device`. Another phone of the same person that was syncing sees the id change and stops, without deleting anything. The new phone's first sync replaces the old phone's events, since per-phone ids differ.
8. **Waking the partner's phone:** opening the calendar tab asks the server to wake the partner's phone, unless their calendar synced in the last 10 minutes or a wake was sent to them in the last 20 minutes. The wake is a data-only push: background and low priority on iOS, normal priority on Android.
9. **The partner sees freshness:** « Agenda de Camille à jour il y a 3 min » / "Camille's calendar updated 3 min ago", from `profiles.calendar_synced_at`.
10. **Privacy:** the policy (FR/EN) says that the events (title and times) of the calendars you follow are copied and kept up to date, including in the background, and that unfollowing removes them. The install id joins the declared "Device ID" (both stores already declare the push token there). The iOS permission text gets its English version in localization PR 4.
11. **Wireframes first:** the « Agenda du téléphone » screen, the synced-event marking and the freshness line go to Claude Design with variants for Thomas to pick before Task 5.

## Global Constraints

- Branches off `dev`, one PR per task group (table below), merged once checks pass; the migration is applied with `scripts/db-migrate.sh nous-deux` after its dry run, the function deployed with `scripts/deploy-functions.sh`.
- Copy is bilingual: new strings in `app/lib/core/constants/calendar_strings.dart` as `lang == 'fr' ? … : …`, dates through `AppLanguages.dateLocale(lang)`. French uses a non-breaking space before « : ».
- `dart format` only the files you touch; `dart analyze lib test` stays at its 7 pre-existing infos.
- Constants: `calendarSyncPastDays = 30`, `calendarSyncFutureDays = 183`, fresh `10 minutes`, wake spacing `20 minutes`, title cap `200`.
- `source_key` is `sha256("$calendarId|$eventId|${start.toUtc().toIso8601String()}")` in lowercase hex: no raw phone identifier leaves the phone.
- Nothing raw is logged: no titles, ids or tokens in function logs or Dart prints.

## Review Focus

1. **The phone calendar can't be read** (permission revoked, plugin error, calendar gone): the sync must change nothing on the server, not delete everything. Test in Task 4.
2. **Leaving the couple or deleting the account** must still delete synced events, including the partner's, although the new trigger forbids deleting a partner's synced event. Test in Task 1.
3. **A recurring event:** each occurrence in the window is its own row; moving one occurrence on the phone replaces only that one. Test in Task 3.
4. **The same person on two phones:** only the phone named in `calendar_sync_device` syncs; the other stops following and deletes nothing. Test in Task 4.
5. **An all-day event** keeps its day in the phone's own time zone, as the plugin really delivers it: Android brings the date back to midnight UTC, iPhone gives no time zone so it arrives in UTC (start stored as the phone's local midnight). Tests in Task 3 use both shapes. A partner in another time zone still sees it shifted, since `calendar_events` has no all-day flag; adding one is left for later.

---

### Task 0: Device check (throwaway branch, not merged)

Proves the two background paths on real phones before anything is built on them: Thomas's Galaxy S25 and an iPhone with build 26's push setup.

- [ ] **Step 1:** Android: a `CoroutineWorker` enqueued as unique one-time work with `addContentUriTrigger(CalendarContract.Events.CONTENT_URI, true)` that starts a `FlutterEngine` on a Dart entrypoint, reads one calendar with `device_calendar` and writes a row through Supabase, then re-enqueues itself. Add, edit and delete events 10 times with the app swiped away. Expected: every change reaches the server, each within 2 minutes.
- [ ] **Step 2:** iOS: a `FirebaseMessaging.onBackgroundMessage` handler for `{type: calendar_sync}` that initialises Supabase, reads EventKit and writes a row; send the Task 2 payload by hand 5 times, 20 minutes apart, with the app in the background (not swiped away). Expected: at least 3 of 5 arrive within a minute.
- [ ] **Step 3:** Write the results into this file under "Where we start", then decide. If Android fails, it uses the iOS path (wake push) instead of Task 8. If iOS fails, iPhones sync on open only and Task 2's push goes to Android only.

### Task 1: Database (PR 1)

**Files:**
- Create: `supabase/migrations/<day>100000_calendar_follow.sql`
- Create: `supabase/tests/93_calendar_follow_scenario.sql`
- Modify: `supabase/tests/README.md` (one paragraph for 93)

**Interfaces:**
- Produces:
  - `calendar_events.source_key TEXT NULL` with `CHECK (source_key ~ '^[0-9a-f]{64}$')`, and a unique index `calendar_events_source_key` on `(created_by, source_key) WHERE source_key IS NOT NULL`.
  - Trigger `calendar_events_synced_rules` (BEFORE UPDATE OR DELETE, function `public.calendar_events_synced_rules()`). When a client changes a synced event it didn't author, an update may only change `is_countdown`, and a delete is refused: `RAISE EXCEPTION 'synced_event' USING ERRCODE = 'P0001'`.
  - `profiles.calendar_sync_device TEXT NULL CHECK (calendar_sync_device ~ '^[0-9a-f-]{36}$')` and `profiles.calendar_synced_at TIMESTAMPTZ NULL`, both added to the column grants of `20261116050000_profiles_own_and_partner_only.sql` (INSERT and UPDATE).
  - `private.calendar_wakes (id UUID PK DEFAULT gen_random_uuid(), user_id UUID NOT NULL REFERENCES public.profiles ON DELETE CASCADE, sent_at TIMESTAMPTZ NOT NULL DEFAULT now())`, with trigger `calendar_wakes_notify` AFTER INSERT → `private.notify_push('wake-partner-calendar')`.
  - `public.request_partner_calendar_sync() RETURNS TEXT`, SECURITY DEFINER, `SET search_path = ''`, executable by `authenticated` only. It returns `'not_paired'`, `'not_following'` (the partner's `calendar_sync_device` is null), `'fresh'` (their `calendar_synced_at` is within 10 minutes), `'recent'` (a wake to them within 20 minutes) or `'sent'` (after inserting into `private.calendar_wakes`).

The cascade exemption is the part a reader would get wrong: foreign-key cascades run the trigger one level deeper than a client's own statement.

```sql
IF pg_trigger_depth() = 1 AND OLD.source_key IS NOT NULL
   AND auth.uid() IS DISTINCT FROM OLD.created_by THEN
  -- DELETE: refuse. UPDATE: refuse unless only is_countdown differs.
END IF;
```

- [ ] **Step 1: Write the scenario** `93_calendar_follow_scenario.sql`, one `pg_temp.expect` line per check:
  - the owner inserts, updates and deletes a synced event;
  - the partner can't change a synced event's title or start, nor delete it, but can switch its countdown;
  - the partner can still edit and delete ordinary events;
  - the same `(created_by, source_key)` can't be inserted twice, and a malformed `source_key` is refused;
  - after `leave_couple()` no synced event of either partner remains, and the same after `delete_my_account()` by `user2`;
  - `request_partner_calendar_sync()` gives `not_paired` alone, then `not_following`, `sent`, `recent` on an immediate second call, and `fresh` once the partner's `calendar_synced_at` is now; it inserts one `private.calendar_wakes` row and the push recorder in `00_supabase_stubs.sql` saw one call to `wake-partner-calendar`;
  - signed-out callers can't call it, and clients can't read `private.calendar_wakes`.
- [ ] **Step 2:** Run the dry run (`supabase/tests/README.md`). Expected: 93 fails at its first check.
- [ ] **Step 3:** Write the migration (comment each part as the other migrations do).
- [ ] **Step 4:** Run the whole dry run. Expected: every scenario passes, 93 included; the column grant change keeps 97 green.
- [ ] **Step 5:** Commit, PR, merge; `scripts/db-migrate.sh nous-deux --list` then apply. Nothing in it needs a superuser.

### Task 2: Wake push function (PR 2)

**Files:**
- Modify: `supabase/functions/_shared/fcm.ts`
- Create: `supabase/functions/wake-partner-calendar/index.ts`, `handler.ts`, `handler_test.ts`
- Modify: `supabase/config.toml` (`[functions.wake-partner-calendar] verify_jwt = false`), `supabase/functions/README` if it lists functions

**Interfaces:**
- Consumes: the `private.calendar_wakes` row from Task 1 (`record.user_id`).
- Produces:
  - `backgroundMessage(token: string, data: Record<string, string>): object`, a pure FCM v1 message builder;
  - `sendBackgroundPush(sa: FirebaseServiceAccount, token: string, data: Record<string, string>): Promise<{ ok: boolean; detail?: string }>`;
  - a push whose data is `{ type: "calendar_sync" }`, as Tasks 7 and 8 expect.

The payload, since the headers decide whether iOS wakes the app:

```ts
{ token, data,
  android: { priority: "normal" },
  apns: { headers: { "apns-push-type": "background", "apns-priority": "5" },
          payload: { aps: { "content-available": 1 } } } }
```

- [ ] **Step 1: Write `handler_test.ts`:**
  - `backgroundMessage` has no `notification` key and has exactly the headers above;
  - the handler refuses without the `x-webhook-secret` (401);
  - it skips with `not following` when the profile's `calendar_sync_device` is null, and with `no token` without `fcm_token`;
  - it sends once otherwise.

  Use fakes for the database and FCM, as `apple-tokens/handler_test.ts` does.
- [ ] **Step 2:** Run it (the Docker `deno test` command at the top of `apple-tokens/handler_test.ts`, with `wake-partner-calendar/`). Expected: FAIL, module missing.
- [ ] **Step 3:** Implement `backgroundMessage`, `sendBackgroundPush` and `handleWake(req, deps)`; `index.ts` wires the real deps the way `notify-partner-ping/index.ts` does (fail closed on the secret).
- [ ] **Step 4:** Run the test. Expected: PASS.
- [ ] **Step 5:** Commit, PR, merge, `scripts/deploy-functions.sh nous-deux`. Then on the server, call `request_partner_calendar_sync()` for two test numbers; the function log shows `not following`.

### Task 3: The sync plan, pure (PR 3)

**Files:**
- Create: `app/lib/domain/calendar/phone_event.dart`, `app/lib/domain/calendar/calendar_sync_plan.dart`
- Modify: `app/lib/domain/entities/calendar_event_entity.dart`, `app/lib/data/models/calendar_event_model.dart` (`source_key`)
- Test: `app/test/domain/calendar/calendar_sync_plan_test.dart`

**Interfaces:**
- Produces:
  - `class PhoneEvent { final String key; final String title; final DateTime start; final DateTime? end; }`
  - `String phoneEventKey(String calendarId, String eventId, DateTime start)` (the hash in Global Constraints)
  - `PhoneEvent? phoneEventFrom(Event e)`: null without an id, start or title; title cut to 200 code points.
  - `CalendarEventEntity.sourceKey` (`String?`) and `bool get isSynced`.
  - `class SyncPlan { final List<PhoneEvent> toInsert; final List<({String id, PhoneEvent event})> toUpdate; final List<String> toDelete; bool get isEmpty; }`
  - `SyncPlan planCalendarSync({required List<PhoneEvent> phone, required List<CalendarEventEntity> synced, required DateTime from, required DateTime to})`, where `synced` holds my events with a `sourceKey`.

- [ ] **Step 1: Write the tests:**
  - **A new key** → insert.
  - **A changed key:** same key with a new title or times → update; with everything equal → nothing.
  - **Deletions:** a synced event missing from the phone list and starting inside `[from, to]` → delete; one starting before `from` → kept.
  - **A duplicate key** in the phone list → one insert.
  - **A recurring event:** one occurrence moved (new start, so a new key) → one delete and one insert, the other occurrences untouched.
  - **An all-day `TZDateTime`** in `Europe/Paris` keeps its local midnight.
  - **The key:** `phoneEventKey` is 64 lowercase hex characters and stable for the same inputs.
- [ ] **Step 2:** `flutter test test/domain/calendar/calendar_sync_plan_test.dart`. Expected: FAIL, undefined names.
- [ ] **Step 3:** Implement. Keys compare exactly; times compare as UTC instants.
- [ ] **Step 4:** Run the test. Expected: PASS.
- [ ] **Step 5:** Commit.

### Task 4: The sync service (PR 3)

**Files:**
- Create: `app/lib/data/calendar_sync/calendar_follow_prefs.dart`, `app/lib/data/calendar_sync/phone_calendar.dart`, `app/lib/data/calendar_sync/calendar_sync_service.dart`, `app/lib/presentation/providers/calendar_sync_provider.dart`
- Modify: the calendar repository and datasource (`createEvent({…, String? sourceKey})`, `getMySyncedEvents({required DateTime from, required DateTime to})`); the profile repository and datasource (`setCalendarSyncDevice(String? device)`, `markCalendarSynced()`); `ProfileEntity` (`calendarSyncDevice`, `calendarSyncedAt`); the test fakes in `app/test/helpers/fakes.dart`
- Test: `app/test/data/calendar_sync/calendar_sync_service_test.dart`

**Interfaces:**
- Consumes: Task 3's `PhoneEvent`, `phoneEventFrom`, `planCalendarSync`.
- Produces:
  - `CalendarFollowPrefs`: `Future<Set<String>> followed()`, `Future<void> setFollowed(Set<String> ids)`, `Future<String> installId()` (a UUID v4 created once, in SharedPreferences, cleared with the other keys on account deletion like `noteWordsKey`).
  - `PhoneCalendar`: `Future<List<Calendar>?> calendars()` and `Future<List<PhoneEvent>?> events(Set<String> calendarIds, DateTime from, DateTime to)`, where null means it couldn't read. `DevicePhoneCalendar` is the `device_calendar` version.
  - `enum CalendarSyncOutcome { notFollowing, otherPhone, noAccess, synced, failed }`.
  - `CalendarSyncService({required PhoneCalendar phone, required CalendarRepository calendar, required ProfileRepository profiles, required CalendarFollowPrefs prefs, DateTime Function() now = DateTime.now})`, buildable without Riverpod for Tasks 7 and 8.
  - `CalendarSyncService.run(): Future<CalendarSyncOutcome>`: followed ids, then `profile.calendarSyncDevice == installId` (else clear followed, return `otherPhone`), then read the phone over `[now - calendarSyncPastDays, now + calendarSyncFutureDays]`, plan, apply, `markCalendarSynced()`.
  - `CalendarSyncService.stopFollowing(): Future<void>`: deletes my synced events in the window, clears the followed set and `calendar_sync_device` (Decision 6, when the last calendar is turned off).
  - `calendarSyncServiceProvider`.

- [ ] **Step 1: Write the tests** with a fake `PhoneCalendar` and the fake repositories:
  - **First run** inserts every phone event with its `sourceKey`, and **a second run** changes nothing.
  - **A phone change:** a title edited on the phone → one update; an event deleted on the phone → one delete.
  - **No access:** `events()` returns null → `noAccess`, no write at all, `calendar_synced_at` unchanged.
  - **Another phone:** `calendarSyncDevice` is another id → `otherPhone`, followed set cleared, no write.
  - **Nothing followed** → `notFollowing`, no read.
  - **A failing write** → `failed`, and `calendar_synced_at` unchanged.
  - **`stopFollowing()`** deletes my synced events in the window (not older ones, not the partner's, not ordinary events) and clears `calendar_sync_device`.
- [ ] **Step 2:** Run. Expected: FAIL.
- [ ] **Step 3:** Implement; apply deletes, updates, then inserts; stop at the first failure.
- [ ] **Step 4:** Run, then `flutter test` and `dart analyze lib test`. Expected: all pass, 7 infos.
- [ ] **Step 5:** Commit.

### Task 5: Screens (PR 3, after the wireframes)

**Files:**
- Create: `app/lib/presentation/screens/calendar/calendar_follow_screen.dart`; delete `calendar_import_screen.dart` (its permission and settings flow moves over)
- Modify: `calendar_screen.dart` (entry point, synced marking, freshness line, sync and wake on open), `calendar_event_form_screen.dart` (read-only synced events, countdown switch kept), `main_shell_screen.dart` (sync on resume), the calendar repository and datasource (the wake call), `calendar_strings.dart`
- Test: `app/test/presentation/screens/calendar/calendar_follow_screen_test.dart`, additions to `calendar_screen_test.dart` and `calendar_event_form_screen_test.dart`

**Interfaces:**
- Consumes: `calendarSyncServiceProvider` (`run`, `stopFollowing`), `CalendarFollowPrefs`, `PhoneCalendar`, `ProfileRepository.setCalendarSyncDevice`.
- Produces: `CalendarRepository.requestPartnerCalendarSync(): Future<String>` (calls the Task 1 RPC; failures are ignored, it is best effort), and strings `calendarFollowTitle`, `calendarFollowIntro`, `calendarFollowShared(lang, partnerName)`, `calendarSyncedFrom(lang, name)`, `calendarSyncedReadOnly`, `calendarPartnerFresh(lang, name, ago)`, `calendarFollowOtherPhone`.

- [ ] **Step 1: Write the widget tests** in both languages over `AppLanguages.supported`:
  - **Turning a calendar on** saves it, writes the install id, runs a sync and lists the copied events; **turning the last one off** calls `stopFollowing()` and the copied events disappear.
  - **A synced event** shows `calendarSyncedFrom` and opens read-only with the countdown switch enabled.
  - **Opening the calendar tab** calls `requestPartnerCalendarSync` once.
  - **The freshness line** shows when the partner follows.
  - **Permission denied** shows the existing settings flow.
  - **A followed calendar no longer on the phone** (a full sync can change its id): the `noAccess` outcome shows a notice and offers to drop the ids that are gone, instead of silently syncing nothing.
  - **The countdown switch on a synced event** saves through a countdown-only update (new `CalendarRepository.setCountdown(id, bool)`), since the form's full update would send an end time the trigger refuses for the partner.
- [ ] **Step 2:** Run. Expected: FAIL.
- [ ] **Step 3:** Implement from the chosen wireframes, in the Carnet style.
- [ ] **Step 4:** Run the whole suite and the analyzer. Expected: pass, 7 infos.
- [ ] **Step 5:** Commit.

### Task 6: Policy and store copy (PR 3)

**Files:** `website/lib/dictionaries/{fr,en}.json` (the "Shared calendar" entry, the effective date, `website/lib/seo.ts`), `docs/PLAY_CONSOLE.md` (calendar row and long description), `docs/APP_STORE_CONNECT.md` (Device ID row: push token and the syncing phone's install id).

- [ ] **Step 1:** Write the FR/EN text of Decision 10; check that `npx tsc --noEmit` in `website/` shows no errors outside `.next/`.
- [ ] **Step 2:** Commit, PR 3 (Tasks 3–6), merge once green. The feature works with sync on open from here.

### Task 7: iPhone background sync (PR 4)

**Files:**
- Create: `app/lib/core/services/calendar_sync_background.dart`
- Modify: `app/lib/main.dart` (register the handler), `app/lib/core/services/fcm_service.dart` (foreground `onMessage` with `type: calendar_sync` runs the service)
- Test: `app/test/core/services/calendar_sync_background_test.dart`

**Interfaces:**
- Consumes: `CalendarSyncService`, Task 2's `{type: calendar_sync}`.
- Produces: `@pragma('vm:entry-point') Future<void> calendarSyncBackgroundHandler(RemoteMessage message)`, plus `bool isCalendarSyncMessage(Map<String, dynamic> data)`.

- [ ] **Step 1: Write the tests:** `isCalendarSyncMessage` is true only for `type == 'calendar_sync'`; pings and period pushes are ignored.
- [ ] **Step 2:** Run. Expected: FAIL.
- [ ] **Step 3:** Implement: the handler initialises Supabase from `AppConfig`, builds the service without Riverpod and runs it with a 20-second limit.
- [ ] **Step 4:** Run the tests. Then, on a TestFlight build: change an event on the iPhone, open the calendar tab on the Android phone; the event appears there within a minute in at least 3 of 5 tries.
- [ ] **Step 5:** Commit.

### Task 8: Android trigger (PR 4)

**Files:**
- Create: `app/android/app/src/main/kotlin/<package>/CalendarChangeWorker.kt`
- Modify: `MainActivity.kt` (MethodChannel `nousdeux/calendar_sync`: `watch`, `unwatch`), `app/android/app/build.gradle*` (`androidx.work:work-runtime-ktx`), `calendar_sync_background.dart` (`@pragma('vm:entry-point') void calendarSyncMain()`, which runs the service and calls `done` on the channel), `calendar_follow_screen.dart` (`watch` when the first calendar is followed, `unwatch` after the last)
- Test: the Task 7 test file (the channel calls, with a mocked `MethodChannel`)

**Interfaces:**
- Consumes: Task 0's working worker, `CalendarSyncService`.
- Produces: unique work name `calendar-follow`, `addContentUriTrigger(CalendarContract.Events.CONTENT_URI, true)`, `setTriggerContentUpdateDelay(5 s)`, `setTriggerContentMaxDelay(60 s)`, re-enqueued at the end of each run; the worker gives the Dart run 60 seconds.

- [ ] **Step 1: Write the test:** following the first calendar calls `watch` once; unfollowing the last calls `unwatch`.
- [ ] **Step 2:** Run. Expected: FAIL.
- [ ] **Step 3:** Implement from Task 0's worker.
- [ ] **Step 4:** On the S25 with the app swiped away, repeat Task 0 Step 1 on a release build. Expected: 10 of 10 changes on the server within 2 minutes.
- [ ] **Step 5:** Commit, PR 4, merge; ship in the next app release (raise the build number).

## PRs and release

| PR | Tasks | Visible change |
| --- | --- | --- |
| — | 0 | none (device check) |
| 1 | 1 | none (migration applied) |
| 2 | 2 | none (function deployed) |
| 3 | 3–6 | Import becomes « Agenda du téléphone »: followed calendars sync when the app opens; the partner sees freshness; the policy says so |
| 4 | 7–8 | changes arrive in the background: within minutes from Android, usually within seconds of the partner opening the calendar from iPhone |

PRs 3 and 4 change the app, so they ship in an app release. The policy change ships with the next site release, before or with that app release.
