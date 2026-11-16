-- Own words: testers asked to write their own little notes and their own
-- daily states. A little note can now be a short text (kind 'custom'), and a
-- check-in can hold states written by the person next to the preset keys.
-- Older app builds keep working: send_ping('kiss') is still a valid call,
-- and the preset keys are still valid states.

-- ---------------------------------------------------------------------------
-- 1. Little notes: the five kinds, or a short text of your own.
--    Still one row per person (couple_pings_couple_sender_key): a new note
--    replaces the last one, text included.
-- ---------------------------------------------------------------------------
ALTER TABLE public.couple_pings ADD COLUMN text TEXT;

ALTER TABLE public.couple_pings DROP CONSTRAINT couple_pings_kind_check;
ALTER TABLE public.couple_pings ADD CONSTRAINT couple_pings_kind_check CHECK (
  kind IN ('thinking_of_you', 'good_night', 'on_my_way', 'miss_you', 'kiss', 'custom')
);

-- A written note has a text, a preset one never does.
ALTER TABLE public.couple_pings ADD CONSTRAINT couple_pings_text_iff_custom CHECK (
  (kind = 'custom') = (text IS NOT NULL)
);

-- One short line: 1 to 40 characters, no spaces around, no line breaks or
-- other control characters.
ALTER TABLE public.couple_pings ADD CONSTRAINT couple_pings_text_valid CHECK (
  text IS NULL OR (
    char_length(text) BETWEEN 1 AND 40
    AND text = btrim(text)
    AND text !~ '[[:cntrl:]]'
  )
);

COMMENT ON COLUMN public.couple_pings.text IS
  'The words of a note the sender wrote (kind custom), 1 to 40 characters; null for the five preset kinds. Never put in a push notification.';

-- p_text is a new, optional argument: older builds call send_ping with
-- p_kind only, and PostgREST finds this function for them. The one-argument
-- version goes first, so there is a single send_ping and no ambiguous call.
DROP FUNCTION public.send_ping(TEXT);

CREATE FUNCTION public.send_ping(p_kind TEXT, p_text TEXT DEFAULT NULL)
RETURNS public.couple_pings
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  _couple_id UUID;
  _text TEXT;
  _row public.couple_pings;
BEGIN
  IF p_kind IS NULL OR p_kind NOT IN
     ('thinking_of_you', 'good_night', 'on_my_way', 'miss_you', 'kiss', 'custom') THEN
    RAISE EXCEPTION 'invalid_kind' USING ERRCODE = 'P0001';
  END IF;

  -- A written note keeps its words without the spaces around them. A preset
  -- one stores no text, whatever was sent with it.
  IF p_kind = 'custom' THEN
    _text := btrim(p_text);
    IF _text IS NULL
       OR char_length(_text) NOT BETWEEN 1 AND 40
       OR _text ~ '[[:cntrl:]]' THEN
      RAISE EXCEPTION 'invalid_text' USING ERRCODE = 'P0001';
    END IF;
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
  -- update only happens when the previous note, of any kind, is at least 30
  -- seconds old.
  INSERT INTO public.couple_pings AS p (couple_id, sender_id, kind, text, sent_at)
  VALUES (_couple_id, auth.uid(), p_kind, _text, NOW())
  ON CONFLICT (couple_id, sender_id) DO UPDATE
    SET kind = EXCLUDED.kind, text = EXCLUDED.text, sent_at = EXCLUDED.sent_at
    WHERE p.sent_at <= NOW() - INTERVAL '30 seconds'
  RETURNING * INTO _row;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'cooldown' USING ERRCODE = 'P0001';
  END IF;

  RETURN _row;
END;
$$;

-- Same grants as before: signed-out callers get nothing, signed-in ones may
-- call it. The table stays read-only for clients.
REVOKE ALL ON FUNCTION public.send_ping(TEXT, TEXT) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.send_ping(TEXT, TEXT) TO authenticated;

COMMENT ON FUNCTION public.send_ping(TEXT, TEXT) IS
  'Send a little note to your partner: one of five kinds, or custom with p_text (1 to 40 characters once trimmed, one line). At most every 30 seconds, whatever the kind.';

-- ---------------------------------------------------------------------------
-- 2. Daily check-ins: next to the preset keys (cramps, headache, acne, pain,
--    bloating), states the person writes, stored as their plain text in the
--    same array. The app writes check-ins directly under RLS, so the table
--    checks the shape: at most 12 states, each 1 to 30 characters, no spaces
--    around, no line breaks or other control characters.
-- ---------------------------------------------------------------------------
CREATE FUNCTION private.valid_checkin_states(states TEXT[])
RETURNS BOOLEAN
LANGUAGE sql
IMMUTABLE
PARALLEL SAFE
SET search_path = ''
AS $$
  SELECT states IS NOT NULL
    AND coalesce(array_ndims(states), 1) = 1
    AND cardinality(states) <= 12
    AND NOT EXISTS (
      SELECT 1
      FROM unnest(states) AS s(state)
      WHERE state IS NULL
         OR char_length(state) NOT BETWEEN 1 AND 30
         OR state <> btrim(state)
         OR state ~ '[[:cntrl:]]'
    )
$$;

-- A CHECK runs its function as whoever writes the row, so the app's role
-- needs EXECUTE (the private schema itself stays closed to it).
REVOKE ALL ON FUNCTION private.valid_checkin_states(TEXT[]) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION private.valid_checkin_states(TEXT[]) TO authenticated, service_role;

COMMENT ON FUNCTION private.valid_checkin_states(TEXT[]) IS
  'Shape of cycle_checkins.symptoms: at most 12 states, each 1 to 30 characters, trimmed, one line.';

ALTER TABLE public.cycle_checkins ADD CONSTRAINT cycle_checkins_symptoms_valid CHECK (
  private.valid_checkin_states(symptoms)
);

COMMENT ON COLUMN public.cycle_checkins.symptoms IS
  'States of the day: preset keys (cramps, headache, acne, pain, bloating) or the words the person wrote, at most 12 of 1 to 30 characters. Read by the partner only while share_checkins is on.';
