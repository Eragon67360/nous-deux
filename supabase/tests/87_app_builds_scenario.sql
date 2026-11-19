\set ON_ERROR_STOP 1
-- Update screen: the latest build per platform (docs/UPDATE_SCREEN.md,
-- Task 1). Signed-in people read it; only the release jobs' token records a
-- build, and never a lower one. Every check prints a line; a wrong result
-- raises.
INSERT INTO auth.users (id) VALUES ('00000000-0000-0000-0000-00000000087a');

CREATE FUNCTION pg_temp.expect(label text, ok boolean) RETURNS text
LANGUAGE plpgsql AS $$
BEGIN
  IF NOT ok THEN RAISE EXCEPTION '%: failed', label; END IF;
  RETURN label || ': ok';
END $$;

INSERT INTO private.release_token (token_sha256)
VALUES (sha256(convert_to('the-release-token', 'UTF8')));

SELECT pg_temp.expect('both platforms start at build 0',
  (SELECT count(*) = 2 AND bool_and(latest_build = 0 AND min_build = 0)
   FROM public.app_builds));

-- Not signed in: the release jobs, and anyone else without a session.
SET ROLE anon;
DO $$ BEGIN
  PERFORM 1 FROM public.app_builds;
  RAISE EXCEPTION 'expected a refusal';
EXCEPTION WHEN insufficient_privilege THEN RAISE NOTICE 'signed out, the rows are out of reach';
END $$;
DO $$ BEGIN
  UPDATE public.app_builds SET min_build = 99;
  RAISE EXCEPTION 'expected a refusal';
EXCEPTION WHEN insufficient_privilege THEN RAISE NOTICE 'anon cannot change a row';
END $$;
DO $$ BEGIN
  INSERT INTO public.app_builds (platform) VALUES ('web');
  RAISE EXCEPTION 'expected a refusal';
EXCEPTION WHEN insufficient_privilege THEN RAISE NOTICE 'anon cannot add a row';
END $$;
DO $$ BEGIN
  PERFORM 1 FROM private.release_token;
  RAISE EXCEPTION 'expected a refusal';
EXCEPTION WHEN insufficient_privilege THEN RAISE NOTICE 'the token hash is out of reach';
END $$;
DO $$ BEGIN
  PERFORM public.record_app_build('ios', 30, '{"fr":"x","en":"x"}', 'a-guess');
  RAISE EXCEPTION 'expected a refusal';
EXCEPTION WHEN insufficient_privilege THEN RAISE NOTICE 'a wrong token records nothing';
END $$;
DO $$ BEGIN
  PERFORM public.record_app_build('ios', 30, '{"fr":"x","en":"x"}', NULL);
  RAISE EXCEPTION 'expected a refusal';
EXCEPTION WHEN insufficient_privilege THEN RAISE NOTICE 'no token records nothing';
END $$;

-- The release job, with the token.
SELECT public.record_app_build('ios', 30,
  '{"fr":"Le suivi de la pilule.","en":"Pill tracking."}', 'the-release-token');
RESET ROLE;
SELECT pg_temp.expect('the job records build 30 and its note',
  (SELECT latest_build = 30 AND note->>'fr' = 'Le suivi de la pilule.'
   FROM public.app_builds WHERE platform = 'ios'));
SELECT pg_temp.expect('the other platform is untouched',
  (SELECT latest_build = 0 FROM public.app_builds WHERE platform = 'android'));
SET ROLE anon;
SELECT public.record_app_build('ios', 29, '{"fr":"Ancien.","en":"Old."}', 'the-release-token');
RESET ROLE;
SELECT pg_temp.expect('an older build changes nothing',
  (SELECT latest_build = 30 AND note->>'en' = 'Pill tracking.'
   FROM public.app_builds WHERE platform = 'ios'));
SET ROLE anon;
SELECT public.record_app_build('ios', 30, '{"fr":"Corrigé.","en":"Fixed."}', 'the-release-token');
RESET ROLE;
SELECT pg_temp.expect('the same build again updates its note',
  (SELECT latest_build = 30 AND note->>'en' = 'Fixed.'
   FROM public.app_builds WHERE platform = 'ios'));
SET ROLE anon;
DO $$ BEGIN
  PERFORM public.record_app_build('web', 30, '{}', 'the-release-token');
  RAISE EXCEPTION 'expected a refusal';
EXCEPTION WHEN invalid_parameter_value THEN RAISE NOTICE 'an unknown platform is refused';
END $$;
DO $$ BEGIN
  PERFORM public.record_app_build('android', 0, '{}', 'the-release-token');
  RAISE EXCEPTION 'expected a refusal';
EXCEPTION WHEN invalid_parameter_value THEN RAISE NOTICE 'build 0 is refused';
END $$;
DO $$ BEGIN
  PERFORM public.record_app_build('android', 31, '"une ligne"', 'the-release-token');
  RAISE EXCEPTION 'expected a refusal';
EXCEPTION WHEN invalid_parameter_value THEN RAISE NOTICE 'a note that is not an object is refused';
END $$;
RESET ROLE;

-- Signed in: reads, but the function is only for the jobs.
SET ROLE authenticated;
SET request.jwt.claim.sub = '00000000-0000-0000-0000-00000000087a';
SELECT pg_temp.expect('signed in, both rows are readable',
  (SELECT count(*) = 2 FROM public.app_builds));
SELECT pg_temp.expect('with the latest build, the minimum and the note',
  (SELECT latest_build = 30 AND min_build = 0 AND note->>'fr' = 'Corrigé.'
   FROM public.app_builds WHERE platform = 'ios'));
DO $$ BEGIN
  PERFORM public.record_app_build('ios', 31, '{}', 'the-release-token');
  RAISE EXCEPTION 'expected a refusal';
EXCEPTION WHEN insufficient_privilege THEN RAISE NOTICE 'signed in, the function is refused';
END $$;
DO $$ BEGIN
  UPDATE public.app_builds SET latest_build = 99 WHERE platform = 'ios';
  RAISE EXCEPTION 'expected a refusal';
EXCEPTION WHEN insufficient_privilege THEN RAISE NOTICE 'signed in, a row cannot change';
END $$;
RESET ROLE;
RESET request.jwt.claim.sub;

-- The minimum is raised by hand (postgres, scripts/app-builds.sh).
UPDATE public.app_builds SET min_build = 30 WHERE platform = 'ios';
SELECT pg_temp.expect('the minimum is set by hand',
  (SELECT min_build = 30 FROM public.app_builds WHERE platform = 'ios'));

DELETE FROM private.release_token;
UPDATE public.app_builds SET latest_build = 0, min_build = 0, note = '{}';
DELETE FROM auth.users WHERE id = '00000000-0000-0000-0000-00000000087a';
