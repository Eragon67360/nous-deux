\set ON_ERROR_STOP 1
-- Pairing through create_couple() / join_couple() (migrations 20261115300000
-- and 20261116500000). Ann invites, Ben joins. Sam is a stranger who guesses
-- codes. Kim and Lou are an existing couple. Tom tries direct writes.
INSERT INTO auth.users (id) VALUES
 ('00000000-0000-0000-0000-0000000095a1'),('00000000-0000-0000-0000-0000000095b1'),
 ('00000000-0000-0000-0000-0000000095c1'),('00000000-0000-0000-0000-0000000095d1'),
 ('00000000-0000-0000-0000-0000000095e1'),('00000000-0000-0000-0000-0000000095f1'),
 ('00000000-0000-0000-0000-0000000095f2'),('00000000-0000-0000-0000-0000000095f3');
-- 95a1 Ann, 95b1 Ben, 95c1 Sam, 95d1 Kim, 95e1 Lou, 95f1 Tom, 95f2 Uma, 95f3 Vic
INSERT INTO public.profiles (id, username) VALUES
 ('00000000-0000-0000-0000-0000000095a1','Ann'),('00000000-0000-0000-0000-0000000095b1','Ben'),
 ('00000000-0000-0000-0000-0000000095c1','Sam'),('00000000-0000-0000-0000-0000000095d1','Kim'),
 ('00000000-0000-0000-0000-0000000095e1','Lou'),('00000000-0000-0000-0000-0000000095f1','Tom'),
 ('00000000-0000-0000-0000-0000000095f2','Uma'),('00000000-0000-0000-0000-0000000095f3','Vic');
INSERT INTO public.couples (id, user1_id, user2_id) VALUES
 ('95000000-0000-0000-0000-0000000000d1','00000000-0000-0000-0000-0000000095d1','00000000-0000-0000-0000-0000000095e1');
UPDATE public.profiles SET partner_id = '00000000-0000-0000-0000-0000000095e1' WHERE id = '00000000-0000-0000-0000-0000000095d1';
UPDATE public.profiles SET partner_id = '00000000-0000-0000-0000-0000000095d1' WHERE id = '00000000-0000-0000-0000-0000000095e1';

-- Nobody can create a couple with someone else in it.
SET ROLE authenticated; SET request.jwt.claim.sub = '00000000-0000-0000-0000-0000000095c1';
DO $$ BEGIN
  INSERT INTO public.couples (user1_id, user2_id) VALUES ('00000000-0000-0000-0000-0000000095c1','00000000-0000-0000-0000-0000000095d1');
  RAISE EXCEPTION 'expected refusal';
EXCEPTION WHEN insufficient_privilege THEN RAISE NOTICE 'couple with someone else as user2 refused';
END $$;
RESET ROLE;

-- Ann's invite: a 6-sign code from the database; asking again gives the same one.
SET ROLE authenticated; SET request.jwt.claim.sub = '00000000-0000-0000-0000-0000000095a1';
DO $$ DECLARE c1 public.couples; c2 public.couples; BEGIN
  c1 := public.create_couple();
  c2 := public.create_couple();
  ASSERT c1.pairing_code ~ '^[A-HJ-NP-Z2-9]{6}$', c1.pairing_code;
  ASSERT c1.id = c2.id AND c1.pairing_code = c2.pairing_code AND c1.user2_id IS NULL;
  RAISE NOTICE 'Ann''s invite has a 6-sign code, the same on a second call';
END $$;
-- Kim, already paired, gets no invite.
SET request.jwt.claim.sub = '00000000-0000-0000-0000-0000000095d1';
DO $$ BEGIN PERFORM public.create_couple(); RAISE EXCEPTION 'expected already_paired';
EXCEPTION WHEN raise_exception THEN IF SQLERRM <> 'already_paired' THEN RAISE; END IF; RAISE NOTICE 'paired people get no invite';
END $$;
RESET ROLE;

