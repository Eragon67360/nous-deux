\set ON_ERROR_STOP 1
-- Ana (e5) agrees to track her cycle, tries to change the recorded time,
-- stops, and starts again. Every check prints a line; a wrong result raises.
INSERT INTO auth.users (id) VALUES ('00000000-0000-0000-0000-0000000000e5');
INSERT INTO public.profiles (id, username, gender)
VALUES ('00000000-0000-0000-0000-0000000000e5', 'Ana', 'woman');

CREATE FUNCTION pg_temp.expect(label text, ok boolean) RETURNS text
LANGUAGE plpgsql AS $$
BEGIN
  IF NOT ok THEN RAISE EXCEPTION '%: failed', label; END IF;
  RETURN label || ': ok';
END $$;

SET ROLE authenticated;
SET request.jwt.claim.sub = '00000000-0000-0000-0000-0000000000e5';

SELECT pg_temp.expect('not asked yet, no consent',
  (SELECT cycle_consent_at IS NULL FROM public.profiles WHERE id = auth.uid()));

UPDATE public.profiles SET tracks_cycle = TRUE WHERE id = auth.uid();
SELECT pg_temp.expect('tracking on records the time',
  (SELECT cycle_consent_at IS NOT NULL FROM public.profiles WHERE id = auth.uid()));
CREATE TEMP TABLE first_consent AS
  SELECT cycle_consent_at AS at FROM public.profiles WHERE id = auth.uid();

UPDATE public.profiles SET cycle_consent_at = '2020-01-01' WHERE id = auth.uid();
SELECT pg_temp.expect('the client cannot change the time',
  (SELECT p.cycle_consent_at = f.at FROM public.profiles p, first_consent f WHERE p.id = auth.uid()));

UPDATE public.profiles SET username = 'Ana B.' WHERE id = auth.uid();
SELECT pg_temp.expect('other edits keep the consent',
  (SELECT p.cycle_consent_at = f.at FROM public.profiles p, first_consent f WHERE p.id = auth.uid()));

UPDATE public.profiles SET tracks_cycle = FALSE WHERE id = auth.uid();
SELECT pg_temp.expect('stopping withdraws it',
  (SELECT cycle_consent_at IS NULL FROM public.profiles WHERE id = auth.uid()));

SELECT pg_sleep(0.01);
UPDATE public.profiles SET tracks_cycle = TRUE WHERE id = auth.uid();
SELECT pg_temp.expect('starting again records a new time',
  (SELECT p.cycle_consent_at > f.at FROM public.profiles p, first_consent f WHERE p.id = auth.uid()));

DO $$ BEGIN
  PERFORM public.record_cycle_consent();
  RAISE EXCEPTION 'expected a refusal';
EXCEPTION
  WHEN insufficient_privilege OR feature_not_supported THEN
    RAISE NOTICE 'clients cannot call the trigger function';
END $$;
RESET ROLE;
