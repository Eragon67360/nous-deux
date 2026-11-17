\set ON_ERROR_STOP 1
-- Sam (9a) signs up on a build that still sends a gender (0.3.6+26). The
-- database keeps none, whichever way it arrives, and saves the rest as
-- before. Every check prints a line; a wrong result raises.
INSERT INTO auth.users (id) VALUES ('00000000-0000-0000-0000-00000000009a');

CREATE FUNCTION pg_temp.expect(label text, ok boolean) RETURNS text
LANGUAGE plpgsql AS $$
BEGIN
  IF NOT ok THEN RAISE EXCEPTION '%: failed', label; END IF;
  RETURN label || ': ok';
END $$;

SET ROLE authenticated;
SET request.jwt.claim.sub = '00000000-0000-0000-0000-00000000009a';

-- getOrCreateMyProfile on 0.3.6+26: an upsert with gender 'woman'.
INSERT INTO public.profiles (id, gender, language)
VALUES (auth.uid(), 'woman', 'fr')
ON CONFLICT (id) DO UPDATE SET id = EXCLUDED.id, gender = EXCLUDED.gender, language = EXCLUDED.language;
SELECT pg_temp.expect('a new profile keeps no gender',
  (SELECT gender IS NULL AND language = 'fr' FROM public.profiles WHERE id = auth.uid()));

-- The same upsert again takes the ON CONFLICT path.
INSERT INTO public.profiles (id, gender, language)
VALUES (auth.uid(), 'woman', 'fr')
ON CONFLICT (id) DO UPDATE SET id = EXCLUDED.id, gender = EXCLUDED.gender, language = EXCLUDED.language;
SELECT pg_temp.expect('an upsert of an existing profile keeps no gender',
  (SELECT gender IS NULL FROM public.profiles WHERE id = auth.uid()));

-- completeOnboarding on 0.3.6+26.
UPDATE public.profiles
SET username = 'Sam', gender = 'man', language = 'en', onboarding_completed_at = now()
WHERE id = auth.uid();
SELECT pg_temp.expect('onboarding keeps no gender, and saves the rest',
  (SELECT gender IS NULL AND username = 'Sam' AND language = 'en'
          AND onboarding_completed_at IS NOT NULL
   FROM public.profiles WHERE id = auth.uid()));

-- Current builds send no gender.
UPDATE public.profiles SET username = 'Sam B.' WHERE id = auth.uid();
SELECT pg_temp.expect('other edits still work',
  (SELECT username = 'Sam B.' FROM public.profiles WHERE id = auth.uid()));

DO $$ BEGIN
  PERFORM public.discard_gender();
  RAISE EXCEPTION 'expected a refusal';
EXCEPTION
  WHEN insufficient_privilege OR feature_not_supported THEN
    RAISE NOTICE 'clients cannot call the trigger function';
END $$;
RESET ROLE;

-- Every scenario before this one wrote a gender too.
SELECT pg_temp.expect('no profile has a gender',
  NOT EXISTS (SELECT 1 FROM public.profiles WHERE gender IS NOT NULL));
