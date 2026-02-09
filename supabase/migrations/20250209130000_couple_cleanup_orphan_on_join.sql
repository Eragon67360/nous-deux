-- When user2_id is set (someone joins), delete any other couple row where the joining
-- user was user1 and user2 is still null (orphan row from their earlier "Générer le code").
CREATE OR REPLACE FUNCTION public.on_couple_paired()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.user2_id IS NOT NULL AND (OLD.user2_id IS NULL OR OLD.user2_id IS DISTINCT FROM NEW.user2_id) THEN
    -- Set partner_id on both profiles
    UPDATE public.profiles SET partner_id = NEW.user2_id, updated_at = NOW() WHERE id = NEW.user1_id;
    UPDATE public.profiles SET partner_id = NEW.user1_id, updated_at = NOW() WHERE id = NEW.user2_id;
    -- Remove the joining user's orphan couple (user1 = joiner, user2 = null)
    DELETE FROM public.couples
    WHERE user1_id = NEW.user2_id AND user2_id IS NULL AND id != NEW.id;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
