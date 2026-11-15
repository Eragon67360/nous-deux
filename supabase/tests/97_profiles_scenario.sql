\set ON_ERROR_STOP 1
-- Profiles are readable by their owner and the owner's partner only
-- (migration 20261116050000). Amy invites and Bo joins through the pairing
-- functions; Cleo waits with an invite; Dax is signed in with no couple.
INSERT INTO auth.users (id) VALUES
 ('00000000-0000-0000-0000-0000000097a1'),('00000000-0000-0000-0000-0000000097b1'),
 ('00000000-0000-0000-0000-0000000097c1'),('00000000-0000-0000-0000-0000000097d1');
INSERT INTO public.profiles (id, username, gender, fcm_token) VALUES
 ('00000000-0000-0000-0000-0000000097a1','Amy','woman','fcm-amy'),('00000000-0000-0000-0000-0000000097b1','Bo','man','fcm-bo'),
 ('00000000-0000-0000-0000-0000000097c1','Cleo','woman','fcm-cleo'),('00000000-0000-0000-0000-0000000097d1','Dax','man','fcm-dax');
INSERT INTO storage.objects (bucket_id, name, owner) VALUES
 ('avatars','00000000-0000-0000-0000-0000000097a1/avatar.jpg','00000000-0000-0000-0000-0000000097a1'),
 ('avatars','00000000-0000-0000-0000-0000000097d1/avatar.jpg','00000000-0000-0000-0000-0000000097d1');

CREATE FUNCTION pg_temp.expect(label text, ok boolean) RETURNS text
LANGUAGE plpgsql AS $$
BEGIN
  IF NOT ok THEN RAISE EXCEPTION '%: failed', label; END IF;
  RETURN label || ': ok';
END $$;
-- Profiles the current caller can see, among this scenario's people.
CREATE FUNCTION pg_temp.seen() RETURNS text LANGUAGE sql AS $$
  SELECT coalesce(string_agg(username, ',' ORDER BY username), '')
  FROM public.profiles WHERE id::text LIKE '00000000-0000-0000-0000-000000009%'
$$;

-- Pairing: Amy invites, Cleo invites, Bo joins Amy. The database links the
-- profiles although clients can no longer write partner_id.
SET ROLE authenticated;
SET request.jwt.claim.sub = '00000000-0000-0000-0000-0000000097a1';
DO $$ BEGIN PERFORM public.create_couple(); END $$;
SET request.jwt.claim.sub = '00000000-0000-0000-0000-0000000097c1';
DO $$ BEGIN PERFORM public.create_couple(); END $$;
RESET ROLE;
DO $$ BEGIN PERFORM set_config('nd.amy_code', (SELECT pairing_code FROM public.couples WHERE user1_id = '00000000-0000-0000-0000-0000000097a1'), false); END $$;
SET ROLE authenticated;
SET request.jwt.claim.sub = '00000000-0000-0000-0000-0000000097b1';
SELECT pg_temp.expect('Bo joins Amy', public.join_couple(current_setting('nd.amy_code')) = 'joined');
SELECT pg_temp.expect('pairing links both profiles',
  (SELECT partner_id FROM public.profiles WHERE id = auth.uid()) = '00000000-0000-0000-0000-0000000097a1');

-- Self and partner: Bo and Amy see each other, nobody else.
SELECT pg_temp.expect('Bo sees Amy and himself', pg_temp.seen() = 'Amy,Bo');
SET request.jwt.claim.sub = '00000000-0000-0000-0000-0000000097a1';
SELECT pg_temp.expect('Amy sees Bo and herself', pg_temp.seen() = 'Amy,Bo');
SELECT pg_temp.expect('Amy reads Bo''s push token, as the partner',
  (SELECT fcm_token FROM public.profiles WHERE id = '00000000-0000-0000-0000-0000000097b1') = 'fcm-bo');

-- A waiting couple's creator and a stranger see only themselves.
SET request.jwt.claim.sub = '00000000-0000-0000-0000-0000000097c1';
SELECT pg_temp.expect('Cleo (waiting) sees only herself', pg_temp.seen() = 'Cleo');
SET request.jwt.claim.sub = '00000000-0000-0000-0000-0000000097d1';
SELECT pg_temp.expect('Dax (stranger) sees only himself', pg_temp.seen() = 'Dax');

-- Dax can't point partner_id at Amy, nor set the consent time.
DO $$ BEGIN
  UPDATE public.profiles SET partner_id = '00000000-0000-0000-0000-0000000097a1' WHERE id = auth.uid();
  RAISE EXCEPTION 'expected refusal';
