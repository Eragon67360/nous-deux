# Pill Tracking Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** someone who takes a hormonal pill gets a daily reminder, ticks the pill in the Règles tab, and sees where they are in the pack. Their partner can see one thing: whether today's pill is taken. Ships in build 30.

**Architecture:**
- **Data:** two owner-only tables. `pill_tracking` holds the settings and the consent time; `pill_intakes` holds one row per day.
- **The partner's view:** the partner reads through a definer function, which only answers whether a pill is expected today and whether it is ticked. A narrow SELECT policy (ticked, last 2 days, while shared) lets Realtime push the tick.
- **Reminders:** they are local notifications, scheduled as one-shots for the next 21 days. Pause days are skipped. Each day gets a reminder and a second one 30 min later, which is cancelled once ticked. Everything is rescheduled whenever the app starts, resumes, the settings change, or a pill is ticked.
- **Groundwork first:** the reminders need Android receivers, the phone's time zone and an injectable notification service. This also fixes the existing period reminder, which never fires on Android.

**Tech Stack:** Postgres (RLS, definer functions, Realtime), Flutter (Riverpod, go_router, gen-l10n), flutter_local_notifications 18, timezone + flutter_timezone.

**Spec:** the Claude Design board « Nous Deux · Suivi de la pilule », https://claude.ai/artifact/DaW9XmWJRFz2g3n77XHinm (screens 1–7, note « Décidé le 18 nov. »). Thomas's decisions are copied in the project memory `pill-tracking-design.md`:
1. **Where:** the tracking lives in the Règles tab. No line on the Nous home screen.
2. **Lock-screen text:** chosen in the settings, either clear (« Pilule ») or discreet (« Petit rappel »). The default is discreet.
3. **Partner:** sees only « prise » or « pas encore cochée », for today. No late reminder to the partner and no history.
4. **Pack type:** each person chooses it (21 + 7, 28 or continuous), at the first question and in the settings.
5. **Missed pill:** screen 4 as drawn. It sends you to the leaflet and an official sheet, with no medical advice of our own.
6. **Wording:** never "contraceptive". The question is « Prenez-vous une pilule hormonale ? », followed by « Contraception, cycle, peau : peu importe la raison. ».

Also from the board:
- a second reminder 30 min later, then nothing;
- ticking from the notification;
- health data, so it gets its own consent;
- « Arrêter le suivi » deletes the history;
- no streak, no score.

## Global Constraints

- **Branch:** `feature/pill-tracking` off `dev`. The PR stays **unmerged and nothing is applied** to the server until Thomas says build 29 is fully out. Build 30's number is raised at release time, not here.
- **Look:** Carnet style, Manrope, dark only. Gold labels, large light numbers, thin lines.
- **Copy:** bilingual through ARB and `*_strings.dart`. French is gender-neutral (« la personne qui la prend », no participle agreeing with a person) and puts a non-breaking space before « : ; ? ! ».
- **Data:** health data. No row exists until the person says yes with consent. Partner access goes only through the definer function and the "taken, last 2 days" policy. The privacy policy FR/EN changes in this branch.
- **Lock screen:** a reminder never says "pilule" when the text is discreet, and a notification never carries a pill number when discreet.
- **Database:** no superuser-only statement in the migration. Run the SQL dry run with a new scenario.
- **Formatting and checks:** `dart format` touched files only, `dart analyze lib test`, full `flutter test`.

## Review Focus

- **Time zone and daylight saving:** a reminder at 21:00 must ring at 21:00 local after the clocks change, and on a phone that travelled. Reminders are built from the phone's zone, never UTC.
- **Ticked, then the second reminder:** once today's pill is ticked (app or notification), today's +30 min reminder must not ring.
- **Pause days:** no reminder during the 7-day break of a 21 + 7 pack. The partner sees "no pill today", not « pas encore cochée ».
- **Stop tracking:** every pending pill notification is cancelled and both tables are emptied for that person. The partner's view goes back to nothing.
- **What the partner sees:** never a missed day, the pack type, the time or older days, even by querying the tables directly.

