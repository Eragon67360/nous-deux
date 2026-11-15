-- Pairing moves into the database (security review of 2026-11-15, F1 + F3).
--
-- Before: anyone, even signed out, could list every waiting couple with its
-- code (the code was only a filter in the app), and a signed-in stranger could
-- join every one of them in one request. Anyone could also create a couple
-- with someone else as user2, and leave_couple() then picked one of the
-- caller's couples at random.
--
-- Now:
-- - create_couple() makes the invite, with a code drawn by the database.
-- - join_couple(code) joins by exact code, at most 5 wrong codes per account
--   every 10 minutes.
-- - Nobody can be put in a couple by someone else, and a signed-in person
--   can't join a second couple while paired (the guard trigger, also for the
--   direct writes older builds make).
-- - leave_couple() leaves every couple the caller is paired in.
--
-- App builds up to 0.3.5 still read and join waiting couples directly, so the
-- two "joinable" policies stay for now. A later migration drops them once the
-- builds that call join_couple() are out.

-- ---------------------------------------------------------------------------
-- 1. A couple is created empty: the caller as user1, nobody as user2.
-- ---------------------------------------------------------------------------
DROP POLICY "User can create couple as user1 (when not already in a couple)" ON public.couples;
CREATE POLICY "User can create couple as user1 (when not already in a couple)"
  ON public.couples FOR INSERT
  WITH CHECK (
    user1_id = auth.uid()
    AND user2_id IS NULL
    AND NOT EXISTS (SELECT 1 FROM public.couples c WHERE c.user1_id = auth.uid() OR c.user2_id = auth.uid())
  );