EXCEPTION WHEN insufficient_privilege THEN RAISE NOTICE 'writing partner_id refused';
END $$;
DO $$ BEGIN
  INSERT INTO public.profiles (id, partner_id) VALUES (auth.uid(), '00000000-0000-0000-0000-0000000097a1')
  ON CONFLICT (id) DO UPDATE SET partner_id = EXCLUDED.partner_id;
  RAISE EXCEPTION 'expected refusal';
EXCEPTION WHEN insufficient_privilege THEN RAISE NOTICE 'upserting partner_id refused';
END $$;
-- Everything the app writes still works: the first-launch upsert and each edit.
INSERT INTO public.profiles (id, gender, language) VALUES (auth.uid(), 'man', 'en')
ON CONFLICT (id) DO UPDATE SET id = EXCLUDED.id, gender = EXCLUDED.gender, language = EXCLUDED.language;
UPDATE public.profiles SET username = 'Dax B.', avatar_url = 'https://api.nous-deux.app/x.jpg', fcm_token = 'fcm-dax-2',
  tracks_cycle = TRUE, share_cycle = FALSE, share_checkins = FALSE, onboarding_completed_at = NOW()
WHERE id = auth.uid();
SELECT pg_temp.expect('the app''s own edits still work',
  (SELECT username = 'Dax B.' AND language = 'en' AND fcm_token = 'fcm-dax-2' AND cycle_consent_at IS NOT NULL FROM public.profiles WHERE id = auth.uid()));
RESET ROLE;

-- Even a partner_id left pointing at Amy (set before this migration) opens nothing.
UPDATE public.profiles SET partner_id = '00000000-0000-0000-0000-0000000097a1' WHERE id = '00000000-0000-0000-0000-0000000097d1';
SET ROLE authenticated;
SET request.jwt.claim.sub = '00000000-0000-0000-0000-0000000097d1';
SELECT pg_temp.expect('a stale partner_id shows nobody else', pg_temp.seen() = 'Dax B.');
SELECT pg_temp.expect('shares_cycle() says nothing about a stranger', NOT public.shares_cycle('00000000-0000-0000-0000-0000000097a1'));
SELECT pg_temp.expect('Dax lists only his own avatar folder',
  (SELECT string_agg(name, ',') FROM storage.objects WHERE bucket_id = 'avatars' AND name LIKE '00000000-0000-0000-0000-000000009%') = '00000000-0000-0000-0000-0000000097d1/avatar.jpg');
RESET ROLE;
UPDATE public.profiles SET partner_id = NULL WHERE id = '00000000-0000-0000-0000-0000000097d1';

-- The partner policies still work: Bo reads Amy's shared check-in, Dax doesn't.
SET ROLE authenticated;
SET request.jwt.claim.sub = '00000000-0000-0000-0000-0000000097a1';
INSERT INTO public.cycle_checkins (user_id, couple_id, day, mood)
SELECT auth.uid(), id, CURRENT_DATE, 'calm' FROM public.couples WHERE user1_id = auth.uid();
SET request.jwt.claim.sub = '00000000-0000-0000-0000-0000000097b1';
SELECT pg_temp.expect('Bo reads Amy''s shared check-in', (SELECT count(*) FROM public.cycle_checkins WHERE user_id = '00000000-0000-0000-0000-0000000097a1') = 1);
SELECT pg_temp.expect('shares_checkins() answers about the partner', public.shares_checkins('00000000-0000-0000-0000-0000000097a1'));
SET request.jwt.claim.sub = '00000000-0000-0000-0000-0000000097d1';
SELECT pg_temp.expect('Dax doesn''t', (SELECT count(*) FROM public.cycle_checkins WHERE user_id = '00000000-0000-0000-0000-0000000097a1') = 0);
RESET ROLE;

-- Signed out: no profile, no avatar list.
SET ROLE anon; RESET request.jwt.claim.sub;
DO $$ BEGIN
  PERFORM 1 FROM public.profiles;
  RAISE EXCEPTION 'expected refusal';
EXCEPTION WHEN insufficient_privilege THEN RAISE NOTICE 'signed out, profiles can''t be read';
END $$;
SELECT pg_temp.expect('signed out, no avatar folder is listed', (SELECT count(*) FROM storage.objects WHERE bucket_id = 'avatars') = 0);
RESET ROLE;

-- Leaving ends it: Bo no longer sees Amy.
SET ROLE authenticated;
SET request.jwt.claim.sub = '00000000-0000-0000-0000-0000000097b1';
SELECT public.leave_couple();
SELECT pg_temp.expect('after leaving, Bo sees only himself', pg_temp.seen() = 'Bo');
RESET ROLE;
