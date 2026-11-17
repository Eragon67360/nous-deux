\set ON_ERROR_STOP 1
-- Ana (93a) and Ben (93b) are a couple; Cleo (93c) is alone. Ana follows a
-- phone calendar: her synced events are hers to change, Ben only switches
-- their countdown. Opening the calendar asks the server to wake the
-- partner's phone, at most once in 20 minutes and not when it just synced.
-- Every check prints a line; a wrong result raises.
INSERT INTO auth.users (id) VALUES
 ('00000000-0000-0000-0000-00000000093a'),
 ('00000000-0000-0000-0000-00000000093b'),
 ('00000000-0000-0000-0000-00000000093c');
INSERT INTO public.profiles (id, username) VALUES
 ('00000000-0000-0000-0000-00000000093a', 'Ana'),
 ('00000000-0000-0000-0000-00000000093b', 'Ben'),
 ('00000000-0000-0000-0000-00000000093c', 'Cleo');
INSERT INTO public.couples (id, user1_id, user2_id) VALUES
 ('93939393-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-00000000093a', '00000000-0000-0000-0000-00000000093b');
UPDATE public.profiles SET partner_id = '00000000-0000-0000-0000-00000000093b'
WHERE id = '00000000-0000-0000-0000-00000000093a';
UPDATE public.profiles SET partner_id = '00000000-0000-0000-0000-00000000093a'
WHERE id = '00000000-0000-0000-0000-00000000093b';
TRUNCATE net.http_calls;
SET app.settings.push_webhook_secret = 'dry-run-secret';

CREATE FUNCTION pg_temp.expect(label text, ok boolean) RETURNS text
LANGUAGE plpgsql AS $$
BEGIN
  IF NOT ok THEN RAISE EXCEPTION '%: failed', label; END IF;
  RETURN label || ': ok';
END $$;

-- Ana's phone copies two events, and she writes one herself.
SET ROLE authenticated;
SET request.jwt.claim.sub = '00000000-0000-0000-0000-00000000093a';
INSERT INTO public.calendar_events (id, couple_id, title, start_time, created_by, source_key) VALUES
 ('93939393-0000-0000-0000-0000000000e1', '93939393-0000-0000-0000-000000000001',
  'Dentiste', now() + interval '2 days', auth.uid(), repeat('a', 64)),
 ('93939393-0000-0000-0000-0000000000e2', '93939393-0000-0000-0000-000000000001',
  'Yoga', now() + interval '3 days', auth.uid(), repeat('b', 64)),
 ('93939393-0000-0000-0000-0000000000e3', '93939393-0000-0000-0000-000000000001',
  'Dîner', now() + interval '4 days', auth.uid(), NULL);

UPDATE public.calendar_events SET title = 'Dentiste (déplacé)', start_time = now() + interval '5 days'
WHERE id = '93939393-0000-0000-0000-0000000000e1';
SELECT pg_temp.expect('the owner updates her synced event',
  (SELECT title = 'Dentiste (déplacé)' FROM public.calendar_events
   WHERE id = '93939393-0000-0000-0000-0000000000e1'));

DO $$ BEGIN
  INSERT INTO public.calendar_events (couple_id, title, start_time, created_by, source_key)
  VALUES ('93939393-0000-0000-0000-000000000001', 'Dentiste', now(), auth.uid(), repeat('a', 64));
  RAISE EXCEPTION 'expected a refusal';
EXCEPTION WHEN unique_violation THEN RAISE NOTICE 'the same source key is refused twice';
END $$;
DO $$ BEGIN
  INSERT INTO public.calendar_events (couple_id, title, start_time, created_by, source_key)
  VALUES ('93939393-0000-0000-0000-000000000001', 'X', now(), auth.uid(), 'not-a-hash');
  RAISE EXCEPTION 'expected a refusal';
EXCEPTION WHEN check_violation THEN RAISE NOTICE 'a malformed source key is refused';
END $$;
SELECT pg_temp.expect('a refused insert left one event per key',
  (SELECT count(*) = 1 FROM public.calendar_events WHERE source_key = repeat('a', 64)));

