\set ON_ERROR_STOP 1
-- The auth server asks public.hook_before_user_created before creating a
-- user. Events are shaped like GoTrue's: the user to be created, with its
-- provider in app_metadata. Every check prints a line; a wrong result raises.

CREATE FUNCTION pg_temp.expect(label text, ok boolean) RETURNS text
LANGUAGE plpgsql AS $$
BEGIN
  IF ok IS NOT TRUE THEN RAISE EXCEPTION '%: failed', label; END IF;
  RETURN label || ': ok';
END $$;

CREATE FUNCTION pg_temp.event(provider text, email text) RETURNS jsonb
LANGUAGE sql AS $$
  SELECT jsonb_build_object(
    'metadata', jsonb_build_object('name', 'before-user-created'),
    'user', jsonb_build_object(
      'email', email,
      'app_metadata', jsonb_build_object(
        'provider', provider, 'providers', jsonb_build_array(provider))))
$$;

SET ROLE supabase_auth_admin;

SELECT pg_temp.expect('an email sign-up is refused with 403',
  (SELECT public.hook_before_user_created(pg_temp.event('email', 'someone@example.com'))
     #>> '{error,http_code}' = '403'));
SELECT pg_temp.expect('Google sign-ups go through',
  public.hook_before_user_created(pg_temp.event('google', 'a@gmail.com')) = '{}'::jsonb);
SELECT pg_temp.expect('Apple sign-ups go through',
  public.hook_before_user_created(pg_temp.event('apple', 'b@privaterelay.appleid.com')) = '{}'::jsonb);
SELECT pg_temp.expect('phone sign-ups go through',
  public.hook_before_user_created(pg_temp.event('phone', NULL)) = '{}'::jsonb);

RESET ROLE;

-- Nobody else can call the hook (it is also reachable as an RPC).
SET ROLE authenticated;
DO $$ BEGIN
  PERFORM public.hook_before_user_created('{}'::jsonb);
  RAISE EXCEPTION 'expected permission denied';
EXCEPTION WHEN insufficient_privilege THEN RAISE NOTICE 'authenticated cannot call the hook';
END $$;
RESET ROLE;
SET ROLE anon;
DO $$ BEGIN
  PERFORM public.hook_before_user_created('{}'::jsonb);
  RAISE EXCEPTION 'expected permission denied';
EXCEPTION WHEN insufficient_privilege THEN RAISE NOTICE 'anon cannot call the hook';
END $$;
RESET ROLE;
