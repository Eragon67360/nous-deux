\set ON_ERROR_STOP 1
-- Joining a partner's code keeps what the joiner entered while waiting with
-- their own invite (migration 20261116400000). Kai and Jo both generate a
-- code; Jo uses the app while waiting, then joins Kai's code instead.
INSERT INTO auth.users (id) VALUES ('00000000-0000-0000-0000-0000000094a1'),('00000000-0000-0000-0000-0000000094b1');
-- 94a1 Kai, 94b1 Jo
INSERT INTO public.profiles (id, username, tracks_cycle, share_cycle, share_checkins) VALUES
 ('00000000-0000-0000-0000-0000000094a1','Kai', NULL, TRUE, TRUE),
 ('00000000-0000-0000-0000-0000000094b1','Jo', TRUE, TRUE, FALSE);

CREATE FUNCTION pg_temp.expect(label text, ok boolean) RETURNS text
LANGUAGE plpgsql AS $$
BEGIN
  IF NOT ok THEN RAISE EXCEPTION '%: failed', label; END IF;
  RETURN label || ': ok';
END $$;

-- Both invite; Jo logs a period start, a check-in, an event, a private note
-- and shares a position, all in Jo's own invite couple.
SET ROLE authenticated;
SET request.jwt.claim.sub = '00000000-0000-0000-0000-0000000094a1';
DO $$ BEGIN PERFORM public.create_couple(); END $$;
SET request.jwt.claim.sub = '00000000-0000-0000-0000-0000000094b1';
DO $$ DECLARE c public.couples; BEGIN
  c := public.create_couple();
  INSERT INTO public.period_logs (user_id, couple_id, start_date) VALUES (auth.uid(), c.id, CURRENT_DATE - 2);
  INSERT INTO public.cycle_checkins (user_id, couple_id, day, mood, symptoms) VALUES (auth.uid(), c.id, CURRENT_DATE, 'tired', '{cramps}');
  INSERT INTO public.calendar_events (couple_id, title, start_time, created_by) VALUES (c.id, 'Doctor', NOW() + INTERVAL '3 days', auth.uid());
  INSERT INTO public.cycle_notes (user_id, day, note) VALUES (auth.uid(), CURRENT_DATE, 'only mine');
  INSERT INTO public.location_sharing (user_id, couple_id, is_sharing, latitude, longitude) VALUES (auth.uid(), c.id, TRUE, 48.58, 7.75);
END $$;
RESET ROLE;
DO $$ BEGIN
  PERFORM set_config('nd.kai_couple', (SELECT id::text FROM public.couples WHERE user1_id = '00000000-0000-0000-0000-0000000094a1'), false);
  PERFORM set_config('nd.kai_code', (SELECT pairing_code FROM public.couples WHERE user1_id = '00000000-0000-0000-0000-0000000094a1'), false);
  PERFORM set_config('nd.jo_invite', (SELECT id::text FROM public.couples WHERE user1_id = '00000000-0000-0000-0000-0000000094b1'), false);
END $$;

-- Jo joins Kai's code (with the push secret set, so a push would be recorded).
SET app.settings.push_webhook_secret = 'dry-run-secret';
TRUNCATE net.http_calls;
SET ROLE authenticated;
SET request.jwt.claim.sub = '00000000-0000-0000-0000-0000000094b1';
SELECT pg_temp.expect('Jo joins Kai', public.join_couple(current_setting('nd.kai_code')) = 'joined');
RESET ROLE;

SELECT pg_temp.expect('Jo''s invite couple is gone',
  NOT EXISTS (SELECT 1 FROM public.couples WHERE id = current_setting('nd.jo_invite')::uuid));
SELECT pg_temp.expect('Jo''s period start, check-in and event moved to the couple',
  (SELECT count(*) FROM public.period_logs WHERE user_id = '00000000-0000-0000-0000-0000000094b1' AND couple_id = current_setting('nd.kai_couple')::uuid) = 1
  AND (SELECT count(*) FROM public.cycle_checkins WHERE user_id = '00000000-0000-0000-0000-0000000094b1' AND couple_id = current_setting('nd.kai_couple')::uuid) = 1
  AND (SELECT count(*) FROM public.calendar_events WHERE title = 'Doctor' AND couple_id = current_setting('nd.kai_couple')::uuid
         AND created_by = '00000000-0000-0000-0000-0000000094b1') = 1);
SELECT pg_temp.expect('Jo''s private note stays',
  (SELECT count(*) FROM public.cycle_notes WHERE user_id = '00000000-0000-0000-0000-0000000094b1') = 1);
SELECT pg_temp.expect('Jo''s live position is not carried',
  NOT EXISTS (SELECT 1 FROM public.location_sharing WHERE user_id = '00000000-0000-0000-0000-0000000094b1'));

-- Jo still sees all of it.
SET ROLE authenticated;
SET request.jwt.claim.sub = '00000000-0000-0000-0000-0000000094b1';
SELECT pg_temp.expect('Jo reads their own period start and check-in',
  (SELECT count(*) FROM public.period_logs WHERE user_id = auth.uid()) = 1
  AND (SELECT count(*) FROM public.cycle_checkins WHERE user_id = auth.uid()) = 1);

-- Kai reads them only as Jo's switches allow: period dates shared, check-ins not.
SET request.jwt.claim.sub = '00000000-0000-0000-0000-0000000094a1';
SELECT pg_temp.expect('Kai reads Jo''s period start (Mon cycle on)',
  (SELECT count(*) FROM public.period_logs WHERE user_id = '00000000-0000-0000-0000-0000000094b1') = 1);
SELECT pg_temp.expect('Kai doesn''t read Jo''s check-in (Mon ressenti du jour off)',
  (SELECT count(*) FROM public.cycle_checkins WHERE user_id = '00000000-0000-0000-0000-0000000094b1') = 0);
SELECT pg_temp.expect('Kai sees the event in the shared calendar',
  (SELECT count(*) FROM public.calendar_events WHERE title = 'Doctor') = 1);
SELECT pg_temp.expect('Kai never reads Jo''s private note',
  (SELECT count(*) FROM public.cycle_notes WHERE user_id = '00000000-0000-0000-0000-0000000094b1') = 0);

-- Jo turns "Mon cycle" off: Kai no longer reads the moved period start either.
SET request.jwt.claim.sub = '00000000-0000-0000-0000-0000000094b1';
UPDATE public.profiles SET share_cycle = FALSE WHERE id = auth.uid();
SET request.jwt.claim.sub = '00000000-0000-0000-0000-0000000094a1';
SELECT pg_temp.expect('with Mon cycle off, Kai reads none of Jo''s period dates',
  (SELECT count(*) FROM public.period_logs WHERE user_id = '00000000-0000-0000-0000-0000000094b1') = 0);
RESET ROLE;

-- Moving the period start sends no "updated their tracking" push: only new
-- period logs do.
SELECT pg_temp.expect('no push for the moved period start',
  NOT EXISTS (SELECT 1 FROM net.http_calls WHERE body->>'table' = 'period_logs'));
RESET app.settings.push_webhook_secret;