-- Ben, the partner.
SET request.jwt.claim.sub = '00000000-0000-0000-0000-00000000093b';
DO $$ BEGIN
  UPDATE public.calendar_events SET title = 'Autre chose'
  WHERE id = '93939393-0000-0000-0000-0000000000e1';
  RAISE EXCEPTION 'expected a refusal';
EXCEPTION WHEN SQLSTATE 'P0001' THEN
  IF SQLERRM <> 'synced_event' THEN RAISE; END IF;
  RAISE NOTICE 'the partner cannot rename a synced event';
END $$;
DO $$ BEGIN
  UPDATE public.calendar_events SET start_time = now()
  WHERE id = '93939393-0000-0000-0000-0000000000e1';
  RAISE EXCEPTION 'expected a refusal';
EXCEPTION WHEN SQLSTATE 'P0001' THEN RAISE NOTICE 'the partner cannot move a synced event';
END $$;
DO $$ BEGIN
  DELETE FROM public.calendar_events WHERE id = '93939393-0000-0000-0000-0000000000e1';
  RAISE EXCEPTION 'expected a refusal';
EXCEPTION WHEN SQLSTATE 'P0001' THEN RAISE NOTICE 'the partner cannot delete a synced event';
END $$;
UPDATE public.calendar_events SET is_countdown = true
WHERE id = '93939393-0000-0000-0000-0000000000e1';
SELECT pg_temp.expect('the partner switches a synced event''s countdown',
  (SELECT is_countdown AND title = 'Dentiste (déplacé)' FROM public.calendar_events
   WHERE id = '93939393-0000-0000-0000-0000000000e1'));
UPDATE public.calendar_events SET title = 'Dîner chez Léa'
WHERE id = '93939393-0000-0000-0000-0000000000e3';
SELECT pg_temp.expect('the partner still edits an ordinary event',
  (SELECT title = 'Dîner chez Léa' FROM public.calendar_events
   WHERE id = '93939393-0000-0000-0000-0000000000e3'));
DELETE FROM public.calendar_events WHERE id = '93939393-0000-0000-0000-0000000000e3';
SELECT pg_temp.expect('the partner still deletes an ordinary event',
  NOT EXISTS (SELECT 1 FROM public.calendar_events WHERE id = '93939393-0000-0000-0000-0000000000e3'));

-- Ana deletes one of hers (it was removed from her phone).
SET request.jwt.claim.sub = '00000000-0000-0000-0000-00000000093a';
DELETE FROM public.calendar_events WHERE id = '93939393-0000-0000-0000-0000000000e2';
SELECT pg_temp.expect('the owner deletes her synced event',
  NOT EXISTS (SELECT 1 FROM public.calendar_events WHERE id = '93939393-0000-0000-0000-0000000000e2'));

-- Waking the partner's phone.
SET request.jwt.claim.sub = '00000000-0000-0000-0000-00000000093c';
SELECT pg_temp.expect('alone, there is nobody to wake',
  public.request_partner_calendar_sync() = 'not_paired');
SET request.jwt.claim.sub = '00000000-0000-0000-0000-00000000093a';
SELECT pg_temp.expect('a partner who follows nothing is not woken',
  public.request_partner_calendar_sync() = 'not_following');
SET request.jwt.claim.sub = '00000000-0000-0000-0000-00000000093b';
UPDATE public.profiles SET calendar_sync_device = '7c9e6679-7425-40de-944b-e07fc1f90ae7'
WHERE id = auth.uid();
SET request.jwt.claim.sub = '00000000-0000-0000-0000-00000000093a';
SELECT pg_temp.expect('a partner who follows is woken',
  public.request_partner_calendar_sync() = 'sent');
SELECT pg_temp.expect('a second ask within 20 minutes waits',
  public.request_partner_calendar_sync() = 'recent');
