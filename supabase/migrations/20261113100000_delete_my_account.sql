-- Account deletion from the app, which both app stores require.
-- One call removes the caller's account and every row tied to it.
--
-- Leaving comes first, because the foreign keys alone would get it wrong:
-- the partner's profiles.partner_id has no ON DELETE action (the delete
-- would fail), and a couple whose user2 deletes their account would survive
-- with user2_id set to NULL, keeping everything the two shared.
--
-- The avatar file is not covered here: Storage refuses direct deletes from
-- storage.objects, so the app removes it through the Storage API first.
CREATE OR REPLACE FUNCTION public.delete_my_account()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  _me UUID := auth.uid();
BEGIN
  IF _me IS NULL THEN
    RAISE EXCEPTION 'Not signed in' USING ERRCODE = '42501';
  END IF;

  -- Same as leave_couple(): unlink both profiles, then delete the couple,
  -- which cascades to the calendar, cycle, positions, lists and notes.
  UPDATE public.profiles
  SET partner_id = NULL, updated_at = NOW()
  WHERE id = _me OR partner_id = _me;

  DELETE FROM public.couples WHERE user1_id = _me OR user2_id = _me;

  -- The profile and the caller's remaining rows (cycle notes, sign-in
  -- identities and sessions) go with the auth user through ON DELETE CASCADE.
  DELETE FROM auth.users WHERE id = _me;
END;
$$;

COMMENT ON FUNCTION public.delete_my_account() IS
  'Delete the caller''s account: leave the couple (shared data is deleted for both), then remove the auth user and everything that cascades from it.';

REVOKE ALL ON FUNCTION public.delete_my_account() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.delete_my_account() TO authenticated;
