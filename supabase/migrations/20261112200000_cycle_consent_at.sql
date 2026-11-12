-- When the person agreed to their cycle data (health data) being kept.
-- Set by the database, so the time can be shown to an authority and no
-- client can forge or forget it: tracking turned on records now(), turned
-- off clears it (consent withdrawn), and any other update keeps it as is.

ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS cycle_consent_at TIMESTAMPTZ;

COMMENT ON COLUMN public.profiles.cycle_consent_at IS
  'When the person last agreed to track their cycle (explicit consent for health data); null without consent. Set by profiles_cycle_consent.';

CREATE OR REPLACE FUNCTION public.record_cycle_consent()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.tracks_cycle IS TRUE
     AND (TG_OP = 'INSERT' OR OLD.tracks_cycle IS DISTINCT FROM TRUE) THEN
    NEW.cycle_consent_at := now();
  ELSIF NEW.tracks_cycle IS NOT TRUE THEN
    NEW.cycle_consent_at := NULL;
  ELSE
    NEW.cycle_consent_at := OLD.cycle_consent_at;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SET search_path = public;

REVOKE ALL ON FUNCTION public.record_cycle_consent() FROM PUBLIC, anon, authenticated;

CREATE TRIGGER profiles_cycle_consent
  BEFORE INSERT OR UPDATE ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION public.record_cycle_consent();
