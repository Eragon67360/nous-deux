\set ON_ERROR_STOP 1
-- The last review findings the database fixes (migration 20261116200000).
-- Xia and Yan are a couple, Zoe and Ulf another, Wim waits with an invite.
INSERT INTO auth.users (id) VALUES
 ('00000000-0000-0000-0000-0000000098a1'),('00000000-0000-0000-0000-0000000098b1'),
 ('00000000-0000-0000-0000-0000000098c1'),('00000000-0000-0000-0000-0000000098d1'),
 ('00000000-0000-0000-0000-0000000098e1');
-- 98a1 Xia, 98b1 Yan, 98c1 Zoe, 98d1 Ulf, 98e1 Wim
INSERT INTO auth.identities (user_id, provider, provider_id) VALUES
 ('00000000-0000-0000-0000-0000000098a1', 'apple', 'apple-sub-xia');
INSERT INTO public.profiles (id, username) VALUES
 ('00000000-0000-0000-0000-0000000098a1','Xia'),('00000000-0000-0000-0000-0000000098b1','Yan'),
 ('00000000-0000-0000-0000-0000000098c1','Zoe'),('00000000-0000-0000-0000-0000000098d1','Ulf'),
 ('00000000-0000-0000-0000-0000000098e1','Wim');
INSERT INTO public.couples (id, user1_id, user2_id, pairing_code) VALUES
 ('98000000-0000-0000-0000-0000000000a1','00000000-0000-0000-0000-0000000098a1','00000000-0000-0000-0000-0000000098b1',NULL),
 ('98000000-0000-0000-0000-0000000000c1','00000000-0000-0000-0000-0000000098c1','00000000-0000-0000-0000-0000000098d1',NULL),
 ('98000000-0000-0000-0000-0000000000e1','00000000-0000-0000-0000-0000000098e1',NULL,'WIM234');

CREATE FUNCTION pg_temp.expect(label text, ok boolean) RETURNS text
LANGUAGE plpgsql AS $$
BEGIN
  IF NOT ok THEN RAISE EXCEPTION '%: failed', label; END IF;
  RETURN label || ': ok';
END $$;

-- F5: rows go only into the caller's own couple.
SET ROLE authenticated;
SET request.jwt.claim.sub = '00000000-0000-0000-0000-0000000098a1';
DO $$ BEGIN
  INSERT INTO public.period_logs (user_id, couple_id, start_date) VALUES (auth.uid(), '98000000-0000-0000-0000-0000000000c1', CURRENT_DATE);
  RAISE EXCEPTION 'expected refusal';
EXCEPTION WHEN insufficient_privilege THEN RAISE NOTICE 'period log in another couple refused';
END $$;
DO $$ BEGIN
  INSERT INTO public.location_sharing (user_id, couple_id, is_sharing) VALUES (auth.uid(), '98000000-0000-0000-0000-0000000000c1', false);
  RAISE EXCEPTION 'expected refusal';
EXCEPTION WHEN insufficient_privilege THEN RAISE NOTICE 'location row in another couple refused';
END $$;
INSERT INTO public.period_logs (user_id, couple_id, start_date) VALUES (auth.uid(), '98000000-0000-0000-0000-0000000000a1', CURRENT_DATE);
INSERT INTO public.location_sharing (user_id, couple_id, is_sharing, latitude, longitude) VALUES (auth.uid(), '98000000-0000-0000-0000-0000000000a1', true, 48.5, 7.7);
UPDATE public.location_sharing SET latitude = 48.6 WHERE user_id = auth.uid() AND is_sharing;
SELECT pg_temp.expect('own couple: period log and position saved',
  (SELECT count(*) FROM public.period_logs WHERE user_id = auth.uid()) = 1
  AND (SELECT latitude FROM public.location_sharing WHERE user_id = auth.uid()) = 48.6);
DO $$ BEGIN
  UPDATE public.location_sharing SET couple_id = '98000000-0000-0000-0000-0000000000c1' WHERE user_id = auth.uid();
  RAISE EXCEPTION 'expected refusal';
EXCEPTION WHEN insufficient_privilege THEN RAISE NOTICE 'moving the location row to another couple refused';
END $$;
-- Wim, still waiting, keeps using the Règles tab in his invite couple.
SET request.jwt.claim.sub = '00000000-0000-0000-0000-0000000098e1';
INSERT INTO public.period_logs (user_id, couple_id, start_date) VALUES (auth.uid(), '98000000-0000-0000-0000-0000000000e1', CURRENT_DATE);
SELECT pg_temp.expect('waiting person logs in their invite couple', (SELECT count(*) FROM public.period_logs WHERE user_id = auth.uid()) = 1);

-- F5: an event's author is whoever created it, whatever the app sends.
SET request.jwt.claim.sub = '00000000-0000-0000-0000-0000000098b1';
INSERT INTO public.calendar_events (couple_id, title, start_time, created_by)
VALUES ('98000000-0000-0000-0000-0000000000a1', 'Cinema', NOW(), '00000000-0000-0000-0000-0000000098a1');
SELECT pg_temp.expect('event signed as Xia is stored as Yan''s',
  (SELECT created_by FROM public.calendar_events WHERE title = 'Cinema') = '00000000-0000-0000-0000-0000000098b1');
SET request.jwt.claim.sub = '00000000-0000-0000-0000-0000000098a1';
UPDATE public.calendar_events SET title = 'Cinema 20h', created_by = auth.uid() WHERE title = 'Cinema';
SELECT pg_temp.expect('Xia edits it, Yan stays the author',
  (SELECT created_by FROM public.calendar_events WHERE title = 'Cinema 20h') = '00000000-0000-0000-0000-0000000098b1');
