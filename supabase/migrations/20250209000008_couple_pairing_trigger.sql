-- When user2_id is set on a couple, set partner_id on both profiles (SECURITY DEFINER to allow cross-user update).
CREATE OR REPLACE FUNCTION public.on_couple_paired()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.user2_id IS NOT NULL AND (OLD.user2_id IS NULL OR OLD.user2_id IS DISTINCT FROM NEW.user2_id) THEN
    UPDATE public.profiles SET partner_id = NEW.user2_id, updated_at = NOW() WHERE id = NEW.user1_id;
    UPDATE public.profiles SET partner_id = NEW.user1_id, updated_at = NOW() WHERE id = NEW.user2_id;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER after_couple_paired
  AFTER UPDATE ON public.couples
  FOR EACH ROW EXECUTE FUNCTION public.on_couple_paired();
