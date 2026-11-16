-- The remaining findings of the security review of 2026-11-15 that the
-- database can fix on its own (F5, F6, F7 and part of F9). Every app build
-- keeps working: nothing here changes what the app sends or reads.

-- ---------------------------------------------------------------------------
-- F5. Rows belong to the caller's couple, and events keep their author.
--     Period logs and the location row could be filed under any couple's id,
--     and a partner could create calendar events signed as the other person.
-- ---------------------------------------------------------------------------
DROP POLICY "Users can manage own period logs" ON public.period_logs;
CREATE POLICY "Users can manage own period logs"
  ON public.period_logs FOR ALL
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid() AND couple_id IN (SELECT public.my_couple_ids()));

DROP POLICY "Users can read and update own location row" ON public.location_sharing;
CREATE POLICY "Users can read and update own location row"
  ON public.location_sharing FOR ALL
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid() AND couple_id IN (SELECT public.my_couple_ids()));

-- The author of an event is whoever created it, and stays so when the
-- partner edits it (the same rule as shared_lists_keep_owner).
CREATE OR REPLACE FUNCTION public.calendar_events_keep_author()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    NEW.created_by := COALESCE(auth.uid(), NEW.created_by);
  ELSE
    NEW.created_by := OLD.created_by;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SET search_path = public;

REVOKE ALL ON FUNCTION public.calendar_events_keep_author() FROM PUBLIC, anon, authenticated;

CREATE TRIGGER calendar_events_keep_author
  BEFORE INSERT OR UPDATE ON public.calendar_events
  FOR EACH ROW EXECUTE FUNCTION public.calendar_events_keep_author();

-- ---------------------------------------------------------------------------
-- F6. The last SECURITY DEFINER functions without a fixed search_path, and
--     what signed-out callers still had from Supabase's default grants.
-- ---------------------------------------------------------------------------
ALTER FUNCTION public.my_couple_ids() SET search_path = public;
ALTER FUNCTION public.on_couple_paired() SET search_path = public;

REVOKE ALL ON TABLE public.calendar_events, public.period_logs, public.location_sharing FROM anon;
REVOKE TRUNCATE ON TABLE public.calendar_events, public.period_logs, public.location_sharing, public.couples FROM authenticated;
-- The policies that call these run for signed-in callers only now.
REVOKE ALL ON FUNCTION public.my_couple_ids(), public.my_partner_id() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.my_couple_ids(), public.my_partner_id() TO authenticated;

-- ---------------------------------------------------------------------------
-- F7. Realtime sends every DELETE to every subscriber of a table, with the
--     row's primary key only (RLS can't be checked on a deleted row). These
--     two tables were keyed by who they belong to, so deleting a couple told
--     anyone listening who had been paired with whom. They get a random id as
--     primary key; the old key stays unique, so send_ping() and the app's
--     lookups by user work as before.
-- ---------------------------------------------------------------------------
ALTER TABLE public.couple_pings ADD COLUMN id UUID NOT NULL DEFAULT gen_random_uuid();
ALTER TABLE public.couple_pings DROP CONSTRAINT couple_pings_pkey;
ALTER TABLE public.couple_pings ADD PRIMARY KEY (id);
ALTER TABLE public.couple_pings ADD CONSTRAINT couple_pings_couple_sender_key UNIQUE (couple_id, sender_id);

ALTER TABLE public.location_sharing ADD COLUMN id UUID NOT NULL DEFAULT gen_random_uuid();
ALTER TABLE public.location_sharing DROP CONSTRAINT location_sharing_pkey;
ALTER TABLE public.location_sharing ADD PRIMARY KEY (id);
ALTER TABLE public.location_sharing ADD CONSTRAINT location_sharing_user_key UNIQUE (user_id);

-- ---------------------------------------------------------------------------
-- F9. Bounded inputs.
-- ---------------------------------------------------------------------------
-- The display name goes into the partner's notifications: keep it a name.
ALTER TABLE public.profiles
  ADD CONSTRAINT profiles_username_length CHECK (char_length(username) <= 50);

-- Each call to save_apple_authorization() makes the server call Apple with
-- our key. One call per account per minute is plenty for a sign-in, and
-- keeps a loop from getting the app throttled by Apple (revocations would
-- then fail). The time of the last call is kept that minute only.
CREATE TABLE private.apple_authorization_calls (
  user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_apple_authorization_calls_at ON private.apple_authorization_calls(at);
REVOKE ALL ON private.apple_authorization_calls FROM PUBLIC;

CREATE OR REPLACE FUNCTION public.save_apple_authorization(code TEXT)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  _me UUID := auth.uid();
  _apple_sub TEXT;
BEGIN
  IF _me IS NULL THEN
    RAISE EXCEPTION 'Not signed in' USING ERRCODE = '42501';
  END IF;
  IF code IS NULL OR length(code) NOT BETWEEN 1 AND 1000 THEN
    RAISE EXCEPTION 'Invalid authorization code' USING ERRCODE = '22023';
  END IF;

  SELECT provider_id INTO _apple_sub
  FROM auth.identities
  WHERE user_id = _me AND provider = 'apple';
  IF _apple_sub IS NULL THEN
    RAISE EXCEPTION 'Not signed in with Apple' USING ERRCODE = '42501';
  END IF;

  -- At most one call to Apple per minute: another one is skipped quietly
  -- (the app never lets this call fail a sign-in anyway). One at a time per
  -- account, so parallel calls share the limit.
  PERFORM pg_advisory_xact_lock(hashtextextended('save_apple_authorization:' || _me, 0));
  DELETE FROM private.apple_authorization_calls WHERE at < NOW() - INTERVAL '1 minute';
  IF EXISTS (SELECT 1 FROM private.apple_authorization_calls WHERE user_id = _me) THEN
    RETURN;
  END IF;

  IF private.call_apple_tokens(jsonb_build_object(
    'type', 'exchange',
    'user_id', _me,
    'apple_sub', _apple_sub,
    'code', code
  )) THEN
    INSERT INTO private.apple_authorization_calls (user_id) VALUES (_me);
  END IF;
END;
$$;