RESET ROLE;

-- F6: no definer function without a search_path; signed-out callers get
-- nothing in public, but record_app_build, which the release jobs call with
-- their token (87_app_builds); nobody can TRUNCATE.
SELECT pg_temp.expect('every SECURITY DEFINER function fixes its search_path', NOT EXISTS (
  SELECT 1 FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
  WHERE n.nspname IN ('public', 'private') AND p.prosecdef
    AND NOT EXISTS (SELECT 1 FROM unnest(coalesce(p.proconfig, '{}')) c WHERE c LIKE 'search_path=%')));
SELECT pg_temp.expect('anon has no table in public', NOT EXISTS (
  SELECT 1 FROM pg_class c WHERE c.relnamespace = 'public'::regnamespace AND c.relkind = 'r'
    AND (has_table_privilege('anon', c.oid, 'SELECT') OR has_table_privilege('anon', c.oid, 'INSERT')
      OR has_table_privilege('anon', c.oid, 'UPDATE') OR has_table_privilege('anon', c.oid, 'DELETE'))));
SELECT pg_temp.expect('anon can call no function in public but the release jobs''', NOT EXISTS (
  SELECT 1 FROM pg_proc p WHERE p.pronamespace = 'public'::regnamespace
    AND p.prorettype <> 'trigger'::regtype AND has_function_privilege('anon', p.oid, 'EXECUTE')
    AND p.oid <> 'public.record_app_build(text, integer, jsonb, text)'::regprocedure));
SELECT pg_temp.expect('signed-in callers can TRUNCATE no table in public', NOT EXISTS (
  SELECT 1 FROM pg_class c WHERE c.relnamespace = 'public'::regnamespace AND c.relkind = 'r'
    AND has_table_privilege('authenticated', c.oid, 'TRUNCATE')));

-- F7: Realtime deletes carry a random id, not who the row belongs to.
SELECT pg_temp.expect('couple_pings and location_sharing are keyed by a random id',
  (SELECT string_agg(c.relname || '(' || a.attname || ')', ',' ORDER BY c.relname)
   FROM pg_index i JOIN pg_class c ON c.oid = i.indrelid JOIN pg_attribute a ON a.attrelid = c.oid AND a.attnum = ANY (i.indkey)
   WHERE i.indisprimary AND c.relname IN ('couple_pings', 'location_sharing')) = 'couple_pings(id),location_sharing(id)');
SET ROLE authenticated;
SET request.jwt.claim.sub = '00000000-0000-0000-0000-0000000098b1';
SELECT pg_temp.expect('send_ping still works', (SELECT kind FROM public.send_ping('kiss')) = 'kiss');
RESET ROLE;
UPDATE public.couple_pings SET sent_at = NOW() - INTERVAL '1 minute' WHERE sender_id = '00000000-0000-0000-0000-0000000098b1';
SET ROLE authenticated;
SELECT pg_temp.expect('and replaces the note', (SELECT kind FROM public.send_ping('miss_you')) = 'miss_you'
  AND (SELECT count(*) FROM public.couple_pings WHERE sender_id = auth.uid()) = 1);
SET request.jwt.claim.sub = '00000000-0000-0000-0000-0000000098a1';
DO $$ BEGIN
  INSERT INTO public.location_sharing (user_id, couple_id, is_sharing) VALUES (auth.uid(), '98000000-0000-0000-0000-0000000000a1', false);
  RAISE EXCEPTION 'expected refusal';
EXCEPTION WHEN unique_violation THEN RAISE NOTICE 'still one location row per person';
END $$;

-- F9: a display name stays a name.
UPDATE public.profiles SET username = repeat('x', 50) WHERE id = auth.uid();
DO $$ BEGIN
  UPDATE public.profiles SET username = repeat('x', 51) WHERE id = auth.uid();
  RAISE EXCEPTION 'expected refusal';
EXCEPTION WHEN check_violation THEN RAISE NOTICE 'a 51-character name refused';
END $$;
RESET ROLE;

-- F9: save_apple_authorization() reaches Apple at most once a minute.
TRUNCATE net.http_calls;
SET app.settings.push_webhook_secret = 'dry-run-secret';
SET ROLE authenticated;
SET request.jwt.claim.sub = '00000000-0000-0000-0000-0000000098a1';
SELECT public.save_apple_authorization('xia-code-1');
SELECT public.save_apple_authorization('xia-code-2');
RESET ROLE;
SELECT pg_temp.expect('two calls in a minute, one sent', (SELECT count(*) FROM net.http_calls) = 1
  AND (SELECT body->>'code' FROM net.http_calls) = 'xia-code-1');
SELECT pg_temp.expect('clients can''t read the call times', NOT has_table_privilege('authenticated', 'private.apple_authorization_calls', 'SELECT'));
UPDATE private.apple_authorization_calls SET at = NOW() - INTERVAL '2 minutes';
SET ROLE authenticated;
SELECT public.save_apple_authorization('xia-code-3');
RESET ROLE;
SELECT pg_temp.expect('a minute later it is sent again', (SELECT count(*) FROM net.http_calls) = 2);
SELECT pg_temp.expect('older call times are deleted',
  (SELECT count(*) FROM private.apple_authorization_calls WHERE at < NOW() - INTERVAL '1 minute') = 0);
RESET app.settings.push_webhook_secret;
