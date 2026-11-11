-- Règles redesign: who tracks a cycle, what the partner may see, daily
-- check-ins and private notes.

-- 1. Settings on the profile. tracks_cycle stays null until the person is
--    asked; both switches default to sharing, as the tab did before.
ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS tracks_cycle BOOLEAN,
  ADD COLUMN IF NOT EXISTS share_cycle BOOLEAN NOT NULL DEFAULT TRUE,
  ADD COLUMN IF NOT EXISTS share_checkins BOOLEAN NOT NULL DEFAULT TRUE;

COMMENT ON COLUMN public.profiles.tracks_cycle IS
  'Whether this person tracks a cycle in the app; null until asked.';
COMMENT ON COLUMN public.profiles.share_cycle IS
  'The partner may read this person''s period dates (day, phase, expected date).';
COMMENT ON COLUMN public.profiles.share_checkins IS
  'The partner may read this person''s daily check-ins (how they feel, mood).';

-- Read by the partner policies below. SECURITY DEFINER so a policy on one
-- table can read the owner's setting without going through profiles' RLS.
CREATE OR REPLACE FUNCTION public.shares_cycle(owner UUID)
RETURNS BOOLEAN AS $$
  SELECT COALESCE((SELECT share_cycle FROM public.profiles WHERE id = owner), FALSE)
$$ LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public;

CREATE OR REPLACE FUNCTION public.shares_checkins(owner UUID)
RETURNS BOOLEAN AS $$
  SELECT COALESCE((SELECT share_checkins FROM public.profiles WHERE id = owner), FALSE)
$$ LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public;

REVOKE ALL ON FUNCTION public.shares_cycle(UUID) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.shares_checkins(UUID) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.shares_cycle(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.shares_checkins(UUID) TO authenticated;

-- 2. The partner reads period dates only while they are shared.
DROP POLICY IF EXISTS "Users can read partner period logs in same couple"
  ON public.period_logs;
CREATE POLICY "Users can read partner period logs in same couple"
  ON public.period_logs FOR SELECT
  USING (
    couple_id IN (SELECT public.my_couple_ids())
    AND user_id = public.my_partner_id()
    AND public.shares_cycle(user_id)
  );

-- 3. Daily check-ins: how the day feels, one row per person and day.
CREATE TABLE public.cycle_checkins (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  couple_id UUID NOT NULL REFERENCES public.couples(id) ON DELETE CASCADE,
  day DATE NOT NULL,
  symptoms TEXT[] NOT NULL DEFAULT '{}',
  mood TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT cycle_checkins_one_per_day UNIQUE (user_id, day)
);

CREATE INDEX idx_cycle_checkins_couple_id ON public.cycle_checkins(couple_id);

CREATE TRIGGER cycle_checkins_updated_at
  BEFORE UPDATE ON public.cycle_checkins
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

ALTER TABLE public.cycle_checkins ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Owner manages own check-ins"
  ON public.cycle_checkins FOR ALL
  USING (user_id = auth.uid())
  WITH CHECK (
    user_id = auth.uid()
    AND couple_id IN (SELECT public.my_couple_ids())
  );

CREATE POLICY "Partner reads shared check-ins"
  ON public.cycle_checkins FOR SELECT
  USING (
    couple_id IN (SELECT public.my_couple_ids())
    AND user_id = public.my_partner_id()
    AND public.shares_checkins(user_id)
  );

REVOKE ALL ON TABLE public.cycle_checkins FROM anon;
REVOKE TRUNCATE ON TABLE public.cycle_checkins FROM authenticated;

ALTER PUBLICATION supabase_realtime ADD TABLE public.cycle_checkins;

COMMENT ON TABLE public.cycle_checkins IS
  'One check-in per person and day; the partner reads it while share_checkins is on.';

-- 4. Private notes: only their author can read them, whatever is shared.
--    No couple_id, so leaving a couple keeps them.
CREATE TABLE public.cycle_notes (
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  day DATE NOT NULL,
  note TEXT NOT NULL CHECK (length(note) BETWEEN 1 AND 2000),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (user_id, day)
);

CREATE TRIGGER cycle_notes_updated_at
  BEFORE UPDATE ON public.cycle_notes
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

ALTER TABLE public.cycle_notes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Only the author reads and writes notes"
  ON public.cycle_notes FOR ALL
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

REVOKE ALL ON TABLE public.cycle_notes FROM anon;
REVOKE TRUNCATE ON TABLE public.cycle_notes FROM authenticated;

COMMENT ON TABLE public.cycle_notes IS 'Private notes; never readable by the partner.';

-- 5. period_logs keeps only the dates. Its notes were readable by the
--    partner: they move to cycle_notes, and mood and symptoms become the
--    check-in of the start day.
INSERT INTO public.cycle_notes (user_id, day, note)
SELECT user_id, start_date, left(btrim(notes), 2000)
FROM public.period_logs
WHERE COALESCE(btrim(notes), '') <> ''
ON CONFLICT (user_id, day) DO NOTHING;

INSERT INTO public.cycle_checkins (user_id, couple_id, day, symptoms, mood)
SELECT user_id, couple_id, start_date, COALESCE(symptoms, '{}'), mood
FROM public.period_logs
WHERE mood IS NOT NULL OR COALESCE(array_length(symptoms, 1), 0) > 0
ON CONFLICT (user_id, day) DO NOTHING;

UPDATE public.period_logs
SET notes = NULL, mood = NULL, symptoms = '{}'
WHERE notes IS NOT NULL
   OR mood IS NOT NULL
   OR COALESCE(array_length(symptoms, 1), 0) > 0;

-- Nothing but dates can land where the partner reads: notes go to
-- cycle_notes, how the day feels to cycle_checkins (shared only by choice).
ALTER TABLE public.period_logs
  ADD CONSTRAINT period_logs_dates_only CHECK (
    notes IS NULL
    AND mood IS NULL
    AND COALESCE(array_length(symptoms, 1), 0) = 0
  );
