-- Gender is no longer asked (app PR #124): nothing ever read it, so the
-- stored values go. The column stays only because builds up to 0.3.6+26
-- still send a gender at sign-up and refusing it would break their
-- onboarding, so a trigger drops whatever they send. Drop the column once
-- nobody is on those builds.

UPDATE public.profiles SET gender = NULL WHERE gender IS NOT NULL;

COMMENT ON COLUMN public.profiles.gender IS
  'Unused since 2026-11-17 and always null: profiles_discard_gender drops what builds up to 0.3.6+26 still send. Drop the column once they are gone.';

CREATE OR REPLACE FUNCTION public.discard_gender()
RETURNS TRIGGER AS $$
BEGIN
  NEW.gender := NULL;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SET search_path = public;

REVOKE ALL ON FUNCTION public.discard_gender() FROM PUBLIC, anon, authenticated;

CREATE TRIGGER profiles_discard_gender
  BEFORE INSERT OR UPDATE ON public.profiles
  FOR EACH ROW WHEN (NEW.gender IS NOT NULL)
  EXECUTE FUNCTION public.discard_gender();