-- ---------------------------------------------------------------------------
-- 2. Membership: only joining yourself, and only while not paired elsewhere.
--    (SQL in a row trigger sees the rows the same statement changed before,
--    so one request can't join several couples either.)
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.couples_guard_members()
RETURNS TRIGGER AS $$
BEGIN
  IF auth.uid() IS NULL THEN
    RETURN NEW;
  END IF;

  IF NEW.user1_id IS DISTINCT FROM OLD.user1_id THEN
    RAISE EXCEPTION 'couple_member_change_refused' USING ERRCODE = '42501';
  END IF;

  IF NEW.user2_id IS DISTINCT FROM OLD.user2_id THEN
    IF NOT (OLD.user2_id IS NULL AND NEW.user2_id = auth.uid()) THEN
      RAISE EXCEPTION 'couple_member_change_refused' USING ERRCODE = '42501';
    END IF;
    IF EXISTS (
      SELECT 1 FROM public.couples
      WHERE id <> NEW.id
        AND user2_id IS NOT NULL
        AND (user1_id = auth.uid() OR user2_id = auth.uid())
    ) THEN
      RAISE EXCEPTION 'already_paired' USING ERRCODE = '42501';
    END IF;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SET search_path = public;

-- ---------------------------------------------------------------------------
-- 3. Wrong codes, per account, kept 10 minutes. Deleted with the account.
-- ---------------------------------------------------------------------------
CREATE TABLE private.pairing_failures (
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_pairing_failures_user_at ON private.pairing_failures(user_id, at);
CREATE INDEX idx_pairing_failures_at ON private.pairing_failures(at);
REVOKE ALL ON private.pairing_failures FROM PUBLIC;

-- ---------------------------------------------------------------------------
-- 4. create_couple(): the caller's invite. Returns the waiting couple they
--    already have, or a new one with a fresh code.
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.create_couple()
RETURNS public.couples
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  _me UUID := auth.uid();
  _alphabet CONSTANT TEXT := 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';  -- 32 signs: no bias below
  _random BYTEA;
  _code TEXT;
  _row public.couples;
BEGIN
  IF _me IS NULL THEN
    RAISE EXCEPTION 'Not signed in' USING ERRCODE = '42501';
  END IF;
  -- Two quick taps create one couple.
  PERFORM pg_advisory_xact_lock(hashtextextended('create_couple:' || _me, 0));

  SELECT * INTO _row FROM public.couples
  WHERE user1_id = _me OR user2_id = _me
  ORDER BY (user2_id IS NOT NULL) DESC
  LIMIT 1;
  IF FOUND THEN
    IF _row.user2_id IS NOT NULL THEN
      RAISE EXCEPTION 'already_paired' USING ERRCODE = 'P0001';
    END IF;
    RETURN _row;
  END IF;

  FOR _attempt IN 1..10 LOOP
    -- gen_random_uuid() draws from the server's strong random source; its
    -- first six bytes are fully random.
    _random := uuid_send(gen_random_uuid());
    _code := '';
    FOR i IN 0..5 LOOP
      _code := _code || substr(_alphabet, 1 + get_byte(_random, i) % 32, 1);
    END LOOP;
    BEGIN
      INSERT INTO public.couples (user1_id, pairing_code)
      VALUES (_me, _code)
      RETURNING * INTO _row;
      RETURN _row;
    EXCEPTION WHEN unique_violation THEN
      -- Code taken: draw another.
    END;
  END LOOP;
  RAISE EXCEPTION 'no_free_code' USING ERRCODE = 'P0001';
END;
$$;

-- ---------------------------------------------------------------------------
-- 5. join_couple(code, day): join the couple whose code was typed or scanned.
--    Returns what happened rather than raising, so a wrong code is counted:
--    'joined', 'invalid_code', 'code_used', 'own_code', 'already_paired' or
--    'too_many_attempts'. p_day is the joiner's local day (together_since).
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.join_couple(p_code TEXT, p_day DATE DEFAULT NULL)
RETURNS TEXT
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  _me UUID := auth.uid();
  _code TEXT := upper(btrim(coalesce(p_code, '')));
  _couple public.couples;
BEGIN
  IF _me IS NULL THEN
    RAISE EXCEPTION 'Not signed in' USING ERRCODE = '42501';
  END IF;
  -- One attempt at a time per account, so parallel requests share the limit.
  PERFORM pg_advisory_xact_lock(hashtextextended('join_couple:' || _me, 0));

  DELETE FROM private.pairing_failures WHERE at < NOW() - INTERVAL '10 minutes';
  IF (SELECT count(*) FROM private.pairing_failures WHERE user_id = _me) >= 5 THEN
    RETURN 'too_many_attempts';
  END IF;

  SELECT * INTO _couple FROM public.couples
  WHERE pairing_code = _code AND length(_code) BETWEEN 1 AND 32
  FOR UPDATE;
  IF NOT FOUND THEN
    INSERT INTO private.pairing_failures (user_id) VALUES (_me);
    RETURN 'invalid_code';
  END IF;
  IF _couple.user2_id IS NOT NULL THEN
    INSERT INTO private.pairing_failures (user_id) VALUES (_me);
    RETURN 'code_used';
  END IF;
  IF _couple.user1_id = _me THEN
    RETURN 'own_code';
  END IF;
  IF EXISTS (
    SELECT 1 FROM public.couples
    WHERE user2_id IS NOT NULL AND (user1_id = _me OR user2_id = _me)
  ) THEN
    RETURN 'already_paired';
  END IF;

  -- The triggers link both profiles, set together_since and delete the
  -- joiner's own waiting couple.
  UPDATE public.couples
  SET user2_id = _me, together_since = coalesce(p_day, together_since)
  WHERE id = _couple.id;
  RETURN 'joined';
END;
$$;

REVOKE ALL ON FUNCTION public.create_couple() FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.join_couple(TEXT, DATE) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.create_couple() TO authenticated;
GRANT EXECUTE ON FUNCTION public.join_couple(TEXT, DATE) TO authenticated;

COMMENT ON FUNCTION public.create_couple() IS
  'The caller''s invite: their waiting couple, or a new one with a code drawn by the database.';
COMMENT ON FUNCTION public.join_couple(TEXT, DATE) IS
  'Join the couple with this code. Returns joined, invalid_code, code_used, own_code, already_paired or too_many_attempts (5 wrong codes per 10 minutes).';

-- ---------------------------------------------------------------------------
-- 6. leave_couple(): every couple the caller is paired in, not one at random.
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.leave_couple()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  _me UUID := auth.uid();
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM public.couples
    WHERE (user1_id = _me OR user2_id = _me) AND user2_id IS NOT NULL
  ) THEN
    RAISE EXCEPTION 'Not in a couple';
  END IF;

  -- Clear partner on both profiles so Realtime and app state stay consistent
  UPDATE public.profiles
  SET partner_id = NULL, updated_at = NOW()
  WHERE id IN (
    SELECT unnest(ARRAY[user1_id, user2_id]) FROM public.couples
    WHERE (user1_id = _me OR user2_id = _me) AND user2_id IS NOT NULL
  );

  -- Delete the couples; CASCADE removes everything they shared
  DELETE FROM public.couples
  WHERE (user1_id = _me OR user2_id = _me) AND user2_id IS NOT NULL;
END;
$$;

REVOKE ALL ON FUNCTION public.leave_couple() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.leave_couple() TO authenticated;
