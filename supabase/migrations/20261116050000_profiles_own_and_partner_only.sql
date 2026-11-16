-- Profiles: your own and your partner's, nobody else's (security review of
-- 2026-11-15, F2, with F4 and the shares_*() part of F5).
--
-- Before: "partner" meant profiles.partner_id, a column everyone could write
-- on their own row. Pointing it at any user id made that person's profile
-- readable (name, gender, cycle tracking and consent time, push token, and
-- their partner's id, so the whole couple graph could be walked). The avatars
-- bucket listed every user id to anyone, and shares_cycle() and
-- shares_checkins() answered about anyone.
--
-- Now the partner comes from couples, clients can no longer write partner_id
-- (only the pairing, leave and delete functions do), signed-out callers get
-- nothing from profiles, and avatar folders can only be listed by their owner.
-- Every app build writes only the columns granted below, so none breaks.

-- ---------------------------------------------------------------------------
-- 1. The partner is the other member of your paired couple. The guard trigger
--    keeps a signed-in person in one paired couple (migration 20261115300000).
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.my_partner_id()
RETURNS UUID
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT CASE WHEN user1_id = auth.uid() THEN user2_id ELSE user1_id END
  FROM public.couples
  WHERE (user1_id = auth.uid() OR user2_id = auth.uid())
    AND user2_id IS NOT NULL
  ORDER BY created_at
  LIMIT 1
$$;

-- ---------------------------------------------------------------------------
-- 2. What clients may write on their own profile: what the app edits.
--    partner_id, cycle_consent_at and the timestamps are set by the database.
--    id stays writable for the app's upsert; RLS pins it to auth.uid().
-- ---------------------------------------------------------------------------
REVOKE ALL ON TABLE public.profiles FROM anon;
REVOKE INSERT, UPDATE, DELETE, TRUNCATE ON TABLE public.profiles FROM authenticated;
GRANT INSERT (id, username, gender, language, avatar_url, fcm_token,
              tracks_cycle, share_cycle, share_checkins, onboarding_completed_at),
      UPDATE (id, username, gender, language, avatar_url, fcm_token,
              tracks_cycle, share_cycle, share_checkins, onboarding_completed_at)
  ON TABLE public.profiles TO authenticated;

-- ---------------------------------------------------------------------------
-- 3. Sharing switches: answered only about yourself and your partner (the
--    partner policies only ask about the partner).
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.shares_cycle(owner UUID)
RETURNS BOOLEAN AS $$
  SELECT COALESCE((
    SELECT share_cycle FROM public.profiles
    WHERE id = owner AND owner IN (auth.uid(), public.my_partner_id())
  ), FALSE)
$$ LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public;

CREATE OR REPLACE FUNCTION public.shares_checkins(owner UUID)
RETURNS BOOLEAN AS $$
  SELECT COALESCE((
    SELECT share_checkins FROM public.profiles
    WHERE id = owner AND owner IN (auth.uid(), public.my_partner_id())
  ), FALSE)
$$ LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public;

-- ---------------------------------------------------------------------------
-- 4. Avatars: the bucket stays public, so photos load from their URL as
--    before (that needs no policy). Listing, which gave every user id, is
--    limited to your own folder: the app lists it when deleting the account,
--    and re-uploading your photo needs it.
-- ---------------------------------------------------------------------------
DROP POLICY "Avatars are publicly readable" ON storage.objects;
CREATE POLICY "Users can list own avatar folder"
ON storage.objects FOR SELECT
TO authenticated
USING (
  bucket_id = 'avatars'
  AND (storage.foldername(name))[1] = auth.uid()::text
);