---

### Task 1: Notification groundwork (also fixes the period reminder on Android)

**Files:**
- Modify:
  - `app/android/app/src/main/AndroidManifest.xml` (the receivers `ScheduledNotificationReceiver`, `ScheduledNotificationBootReceiver` with BOOT_COMPLETED / MY_PACKAGE_REPLACED / QUICKBOOT_POWERON, and `ActionBroadcastReceiver`; `RECEIVE_BOOT_COMPLETED`);
  - `app/pubspec.yaml` (`flutter_timezone`);
  - `app/lib/core/services/period_reminder_service.dart` (moves onto the service).
- Create: `app/lib/core/services/local_notifications.dart`.
- Test:
  - `app/test/core/services/android_manifest_test.dart`, which reads the manifest and asserts the three receivers and the permission;
  - `app/test/core/services/period_reminder_service_test.dart`.

**Interfaces:**
- Produces:
  - **`abstract class LocalNotifications`** with:
    - `Future<void> schedule({required int id, required tz.TZDateTime at, required String title, required String body, String? category, String? payload})`;
    - `Future<void> cancel(int id)`;
    - `Future<void> cancelRange(int from, int to)`;
    - `Stream<NotificationTap> get taps`, where `NotificationTap = ({String? payload, String? actionId})`.
  - **`PluginLocalNotifications`** wraps the plugin:
    - **On init:** it reads the zone through flutter_timezone and calls `tz.setLocalLocation`. It creates the channels `period_reminder` and `pill_reminder` explicitly.
    - **iOS:** it registers the Darwin category `pill` with the actions `pill_taken` (foreground) and `pill_snooze` (background).
    - **Taps:** a foreground tap or action goes into `taps`. A background `pill_snooze` reschedules +30 min through a top-level `@pragma('vm:entry-point')` handler.
  - **`localNotificationsProvider`**, overridable.
  - **`FakeLocalNotifications`** in `test/helpers/fakes.dart`, which records what is scheduled and cancelled.
- The period reminder keeps its id (1), its time (19:00 local) and its text.

- [ ] **Step 1:** Write the tests:
  - the manifest test, which fails today;
  - `schedulePartnerPeriodReminder` schedules id 1 at 19:00 in the phone's zone (a fake zone `Europe/Paris`, checked across the DST change on 25 Oct 2026);
  - cancelling cancels id 1.
- [ ] **Step 2:** Run `flutter test` on them. Expected: they fail.
- [ ] **Step 3:** Implement. TestDeps overrides `localNotificationsProvider` with the fake.
- [ ] **Step 4:** Run the full suite and `dart analyze`. Then build the debug APK from `app/android` (Java 21; see memory `nous-deux-repos`). Expected: green, and the APK builds.
- [ ] **Step 5:** Commit `fix(app): scheduled reminders fire on Android, in the phone's time zone`.

### Task 2: The database

**Files:**
- Create: `supabase/migrations/20261119100000_pill_tracking.sql`, `supabase/tests/88_pill_scenario.sql`.
- Modify: `supabase/tests/README.md`.

