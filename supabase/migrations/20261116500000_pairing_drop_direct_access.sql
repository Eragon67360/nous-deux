-- Pairing, step 2 (security review of 2026-11-15, F1). Apply once the app
-- builds that call create_couple() and join_couple() (migration
-- 20261115300000) are the ones testers run: older builds can no longer
-- create or join a couple after this.
--
-- Waiting couples were readable by anyone, signed out included, and joinable
-- by any signed-in person without the code. Now a couple is visible only to
-- its members, and only the two functions create or join one.

DROP POLICY "Users can read couple by pairing code when joinable" ON public.couples;
DROP POLICY "User can join couple by code as user2" ON public.couples;
DROP POLICY "User can create couple as user1 (when not already in a couple)" ON public.couples;

-- Members still read their couple and edit together_since (the remaining
-- policies); nobody else gets anything, signed out or not.
REVOKE ALL ON TABLE public.couples FROM anon;
REVOKE INSERT, DELETE, TRUNCATE ON TABLE public.couples FROM authenticated;
