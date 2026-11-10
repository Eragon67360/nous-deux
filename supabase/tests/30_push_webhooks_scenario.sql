\set ON_ERROR_STOP 1
-- E and F are a couple. Pushes go to the internal functions with the secret.
INSERT INTO auth.users (id) VALUES
 ('00000000-0000-0000-0000-0000000000e1'),('00000000-0000-0000-0000-0000000000f1');
INSERT INTO public.profiles (id, username) VALUES
 ('00000000-0000-0000-0000-0000000000e1','Eva'),('00000000-0000-0000-0000-0000000000f1','Fred');
INSERT INTO public.couples (id, user1_id, user2_id) VALUES
 ('66666666-6666-6666-6666-666666666666','00000000-0000-0000-0000-0000000000e1','00000000-0000-0000-0000-0000000000f1');
TRUNCATE net.http_calls;

SET app.settings.push_webhook_secret = 'dry-run-secret';
SET ROLE authenticated; SET request.jwt.claim.sub = '00000000-0000-0000-0000-0000000000e1';

INSERT INTO public.period_logs (user_id, couple_id, start_date)
VALUES ('00000000-0000-0000-0000-0000000000e1','66666666-6666-6666-6666-666666666666', CURRENT_DATE);
RESET ROLE;
SELECT 'period push: ' || url || ' ' || (headers->>'x-webhook-secret' = 'dry-run-secret')
  || ' ' || (body->>'type') || ' ' || (body->>'table')
  || ' by E: ' || (body->'record'->>'user_id' = '00000000-0000-0000-0000-0000000000e1')
FROM net.http_calls ORDER BY id DESC LIMIT 1;

SET ROLE authenticated;
SELECT 'E sent: ' || kind FROM public.send_ping('kiss');
RESET ROLE;
SELECT 'ping push: ' || url || ' ' || (body->>'type') || ' kind ' || (body->'record'->>'kind')
FROM net.http_calls ORDER BY id DESC LIMIT 1;

-- Sending again after the 30 seconds updates the row: an UPDATE push.
UPDATE public.couple_pings SET sent_at = NOW() - INTERVAL '1 minute';
TRUNCATE net.http_calls;  -- the line above fired one too
SET ROLE authenticated;
SELECT 'E sent again: ' || kind FROM public.send_ping('good_night');
RESET ROLE;
SELECT 'ping update push: ' || (body->>'type') || ' old ' || (body->'old_record'->>'kind') || ' new ' || (body->'record'->>'kind')
FROM net.http_calls ORDER BY id DESC LIMIT 1;

-- Without the secret, nothing is sent and the write still succeeds.
RESET app.settings.push_webhook_secret;
TRUNCATE net.http_calls;
SET ROLE authenticated;
INSERT INTO public.period_logs (user_id, couple_id, start_date)
VALUES ('00000000-0000-0000-0000-0000000000e1','66666666-6666-6666-6666-666666666666', CURRENT_DATE - 30);
RESET ROLE;
SELECT 'no secret: calls=' || count(*) || ', log saved=' || (SELECT count(*) = 2 FROM public.period_logs WHERE couple_id = '66666666-6666-6666-6666-666666666666') FROM net.http_calls;

-- Signed-in users can't call the trigger function or pg_net themselves.
SET ROLE authenticated;
DO $$ BEGIN
  PERFORM net.http_post('http://example.test');
  RAISE EXCEPTION 'expected permission denied';
EXCEPTION WHEN insufficient_privilege THEN RAISE NOTICE 'authenticated cannot call net.http_post';
END $$;
DO $$ BEGIN
  PERFORM private.notify_push();
  RAISE EXCEPTION 'expected permission denied';
EXCEPTION WHEN insufficient_privilege THEN RAISE NOTICE 'authenticated cannot reach private.notify_push';
END $$;
RESET ROLE;
