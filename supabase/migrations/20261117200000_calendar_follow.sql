-- Following a phone calendar (docs/CALENDAR_SYNC.md): the events of the
-- calendars a person follows are copied into the couple's calendar and kept
-- up to date by that person's phone. This migration holds what the server
-- needs for it; the phones do the copying.

-- ---------------------------------------------------------------------------
-- 1. Synced events: source_key ties a copy to its phone event (a SHA-256 of
--    the phone's calendar id, event id and start, so no phone identifier is
--    stored). Null for events written in Nous Deux.
-- ---------------------------------------------------------------------------
ALTER TABLE public.calendar_events
  ADD COLUMN source_key TEXT CHECK (source_key ~ '^[0-9a-f]{64}$');

COMMENT ON COLUMN public.calendar_events.source_key IS
  'For an event copied from a followed phone calendar: SHA-256 (hex) of its phone calendar id, event id and start. Null for events written in Nous Deux.';

CREATE UNIQUE INDEX calendar_events_source_key
  ON public.calendar_events (created_by, source_key)
  WHERE source_key IS NOT NULL;

-- A synced event is changed on its owner's phone, so the partner can only
-- switch its countdown, and can't delete it. Statements a cascade runs
-- (leaving the couple, deleting an account) sit one trigger level deeper
-- and stay allowed.
CREATE OR REPLACE FUNCTION public.calendar_events_synced_rules()
RETURNS TRIGGER AS $$
BEGIN
  IF pg_trigger_depth() = 1
     AND OLD.source_key IS NOT NULL
     AND auth.uid() IS DISTINCT FROM OLD.created_by THEN
    IF TG_OP = 'DELETE'
       OR to_jsonb(NEW) - 'is_countdown' - 'updated_at'
          IS DISTINCT FROM to_jsonb(OLD) - 'is_countdown' - 'updated_at' THEN
      RAISE EXCEPTION 'synced_event' USING ERRCODE = 'P0001';
    END IF;
  END IF;
  RETURN CASE WHEN TG_OP = 'DELETE' THEN OLD ELSE NEW END;
END;
$$ LANGUAGE plpgsql SET search_path = public;

REVOKE ALL ON FUNCTION public.calendar_events_synced_rules() FROM PUBLIC, anon, authenticated;

CREATE TRIGGER calendar_events_synced_rules
  BEFORE UPDATE OR DELETE ON public.calendar_events
  FOR EACH ROW EXECUTE FUNCTION public.calendar_events_synced_rules();

-- ---------------------------------------------------------------------------
-- 2. Who syncs: the install id of the one phone that follows calendars for
--    this person (another phone of theirs stops when it sees a different
--    id), and when it last synced, which the partner sees.
-- ---------------------------------------------------------------------------
ALTER TABLE public.profiles
  ADD COLUMN calendar_sync_device TEXT CHECK (calendar_sync_device ~ '^[0-9a-f-]{36}$'),
  ADD COLUMN calendar_synced_at TIMESTAMPTZ;

COMMENT ON COLUMN public.profiles.calendar_sync_device IS
  'Install id (random UUID) of the phone that follows calendars for this person; null when they follow none.';
COMMENT ON COLUMN public.profiles.calendar_synced_at IS
  'When that phone last synced the followed calendars.';

GRANT INSERT (calendar_sync_device, calendar_synced_at),
      UPDATE (calendar_sync_device, calendar_synced_at)
  ON TABLE public.profiles TO authenticated;

-- ---------------------------------------------------------------------------
-- 3. Waking the partner's phone. Opening the calendar asks for it; the
--    server sends a silent push (wake-partner-calendar) unless the partner
--    follows nothing, synced in the last 10 minutes, or was woken in the
--    last 20 (iOS throttles these pushes). Only the latest wake is kept.
-- ---------------------------------------------------------------------------
CREATE TABLE private.calendar_wakes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  sent_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

COMMENT ON TABLE private.calendar_wakes IS
  'Latest calendar wake push sent to each person, to space them out.';

REVOKE ALL ON private.calendar_wakes FROM PUBLIC;

CREATE TRIGGER calendar_wakes_notify
  AFTER INSERT ON private.calendar_wakes
  FOR EACH ROW EXECUTE FUNCTION private.notify_push('wake-partner-calendar');

CREATE OR REPLACE FUNCTION public.request_partner_calendar_sync()
RETURNS TEXT
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  _partner UUID;
  _device TEXT;
  _synced_at TIMESTAMPTZ;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'Not signed in' USING ERRCODE = '42501';
  END IF;
  _partner := public.my_partner_id();
  IF _partner IS NULL THEN
    RETURN 'not_paired';
  END IF;
  -- One ask at a time per partner, so two taps can't both send.
  PERFORM pg_advisory_xact_lock(hashtext('calendar_wake:' || _partner::text));
  SELECT calendar_sync_device, calendar_synced_at INTO _device, _synced_at
  FROM public.profiles WHERE id = _partner;
  IF _device IS NULL THEN
    RETURN 'not_following';
  END IF;
  IF _synced_at > now() - interval '10 minutes' THEN
    RETURN 'fresh';
  END IF;
  IF EXISTS (SELECT 1 FROM private.calendar_wakes
             WHERE user_id = _partner AND sent_at > now() - interval '20 minutes') THEN
    RETURN 'recent';
  END IF;
  DELETE FROM private.calendar_wakes WHERE user_id = _partner;
  INSERT INTO private.calendar_wakes (user_id) VALUES (_partner);
  RETURN 'sent';
END;
$$;

COMMENT ON FUNCTION public.request_partner_calendar_sync() IS
  'Ask the partner''s phone to sync its followed calendars: not_paired, not_following, fresh (synced in the last 10 minutes), recent (woken in the last 20) or sent.';

REVOKE ALL ON FUNCTION public.request_partner_calendar_sync() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.request_partner_calendar_sync() TO authenticated;
