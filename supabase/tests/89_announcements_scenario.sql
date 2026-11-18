\set ON_ERROR_STOP 1
-- Nouveautés: the team's messages to everyone (docs/NOUVEAUTES.md, Task 1).
-- Ada (89a) and Bo (89b) are a couple. Sent messages are readable by anyone
-- signed in, drafts by nobody; only the send-announcement function (service
-- role) writes them. Each person keeps their own push switch and last-read
-- time. Every check prints a line; a wrong result raises.
INSERT INTO auth.users (id) VALUES
 ('00000000-0000-0000-0000-00000000089a'),
 ('00000000-0000-0000-0000-00000000089b');
INSERT INTO public.profiles (id, username) VALUES
 ('00000000-0000-0000-0000-00000000089a', 'Ada'),
 ('00000000-0000-0000-0000-00000000089b', 'Bo');
INSERT INTO public.couples (id, user1_id, user2_id) VALUES
 ('89898989-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-00000000089a', '00000000-0000-0000-0000-00000000089b');

CREATE FUNCTION pg_temp.expect(label text, ok boolean) RETURNS text
LANGUAGE plpgsql AS $$
BEGIN
  IF NOT ok THEN RAISE EXCEPTION '%: failed', label; END IF;
  RETURN label || ': ok';
END $$;

-- What the function writes: one sent message, one tested draft, a tester.
INSERT INTO public.announcements (id, slug, content, tested_at, sent_at) VALUES
 ('89898989-0000-0000-0000-0000000000a1', '2026-11-20-listes',
  '{"fr":{"title":"Les listes","body":"Courses."},"en":{"title":"Lists","body":"Groceries."}}',
  now() - interval '1 hour', now()),
 ('89898989-0000-0000-0000-0000000000a2', '2026-11-21-brouillon',
  '{"fr":{"title":"Brouillon","body":"Pas encore."},"en":{"title":"Draft","body":"Not yet."}}',
  now(), NULL);
INSERT INTO public.announcement_testers (profile_id) VALUES ('00000000-0000-0000-0000-00000000089a');

DO $$ BEGIN
  INSERT INTO public.announcements (slug, content) VALUES ('2026-11-20-listes', '{}');
  RAISE EXCEPTION 'expected a refusal';
EXCEPTION WHEN unique_violation THEN RAISE NOTICE 'a slug is stored once';
END $$;
DO $$ BEGIN
  INSERT INTO public.announcements (slug, content) VALUES ('Listes partagées', '{}');
  RAISE EXCEPTION 'expected a refusal';
EXCEPTION WHEN check_violation THEN RAISE NOTICE 'a malformed slug is refused';
END $$;

SELECT pg_temp.expect('a new profile gets app-news pushes',
  (SELECT announcements_push FROM public.profiles WHERE id = '00000000-0000-0000-0000-00000000089a'));
SELECT pg_temp.expect('and has read everything sent before it existed',
  (SELECT announcements_seen_at > now() - interval '1 minute'
   FROM public.profiles WHERE id = '00000000-0000-0000-0000-00000000089a'));

-- Ada, signed in.
SET ROLE authenticated;
SET request.jwt.claim.sub = '00000000-0000-0000-0000-00000000089a';
SELECT pg_temp.expect('signed in, the sent message is readable',
  (SELECT count(*) = 1 FROM public.announcements));
SELECT pg_temp.expect('with its text and send time',
  (SELECT content->'fr'->>'title' = 'Les listes' AND sent_at IS NOT NULL
   FROM public.announcements WHERE id = '89898989-0000-0000-0000-0000000000a1'));
DO $$ BEGIN
  PERFORM slug FROM public.announcements;
  RAISE EXCEPTION 'expected a refusal';
EXCEPTION WHEN insufficient_privilege THEN RAISE NOTICE 'the slug stays the function''s';
END $$;
DO $$ BEGIN
  PERFORM tested_at FROM public.announcements;
  RAISE EXCEPTION 'expected a refusal';
