-- Enable RLS on all tables
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.couples ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.calendar_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.period_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.location_sharing ENABLE ROW LEVEL SECURITY;

-- Helper: current user's profile partner_id
CREATE OR REPLACE FUNCTION public.my_partner_id()
RETURNS UUID AS $$
  SELECT partner_id FROM public.profiles WHERE id = auth.uid()
$$ LANGUAGE sql STABLE SECURITY DEFINER;

-- Helper: couple ids the current user belongs to
CREATE OR REPLACE FUNCTION public.my_couple_ids()
RETURNS SETOF UUID AS $$
  SELECT id FROM public.couples WHERE user1_id = auth.uid() OR user2_id = auth.uid()
$$ LANGUAGE sql STABLE SECURITY DEFINER;

-- ---------- profiles ----------
CREATE POLICY "Users can read own profile"
  ON public.profiles FOR SELECT
  USING (id = auth.uid());

CREATE POLICY "Users can read partner profile"
  ON public.profiles FOR SELECT
  USING (id = public.my_partner_id());

CREATE POLICY "Users can update own profile"
  ON public.profiles FOR UPDATE
  USING (id = auth.uid());

CREATE POLICY "Users can insert own profile"
  ON public.profiles FOR INSERT
  WITH CHECK (id = auth.uid());

-- ---------- couples ----------
CREATE POLICY "Users can read own couple"
  ON public.couples FOR SELECT
  USING (user1_id = auth.uid() OR user2_id = auth.uid());

CREATE POLICY "User can create couple as user1 (when not already in a couple)"
  ON public.couples FOR INSERT
  WITH CHECK (
    user1_id = auth.uid()
    AND NOT EXISTS (SELECT 1 FROM public.couples c WHERE c.user1_id = auth.uid() OR c.user2_id = auth.uid())
  );

CREATE POLICY "User can update couple to join as user2"
  ON public.couples FOR UPDATE
  USING (user2_id = auth.uid() OR user1_id = auth.uid())
  WITH CHECK (user1_id = auth.uid() OR user2_id = auth.uid());

-- ---------- calendar_events ----------
CREATE POLICY "Couple members can manage calendar events"
  ON public.calendar_events FOR ALL
  USING (couple_id IN (SELECT public.my_couple_ids()))
  WITH CHECK (couple_id IN (SELECT public.my_couple_ids()));

-- ---------- period_logs ----------
CREATE POLICY "Users can manage own period logs"
  ON public.period_logs FOR ALL
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can read partner period logs in same couple"
  ON public.period_logs FOR SELECT
  USING (
    couple_id IN (SELECT public.my_couple_ids())
    AND user_id = public.my_partner_id()
  );

-- ---------- location_sharing ----------
CREATE POLICY "Users can read and update own location row"
  ON public.location_sharing FOR ALL
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can read partner location when in same couple"
  ON public.location_sharing FOR SELECT
  USING (
    couple_id IN (SELECT public.my_couple_ids())
    AND user_id = public.my_partner_id()
  );

-- ---------- Triggers: updated_at ----------
CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER profiles_updated_at
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER couples_updated_at
  BEFORE UPDATE ON public.couples
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER calendar_events_updated_at
  BEFORE UPDATE ON public.calendar_events
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER period_logs_updated_at
  BEFORE UPDATE ON public.period_logs
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER location_sharing_updated_at
  BEFORE UPDATE ON public.location_sharing
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- Create profile on signup (call from Supabase Auth hook or client after first sign-in)
-- Alternatively use Database Webhook or Edge Function; for PoC we create from client after sign-in.
