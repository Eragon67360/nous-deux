\set ON_ERROR_STOP 1
-- Camille (a2) tracks her cycle, Léo (b2) is her partner; Sam (c2) and Noa
-- (d2) are another couple. Every check prints a line; a wrong result raises.
INSERT INTO auth.users (id) VALUES
 ('00000000-0000-0000-0000-0000000000a2'),('00000000-0000-0000-0000-0000000000b2'),
 ('00000000-0000-0000-0000-0000000000c2'),('00000000-0000-0000-0000-0000000000d2');
INSERT INTO public.profiles (id, username, gender, partner_id) VALUES
 ('00000000-0000-0000-0000-0000000000a2','Camille','woman',NULL),
 ('00000000-0000-0000-0000-0000000000b2','Léo','man',NULL),
 ('00000000-0000-0000-0000-0000000000c2','Sam','man',NULL),
 ('00000000-0000-0000-0000-0000000000d2','Noa','woman',NULL);
INSERT INTO public.couples (id, user1_id, user2_id) VALUES
 ('c4c4c4c4-0000-0000-0000-000000000001','00000000-0000-0000-0000-0000000000a2','00000000-0000-0000-0000-0000000000b2'),
 ('c4c4c4c4-0000-0000-0000-000000000002','00000000-0000-0000-0000-0000000000c2','00000000-0000-0000-0000-0000000000d2');
UPDATE public.profiles SET partner_id = '00000000-0000-0000-0000-0000000000b2' WHERE id = '00000000-0000-0000-0000-0000000000a2';
UPDATE public.profiles SET partner_id = '00000000-0000-0000-0000-0000000000a2' WHERE id = '00000000-0000-0000-0000-0000000000b2';
UPDATE public.profiles SET partner_id = '00000000-0000-0000-0000-0000000000d2' WHERE id = '00000000-0000-0000-0000-0000000000c2';
UPDATE public.profiles SET partner_id = '00000000-0000-0000-0000-0000000000c2' WHERE id = '00000000-0000-0000-0000-0000000000d2';

CREATE FUNCTION pg_temp.expect(label text, actual bigint, wanted bigint) RETURNS text
LANGUAGE plpgsql AS $$
BEGIN
  IF actual <> wanted THEN
    RAISE EXCEPTION '%: got %, wanted %', label, actual, wanted;
  END IF;
  RETURN label || ': ' || actual;
END $$;

SELECT 'new profiles share by default and have not been asked: ' ||
  bool_and(share_cycle AND share_checkins AND tracks_cycle IS NULL)
FROM public.profiles;

-- Camille logs a period start, a check-in and a private note.
SET ROLE authenticated;
SET request.jwt.claim.sub = '00000000-0000-0000-0000-0000000000a2';
UPDATE public.profiles SET tracks_cycle = TRUE WHERE id = auth.uid();
INSERT INTO public.period_logs (user_id, couple_id, start_date)
VALUES (auth.uid(), 'c4c4c4c4-0000-0000-0000-000000000001', '2026-10-21');
DO $$ BEGIN
  INSERT INTO public.period_logs (user_id, couple_id, start_date, notes)
  VALUES (auth.uid(), 'c4c4c4c4-0000-0000-0000-000000000001', '2026-09-23', 'secret');
  RAISE EXCEPTION 'expected check violation';
EXCEPTION WHEN check_violation THEN RAISE NOTICE 'a note on period_logs is refused';
END $$;
DO $$ BEGIN
  INSERT INTO public.period_logs (user_id, couple_id, start_date, mood, symptoms)
  VALUES (auth.uid(), 'c4c4c4c4-0000-0000-0000-000000000001', '2026-09-23', 'tired', '{cramps}');
  RAISE EXCEPTION 'expected check violation';
EXCEPTION WHEN check_violation THEN RAISE NOTICE 'mood and symptoms on period_logs are refused';
END $$;
INSERT INTO public.cycle_checkins (user_id, couple_id, day, symptoms, mood)
VALUES (auth.uid(), 'c4c4c4c4-0000-0000-0000-000000000001', '2026-11-11', '{tired,headache}', 'tired');
-- Same day again updates through the unique key.
INSERT INTO public.cycle_checkins (user_id, couple_id, day, symptoms)
VALUES (auth.uid(), 'c4c4c4c4-0000-0000-0000-000000000001', '2026-11-11', '{tired}')
ON CONFLICT (user_id, day) DO UPDATE SET symptoms = EXCLUDED.symptoms;
INSERT INTO public.cycle_notes (user_id, day, note) VALUES (auth.uid(), '2026-11-11', 'dormi tôt');
SELECT pg_temp.expect('Camille sees her check-ins', (SELECT count(*) FROM public.cycle_checkins), 1);
SELECT pg_temp.expect('Camille sees her note', (SELECT count(*) FROM public.cycle_notes), 1);
-- Cannot write into another couple.
DO $$ BEGIN
  INSERT INTO public.cycle_checkins (user_id, couple_id, day)
  VALUES (auth.uid(), 'c4c4c4c4-0000-0000-0000-000000000002', '2026-11-10');
  RAISE EXCEPTION 'expected RLS refusal';