EXCEPTION WHEN insufficient_privilege THEN RAISE NOTICE 'so does the test time';
END $$;
DO $$ BEGIN
  INSERT INTO public.announcements (slug, content, sent_at)
  VALUES ('2026-11-22-faux', '{}', now());
  RAISE EXCEPTION 'expected a refusal';
EXCEPTION WHEN insufficient_privilege THEN RAISE NOTICE 'clients can''t write a message';
END $$;
DO $$ BEGIN
  UPDATE public.announcements SET sent_at = now();
  RAISE EXCEPTION 'expected a refusal';
EXCEPTION WHEN insufficient_privilege THEN RAISE NOTICE 'or send a draft';
END $$;
DO $$ BEGIN
  DELETE FROM public.announcements;
  RAISE EXCEPTION 'expected a refusal';
EXCEPTION WHEN insufficient_privilege THEN RAISE NOTICE 'or delete one';
END $$;
DO $$ BEGIN
  PERFORM 1 FROM public.announcement_testers;
  RAISE EXCEPTION 'expected a refusal';
EXCEPTION WHEN insufficient_privilege THEN RAISE NOTICE 'clients can''t read who tests';
END $$;
DO $$ BEGIN
  INSERT INTO public.announcement_testers (profile_id) VALUES (auth.uid());
  RAISE EXCEPTION 'expected a refusal';
EXCEPTION WHEN insufficient_privilege THEN RAISE NOTICE 'or make themselves a tester';
END $$;

UPDATE public.profiles SET announcements_push = false, announcements_seen_at = now()
WHERE id = auth.uid();
SELECT pg_temp.expect('Ada turns app-news pushes off and marks the list read',
  (SELECT NOT announcements_push FROM public.profiles WHERE id = auth.uid()));
WITH changed AS (
  UPDATE public.profiles SET announcements_push = false
  WHERE id = '00000000-0000-0000-0000-00000000089b' RETURNING 1
)
SELECT pg_temp.expect('but can''t switch Bo''s', (SELECT count(*) = 0 FROM changed));

-- Signed out.
RESET ROLE;
SET ROLE anon; RESET request.jwt.claim.sub;
DO $$ BEGIN
  PERFORM 1 FROM public.announcements;
  RAISE EXCEPTION 'expected a refusal';
EXCEPTION WHEN insufficient_privilege THEN RAISE NOTICE 'signed out, no message is readable';
END $$;
DO $$ BEGIN
  PERFORM 1 FROM public.announcement_testers;
  RAISE EXCEPTION 'expected a refusal';
EXCEPTION WHEN insufficient_privilege THEN RAISE NOTICE 'nor who tests';
END $$;

-- The function's own reads, as the service role.
RESET ROLE;
SET ROLE service_role;
SELECT pg_temp.expect('the function reads drafts and testers',
  (SELECT count(*) = 2 FROM public.announcements)
  AND (SELECT count(*) = 1 FROM public.announcement_testers));
WITH sent AS (
  UPDATE public.announcements SET sent_at = now()
  WHERE slug = '2026-11-20-listes' AND sent_at IS NULL RETURNING id
)
SELECT pg_temp.expect('a message already sent can''t be sent again', (SELECT count(*) = 0 FROM sent));

-- Ada deletes her account: her tester row goes with it.
RESET ROLE;
SET ROLE authenticated;
SET request.jwt.claim.sub = '00000000-0000-0000-0000-00000000089a';
SELECT public.delete_my_account();
RESET ROLE;
SELECT pg_temp.expect('deleting an account removes its tester row',
  NOT EXISTS (SELECT 1 FROM public.announcement_testers));
SELECT pg_temp.expect('and leaves the messages',
  (SELECT count(*) = 2 FROM public.announcements));
DELETE FROM public.announcements WHERE id IN
 ('89898989-0000-0000-0000-0000000000a1', '89898989-0000-0000-0000-0000000000a2');
