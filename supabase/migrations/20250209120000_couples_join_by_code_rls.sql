-- Allow partners to find and join a couple by pairing code.
-- Without this, the joining user cannot SELECT the row (they are not yet user1/user2),
-- so the app always gets "Code invalide".

-- SELECT: allow reading a couple row when it is joinable (code set, user2 slot empty).
-- The app only looks up by pairing_code, so users only see the row for the code they know.
CREATE POLICY "Users can read couple by pairing code when joinable"
  ON public.couples FOR SELECT
  USING (user2_id IS NULL AND pairing_code IS NOT NULL);

-- UPDATE: allow setting user2_id when the row is joinable (so the current user can join).
CREATE POLICY "User can join couple by code as user2"
  ON public.couples FOR UPDATE
  USING (user2_id IS NULL AND pairing_code IS NOT NULL)
  WITH CHECK (user2_id = auth.uid());
