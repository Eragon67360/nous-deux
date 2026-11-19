-- Update screen (docs/UPDATE_SCREEN.md): the latest build sent to testers,
-- per platform, the oldest build that still works, and one line on what
-- changed. Signed-in people read it (signed-out callers get nothing in
-- public, 98_hardening). Only the release jobs write the latest build,
-- through record_app_build() and a token whose SHA-256 alone is stored
-- here; the minimum is raised by hand (scripts/app-builds.sh).

CREATE TABLE public.app_builds (
  platform text PRIMARY KEY CHECK (platform IN ('android', 'ios')),
  latest_build integer NOT NULL DEFAULT 0 CHECK (latest_build >= 0),
  min_build integer NOT NULL DEFAULT 0 CHECK (min_build >= 0),
  note jsonb NOT NULL DEFAULT '{}'::jsonb CHECK (jsonb_typeof(note) = 'object'),
  updated_at timestamptz NOT NULL DEFAULT now()
);

INSERT INTO public.app_builds (platform) VALUES ('android'), ('ios');

ALTER TABLE public.app_builds ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE public.app_builds FROM PUBLIC, anon, authenticated;
GRANT SELECT (platform, latest_build, min_build, note)
  ON TABLE public.app_builds TO authenticated;
GRANT ALL ON TABLE public.app_builds TO service_role;

CREATE POLICY "Signed-in people read the latest builds"
  ON public.app_builds FOR SELECT TO authenticated
  USING (true);

-- The release jobs' token, as its SHA-256. One row at most.
CREATE TABLE private.release_token (
  only_row boolean PRIMARY KEY DEFAULT true CHECK (only_row),
  token_sha256 bytea NOT NULL CHECK (length(token_sha256) = 32)
);
REVOKE ALL ON TABLE private.release_token FROM PUBLIC, anon, authenticated;

-- Called by the release jobs, which have no session (the anon key): the
-- one function signed-out callers may run, and only with the token.
-- Records a build sent to testers and its note; a build older than the
-- latest (a re-run) changes nothing.
CREATE FUNCTION public.record_app_build(
  p_platform text,
  p_build integer,
  p_note jsonb,
  p_token text
) RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
  IF p_token IS NULL OR NOT EXISTS (
    SELECT 1 FROM private.release_token
    WHERE token_sha256 = pg_catalog.sha256(pg_catalog.convert_to(p_token, 'UTF8'))
  ) THEN
    RAISE EXCEPTION 'not allowed' USING ERRCODE = '42501';
  END IF;
  IF p_platform IS NULL OR p_platform NOT IN ('android', 'ios')
     OR p_build IS NULL OR p_build < 1
     OR p_note IS NULL OR jsonb_typeof(p_note) <> 'object' THEN
    RAISE EXCEPTION 'a platform, a build and a note object are needed'
      USING ERRCODE = '22023';
  END IF;
  UPDATE public.app_builds
  SET latest_build = p_build,
      note = p_note,
      updated_at = now()
  WHERE platform = p_platform AND p_build >= latest_build;
END;
$$;

REVOKE ALL ON FUNCTION public.record_app_build(text, integer, jsonb, text)
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.record_app_build(text, integer, jsonb, text)
  TO anon;
