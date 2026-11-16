-- The push secret moves from a database-wide setting into a private table
-- (security review of 2026-11-15, F8).
--
-- ALTER DATABASE ... SET app.settings.push_webhook_secret put it in every
-- session of every role: any SQL running as anon or authenticated could read
-- it with current_setting(). private.secrets is readable by the database
-- owner only, which the trigger functions run as (SECURITY DEFINER).
--
-- A fresh stack still gets the setting from its environment at first boot
-- (infra/supabase/compose.yml); this migration moves it here and removes the
-- setting. Removing it takes a superuser: run as postgres (db-migrate.sh), the
-- migration warns instead, and docs/SELF_HOSTING.md has the one-line fix to
-- run as supabase_admin. To rotate, see the same page.

CREATE TABLE private.secrets (
  name TEXT PRIMARY KEY,
  value TEXT NOT NULL
);
REVOKE ALL ON private.secrets FROM PUBLIC;

COMMENT ON TABLE private.secrets IS
  'Secrets the database itself uses (push_webhook_secret). Owner only.';

DO $$
DECLARE
  _secret TEXT := current_setting('app.settings.push_webhook_secret', true);
BEGIN
  IF _secret IS NOT NULL AND _secret <> '' THEN
    INSERT INTO private.secrets (name, value) VALUES ('push_webhook_secret', _secret)
    ON CONFLICT (name) DO NOTHING;
    BEGIN
      EXECUTE format('ALTER DATABASE %I RESET %I', current_database(), 'app.settings.push_webhook_secret');
    EXCEPTION WHEN insufficient_privilege THEN
      RAISE WARNING 'push secret copied to private.secrets; remove the old setting as supabase_admin: ALTER DATABASE % RESET "app.settings.push_webhook_secret"', current_database();
    END;
  END IF;
END $$;

-- The secret, or null when there is none. The session setting is only a
-- fallback for the SQL dry run, which sets it per session.
CREATE OR REPLACE FUNCTION private.push_webhook_secret()
RETURNS TEXT
LANGUAGE sql
STABLE
SET search_path = ''
AS $$
  SELECT COALESCE(
    (SELECT value FROM private.secrets WHERE name = 'push_webhook_secret'),
    NULLIF(current_setting('app.settings.push_webhook_secret', true), '')
  )
$$;
REVOKE ALL ON FUNCTION private.push_webhook_secret() FROM PUBLIC;

-- The two callers read it from there; nothing else changes.
CREATE OR REPLACE FUNCTION private.notify_push()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  _secret TEXT := private.push_webhook_secret();
BEGIN
  IF _secret IS NULL THEN
    RAISE WARNING 'push skipped: no push_webhook_secret';
    RETURN NULL;
  END IF;
  PERFORM net.http_post(
    url := 'http://supabase-edge-functions:9000/' || TG_ARGV[0],
    body := jsonb_build_object(
      'type', TG_OP,
      'table', TG_TABLE_NAME,
      'schema', TG_TABLE_SCHEMA,
      'record', to_jsonb(NEW),
      'old_record', CASE WHEN TG_OP = 'UPDATE' THEN to_jsonb(OLD) END
    ),
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'x-webhook-secret', _secret
    ),
    timeout_milliseconds := 5000
  );
  RETURN NULL;
END;
$$;

CREATE OR REPLACE FUNCTION private.call_apple_tokens(_body JSONB)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  _secret TEXT := private.push_webhook_secret();
BEGIN
  IF _secret IS NULL THEN
    RAISE WARNING 'apple-tokens skipped: no push_webhook_secret';
    RETURN FALSE;
  END IF;
  PERFORM net.http_post(
    url := 'http://supabase-edge-functions:9000/apple-tokens',
    body := _body,
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'x-webhook-secret', _secret
    ),
    timeout_milliseconds := 20000
  );
  RETURN TRUE;
END;
$$;
