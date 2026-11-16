\set ON_ERROR_STOP 1
-- The push secret lives in private.secrets (migration 20261116300000), not in
-- a setting every session can read. Pia and Quin are a couple.
INSERT INTO auth.users (id) VALUES ('00000000-0000-0000-0000-0000000099a1'),('00000000-0000-0000-0000-0000000099b1');
INSERT INTO public.profiles (id, username) VALUES ('00000000-0000-0000-0000-0000000099a1','Pia'),('00000000-0000-0000-0000-0000000099b1','Quin');
INSERT INTO public.couples (id, user1_id, user2_id) VALUES
 ('99000000-0000-0000-0000-0000000000a1','00000000-0000-0000-0000-0000000099a1','00000000-0000-0000-0000-0000000099b1');

CREATE FUNCTION pg_temp.expect(label text, ok boolean) RETURNS text
LANGUAGE plpgsql AS $$
BEGIN
  IF NOT ok THEN RAISE EXCEPTION '%: failed', label; END IF;
  RETURN label || ': ok';
END $$;

INSERT INTO private.secrets (name, value) VALUES ('push_webhook_secret', 'table-secret');
TRUNCATE net.http_calls;

-- Pushes carry the secret from the table, with no setting anywhere.
SET ROLE authenticated;
SET request.jwt.claim.sub = '00000000-0000-0000-0000-0000000099a1';
SELECT pg_temp.expect('no session can read a push secret setting',
  coalesce(current_setting('app.settings.push_webhook_secret', true), '') = '');
INSERT INTO public.period_logs (user_id, couple_id, start_date) VALUES (auth.uid(), '99000000-0000-0000-0000-0000000000a1', CURRENT_DATE);
RESET ROLE;
SELECT pg_temp.expect('the push carries the secret from private.secrets',
  (SELECT count(*) FROM net.http_calls) = 1
  AND (SELECT headers->>'x-webhook-secret' FROM net.http_calls) = 'table-secret');

-- Clients can't read it, directly or through the helper.
SET ROLE authenticated;
DO $$ BEGIN
  PERFORM 1 FROM private.secrets;
  RAISE EXCEPTION 'expected refusal';
EXCEPTION WHEN insufficient_privilege THEN RAISE NOTICE 'signed-in callers can''t read private.secrets';
END $$;
DO $$ BEGIN
  PERFORM private.push_webhook_secret();
  RAISE EXCEPTION 'expected refusal';
EXCEPTION WHEN insufficient_privilege THEN RAISE NOTICE 'signed-in callers can''t call private.push_webhook_secret()';
END $$;
RESET ROLE;
SET ROLE anon;
DO $$ BEGIN
  PERFORM 1 FROM private.secrets;
  RAISE EXCEPTION 'expected refusal';
EXCEPTION WHEN insufficient_privilege THEN RAISE NOTICE 'signed-out callers can''t read private.secrets';
END $$;
RESET ROLE;

-- The other scenarios set the secret per session; leave the table as found.
DELETE FROM private.secrets WHERE name = 'push_webhook_secret';
TRUNCATE net.http_calls;