-- Codes are no longer something the app has to find: wrong, own and used codes.
SET ROLE authenticated; SET request.jwt.claim.sub = '00000000-0000-0000-0000-0000000095a1';
DO $$ BEGIN ASSERT public.join_couple((SELECT pairing_code FROM public.couples WHERE user1_id = auth.uid())) = 'own_code'; RAISE NOTICE 'own code refused'; END $$;
SET request.jwt.claim.sub = '00000000-0000-0000-0000-0000000095b1';
DO $$ BEGIN ASSERT public.join_couple('ZZZZZZ') = 'invalid_code'; RAISE NOTICE 'unknown code refused'; END $$;
RESET ROLE;
-- Ben types Ann's code in lower case with spaces, on his local day.
DO $$ BEGIN PERFORM set_config('nd.ann_code', (SELECT pairing_code FROM public.couples WHERE user1_id = '00000000-0000-0000-0000-0000000095a1'), false); END $$;
SET ROLE authenticated; SET request.jwt.claim.sub = '00000000-0000-0000-0000-0000000095b1';
DO $$ BEGIN
  ASSERT public.join_couple(' ' || lower(current_setting('nd.ann_code')) || ' ', CURRENT_DATE + 1) = 'joined';
  RAISE NOTICE 'Ben joined with Ann''s code';
END $$;
RESET ROLE;
SELECT 'Ann and Ben linked: ' || ((SELECT partner_id FROM public.profiles WHERE id = '00000000-0000-0000-0000-0000000095a1') = '00000000-0000-0000-0000-0000000095b1'
  AND (SELECT partner_id FROM public.profiles WHERE id = '00000000-0000-0000-0000-0000000095b1') = '00000000-0000-0000-0000-0000000095a1')
  || ', together_since = Ben''s day: ' || (together_since = CURRENT_DATE + 1)
FROM public.couples WHERE user1_id = '00000000-0000-0000-0000-0000000095a1';
SET ROLE authenticated; SET request.jwt.claim.sub = '00000000-0000-0000-0000-0000000095c1';
DO $$ BEGIN ASSERT public.join_couple(current_setting('nd.ann_code')) = 'code_used'; RAISE NOTICE 'used code refused'; END $$;
-- Kim, already paired, can't join Uma's invite.
SET request.jwt.claim.sub = '00000000-0000-0000-0000-0000000095f2';
DO $$ BEGIN PERFORM public.create_couple(); END $$;
RESET ROLE;
DO $$ BEGIN PERFORM set_config('nd.uma_code', (SELECT pairing_code FROM public.couples WHERE user1_id = '00000000-0000-0000-0000-0000000095f2'), false); END $$;
SET ROLE authenticated; SET request.jwt.claim.sub = '00000000-0000-0000-0000-0000000095d1';
DO $$ BEGIN ASSERT public.join_couple(current_setting('nd.uma_code')) = 'already_paired'; RAISE NOTICE 'paired person can''t join a second couple'; END $$;
RESET ROLE;

-- Sam guesses: 5 wrong codes, then even Uma's real code is refused for 10 minutes.
SET ROLE authenticated; SET request.jwt.claim.sub = '00000000-0000-0000-0000-0000000095c1';
DO $$ BEGIN
  FOR i IN 1..4 LOOP ASSERT public.join_couple('WRONG' || i) = 'invalid_code'; END LOOP;
  ASSERT public.join_couple(current_setting('nd.uma_code')) = 'too_many_attempts';
  RAISE NOTICE '5 wrong codes (the used one counts), then a right one is refused';
END $$;
RESET ROLE;
SELECT 'Uma still waiting: ' || (user2_id IS NULL) FROM public.couples WHERE user1_id = '00000000-0000-0000-0000-0000000095f2';
SELECT 'clients can''t read the attempts: ' || NOT has_table_privilege('authenticated', 'private.pairing_failures', 'SELECT');
-- 10 minutes later the attempts are forgotten.
UPDATE private.pairing_failures SET at = NOW() - INTERVAL '11 minutes';
SET ROLE authenticated; SET request.jwt.claim.sub = '00000000-0000-0000-0000-0000000095c1';
DO $$ BEGIN ASSERT public.join_couple(current_setting('nd.uma_code')) = 'joined'; RAISE NOTICE 'after 10 minutes Sam can join again'; END $$;
RESET ROLE;
SELECT 'old attempts deleted: ' || (count(*) = 0) FROM private.pairing_failures WHERE user_id = '00000000-0000-0000-0000-0000000095c1';

