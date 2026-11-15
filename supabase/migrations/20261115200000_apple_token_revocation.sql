-- Sign in with Apple: revoke the app's access when the account is deleted
-- (App Store guideline 5.1.1(v)).
--
-- Apple revokes with a refresh token, which only exists once the one-time
-- authorization code from the sign-in sheet is exchanged with our key. The app
-- passes that code to save_apple_authorization() right after signing in; the
-- database hands it to the internal apple-tokens function, which exchanges it
-- and stores the refresh token here. Deleting the account deletes the row
-- (ON DELETE CASCADE), and the delete trigger sends the token back to the
-- function, which revokes it.
--
-- The functions are on the stack's internal network only and check the same
-- shared secret as the push functions (migration 20261111100000). Without it
-- set, nothing is sent: sign-in and deletion still work.

CREATE TABLE public.apple_tokens (
  user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  refresh_token TEXT NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE public.apple_tokens IS
  'Apple refresh token per Apple-signed-in account, kept only to revoke the app''s access when the account is deleted. Server only.';

-- Only the apple-tokens function (service role) reads or writes it.
ALTER TABLE public.apple_tokens ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.apple_tokens FROM PUBLIC, anon, authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.apple_tokens TO service_role;

-- Calls the internal apple-tokens function. Returns false when the secret
-- isn't set, so nothing was sent.
CREATE OR REPLACE FUNCTION private.call_apple_tokens(_body JSONB)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  _secret TEXT := current_setting('app.settings.push_webhook_secret', true);
BEGIN
  IF _secret IS NULL OR _secret = '' THEN
    RAISE WARNING 'apple-tokens skipped: app.settings.push_webhook_secret is not set';
    RETURN FALSE;
  END IF;
  PERFORM net.http_post(
    url := 'http://supabase-edge-functions:9000/apple-tokens',
    body := _body,
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'x-webhook-secret', _secret
    ),
    timeout_milliseconds := 10000
  );
  RETURN TRUE;
END;
$$;

REVOKE ALL ON FUNCTION private.call_apple_tokens(JSONB) FROM PUBLIC;

-- The app calls this once after each Sign in with Apple, with the
-- authorization code from the sign-in sheet (valid five minutes, single use).
-- The Apple account id goes along, so the function only keeps a token that
-- belongs to the caller's Apple identity.
CREATE OR REPLACE FUNCTION public.save_apple_authorization(code TEXT)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  _me UUID := auth.uid();
  _apple_sub TEXT;
BEGIN
  IF _me IS NULL THEN
    RAISE EXCEPTION 'Not signed in' USING ERRCODE = '42501';
  END IF;
  IF code IS NULL OR length(code) NOT BETWEEN 1 AND 1000 THEN
    RAISE EXCEPTION 'Invalid authorization code' USING ERRCODE = '22023';
  END IF;

  SELECT provider_id INTO _apple_sub
  FROM auth.identities
  WHERE user_id = _me AND provider = 'apple';
  IF _apple_sub IS NULL THEN
    RAISE EXCEPTION 'Not signed in with Apple' USING ERRCODE = '42501';
  END IF;

  PERFORM private.call_apple_tokens(jsonb_build_object(
    'type', 'exchange',
    'user_id', _me,
    'apple_sub', _apple_sub,
    'code', code
  ));
END;
$$;

COMMENT ON FUNCTION public.save_apple_authorization(TEXT) IS
  'After Sign in with Apple: pass the authorization code to the server, which keeps Apple''s refresh token to revoke it when the account is deleted.';

REVOKE ALL ON FUNCTION public.save_apple_authorization(TEXT) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.save_apple_authorization(TEXT) TO authenticated;

-- The row goes with the account (delete_my_account, or a delete in Studio).
CREATE OR REPLACE FUNCTION private.revoke_apple_token()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
  PERFORM private.call_apple_tokens(jsonb_build_object(
    'type', 'revoke',
    'refresh_token', OLD.refresh_token
  ));
  RETURN NULL;
END;
$$;

REVOKE ALL ON FUNCTION private.revoke_apple_token() FROM PUBLIC;

CREATE TRIGGER apple_tokens_revoke
  AFTER DELETE ON public.apple_tokens
  FOR EACH ROW EXECUTE FUNCTION private.revoke_apple_token();
