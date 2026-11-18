-- Nouveautés: messages from the team to everyone who uses the app
-- (docs/NOUVEAUTES.md). scripts/announce.sh posts a message file to the
-- internal send-announcement function, which records it here and pushes it
-- in each person's app language. The app lists the sent messages under
-- Paramètres › Nouveautés.
--
-- A message holds no personal data. Per person, the profile keeps whether
-- app-news pushes are on and how far they have read the list (the newest
-- message's send time when they opened it); opens aren't tracked.

-- ---------------------------------------------------------------------------
-- 1. The messages. A row is a draft once its test send went to the team
--    (tested_at), and a message once sent to everyone (sent_at). The slug is
--    the message file's name, so a file can't be sent twice. Signed-in
--    people read the sent ones, whenever they joined; only the function
--    (service role) writes.
-- ---------------------------------------------------------------------------
CREATE TABLE public.announcements (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  slug TEXT NOT NULL UNIQUE CHECK (slug ~ '^[0-9]{4}-[0-9]{2}-[0-9]{2}-[a-z0-9-]+$'),
  content JSONB NOT NULL,
  tested_at TIMESTAMPTZ,
  sent_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

COMMENT ON TABLE public.announcements IS
  'Messages from the team: {"fr":{"title","body"},"en":{...}} per app language. Draft until sent_at.';

CREATE INDEX idx_announcements_sent_at ON public.announcements (sent_at DESC)
  WHERE sent_at IS NOT NULL;

ALTER TABLE public.announcements ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE public.announcements FROM PUBLIC, anon, authenticated;
GRANT SELECT (id, content, sent_at) ON TABLE public.announcements TO authenticated;
GRANT ALL ON TABLE public.announcements TO service_role;

CREATE POLICY "Signed-in people read sent messages"
ON public.announcements FOR SELECT
TO authenticated
USING (sent_at IS NOT NULL);

-- ---------------------------------------------------------------------------
-- 2. Who gets the test send: the team's own accounts. No client reads or
--    writes this; a row goes with its account.
-- ---------------------------------------------------------------------------
CREATE TABLE public.announcement_testers (
  profile_id UUID PRIMARY KEY REFERENCES public.profiles(id) ON DELETE CASCADE
);

COMMENT ON TABLE public.announcement_testers IS
  'Accounts that receive the test send of a message (scripts/announce.sh --test).';

ALTER TABLE public.announcement_testers ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE public.announcement_testers FROM PUBLIC, anon, authenticated;
GRANT ALL ON TABLE public.announcement_testers TO service_role;

-- ---------------------------------------------------------------------------
-- 3. Each person's switch and how far they have read. Pushes are on for
--    everyone, existing accounts included; turning them off leaves the list
--    readable.
--    The last-read time starts when the profile is created, so someone who
--    joins later sees every older message without them all marked unread.
-- ---------------------------------------------------------------------------
ALTER TABLE public.profiles
  ADD COLUMN announcements_push BOOLEAN NOT NULL DEFAULT TRUE,
  ADD COLUMN announcements_seen_at TIMESTAMPTZ NOT NULL DEFAULT now();

COMMENT ON COLUMN public.profiles.announcements_push IS
  'Whether this person gets a push for each new message from the team.';
COMMENT ON COLUMN public.profiles.announcements_seen_at IS
  'Send time of the newest message this person has read in Nouveautés (creation time until then); later messages show as unread.';

GRANT INSERT (announcements_push, announcements_seen_at),
      UPDATE (announcements_push, announcements_seen_at)
  ON TABLE public.profiles TO authenticated;
