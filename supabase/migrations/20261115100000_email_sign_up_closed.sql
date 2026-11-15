-- Email and password accounts exist only for people we create them for
-- (store reviewers, test accounts), through the auth admin API
-- (scripts/create-email-account.sh). Anyone else signing up with an email,
-- through /signup, /otp or /magiclink, is refused before the account exists.
-- Google, Apple and phone sign-ups go through unchanged.
--
-- The auth server calls this hook before creating any user once
-- GOTRUE_HOOK_BEFORE_USER_CREATED_ENABLED is on (docs/SELF_HOSTING.md).
-- Accounts created through the admin API never reach it.

CREATE OR REPLACE FUNCTION public.hook_before_user_created(event jsonb)
RETURNS jsonb
LANGUAGE sql
STABLE
SET search_path = ''
AS $$
  SELECT CASE
    WHEN event #>> '{user,app_metadata,provider}' = 'email' THEN
      jsonb_build_object('error', jsonb_build_object(
        'http_code', 403,
        'message', 'Email sign-up is not open.'))
    ELSE '{}'::jsonb
  END
$$;

REVOKE ALL ON FUNCTION public.hook_before_user_created(jsonb) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.hook_before_user_created(jsonb) TO supabase_auth_admin;
