-- Turning location sharing off erases the last position. Before this, only
-- is_sharing went false: the coordinates stayed, and the partner's map kept
-- showing where the person was when they stopped. The database clears them
-- so every app build, old ones included, gets the same rule.

CREATE OR REPLACE FUNCTION public.clear_position_when_not_sharing()
RETURNS TRIGGER AS $$
BEGIN
  IF NOT NEW.is_sharing THEN
    NEW.latitude := NULL;
    NEW.longitude := NULL;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SET search_path = public;

REVOKE ALL ON FUNCTION public.clear_position_when_not_sharing() FROM PUBLIC, anon, authenticated;

CREATE TRIGGER location_sharing_clear_when_off
  BEFORE INSERT OR UPDATE ON public.location_sharing
  FOR EACH ROW EXECUTE FUNCTION public.clear_position_when_not_sharing();

-- People who already stopped sharing.
UPDATE public.location_sharing
SET latitude = NULL, longitude = NULL
WHERE NOT is_sharing
  AND (latitude IS NOT NULL OR longitude IS NOT NULL);
