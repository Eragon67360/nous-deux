#!/usr/bin/env bash
# Lists, then deletes, the accounts Google Play's pre-launch report creates.
#
# After each upload to a testing track, Google runs the build on a few test
# phones, each signed in to its own Gmail account. The crawler taps "Continue
# with Google" (a new user per phone), types the App access login into the
# name field (docs/PLAY_CONSOLE.md) and taps around for a few minutes: it
# leaves a profile, a waiting couple and whatever it entered, and never
# comes back.
#
# A robot account here: Google sign-in, a gmail.com address, an App access
# login as display name, no partner, created over an hour ago and not signed
# in since its first hour. The real review accounts (@nous-deux.app) never
# match, and neither does anyone who paired.
#
# Usage: scripts/delete-play-robots.sh nous-deux            # list them
#        scripts/delete-play-robots.sh nous-deux --delete   # delete them
#        (`local` instead of the SSH host for a local docker stack)
# Deleting does what delete_my_account() does, for all of them in one
# transaction. Prints dates and counts only, never addresses.
set -euo pipefail
target="${1:?usage: $0 user@server|local [--delete]}"
mode="${2:-}"
[[ -z "$mode" || "$mode" == --delete ]] || { echo "unknown option: $mode" >&2; exit 2; }

run() { if [[ "$target" == local ]]; then bash -c "$1"; else ssh "$target" "$1"; fi; }

db=$(run "docker ps --format '{{.Names}}' | grep -E '(^|-)supabase-db(-|$)' | head -n1")
[[ -n "$db" ]] || { echo "no supabase-db container on $target" >&2; exit 1; }
psql_in="docker exec -i $db psql -U postgres -d postgres -v ON_ERROR_STOP=1 -q -t -A"

# The display names are the App access logins in docs/PLAY_CONSOLE.md.
pick="
CREATE TEMP TABLE robots AS
  SELECT u.id, u.created_at
  FROM auth.users u JOIN public.profiles p ON p.id = u.id
  WHERE p.username IN ('review1@nous-deux.app', 'review2@nous-deux.app')
    AND lower(split_part(u.email, '@', 2)) = 'gmail.com'
    AND u.raw_app_meta_data->>'provider' = 'google'
    AND p.partner_id IS NULL
    AND u.created_at < now() - interval '1 hour'
    AND (u.last_sign_in_at IS NULL OR u.last_sign_in_at < u.created_at + interval '1 hour');
"

if [[ "$mode" != --delete ]]; then
  run "$psql_in" <<SQL
$pick
SELECT 'created ' || to_char(r.created_at AT TIME ZONE 'Europe/Paris', 'YYYY-MM-DD HH24:MI')
       || ', couples ' || (SELECT count(*) FROM public.couples c WHERE r.id IN (c.user1_id, c.user2_id))
       || ', period entries ' || (SELECT count(*) FROM public.period_logs l WHERE l.user_id = r.id)
FROM robots r ORDER BY r.created_at;
SELECT count(*) || ' robot account(s); add --delete to delete them' FROM robots;
SQL
  exit 0
fi

run "$psql_in" <<SQL
BEGIN;
$pick
DO \$\$
BEGIN
  IF EXISTS (SELECT 1 FROM public.couples
             WHERE (user1_id IN (SELECT id FROM robots) AND user2_id IS NOT NULL AND user2_id NOT IN (SELECT id FROM robots))
                OR (user2_id IN (SELECT id FROM robots) AND user1_id NOT IN (SELECT id FROM robots))) THEN
    RAISE EXCEPTION 'a robot account shares a couple with someone else; nothing deleted';
  END IF;
END \$\$;
-- As delete_my_account(): unlink, delete the couples (their calendar, cycle,
-- lists and notes cascade), then the auth users (profiles and the rest cascade).
UPDATE public.profiles SET partner_id = NULL, updated_at = NOW()
WHERE partner_id IN (SELECT id FROM robots);
WITH d AS (DELETE FROM public.couples
           WHERE user1_id IN (SELECT id FROM robots) OR user2_id IN (SELECT id FROM robots) RETURNING 1)
SELECT 'couples deleted: ' || count(*) FROM d;
WITH d AS (DELETE FROM auth.users WHERE id IN (SELECT id FROM robots) RETURNING 1)
SELECT 'robot accounts deleted: ' || count(*) FROM d;
COMMIT;
SQL