**Interfaces:**
- Produces:
  - **`public.pill_tracking`:**
    - `user_id uuid PK → profiles ON DELETE CASCADE`;
    - `pack_type text CHECK IN ('21_7','28','continuous')`;
    - `pack_started_on date NOT NULL`, day 1 of a pack (any pack);
    - `reminder_on bool default true`;
    - `reminder_time time default '21:00'`;
    - `reminder_text text default 'discreet' CHECK IN ('clear','discreet')`;
    - `share_with_partner bool default true`;
    - `consent_at timestamptz NOT NULL default now()`, not grantable;
    - `created_at` and `updated_at`, with the existing `updated_at` trigger if one exists.
    - RLS: owner only, for all.
    - Grants: authenticated gets INSERT/UPDATE on every column except `consent_at`, `created_at` and `updated_at`, plus SELECT and DELETE. Anon gets nothing.
  - **`public.pill_intakes`:**
    - `id uuid PK`;
    - `user_id → profiles CASCADE`;
    - `day date`;
    - `status text CHECK IN ('taken','missed')`;
    - `taken_at timestamptz`, with `CHECK ((status = 'taken') = (taken_at IS NOT NULL))`;
    - `created_at`;
    - `UNIQUE (user_id, day)`.
    - Owner, for all: `user_id = auth.uid()`, and the insert check requires the owner's `pill_tracking` row.
    - Partner, SELECT: `user_id = my_partner_id() AND status = 'taken' AND day >= current_date - 2 AND shares_pill(user_id)`.
    - Added to `supabase_realtime`.
  - **Functions:**
    - `public.shares_pill(owner uuid) → bool` (definer, like `shares_cycle`);
    - `public.pill_is_pill_day(pack_type text, started_on date, d date) → bool`, immutable: 21_7 means `((d - started_on) % 28 + 28) % 28 < 21`, the others always;
    - `public.partner_pill_today(p_day date) → TABLE(tracking bool, expected bool, taken_at timestamptz)`, definer, for the caller's partner only;
    - `public.stop_pill_tracking() → void`, definer, deletes the caller's intakes and settings.
    - EXECUTE is revoked from anon on all four.

- [ ] **Step 1:** Write scenario 88. It must check:
  - the owner inserts settings and ticks;
  - `consent_at` can't be written;
  - no intake without settings;
  - the partner reads only `taken` rows of the last 2 days while shared, never `missed`, older rows or the settings;
  - `partner_pill_today` gives tracking / expected / taken for a pill day, `expected = false` on a pause day, and `tracking = false` when sharing is off;
  - a stranger and anon read nothing and can't call the functions;
  - `stop_pill_tracking` empties both;
  - deleting the account removes both;
  - leaving the couple keeps the person's own rows.
- [ ] **Step 2:** Dry run without the migration. Expected: 88 fails.
- [ ] **Step 3:** Write the migration.
- [ ] **Step 4:** Full dry run. Expected: all scenarios pass, 97 and 98 included.
- [ ] **Step 5:** Commit `feat(db): pill tracking, private, with a one-line view for the partner`.

### Task 3: The pack, in Dart

**Files:**
- Create: `app/lib/domain/pill/pill_schedule.dart`.
- Test: `app/test/domain/pill/pill_schedule_test.dart`.

**Interfaces:**
- Produces:
  - `enum PackType { p21x7, p28, continuous }` with `wire` ↔ `'21_7'|'28'|'continuous'`;
  - `class PillSchedule(PackType type, DateTime startedOn)`, with:
    - `int dayInPack(DateTime d)` (1-based);
    - `bool isPillDay(DateTime d)`;
    - `int? pillNumber(DateTime d)`, null on a pause day;
    - `int get pillsInPack` (21, 28, or 28 shown for continuous);
    - `DateTime nextPackStart(DateTime d)`;
    - `({DateTime from, DateTime to})? pauseAround(DateTime d)`, the current or next pause (21 + 7 only).
  - Dates are local calendar days (`dateOnly`).
  - The same arithmetic as `pill_is_pill_day`.

- [ ] **Steps:** Write the tests:
  - day 1, day 21, day 22 (pause), day 28, day 29 = day 1;
  - a start in the future;
  - across the DST change;
  - 28 and continuous are always pill days.

  Watch them fail, implement, watch them pass, commit `feat(app): where you are in a pill pack`.

### Task 4: The data layer

**Files:**
- Create:
  - `app/lib/domain/entities/pill_entities.dart` (`PillSettings`, `PillIntake`, `PartnerPillToday`);
  - `app/lib/domain/repositories/pill_repository.dart`;
  - `app/lib/data/repositories/pill_repository_impl.dart`;
  - `app/lib/presentation/providers/pill_provider.dart`.
- Modify: `app/test/helpers/fakes.dart` (`FakePillRepository`), `app/test/helpers/test_app.dart`.
- Test: `app/test/presentation/providers/pill_provider_test.dart`.

