\set ON_ERROR_STOP 1
-- Pill tracking (docs/PILL.md, Task 2). Pia (88a) takes a pill and tracks
-- it; Paul (88b) is her partner; Sam (88c) is a stranger. Pia's settings
-- and history are hers; Paul learns only whether a pill is expected today
-- and whether it is ticked, never a missed day, older days or her pack.
-- Every check prints a line; a wrong result raises.
INSERT INTO auth.users (id) VALUES
 ('00000000-0000-0000-0000-00000000088a'),
 ('00000000-0000-0000-0000-00000000088b'),
 ('00000000-0000-0000-0000-00000000088c');
INSERT INTO public.profiles (id, username) VALUES
 ('00000000-0000-0000-0000-00000000088a', 'Pia'),
 ('00000000-0000-0000-0000-00000000088b', 'Paul'),
 ('00000000-0000-0000-0000-00000000088c', 'Sam');
INSERT INTO public.couples (id, user1_id, user2_id) VALUES
 ('88888888-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-00000000088a', '00000000-0000-0000-0000-00000000088b');

CREATE FUNCTION pg_temp.expect(label text, ok boolean) RETURNS text
LANGUAGE plpgsql AS $$
BEGIN
  IF NOT ok THEN RAISE EXCEPTION '%: failed', label; END IF;
  RETURN label || ': ok';
END $$;

-- Pia, signed in.
SET ROLE authenticated;
SET request.jwt.claim.sub = '00000000-0000-0000-0000-00000000088a';
DO $$ BEGIN
  INSERT INTO public.pill_intakes (user_id, day, status, taken_at)
  VALUES (auth.uid(), current_date, 'taken', now());
  RAISE EXCEPTION 'expected a refusal';
EXCEPTION WHEN insufficient_privilege THEN RAISE NOTICE 'no pill is ticked before tracking starts';
END $$;
DO $$ BEGIN
  INSERT INTO public.pill_tracking (user_id, pack_type, pack_started_on, consent_at)
  VALUES (auth.uid(), '21_7', current_date - 11, now() - interval '1 year');
  RAISE EXCEPTION 'expected a refusal';
EXCEPTION WHEN insufficient_privilege THEN RAISE NOTICE 'the consent time is the database''s';
END $$;

-- Today is pill 12 of a 21 + 7 pack.
INSERT INTO public.pill_tracking (user_id, pack_type, pack_started_on, reminder_time)
VALUES (auth.uid(), '21_7', current_date - 11, '21:00');
SELECT pg_temp.expect('starting records the consent time',
  (SELECT consent_at > now() - interval '1 minute' FROM public.pill_tracking WHERE user_id = auth.uid()));
SELECT pg_temp.expect('discreet text and sharing are the defaults',
  (SELECT reminder_text = 'discreet' AND share_with_partner AND reminder_on
   FROM public.pill_tracking WHERE user_id = auth.uid()));
DO $$ BEGIN
  INSERT INTO public.pill_tracking (user_id, pack_type, pack_started_on)
  VALUES ('00000000-0000-0000-0000-00000000088c', '28', current_date);
  RAISE EXCEPTION 'expected a refusal';
EXCEPTION WHEN insufficient_privilege THEN RAISE NOTICE 'nobody starts tracking for someone else';
END $$;

INSERT INTO public.pill_intakes (user_id, day, status, taken_at) VALUES
 (auth.uid(), current_date, 'taken', now() - interval '5 minutes'),
 (auth.uid(), current_date - 5, 'taken', now() - interval '5 days');
INSERT INTO public.pill_intakes (user_id, day, status) VALUES (auth.uid(), current_date - 1, 'missed');
DO $$ BEGIN
  INSERT INTO public.pill_intakes (user_id, day, status) VALUES (auth.uid(), current_date - 2, 'taken');
  RAISE EXCEPTION 'expected a refusal';
EXCEPTION WHEN check_violation THEN RAISE NOTICE 'a taken pill has its time';
END $$;
DO $$ BEGIN
  INSERT INTO public.pill_intakes (user_id, day, status, taken_at) VALUES (auth.uid(), current_date, 'taken', now());
  RAISE EXCEPTION 'expected a refusal';
EXCEPTION WHEN unique_violation THEN RAISE NOTICE 'one row per day';
END $$;
SELECT pg_temp.expect('Pia reads her whole history',
  (SELECT count(*) = 3 FROM public.pill_intakes));

-- Paul, her partner.
SET request.jwt.claim.sub = '00000000-0000-0000-0000-00000000088b';
SELECT pg_temp.expect('the partner reads only today''s ticked pill',
  (SELECT count(*) = 1 AND bool_and(status = 'taken' AND day = current_date) FROM public.pill_intakes));
SELECT pg_temp.expect('never her settings',
  (SELECT count(*) = 0 FROM public.pill_tracking));
SELECT pg_temp.expect('today: tracking, a pill day, ticked',
  (SELECT tracking AND expected AND taken_at IS NOT NULL FROM public.partner_pill_today(current_date)));
SELECT pg_temp.expect('a day far away tells nothing',
  (SELECT NOT tracking AND taken_at IS NULL FROM public.partner_pill_today(current_date - 5)));
