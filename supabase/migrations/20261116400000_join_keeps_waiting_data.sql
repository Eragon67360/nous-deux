-- Joining a partner's code no longer deletes what the joiner entered while
-- waiting with their own invite.
--
-- Someone who generates a code can use the app while waiting: their period
-- dates, daily check-ins and calendar events go into that invite couple. If
-- they then join their partner's code instead, on_couple_paired() deleted the
-- invite couple, and everything in it went with it (ON DELETE CASCADE). The
-- invite's creator never lost anything: their waiting data is already in the
-- couple that gets paired.
--
-- Now the joiner's period dates, check-ins and calendar events move into the
-- couple they join, before their invite couple is deleted. The partner reads
-- them under the usual rules: period dates and check-ins only while the
-- joiner's sharing switches allow it, calendar events as the couple's shared
-- calendar (Thomas's choice, 2026-11-16). A live position is not carried: it
-- goes with the invite couple, as before, and the app creates a new row when
-- sharing is turned on. Lists and little notes can't exist before pairing.
-- Every join path (join_couple(), and the direct update app 0.3.5 makes)
-- runs this trigger.
CREATE OR REPLACE FUNCTION public.on_couple_paired()
RETURNS TRIGGER AS $$
DECLARE
  _invites UUID[];
BEGIN
  IF NEW.user2_id IS NOT NULL AND (OLD.user2_id IS NULL OR OLD.user2_id IS DISTINCT FROM NEW.user2_id) THEN
    -- Set partner_id on both profiles
    UPDATE public.profiles SET partner_id = NEW.user2_id, updated_at = NOW() WHERE id = NEW.user1_id;
    UPDATE public.profiles SET partner_id = NEW.user1_id, updated_at = NOW() WHERE id = NEW.user2_id;

    -- The joiner's own invite couple (user1 = joiner, nobody else in it)
    SELECT array_agg(id) INTO _invites
    FROM public.couples
    WHERE user1_id = NEW.user2_id AND user2_id IS NULL AND id <> NEW.id;

    IF _invites IS NOT NULL THEN
      -- What they entered while waiting follows them
      UPDATE public.period_logs SET couple_id = NEW.id WHERE couple_id = ANY (_invites);
      UPDATE public.cycle_checkins SET couple_id = NEW.id WHERE couple_id = ANY (_invites);
      UPDATE public.calendar_events SET couple_id = NEW.id WHERE couple_id = ANY (_invites);
      -- Then the invite goes, with the rest (a live position)
      DELETE FROM public.couples WHERE id = ANY (_invites);
    END IF;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;