**Interfaces:**
- Produces:
  - **`PillRepository`:**
    - `Future<PillSettings?> mySettings()`;
    - `Future<Failure?> saveSettings(PillSettings s)` (an upsert);
    - `Future<List<PillIntake>> myIntakes({required DateTime from})`;
    - `Future<Failure?> markTaken(DateTime day, DateTime at)`;
    - `Future<Failure?> markMissed(DateTime day)`;
    - `Future<Failure?> unmark(DateTime day)`;
    - `Future<Failure?> stopTracking()` (the RPC);
    - `Future<PartnerPillToday> partnerToday(DateTime day)` (the RPC);
    - `Stream<void> partnerChanges(String partnerId)` (Realtime on `pill_intakes`, filtered `user_id=eq.<id>`).
  - **Providers:**
    - `pillSettingsProvider` (FutureProvider);
    - `pillWeekProvider`, intakes of the last 7 days;
    - `pillTodayProvider`, which combines schedule, settings, intakes and `clockProvider`, and reports `notTracking | pauseDay | taken(at) | due | late`, where `late` means 1 h after the reminder time;
    - `partnerPillTodayProvider`, refreshed on Realtime and when the app resumes.

- [ ] **Steps:** Write the `pillTodayProvider` tests: pause day, due before the reminder time, late an hour after it, taken, and not tracking. Then the partner provider's refresh on a Realtime event, using the fake realtime. Red, implement, green, commit `feat(app): pill data and today's state`.

### Task 5: The reminders

**Files:**
- Create: `app/lib/core/services/pill_reminders.dart`.
- Modify: `app/lib/presentation/screens/main/main_shell_screen.dart` (start, resume, tap routing), `app/lib/presentation/providers/settings_provider.dart` (account deletion cancels them).
- Test: `app/test/core/services/pill_reminders_test.dart`.

**Interfaces:**
- Consumes: `LocalNotifications` (Task 1), `PillSchedule` (Task 3), `PillSettings` and intakes (Task 4).
- Produces:
  - **`List<PlannedReminder> planPillReminders({settings, intakes, now, lang, days = 21})`**, a pure function. It produces a reminder at `reminder_time` and a second one 30 min later on each pill day where the pill isn't ticked. Moments already past are skipped, and nothing is produced when `reminder_on` is false.
    - **Ids:** `1000 + 2*i` for the reminder, `1001 + 2*i` for the second one, where `i` is the day offset.
    - **Texts:** they depend on `reminder_text` and `lang`.
      - Clear: « Pilule » / « C'est l'heure de votre pilule. Comprimé {n}. »
      - Discreet: « Petit rappel » / « Votre rappel de {heure}. »
      - The second one, clear: « Pas encore cochée : c'est l'heure de votre pilule. »
      - The second one, discreet: « Petit rappel » / « Toujours là : votre rappel de {heure}. »
    - **Category:** `pill`.
    - **Payload:** `pill:<yyyy-mm-dd>`.
  - **`syncPillReminders(ref)`:** cancels the range 1000–1099, then schedules the plan.
  - **Taps:**
    - `pill_taken` marks that day taken, then syncs;
    - `pill_snooze` adds a one-shot +30 min (in the background, no network);
    - a plain tap opens Règles.

- [ ] **Steps:** Write the planner tests:
  - 21 + 7 skips the pause;
  - ticked today means no second reminder today;
  - the discreet text never contains the word "pilule" or a number;
  - a reminder at 21:00 lands at 21:00 Paris on both sides of the DST change;
  - `reminder_on` false plans nothing;
  - past moments are skipped.

  Then the sync tests with the fake (cancel range, then schedule) and the routing of a `pill_taken` tap. Red, implement, green, commit `feat(app): daily pill reminders, a second one 30 min later`.

### Task 6: The screens

**Files:**
- Create:
  - `app/lib/presentation/screens/period/pill_setup_screen.dart` (board 1, route `/main/period/pill-setup`);
  - `app/lib/presentation/screens/period/pill_section.dart` (boards 2 and 4, inside `CycleTodayView`);
  - `app/lib/presentation/screens/settings/pill_settings_screen.dart` (board 7, route `/settings/pill`);
  - `app/lib/core/constants/pill_strings.dart`.
- Modify:
  - `cycle_today_view.dart`: the section goes after `_NoteRow`, behind a rule. When not tracking it is one line « Pilule › » that opens setup, asked once.
  - `partner_cycle_view.dart`: the line "Pilule prise à 21:04 ✓" / « pas encore cochée » next to the check-in, nothing on a pause day or when not shared.
  - `settings_screen.dart`: the Règles group gets a « Suivi de la pilule » row.
  - The ARB files and the router.
- Test: widget tests next to `period_screen_test.dart`, plus the settings tests.

**Interfaces:**
- Consumes: Tasks 3–5.
- **Setup (board 1):**
  - the label « PILULE » and the question « Prenez-vous une pilule hormonale ? » with its line;
  - the choices « Oui, me la rappeler » / « Non » / « Plus tard »;
  - the reminder time, today's pill number and the pack type;
  - the health-data line;
  - « Continuer ».
  - « Oui » saves the settings, which records consent, after the same consent sheet as the cycle (`CycleConsentText`-style text written for the pill).
  - « Non » remembers the answer locally and doesn't ask again.
  - « Plus tard » asks again the next week.
- **Today (board 2):**
  - PILULE, « Rappel à 21:00 »;
  - the large number with « comprimé sur 21 », and the state;
  - the gold « Je l'ai prise » button;
  - the 28-dot pack grid (taken in gold, today as a ring, empty, pause dark);
  - the line « Jour 12 sur 21 · arrêt du … au … / Nouvelle plaquette le … »;
  - CETTE SEMAINE with the times.
- **Late (board 4):**
  - « Pas encore cochée ce soir »;
  - « Je l'ai prise » with a time chip (a time picker), and « Je la prends maintenant »;
  - EN CAS D'OUBLI: the leaflet line plus the official sheet link (Task 7);
  - « Noter un oubli »;
  - « Pas de série, pas de score. ».
- **Settings (board 7):**
  - RAPPEL: daily switch, time, and the lock-screen text segmented « Pilule » / « Petit rappel »;
  - PLAQUETTE: type, and « Plaquette en cours depuis le … »;
  - AVEC {partner}: « {partner} voit si elle est prise »;
  - « Arrêter le suivi » with its line, which calls `stopTracking`, cancels the reminders and confirms first.

- [ ] **Steps:** Write the widget tests:
  - setup saves the chosen pack and time;
  - « Non » isn't asked again;
  - today shows the number and the grid;
  - ticking calls `markTaken` and the state becomes taken;
  - late shows the missed block with the official link;
  - the partner line in its three states (taken, not yet, pause, which shows nothing);
  - settings writes each field, and stopping calls `stopTracking` and cancels the range.

  Red, implement, green, `UPDATE_STRINGS_SNAPSHOT` not needed (new keys), full suite, analyze. Commit `feat(app): pill tracking in Règles`.

### Task 7: Sources and privacy policy

**Files:**
- Modify:
  - `app/lib/core/constants/period_verified_sources.dart` (a `VerifiedSourceTopic.missedPill`, with ANSM for fr and NHS for en; URLs checked to answer 200 and to be the official missed-pill page);
  - `website/lib/dictionaries/{fr,en}.json` (a new `dataCollected` item « Suivi de la pilule », plus the legal basis, retention and the date);
  - `app/scripts/linkcheck-allowlist.txt` only if a site blocks GitHub runners.
- Test: the content completeness and snapshot tests, and the website build.

- [ ] **Steps:**
  1. Add the source and the policy text.
  2. Run `flutter test test/l10n` (refresh the content snapshot on purpose) and the website build.
  3. Commit `docs: pill tracking in the privacy policy; official missed-pill sheets`.

## After the tasks

1. Final whole-branch review.
2. Open the PR into `dev` marked "do not merge before build 29 is fully out".
3. Then, on Thomas's word: merge, apply the migration, release build 30 with the update screen and the first Nouveautés message.
