\set ON_ERROR_STOP 1
-- Mia (7a) shares her position with Tom (7b), then stops. Every check prints
-- a line; a wrong result raises.
INSERT INTO auth.users (id) VALUES
 ('00000000-0000-0000-0000-00000000007a'),('00000000-0000-0000-0000-00000000007b');
INSERT INTO public.profiles (id, username, gender, partner_id) VALUES
 ('00000000-0000-0000-0000-00000000007a','Mia','woman',NULL),
 ('00000000-0000-0000-0000-00000000007b','Tom','man',NULL);
INSERT INTO public.couples (id, user1_id, user2_id) VALUES
 ('70c70c70-0000-0000-0000-000000000001','00000000-0000-0000-0000-00000000007a','00000000-0000-0000-0000-00000000007b');
UPDATE public.profiles SET partner_id = '00000000-0000-0000-0000-00000000007b' WHERE id = '00000000-0000-0000-0000-00000000007a';
UPDATE public.profiles SET partner_id = '00000000-0000-0000-0000-00000000007a' WHERE id = '00000000-0000-0000-0000-00000000007b';

CREATE FUNCTION pg_temp.expect(label text, ok boolean) RETURNS text
LANGUAGE plpgsql AS $$
BEGIN
  IF ok IS NOT TRUE THEN RAISE EXCEPTION '%: failed', label; END IF;
  RETURN label || ': ok';
END $$;

SET ROLE authenticated;

-- Mia turns sharing on and sends her position.
SET request.jwt.claim.sub = '00000000-0000-0000-0000-00000000007a';
INSERT INTO public.location_sharing (user_id, couple_id, is_sharing, latitude, longitude)
VALUES (auth.uid(), '70c70c70-0000-0000-0000-000000000001', TRUE, 48.8566, 2.3522);

SET request.jwt.claim.sub = '00000000-0000-0000-0000-00000000007b';
SELECT pg_temp.expect('while she shares, Tom reads her position',
  (SELECT latitude = 48.8566 AND longitude = 2.3522 FROM public.location_sharing
   WHERE user_id = '00000000-0000-0000-0000-00000000007a'));

-- Mia turns sharing off the way the app does: only is_sharing changes.
SET request.jwt.claim.sub = '00000000-0000-0000-0000-00000000007a';
UPDATE public.location_sharing SET is_sharing = FALSE, updated_at = now()
WHERE user_id = auth.uid();
SELECT pg_temp.expect('stopping erases her last position',
  (SELECT latitude IS NULL AND longitude IS NULL FROM public.location_sharing
   WHERE user_id = auth.uid()));

SET request.jwt.claim.sub = '00000000-0000-0000-0000-00000000007b';
SELECT pg_temp.expect('Tom still sees that she stopped',
  (SELECT NOT is_sharing FROM public.location_sharing
   WHERE user_id = '00000000-0000-0000-0000-00000000007a'));
SELECT pg_temp.expect('Tom reads no position for her',
  (SELECT count(*) = 0 FROM public.location_sharing
   WHERE user_id = '00000000-0000-0000-0000-00000000007a'
     AND (latitude IS NOT NULL OR longitude IS NOT NULL)));

-- A position sent while not sharing is not kept, on update or insert.
SET request.jwt.claim.sub = '00000000-0000-0000-0000-00000000007a';
UPDATE public.location_sharing SET latitude = 45.76, longitude = 4.84
WHERE user_id = auth.uid();
SELECT pg_temp.expect('a position without sharing is not stored',
  (SELECT latitude IS NULL AND longitude IS NULL FROM public.location_sharing
   WHERE user_id = auth.uid()));

SET request.jwt.claim.sub = '00000000-0000-0000-0000-00000000007b';
INSERT INTO public.location_sharing (user_id, couple_id, latitude, longitude)
VALUES (auth.uid(), '70c70c70-0000-0000-0000-000000000001', 45.76, 4.84);
SELECT pg_temp.expect('a new row that does not share keeps no position',
  (SELECT latitude IS NULL AND longitude IS NULL FROM public.location_sharing
   WHERE user_id = auth.uid()));

-- Mia shares again from somewhere else: Tom sees the new position only.
SET request.jwt.claim.sub = '00000000-0000-0000-0000-00000000007a';
UPDATE public.location_sharing SET is_sharing = TRUE, latitude = 43.2965, longitude = 5.3698
WHERE user_id = auth.uid();

SET request.jwt.claim.sub = '00000000-0000-0000-0000-00000000007b';
SELECT pg_temp.expect('sharing again shows the new position',
  (SELECT latitude = 43.2965 AND longitude = 5.3698 FROM public.location_sharing
   WHERE user_id = '00000000-0000-0000-0000-00000000007a'));

DO $$ BEGIN
  PERFORM public.clear_position_when_not_sharing();
  RAISE EXCEPTION 'expected a refusal';
EXCEPTION
  WHEN insufficient_privilege OR feature_not_supported THEN
    RAISE NOTICE 'clients cannot call the trigger function';
END $$;
RESET ROLE;
