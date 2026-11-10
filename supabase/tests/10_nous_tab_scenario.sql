\set ON_ERROR_STOP 1
-- Three people: A and B will pair, C is a stranger.
INSERT INTO auth.users (id) VALUES
 ('00000000-0000-0000-0000-00000000000a'),('00000000-0000-0000-0000-00000000000b'),('00000000-0000-0000-0000-00000000000c');
INSERT INTO public.profiles (id, username, language) VALUES
 ('00000000-0000-0000-0000-00000000000a','Alex','fr'),('00000000-0000-0000-0000-00000000000b','Camille','en'),('00000000-0000-0000-0000-00000000000c','Sam','fr');
INSERT INTO public.couples (id, user1_id, pairing_code) VALUES ('11111111-1111-1111-1111-111111111111','00000000-0000-0000-0000-00000000000a','ABC123');

-- Before pairing: together_since stays empty, and A cannot ping.
SELECT 'unpaired together_since is null: ' || (together_since IS NULL) FROM public.couples;
SET ROLE authenticated; SET request.jwt.claim.sub = '00000000-0000-0000-0000-00000000000a';
DO $$ BEGIN PERFORM public.send_ping('kiss'); RAISE EXCEPTION 'expected not_paired'; EXCEPTION WHEN raise_exception THEN IF SQLERRM <> 'not_paired' THEN RAISE; END IF; RAISE NOTICE 'unpaired ping refused: %', SQLERRM; END $$;
RESET ROLE;

-- A cannot pull C into the couple (pre-existing hole, now guarded).
SET ROLE authenticated; SET request.jwt.claim.sub = '00000000-0000-0000-0000-00000000000a';
DO $$ BEGIN
  UPDATE public.couples SET user2_id = '00000000-0000-0000-0000-00000000000c';
  RAISE EXCEPTION 'expected refusal';
EXCEPTION WHEN insufficient_privilege THEN RAISE NOTICE 'forced pairing refused: %', SQLERRM;
END $$;
-- B joins by code the way the app does (join policy, sets themself).
SET request.jwt.claim.sub = '00000000-0000-0000-0000-00000000000b';
UPDATE public.couples SET user2_id = '00000000-0000-0000-0000-00000000000b' WHERE pairing_code = 'ABC123';
RESET ROLE;
SELECT 'B joined: ' || (user2_id = '00000000-0000-0000-0000-00000000000b') FROM public.couples;
SELECT 'paired together_since = today: ' || (together_since = CURRENT_DATE) FROM public.couples;
SELECT 'profiles linked: ' || ((SELECT partner_id FROM public.profiles WHERE id = '00000000-0000-0000-0000-00000000000a') = '00000000-0000-0000-0000-00000000000b');

-- A pings; a second ping inside 30 s is refused; an unknown kind is refused.
SET ROLE authenticated; SET request.jwt.claim.sub = '00000000-0000-0000-0000-00000000000a';
SELECT 'A sent: ' || kind FROM public.send_ping('thinking_of_you');
DO $$ BEGIN PERFORM public.send_ping('kiss'); RAISE EXCEPTION 'expected cooldown'; EXCEPTION WHEN raise_exception THEN IF SQLERRM <> 'cooldown' THEN RAISE; END IF; RAISE NOTICE 'second ping within 30 s refused: %', SQLERRM; END $$;
DO $$ BEGIN PERFORM public.send_ping('hello'); RAISE EXCEPTION 'expected invalid_kind'; EXCEPTION WHEN raise_exception THEN IF SQLERRM <> 'invalid_kind' THEN RAISE; END IF; RAISE NOTICE 'unknown kind refused: %', SQLERRM; END $$;
-- Direct writes are not allowed (no policy).
DO $$ BEGIN INSERT INTO public.couple_pings (couple_id, sender_id, kind) VALUES ('11111111-1111-1111-1111-111111111111','00000000-0000-0000-0000-00000000000a','kiss'); RAISE EXCEPTION 'expected RLS refusal'; EXCEPTION WHEN insufficient_privilege THEN RAISE NOTICE 'direct insert refused by RLS'; END $$;
RESET ROLE;

-- Signed-out callers cannot use the function at all.
SET ROLE anon;
DO $$ BEGIN PERFORM public.send_ping('kiss'); RAISE EXCEPTION 'expected refusal'; EXCEPTION WHEN insufficient_privilege THEN RAISE NOTICE 'anon cannot call send_ping'; END $$;
RESET ROLE;

-- Pretend 31 s passed: A can ping again, and the row is replaced, not added.
UPDATE public.couple_pings SET sent_at = NOW() - INTERVAL '31 seconds';
SET ROLE authenticated; SET request.jwt.claim.sub = '00000000-0000-0000-0000-00000000000a';
SELECT 'A sent again: ' || kind FROM public.send_ping('good_night');
RESET ROLE;
SELECT 'rows for A (no history): ' || count(*) FROM public.couple_pings WHERE sender_id = '00000000-0000-0000-0000-00000000000a';

-- B (partner) reads it; C (stranger) sees nothing.
SET ROLE authenticated; SET request.jwt.claim.sub = '00000000-0000-0000-0000-00000000000b';
SELECT 'B sees: ' || kind FROM public.couple_pings;
SET request.jwt.claim.sub = '00000000-0000-0000-0000-00000000000c';
SELECT 'C sees rows: ' || count(*) FROM public.couple_pings;
-- Either partner can change the start date.
SET request.jwt.claim.sub = '00000000-0000-0000-0000-00000000000b';
UPDATE public.couples SET together_since = DATE '2025-09-24';
DO $$ BEGIN
  UPDATE public.couples SET together_since = CURRENT_DATE + 10;
  RAISE EXCEPTION 'expected refusal';
EXCEPTION WHEN raise_exception THEN RAISE NOTICE 'future start date refused: %', SQLERRM;
END $$;
RESET ROLE;
SELECT 'together_since edited by B: ' || together_since FROM public.couples;

-- Countdown flag defaults to false and can be set.
INSERT INTO public.calendar_events (couple_id, title, start_time, created_by, is_countdown)
VALUES ('11111111-1111-1111-1111-111111111111','Lyon', NOW() + INTERVAL '9 days','00000000-0000-0000-0000-00000000000a', true);
SELECT 'countdown events: ' || count(*) FROM public.calendar_events WHERE is_countdown;

-- B leaves the couple: pings, events and the couple row go.
SET ROLE authenticated; SET request.jwt.claim.sub = '00000000-0000-0000-0000-00000000000b';
SELECT public.leave_couple();
RESET ROLE;
SELECT 'after leave: couples=' || (SELECT count(*) FROM public.couples) || ' pings=' || (SELECT count(*) FROM public.couple_pings) || ' events=' || (SELECT count(*) FROM public.calendar_events);
SELECT 'realtime has couple_pings: ' || EXISTS (SELECT 1 FROM pg_publication_tables WHERE pubname = 'supabase_realtime' AND tablename = 'couple_pings');
