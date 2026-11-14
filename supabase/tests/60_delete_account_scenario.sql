\set ON_ERROR_STOP 1
-- Ivo deletes his account from inside his couple with Lea. He is user2, the
-- case the foreign keys alone get wrong. Then Una, who only has a pending
-- pairing code, deletes hers. Every check prints a line; a wrong result raises.
INSERT INTO auth.users (id) VALUES
 ('00000000-0000-0000-0000-00000000060a'),('00000000-0000-0000-0000-00000000060b'),
 ('00000000-0000-0000-0000-00000000060c'),('00000000-0000-0000-0000-00000000060d'),
 ('00000000-0000-0000-0000-00000000060e');
INSERT INTO public.profiles (id, username) VALUES
 ('00000000-0000-0000-0000-00000000060a','Lea'),('00000000-0000-0000-0000-00000000060b','Ivo'),
 ('00000000-0000-0000-0000-00000000060c','Max'),('00000000-0000-0000-0000-00000000060d','Zoe'),
 ('00000000-0000-0000-0000-00000000060e','Una');
INSERT INTO public.couples (id, user1_id, user2_id) VALUES
 ('de1e7e00-0000-0000-0000-000000000001','00000000-0000-0000-0000-00000000060a','00000000-0000-0000-0000-00000000060b'),
 ('de1e7e00-0000-0000-0000-000000000002','00000000-0000-0000-0000-00000000060c','00000000-0000-0000-0000-00000000060d');
INSERT INTO public.couples (id, user1_id, pairing_code) VALUES
 ('de1e7e00-0000-0000-0000-000000000003','00000000-0000-0000-0000-00000000060e','UNA2345');
UPDATE public.profiles SET partner_id = CASE id
  WHEN '00000000-0000-0000-0000-00000000060a' THEN '00000000-0000-0000-0000-00000000060b'::uuid
  WHEN '00000000-0000-0000-0000-00000000060b' THEN '00000000-0000-0000-0000-00000000060a'::uuid
  WHEN '00000000-0000-0000-0000-00000000060c' THEN '00000000-0000-0000-0000-00000000060d'::uuid
  WHEN '00000000-0000-0000-0000-00000000060d' THEN '00000000-0000-0000-0000-00000000060c'::uuid
END WHERE id IN ('00000000-0000-0000-0000-00000000060a','00000000-0000-0000-0000-00000000060b',
                 '00000000-0000-0000-0000-00000000060c','00000000-0000-0000-0000-00000000060d');

-- What Lea and Ivo share, and what each keeps for themselves.
INSERT INTO public.calendar_events (couple_id, title, start_time, created_by) VALUES
 ('de1e7e00-0000-0000-0000-000000000001','Dentiste',now(),'00000000-0000-0000-0000-00000000060a'),
 ('de1e7e00-0000-0000-0000-000000000001','Foot',now(),'00000000-0000-0000-0000-00000000060b'),
 ('de1e7e00-0000-0000-0000-000000000002','Ciné',now(),'00000000-0000-0000-0000-00000000060c');
INSERT INTO public.shared_lists (id, couple_id, name, icon, created_by) VALUES
 ('de1e7e00-0000-0000-0000-0000000000a1','de1e7e00-0000-0000-0000-000000000001','Courses','cart','00000000-0000-0000-0000-00000000060a');
INSERT INTO public.shared_list_items (list_id, couple_id, text, added_by) VALUES
 ('de1e7e00-0000-0000-0000-0000000000a1','de1e7e00-0000-0000-0000-000000000001','Pain','00000000-0000-0000-0000-00000000060b');
INSERT INTO public.couple_pings (couple_id, sender_id, kind) VALUES
 ('de1e7e00-0000-0000-0000-000000000001','00000000-0000-0000-0000-00000000060b','kiss');
INSERT INTO public.period_logs (user_id, couple_id, start_date) VALUES
 ('00000000-0000-0000-0000-00000000060a','de1e7e00-0000-0000-0000-000000000001','2026-11-01');
INSERT INTO public.cycle_checkins (user_id, couple_id, day, mood) VALUES
 ('00000000-0000-0000-0000-00000000060a','de1e7e00-0000-0000-0000-000000000001','2026-11-02','good');
INSERT INTO public.location_sharing (user_id, couple_id, latitude, longitude, is_sharing) VALUES
 ('00000000-0000-0000-0000-00000000060a','de1e7e00-0000-0000-0000-000000000001',45.77,4.83,true),
 ('00000000-0000-0000-0000-00000000060b','de1e7e00-0000-0000-0000-000000000001',45.75,4.83,true);
INSERT INTO public.cycle_notes (user_id, day, note) VALUES
 ('00000000-0000-0000-0000-00000000060a','2026-11-02','Lea''s note'),
 ('00000000-0000-0000-0000-00000000060b','2026-11-02','Ivo''s note');