SET request.jwt.claim.sub = '00000000-0000-0000-0000-00000000093b';
UPDATE public.profiles SET calendar_synced_at = now() WHERE id = auth.uid();
SET request.jwt.claim.sub = '00000000-0000-0000-0000-00000000093a';
SELECT pg_temp.expect('a partner who just synced is not woken',
  public.request_partner_calendar_sync() = 'fresh');
DO $$ BEGIN
  PERFORM count(*) FROM private.calendar_wakes;
  RAISE EXCEPTION 'expected a refusal';
EXCEPTION WHEN insufficient_privilege THEN RAISE NOTICE 'clients cannot read the wakes';
END $$;
RESET ROLE;
SELECT pg_temp.expect('one wake, for Ben',
  (SELECT count(*) = 1 AND bool_and(user_id = '00000000-0000-0000-0000-00000000093b')
   FROM private.calendar_wakes));
SELECT pg_temp.expect('the wake went to wake-partner-calendar with the secret',
  (SELECT count(*) = 1
          AND bool_and(url = 'http://supabase-edge-functions:9000/wake-partner-calendar')
          AND bool_and(headers->>'x-webhook-secret' = 'dry-run-secret')
          AND bool_and(body->'record'->>'user_id' = '00000000-0000-0000-0000-00000000093b')
   FROM net.http_calls WHERE url LIKE '%wake-partner-calendar'));
SET ROLE anon;
DO $$ BEGIN
  PERFORM public.request_partner_calendar_sync();
  RAISE EXCEPTION 'expected a refusal';
EXCEPTION WHEN insufficient_privilege THEN RAISE NOTICE 'signed-out callers cannot ask';
END $$;
RESET ROLE;

-- Leaving the couple deletes both partners' synced events.
SET ROLE authenticated;
SET request.jwt.claim.sub = '00000000-0000-0000-0000-00000000093b';
INSERT INTO public.calendar_events (couple_id, title, start_time, created_by, source_key)
VALUES ('93939393-0000-0000-0000-000000000001', 'Foot', now(), auth.uid(), repeat('c', 64));
SET request.jwt.claim.sub = '00000000-0000-0000-0000-00000000093a';
SELECT public.leave_couple();
RESET ROLE;
SELECT pg_temp.expect('leaving the couple deletes both partners'' synced events',
  NOT EXISTS (SELECT 1 FROM public.calendar_events
              WHERE couple_id = '93939393-0000-0000-0000-000000000001'));

-- Paired again; Ben (user2) deletes his account.
INSERT INTO public.couples (id, user1_id, user2_id) VALUES
 ('93939393-0000-0000-0000-000000000002',
  '00000000-0000-0000-0000-00000000093a', '00000000-0000-0000-0000-00000000093b');
UPDATE public.profiles SET partner_id = '00000000-0000-0000-0000-00000000093b'
WHERE id = '00000000-0000-0000-0000-00000000093a';
UPDATE public.profiles SET partner_id = '00000000-0000-0000-0000-00000000093a'
WHERE id = '00000000-0000-0000-0000-00000000093b';
SET ROLE authenticated;
SET request.jwt.claim.sub = '00000000-0000-0000-0000-00000000093a';
INSERT INTO public.calendar_events (couple_id, title, start_time, created_by, source_key)
VALUES ('93939393-0000-0000-0000-000000000002', 'Dentiste', now(), auth.uid(), repeat('d', 64));
SET request.jwt.claim.sub = '00000000-0000-0000-0000-00000000093b';
INSERT INTO public.calendar_events (couple_id, title, start_time, created_by, source_key)
VALUES ('93939393-0000-0000-0000-000000000002', 'Foot', now(), auth.uid(), repeat('e', 64));
SELECT public.delete_my_account();
RESET ROLE;
SELECT pg_temp.expect('deleting user2''s account deletes both partners'' synced events',
  NOT EXISTS (SELECT 1 FROM public.calendar_events
              WHERE couple_id = '93939393-0000-0000-0000-000000000002'));
SELECT pg_temp.expect('and Ben''s wake goes with his account',
  NOT EXISTS (SELECT 1 FROM private.calendar_wakes));
