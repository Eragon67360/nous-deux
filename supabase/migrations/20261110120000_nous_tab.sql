-- The "Nous" tab: days together, countdowns, and little notes (pings).
-- Everything here belongs to a couple and is deleted with it (leave_couple
-- deletes the couple row; the foreign keys cascade).

-- ---------------------------------------------------------------------------
-- 1. Days together
-- ---------------------------------------------------------------------------
ALTER TABLE public.couples ADD COLUMN together_since DATE;

COMMENT ON COLUMN public.couples.together_since IS
  'Start of the relationship, shown as "days together". Set to the pairing day, editable by either partner.';

-- Couples already paired: best guess is the day the couple was created.
UPDATE public.couples
SET together_since = created_at::date
WHERE user2_id IS NOT NULL AND together_since IS NULL;

-- New pairs: the app sends the joiner's local day; if it doesn't, fall back
-- to the server's day. Dates more than a day ahead (a timezone's worth) are
-- refused.
CREATE OR REPLACE FUNCTION public.set_together_since_on_pair()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.user2_id IS NOT NULL
     AND OLD.user2_id IS NULL
     AND NEW.together_since IS NULL THEN
    NEW.together_since := CURRENT_DATE;
  END IF;
  IF NEW.together_since IS DISTINCT FROM OLD.together_since
     AND NEW.together_since > CURRENT_DATE + 1 THEN
    RAISE EXCEPTION 'together_since_in_future' USING ERRCODE = 'P0001';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER couples_together_since
  BEFORE UPDATE ON public.couples
  FOR EACH ROW EXECUTE FUNCTION public.set_together_since_on_pair();

-- ---------------------------------------------------------------------------
-- 2. Countdowns: any calendar event can be counted down to on the Nous tab
-- ---------------------------------------------------------------------------
ALTER TABLE public.calendar_events
  ADD COLUMN is_countdown BOOLEAN NOT NULL DEFAULT false;

COMMENT ON COLUMN public.calendar_events.is_countdown IS
  'Show a countdown to this event on the Nous tab.';

-- ---------------------------------------------------------------------------
-- 3. Little notes (pings): only each person's latest one is kept
-- ---------------------------------------------------------------------------
CREATE TABLE public.couple_pings (
  couple_id UUID NOT NULL REFERENCES public.couples(id) ON DELETE CASCADE,
  sender_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  kind TEXT NOT NULL CHECK (
    kind IN ('thinking_of_you', 'good_night', 'on_my_way', 'miss_you', 'kiss')
  ),
  sent_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (couple_id, sender_id)
);

COMMENT ON TABLE public.couple_pings IS
  'Latest little note per person in a couple. No history: each send replaces the row.';

ALTER TABLE public.couple_pings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Couple members can read their couple's pings"
  ON public.couple_pings FOR SELECT
  USING (couple_id IN (SELECT public.my_couple_ids()));

-- No INSERT/UPDATE/DELETE policies: send_ping() is the only way to write,
-- so the couple check and the 30-second limit cannot be skipped.
CREATE OR REPLACE FUNCTION public.send_ping(p_kind TEXT)
RETURNS public.couple_pings
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  _couple_id UUID;
  _row public.couple_pings;
BEGIN
  IF p_kind IS NULL OR p_kind NOT IN
     ('thinking_of_you', 'good_night', 'on_my_way', 'miss_you', 'kiss') THEN
    RAISE EXCEPTION 'invalid_kind' USING ERRCODE = 'P0001';
  END IF;

  SELECT id INTO _couple_id
  FROM public.couples
  WHERE (user1_id = auth.uid() OR user2_id = auth.uid())
    AND user2_id IS NOT NULL
  LIMIT 1;

  IF _couple_id IS NULL THEN
    RAISE EXCEPTION 'not_paired' USING ERRCODE = 'P0001';
  END IF;

  -- One atomic statement, so two quick taps cannot both get through: the
  -- update only happens when the previous note is at least 30 seconds old.
  INSERT INTO public.couple_pings AS p (couple_id, sender_id, kind, sent_at)
  VALUES (_couple_id, auth.uid(), p_kind, NOW())
  ON CONFLICT (couple_id, sender_id) DO UPDATE
    SET kind = EXCLUDED.kind, sent_at = EXCLUDED.sent_at
    WHERE p.sent_at <= NOW() - INTERVAL '30 seconds'
  RETURNING * INTO _row;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'cooldown' USING ERRCODE = 'P0001';
  END IF;

  RETURN _row;
END;
$$;

-- Supabase grants new tables and functions to anon and authenticated by
-- default. Signed-out callers get nothing; signed-in ones may only read the
-- table and call the function.
REVOKE ALL ON FUNCTION public.send_ping(TEXT) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.send_ping(TEXT) TO authenticated;
REVOKE ALL ON TABLE public.couple_pings FROM anon;
REVOKE INSERT, UPDATE, DELETE, TRUNCATE ON TABLE public.couple_pings FROM authenticated;

COMMENT ON FUNCTION public.send_ping(TEXT) IS
  'Send a little note to your partner: one of five kinds, at most every 30 seconds.';

-- The open app shows a received note immediately.
ALTER PUBLICATION supabase_realtime ADD TABLE public.couple_pings;
