-- Close a hole in the couples UPDATE policies: its WITH CHECK only required
-- the caller to stay a member, so user1 could set user2_id to any profile id
-- and pair that person without their consent (on_couple_paired then links
-- both profiles). Membership rows can now change only in the ways the app
-- uses: someone joins as user2 themselves. Other columns stay editable.
-- Server-side callers without a user (service role, SQL editor) are not
-- restricted.
CREATE OR REPLACE FUNCTION public.couples_guard_members()
RETURNS TRIGGER AS $$
BEGIN
  IF auth.uid() IS NULL THEN
    RETURN NEW;
  END IF;

  IF NEW.user1_id IS DISTINCT FROM OLD.user1_id THEN
    RAISE EXCEPTION 'couple_member_change_refused' USING ERRCODE = '42501';
  END IF;

  IF NEW.user2_id IS DISTINCT FROM OLD.user2_id
     AND NOT (OLD.user2_id IS NULL AND NEW.user2_id = auth.uid()) THEN
    RAISE EXCEPTION 'couple_member_change_refused' USING ERRCODE = '42501';
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER couples_guard_members
  BEFORE UPDATE ON public.couples
  FOR EACH ROW EXECUTE FUNCTION public.couples_guard_members();
