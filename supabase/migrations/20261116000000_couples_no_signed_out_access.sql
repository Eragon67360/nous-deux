-- Signed-out callers keep Supabase's default privileges on public.couples, and
-- the "Users can read couple by pairing code when joinable" policy has no TO
-- clause. So anyone holding the app's public anon key could list every couple
-- waiting for a partner, with its pairing code (security review 2026-11-15, F1).
-- The app only touches couples once signed in, so no released build needs
-- these privileges. Migration 20261116100000 (#90) later drops the joinable
-- policies themselves and repeats this revoke.
REVOKE ALL ON TABLE public.couples FROM anon;
