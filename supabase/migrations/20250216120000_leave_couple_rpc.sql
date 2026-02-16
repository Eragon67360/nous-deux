-- RPC for current user to leave their couple.
-- Clears partner_id on both profiles, then deletes the couple row (CASCADE removes
-- calendar_events, period_logs, location_sharing for that couple).
CREATE OR REPLACE FUNCTION public.leave_couple()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  _couple_id UUID;
  _user1_id UUID;
  _user2_id UUID;
BEGIN
  SELECT id, user1_id, user2_id
  INTO _couple_id, _user1_id, _user2_id
  FROM public.couples
  WHERE (user1_id = auth.uid() OR user2_id = auth.uid())
    AND user2_id IS NOT NULL
  LIMIT 1;

  IF _couple_id IS NULL THEN
    RAISE EXCEPTION 'Not in a couple';
  END IF;

  -- Clear partner on both profiles so Realtime and app state stay consistent
  UPDATE public.profiles
  SET partner_id = NULL, updated_at = NOW()
  WHERE id IN (_user1_id, _user2_id);

  -- Delete couple; CASCADE removes calendar_events, period_logs, location_sharing
  DELETE FROM public.couples WHERE id = _couple_id;
END;
$$;

COMMENT ON FUNCTION public.leave_couple() IS 'Leave current couple: clear partner_id on both profiles and delete the couple row.';