CREATE FUNCTION pg_temp.expect(label text, ok boolean) RETURNS text
LANGUAGE plpgsql AS $$
BEGIN
  IF NOT ok THEN RAISE EXCEPTION '%: failed', label; END IF;
  RETURN label || ': ok';
END $$;

-- Signed-out callers cannot use it, and nobody deletes auth users directly.
SET ROLE anon;
DO $$ BEGIN
  PERFORM public.delete_my_account();
  RAISE EXCEPTION 'expected a refusal';
EXCEPTION WHEN insufficient_privilege THEN
  RAISE NOTICE 'signed-out callers are refused';
END $$;

SET ROLE authenticated;
SET request.jwt.claim.sub = '00000000-0000-0000-0000-00000000060b';
DO $$ BEGIN
  DELETE FROM auth.users WHERE id = '00000000-0000-0000-0000-00000000060a';
  RAISE EXCEPTION 'expected a refusal';
EXCEPTION WHEN insufficient_privilege THEN
  RAISE NOTICE 'clients cannot delete auth users themselves';
END $$;

-- Ivo deletes his account.
SELECT public.delete_my_account();
RESET ROLE;

SELECT pg_temp.expect('Ivo''s account and profile are gone',
  NOT EXISTS (SELECT 1 FROM auth.users WHERE id = '00000000-0000-0000-0000-00000000060b')
  AND NOT EXISTS (SELECT 1 FROM public.profiles WHERE id = '00000000-0000-0000-0000-00000000060b'));
SELECT pg_temp.expect('their couple is gone',
  NOT EXISTS (SELECT 1 FROM public.couples WHERE id = 'de1e7e00-0000-0000-0000-000000000001'));
SELECT pg_temp.expect('everything they shared is gone, for both',
  (SELECT count(*) FROM public.calendar_events WHERE couple_id = 'de1e7e00-0000-0000-0000-000000000001')
  + (SELECT count(*) FROM public.shared_lists WHERE couple_id = 'de1e7e00-0000-0000-0000-000000000001')
  + (SELECT count(*) FROM public.shared_list_items WHERE couple_id = 'de1e7e00-0000-0000-0000-000000000001')
  + (SELECT count(*) FROM public.couple_pings WHERE couple_id = 'de1e7e00-0000-0000-0000-000000000001')
  + (SELECT count(*) FROM public.period_logs WHERE couple_id = 'de1e7e00-0000-0000-0000-000000000001')
  + (SELECT count(*) FROM public.cycle_checkins WHERE couple_id = 'de1e7e00-0000-0000-0000-000000000001')
  + (SELECT count(*) FROM public.location_sharing WHERE couple_id = 'de1e7e00-0000-0000-0000-000000000001') = 0);
SELECT pg_temp.expect('Ivo''s private notes are gone',
  NOT EXISTS (SELECT 1 FROM public.cycle_notes WHERE user_id = '00000000-0000-0000-0000-00000000060b'));
SELECT pg_temp.expect('Lea keeps her account, now unpaired',
  (SELECT partner_id IS NULL FROM public.profiles WHERE id = '00000000-0000-0000-0000-00000000060a'));
SELECT pg_temp.expect('Lea keeps her private notes',
  (SELECT count(*) = 1 FROM public.cycle_notes WHERE user_id = '00000000-0000-0000-0000-00000000060a'));
SELECT pg_temp.expect('another couple is untouched',
  (SELECT count(*) = 1 FROM public.calendar_events WHERE couple_id = 'de1e7e00-0000-0000-0000-000000000002')
  AND (SELECT partner_id = '00000000-0000-0000-0000-00000000060d' FROM public.profiles WHERE id = '00000000-0000-0000-0000-00000000060c'));

-- A second call with the same, now orphaned, token changes nothing.
SET ROLE authenticated;
SELECT public.delete_my_account();
RESET ROLE;
SELECT pg_temp.expect('a repeated call is harmless',
  (SELECT count(*) = 4 FROM auth.users WHERE id::text LIKE '00000000-0000-0000-0000-0000000006%'));

-- Una only has a pending pairing code.
SET ROLE authenticated;
SET request.jwt.claim.sub = '00000000-0000-0000-0000-00000000060e';
SELECT public.delete_my_account();
RESET ROLE;
SELECT pg_temp.expect('a pending pairing code goes with the account',
  NOT EXISTS (SELECT 1 FROM public.couples WHERE id = 'de1e7e00-0000-0000-0000-000000000003')
  AND NOT EXISTS (SELECT 1 FROM auth.users WHERE id = '00000000-0000-0000-0000-00000000060e'));
