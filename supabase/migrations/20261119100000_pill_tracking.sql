-- Pill tracking (docs/PILL.md). Someone who takes a hormonal pill keeps
-- its settings and a row per day here; the app reminds them on the phone.
-- It is health data, like the cycle: nothing exists until they say yes,
-- which records when (consent_at). Their partner learns only whether a pill
-- is expected today and whether it is ticked: never a missed day, older
-- days, the pack or the time.

-- ---------------------------------------------------------------------------
-- 1. The settings, one row per person who tracks. Only they read or write
--    it. Its creation is the consent; the database sets the time.
-- ---------------------------------------------------------------------------
CREATE TABLE public.pill_tracking (
  user_id UUID PRIMARY KEY REFERENCES public.profiles(id) ON DELETE CASCADE,
  pack_type TEXT NOT NULL CHECK (pack_type IN ('21_7', '28', 'continuous')),
  -- Day 1 of a pack (any one: the schedule repeats from it).
  pack_started_on DATE NOT NULL,
  reminder_on BOOLEAN NOT NULL DEFAULT TRUE,
  reminder_time TIME NOT NULL DEFAULT '21:00',
  -- What the lock screen shows: 'clear' names the pill, 'discreet' doesn't.
  reminder_text TEXT NOT NULL DEFAULT 'discreet' CHECK (reminder_text IN ('clear', 'discreet')),
  share_with_partner BOOLEAN NOT NULL DEFAULT TRUE,
  -- The phone's zone (IANA name): "today" for the partner's line is today
  -- where this person is.
  time_zone TEXT NOT NULL DEFAULT 'UTC',
  consent_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

COMMENT ON TABLE public.pill_tracking IS
  'Pill tracking settings (health data). Owner only; created on consent, deleted by stop_pill_tracking().';

CREATE TRIGGER pill_tracking_updated_at BEFORE UPDATE ON public.pill_tracking
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

ALTER TABLE public.pill_tracking ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE public.pill_tracking FROM PUBLIC, anon, authenticated;
-- consent_at and the timestamps are the database's. user_id stays writable
-- for the app's upsert; RLS pins it to the caller.
GRANT SELECT, DELETE ON TABLE public.pill_tracking TO authenticated;
GRANT INSERT (user_id, pack_type, pack_started_on, reminder_on, reminder_time, reminder_text, share_with_partner, time_zone),
      UPDATE (user_id, pack_type, pack_started_on, reminder_on, reminder_time, reminder_text, share_with_partner, time_zone)
  ON TABLE public.pill_tracking TO authenticated;
GRANT ALL ON TABLE public.pill_tracking TO service_role;

CREATE POLICY "Own pill settings"
ON public.pill_tracking FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- Today where [owner] is (their pill_tracking zone), for the partner's
-- line; an unknown zone counts as UTC.
CREATE FUNCTION public.pill_today_for(owner UUID)
RETURNS DATE
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  _zone TEXT;
BEGIN
  SELECT time_zone INTO _zone FROM public.pill_tracking WHERE user_id = owner;
  BEGIN
    RETURN (now() AT TIME ZONE COALESCE(_zone, 'UTC'))::date;
  EXCEPTION WHEN invalid_parameter_value THEN
    RETURN (now() AT TIME ZONE 'UTC')::date;
  END;
END;
$$;
REVOKE ALL ON FUNCTION public.pill_today_for(UUID) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.pill_today_for(UUID) TO authenticated;

-- ---------------------------------------------------------------------------
-- 2. One row per day: taken (with its time) or missed. Only while tracking:
--    the rows go with the settings. The partner reads today's ticked pill
--    (so the app's Realtime hears the tick), today being the owner's, and
--    only while it is shared.
-- ---------------------------------------------------------------------------
CREATE TABLE public.pill_intakes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.pill_tracking(user_id) ON DELETE CASCADE,
  day DATE NOT NULL,
  status TEXT NOT NULL CHECK (status IN ('taken', 'missed')),
  taken_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (user_id, day),
  CHECK ((status = 'taken') = (taken_at IS NOT NULL))
);

COMMENT ON TABLE public.pill_intakes IS
  'One row per day of pill tracking (health data). The partner reads only ticked pills of the last two days, while shared.';

ALTER TABLE public.pill_intakes ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE public.pill_intakes FROM PUBLIC, anon, authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.pill_intakes TO authenticated;
GRANT ALL ON TABLE public.pill_intakes TO service_role;

-- Whether [owner] shares their pill with the caller: only about yourself and
-- your partner, like shares_cycle().
CREATE FUNCTION public.shares_pill(owner UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT COALESCE((
    SELECT share_with_partner FROM public.pill_tracking
    WHERE user_id = owner AND owner IN (auth.uid(), public.my_partner_id())
  ), FALSE)
$$;
REVOKE ALL ON FUNCTION public.shares_pill(UUID) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.shares_pill(UUID) TO authenticated;

CREATE POLICY "Own pill days"
ON public.pill_intakes FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (
  user_id = auth.uid()
  AND EXISTS (SELECT 1 FROM public.pill_tracking WHERE user_id = auth.uid())
);

CREATE POLICY "Partner sees today's ticked pill"
ON public.pill_intakes FOR SELECT
TO authenticated
USING (
  user_id = public.my_partner_id()
  AND status = 'taken'
  AND day = public.pill_today_for(user_id)
  AND public.shares_pill(user_id)
);

ALTER PUBLICATION supabase_realtime ADD TABLE public.pill_intakes;

-- ---------------------------------------------------------------------------
-- 3. The pack: whether [d] is a pill day. A 21 + 7 pack pauses after pill
--    21 for 7 days; 28 and continuous packs have a pill every day. The app
--    has the same rule (lib/domain/pill/pill_schedule.dart).
-- ---------------------------------------------------------------------------
CREATE FUNCTION public.pill_is_pill_day(pack_type TEXT, started_on DATE, d DATE)
RETURNS BOOLEAN
LANGUAGE sql
IMMUTABLE
SET search_path = public
AS $$
  SELECT CASE
    WHEN pack_type = '21_7' THEN (((d - started_on) % 28) + 28) % 28 < 21
    ELSE TRUE
  END
$$;
REVOKE ALL ON FUNCTION public.pill_is_pill_day(TEXT, DATE, DATE) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.pill_is_pill_day(TEXT, DATE, DATE) TO authenticated;

-- ---------------------------------------------------------------------------
-- 4. The partner's one line, for today where my partner is: whether they
--    track and share, whether a pill is expected today, and when it was
--    ticked. No other day can be asked about.
-- ---------------------------------------------------------------------------
CREATE FUNCTION public.partner_pill_today()
RETURNS TABLE (tracking BOOLEAN, expected BOOLEAN, taken_at TIMESTAMPTZ)
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  WITH shared AS (
    SELECT t.user_id, t.pack_type, t.pack_started_on,
           public.pill_today_for(t.user_id) AS today
    FROM public.pill_tracking t
    WHERE t.user_id = public.my_partner_id()
      AND t.share_with_partner
  )
  SELECT
    shared.user_id IS NOT NULL,
    -- Only for someone who tracks and shares: with no pack, the rule's
    -- "every day" would answer yes.
    shared.user_id IS NOT NULL
      AND public.pill_is_pill_day(shared.pack_type, shared.pack_started_on, shared.today),
    (SELECT i.taken_at FROM public.pill_intakes i
     WHERE i.user_id = shared.user_id AND i.day = shared.today AND i.status = 'taken')
  FROM (SELECT 1) AS one
  LEFT JOIN shared ON TRUE
$$;
REVOKE ALL ON FUNCTION public.partner_pill_today() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.partner_pill_today() TO authenticated;

-- ---------------------------------------------------------------------------
-- 5. « Arrêter le suivi »: the caller's history and settings, both at once.
-- ---------------------------------------------------------------------------
CREATE FUNCTION public.stop_pill_tracking()
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'not signed in' USING ERRCODE = '42501';
  END IF;
  DELETE FROM public.pill_intakes WHERE user_id = auth.uid();
  DELETE FROM public.pill_tracking WHERE user_id = auth.uid();
END;
$$;
REVOKE ALL ON FUNCTION public.stop_pill_tracking() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.stop_pill_tracking() TO authenticated;
