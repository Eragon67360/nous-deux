\set ON_ERROR_STOP 1
-- Signed-out callers can't read couples (migration 20261116000000), while the
-- signed-in path that app 0.3.5 still uses keeps working. Ada waits with code
-- ADA234, Bob and Cy are paired, Dee is signed in with no couple.
INSERT INTO auth.users (id) VALUES
 ('00000000-0000-0000-0000-0000000096a1'),('00000000-0000-0000-0000-0000000096b1'),
 ('00000000-0000-0000-0000-0000000096c1'),('00000000-0000-0000-0000-0000000096d1');
INSERT INTO public.profiles (id, username) VALUES
 ('00000000-0000-0000-0000-0000000096a1','Ada'),('00000000-0000-0000-0000-0000000096b1','Bob'),
 ('00000000-0000-0000-0000-0000000096c1','Cy'),('00000000-0000-0000-0000-0000000096d1','Dee');
INSERT INTO public.couples (id, user1_id, user2_id, pairing_code) VALUES
 ('96000000-0000-0000-0000-0000000000a1','00000000-0000-0000-0000-0000000096a1',NULL,'ADA234'),
 ('96000000-0000-0000-0000-0000000000b1','00000000-0000-0000-0000-0000000096b1','00000000-0000-0000-0000-0000000096c1',NULL);

-- Signed out: no list of waiting couples, no single couple by its code, no writes.
SET ROLE anon; RESET request.jwt.claim.sub;
DO $$ BEGIN
  PERFORM 1 FROM public.couples;
  RAISE EXCEPTION 'expected refusal';
EXCEPTION WHEN insufficient_privilege THEN RAISE NOTICE 'signed-out list of couples refused';
END $$;
DO $$ BEGIN
  PERFORM 1 FROM public.couples WHERE pairing_code = 'ADA234';
  RAISE EXCEPTION 'expected refusal';
EXCEPTION WHEN insufficient_privilege THEN RAISE NOTICE 'signed-out lookup by code refused';
END $$;
DO $$ BEGIN
  UPDATE public.couples SET user2_id = '00000000-0000-0000-0000-0000000096d1' WHERE user2_id IS NULL;
  RAISE EXCEPTION 'expected refusal';
EXCEPTION WHEN insufficient_privilege THEN RAISE NOTICE 'signed-out write to couples refused';
END $$;
RESET ROLE;

-- Signed in: Ada sees her invite and Bob his couple. Since migration
-- 20261116100000, Dee no longer finds Ada's waiting couple by its code:
-- join_couple() is the only way in.
SET ROLE authenticated;
SET request.jwt.claim.sub = '00000000-0000-0000-0000-0000000096a1';
DO $$ BEGIN ASSERT (SELECT pairing_code FROM public.couples WHERE user1_id = auth.uid()) = 'ADA234'; RAISE NOTICE 'Ada still reads her invite'; END $$;
SET request.jwt.claim.sub = '00000000-0000-0000-0000-0000000096b1';
DO $$ BEGIN ASSERT (SELECT count(*) FROM public.couples WHERE id = '96000000-0000-0000-0000-0000000000b1') = 1; RAISE NOTICE 'Bob still reads his couple'; END $$;
SET request.jwt.claim.sub = '00000000-0000-0000-0000-0000000096d1';
DO $$ BEGIN ASSERT (SELECT count(*) FROM public.couples WHERE pairing_code = 'ADA234') = 0; RAISE NOTICE 'signed-in lookup by code refused'; END $$;
RESET ROLE;