DO $$ BEGIN
  INSERT INTO public.pill_intakes (user_id, day, status, taken_at)
  VALUES ('00000000-0000-0000-0000-00000000088a', current_date + 1, 'taken', now());
  RAISE EXCEPTION 'expected a refusal';
EXCEPTION WHEN insufficient_privilege THEN RAISE NOTICE 'the partner can''t tick for her';
END $$;
WITH changed AS (
  UPDATE public.pill_intakes SET status = 'missed', taken_at = NULL RETURNING 1
)
SELECT pg_temp.expect('or change her rows', (SELECT count(*) = 0 FROM changed));

-- Pia's pack moves to its pause week; then she stops sharing.
SET request.jwt.claim.sub = '00000000-0000-0000-0000-00000000088a';
UPDATE public.pill_tracking SET pack_started_on = current_date - 22 WHERE user_id = auth.uid();
SET request.jwt.claim.sub = '00000000-0000-0000-0000-00000000088b';
SELECT pg_temp.expect('in the pause week, no pill is expected',
  (SELECT tracking AND NOT expected FROM public.partner_pill_today(current_date)));
SET request.jwt.claim.sub = '00000000-0000-0000-0000-00000000088a';
UPDATE public.pill_tracking SET share_with_partner = false WHERE user_id = auth.uid();
SET request.jwt.claim.sub = '00000000-0000-0000-0000-00000000088b';
SELECT pg_temp.expect('not shared: the partner reads nothing',
  (SELECT count(*) = 0 FROM public.pill_intakes)
  AND (SELECT NOT tracking AND NOT expected AND taken_at IS NULL FROM public.partner_pill_today(current_date)));

-- Sam, a stranger, and a signed-out caller.
SET request.jwt.claim.sub = '00000000-0000-0000-0000-00000000088a';
UPDATE public.pill_tracking SET share_with_partner = true WHERE user_id = auth.uid();
SET request.jwt.claim.sub = '00000000-0000-0000-0000-00000000088c';
SELECT pg_temp.expect('a stranger reads nothing',
  (SELECT count(*) = 0 FROM public.pill_intakes)
  AND (SELECT count(*) = 0 FROM public.pill_tracking)
  AND (SELECT NOT tracking FROM public.partner_pill_today(current_date)));
RESET ROLE;
SET ROLE anon; RESET request.jwt.claim.sub;
DO $$ BEGIN
  PERFORM 1 FROM public.pill_intakes;
  RAISE EXCEPTION 'expected a refusal';
EXCEPTION WHEN insufficient_privilege THEN RAISE NOTICE 'signed out, no history';
END $$;
DO $$ BEGIN
  PERFORM public.partner_pill_today(current_date);
  RAISE EXCEPTION 'expected a refusal';
EXCEPTION WHEN insufficient_privilege THEN RAISE NOTICE 'nor the partner''s view';
END $$;
DO $$ BEGIN
  PERFORM public.stop_pill_tracking();
  RAISE EXCEPTION 'expected a refusal';
EXCEPTION WHEN insufficient_privilege THEN RAISE NOTICE 'nor stopping anyone''s tracking';
END $$;

-- Leaving the couple keeps her own history; stopping deletes it.
RESET ROLE;
SET ROLE authenticated;
SET request.jwt.claim.sub = '00000000-0000-0000-0000-00000000088a';
SELECT public.leave_couple();
SELECT pg_temp.expect('leaving the couple keeps her history',
  (SELECT count(*) = 3 FROM public.pill_intakes)
  AND (SELECT count(*) = 1 FROM public.pill_tracking));
SELECT public.stop_pill_tracking();
SELECT pg_temp.expect('stopping deletes her settings and history',
  (SELECT count(*) = 0 FROM public.pill_intakes)
  AND (SELECT count(*) = 0 FROM public.pill_tracking));

-- She starts again, then deletes her account: everything goes.
INSERT INTO public.pill_tracking (user_id, pack_type, pack_started_on) VALUES (auth.uid(), '28', current_date);
INSERT INTO public.pill_intakes (user_id, day, status, taken_at) VALUES (auth.uid(), current_date, 'taken', now());
SELECT public.delete_my_account();
RESET ROLE;
SELECT pg_temp.expect('deleting the account deletes the pill data',
  NOT EXISTS (SELECT 1 FROM public.pill_intakes WHERE user_id = '00000000-0000-0000-0000-00000000088a')
  AND NOT EXISTS (SELECT 1 FROM public.pill_tracking WHERE user_id = '00000000-0000-0000-0000-00000000088a'));
SELECT pg_temp.expect('the pill day rule: 21 + 7 pauses after pill 21, the others never',
  public.pill_is_pill_day('21_7', '2026-11-01', '2026-11-21')
  AND NOT public.pill_is_pill_day('21_7', '2026-11-01', '2026-11-22')
  AND public.pill_is_pill_day('21_7', '2026-11-01', '2026-11-29')
  AND NOT public.pill_is_pill_day('21_7', '2026-11-01', '2026-10-31')
  AND public.pill_is_pill_day('28', '2026-11-01', '2026-11-25')
  AND public.pill_is_pill_day('continuous', '2026-11-01', '2026-11-25'));
