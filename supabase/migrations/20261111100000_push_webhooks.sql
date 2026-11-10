-- Pushes to the partner: the database calls the push functions itself.
--
-- Replaces the two Database Webhooks that used to be set up by hand in the
-- hosted dashboard, so a fresh database gets them with the other migrations.
-- The functions are reachable on the stack's internal network only (no public
-- route), and each checks a shared secret. The secret lives in the database
-- setting app.settings.push_webhook_secret, written at first boot from the
-- server's environment (see docs/SELF_HOSTING.md). Without it, pushes are
-- skipped and the write still succeeds.

-- pg_net ships with the Supabase Postgres image (and is already created there
-- at first boot). The plain Postgres used for the SQL dry run stubs it.
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'pg_net')
     AND EXISTS (SELECT 1 FROM pg_available_extensions WHERE name = 'pg_net') THEN
    CREATE EXTENSION pg_net;
  END IF;
END $$;

CREATE SCHEMA IF NOT EXISTS private;
REVOKE ALL ON SCHEMA private FROM PUBLIC;

-- Trigger argument: the function to call (e.g. 'notify-partner-ping').
-- The body has the shape of a Supabase Database Webhook.
CREATE OR REPLACE FUNCTION private.notify_push()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  _secret TEXT := current_setting('app.settings.push_webhook_secret', true);
BEGIN
  IF _secret IS NULL OR _secret = '' THEN
    RAISE WARNING 'push skipped: app.settings.push_webhook_secret is not set';
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

REVOKE ALL ON FUNCTION private.notify_push() FROM PUBLIC;

CREATE TRIGGER period_logs_notify_partner
  AFTER INSERT ON public.period_logs
  FOR EACH ROW EXECUTE FUNCTION private.notify_push('notify-partner-period');

-- One row per person: sending again updates it.
CREATE TRIGGER couple_pings_notify_partner
  AFTER INSERT OR UPDATE ON public.couple_pings
  FOR EACH ROW EXECUTE FUNCTION private.notify_push('notify-partner-ping');