EXCEPTION WHEN insufficient_privilege THEN RAISE NOTICE 'check-in in another couple refused';
END $$;
RESET ROLE;

-- Léo reads her dates and check-in, never her note, and cannot write as her.
SET ROLE authenticated;
SET request.jwt.claim.sub = '00000000-0000-0000-0000-0000000000b2';
SELECT pg_temp.expect('Léo sees her period dates', (SELECT count(*) FROM public.period_logs), 1);
SELECT pg_temp.expect('Léo sees her check-in', (SELECT count(*) FROM public.cycle_checkins), 1);
SELECT pg_temp.expect('Léo sees no note', (SELECT count(*) FROM public.cycle_notes), 0);
DO $$ BEGIN
  INSERT INTO public.cycle_checkins (user_id, couple_id, day)
  VALUES ('00000000-0000-0000-0000-0000000000a2', 'c4c4c4c4-0000-0000-0000-000000000001', '2026-11-09');
  RAISE EXCEPTION 'expected RLS refusal';
EXCEPTION WHEN insufficient_privilege THEN RAISE NOTICE 'Léo cannot write a check-in as Camille';
END $$;
UPDATE public.cycle_checkins SET mood = 'good';
SELECT pg_temp.expect('Léo cannot change her check-in', (SELECT count(*) FROM public.cycle_checkins WHERE mood = 'good'), 0);
RESET ROLE;

-- Camille stops sharing her check-ins, then her cycle.
SET ROLE authenticated;
SET request.jwt.claim.sub = '00000000-0000-0000-0000-0000000000a2';
UPDATE public.profiles SET share_checkins = FALSE WHERE id = auth.uid();
SET request.jwt.claim.sub = '00000000-0000-0000-0000-0000000000b2';
SELECT pg_temp.expect('check-ins hidden from Léo', (SELECT count(*) FROM public.cycle_checkins), 0);
SELECT pg_temp.expect('dates still shared', (SELECT count(*) FROM public.period_logs), 1);
SET request.jwt.claim.sub = '00000000-0000-0000-0000-0000000000a2';
UPDATE public.profiles SET share_cycle = FALSE WHERE id = auth.uid();
SET request.jwt.claim.sub = '00000000-0000-0000-0000-0000000000b2';
SELECT pg_temp.expect('dates hidden from Léo', (SELECT count(*) FROM public.period_logs), 0);
-- Léo cannot flip her switches back.
UPDATE public.profiles SET share_cycle = TRUE WHERE id = '00000000-0000-0000-0000-0000000000a2';
RESET ROLE;
SELECT pg_temp.expect('her switch unchanged by Léo',
  (SELECT count(*) FROM public.profiles WHERE id = '00000000-0000-0000-0000-0000000000a2' AND share_cycle), 0);

-- Another couple sees nothing, signed-out callers get nothing.
SET ROLE authenticated;
SET request.jwt.claim.sub = '00000000-0000-0000-0000-0000000000c2';
SELECT pg_temp.expect('Sam sees no check-ins', (SELECT count(*) FROM public.cycle_checkins), 0);
SELECT pg_temp.expect('Sam sees no notes', (SELECT count(*) FROM public.cycle_notes), 0);
RESET ROLE;
SET ROLE anon;
DO $$ BEGIN
  PERFORM count(*) FROM public.cycle_notes;
  RAISE EXCEPTION 'expected permission denied';
EXCEPTION WHEN insufficient_privilege THEN RAISE NOTICE 'anon cannot read notes';
END $$;
DO $$ BEGIN
  PERFORM count(*) FROM public.cycle_checkins;
  RAISE EXCEPTION 'expected permission denied';
EXCEPTION WHEN insufficient_privilege THEN RAISE NOTICE 'anon cannot read check-ins';
END $$;
RESET ROLE;

-- Leaving the couple deletes the shared check-ins and keeps the private notes.
SET ROLE authenticated;
SET request.jwt.claim.sub = '00000000-0000-0000-0000-0000000000a2';
SELECT public.leave_couple();
RESET ROLE;
SELECT pg_temp.expect('check-ins gone with the couple',
  (SELECT count(*) FROM public.cycle_checkins WHERE user_id = '00000000-0000-0000-0000-0000000000a2'), 0);
SELECT pg_temp.expect('her note kept',
  (SELECT count(*) FROM public.cycle_notes WHERE user_id = '00000000-0000-0000-0000-0000000000a2'), 1);