-- Waiting couples are invisible to everyone else, and direct writes can't
-- create or join one (migration 20261116500000).
INSERT INTO public.couples (id, user1_id, pairing_code) VALUES
 ('95000000-0000-0000-0000-0000000000f3','00000000-0000-0000-0000-0000000095f3','VIC234');
INSERT INTO auth.users (id) VALUES ('00000000-0000-0000-0000-0000000095f4');
INSERT INTO public.profiles (id, username) VALUES ('00000000-0000-0000-0000-0000000095f4','Wes');
INSERT INTO public.couples (id, user1_id, pairing_code) VALUES
 ('95000000-0000-0000-0000-0000000000f4','00000000-0000-0000-0000-0000000095f4','WES234');
SET ROLE anon; RESET request.jwt.claim.sub;
DO $$ BEGIN PERFORM count(*) FROM public.couples; RAISE EXCEPTION 'expected refusal';
EXCEPTION WHEN insufficient_privilege THEN RAISE NOTICE 'signed out, couples can''t be read';
END $$;
RESET ROLE;
SET ROLE authenticated; SET request.jwt.claim.sub = '00000000-0000-0000-0000-0000000095f1';
DO $$ DECLARE n int; BEGIN
  ASSERT (SELECT count(*) FROM public.couples WHERE pairing_code IN ('VIC234','WES234')) = 0;
  UPDATE public.couples SET user2_id = auth.uid() WHERE pairing_code IN ('VIC234','WES234');
  GET DIAGNOSTICS n = ROW_COUNT;
  ASSERT n = 0, n::text;
  RAISE NOTICE 'Tom sees no waiting couple and can''t join one directly';
END $$;
DO $$ BEGIN
  INSERT INTO public.couples (user1_id, pairing_code) VALUES (auth.uid(), 'TOM234');
  RAISE EXCEPTION 'expected refusal';
EXCEPTION WHEN insufficient_privilege THEN RAISE NOTICE 'direct insert refused';
END $$;
DO $$ BEGIN
  ASSERT public.join_couple('VIC234') = 'joined';
  ASSERT public.join_couple('WES234') = 'already_paired';
  RAISE NOTICE 'Tom joins Vic with the code, then can''t join Wes';
END $$;
RESET ROLE;
SELECT 'Tom''s couples: ' || count(*) FROM public.couples WHERE user2_id = '00000000-0000-0000-0000-0000000095f1';

-- A forged second couple from before this migration (Wes + Lou, next to
-- Kim + Lou): leaving removes both, not one at random.
INSERT INTO public.couples (id, user1_id, user2_id) VALUES
 ('95000000-0000-0000-0000-0000000000c1','00000000-0000-0000-0000-0000000095f4','00000000-0000-0000-0000-0000000095e1');
SET ROLE authenticated; SET request.jwt.claim.sub = '00000000-0000-0000-0000-0000000095e1';
SELECT public.leave_couple();
RESET ROLE;
SELECT 'Lou left both couples: ' || (count(*) = 0) FROM public.couples WHERE user1_id = '00000000-0000-0000-0000-0000000095e1' OR user2_id = '00000000-0000-0000-0000-0000000095e1';
SELECT 'Kim and Lou unlinked: ' || (count(*) = 0) FROM public.profiles WHERE id IN ('00000000-0000-0000-0000-0000000095d1','00000000-0000-0000-0000-0000000095e1') AND partner_id IS NOT NULL;

-- Signed-out callers can't use any of it.
SET ROLE anon; RESET request.jwt.claim.sub;
DO $$ BEGIN PERFORM public.create_couple(); RAISE EXCEPTION 'expected refusal'; EXCEPTION WHEN insufficient_privilege THEN RAISE NOTICE 'anon cannot call create_couple'; END $$;
DO $$ BEGIN PERFORM public.join_couple('ABCDEF'); RAISE EXCEPTION 'expected refusal'; EXCEPTION WHEN insufficient_privilege THEN RAISE NOTICE 'anon cannot call join_couple'; END $$;
DO $$ BEGIN PERFORM public.leave_couple(); RAISE EXCEPTION 'expected refusal'; EXCEPTION WHEN insufficient_privilege THEN RAISE NOTICE 'anon cannot call leave_couple'; END $$;
RESET ROLE;
