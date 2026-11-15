\set ON_ERROR_STOP 1
-- Ada signed in with Apple, Gus with Google. Ada's authorization code goes to
-- the apple-tokens function; her refresh token is revoked when she deletes
-- her account. Every check prints a line; a wrong result raises.
INSERT INTO auth.users (id) VALUES
 ('00000000-0000-0000-0000-00000000090a'),('00000000-0000-0000-0000-00000000090b'),
 ('00000000-0000-0000-0000-00000000090c');
INSERT INTO auth.identities (user_id, provider, provider_id) VALUES
 ('00000000-0000-0000-0000-00000000090a','apple','001234.ada.apple'),
 ('00000000-0000-0000-0000-00000000090b','google','gus-google-sub'),
 ('00000000-0000-0000-0000-00000000090c','apple','009876.cy.apple');
INSERT INTO public.profiles (id, username) VALUES
 ('00000000-0000-0000-0000-00000000090a','Ada'),('00000000-0000-0000-0000-00000000090b','Gus'),
 ('00000000-0000-0000-0000-00000000090c','Cy');
TRUNCATE net.http_calls;

CREATE FUNCTION pg_temp.expect(label text, ok boolean) RETURNS text
LANGUAGE plpgsql AS $$
BEGIN
  IF NOT ok THEN RAISE EXCEPTION '%: failed', label; END IF;
  RETURN label || ': ok';
END $$;

-- Signed-out callers are refused.
SET ROLE anon;
DO $$ BEGIN
  PERFORM public.save_apple_authorization('code');
  RAISE EXCEPTION 'expected a refusal';
EXCEPTION WHEN insufficient_privilege THEN
  RAISE NOTICE 'signed-out callers are refused';
END $$;
RESET ROLE;

-- Without the secret, nothing is sent and sign-in carries on.
SET ROLE authenticated;
SET request.jwt.claim.sub = '00000000-0000-0000-0000-00000000090a';
SELECT public.save_apple_authorization('ada-code-0');
RESET ROLE;
SELECT pg_temp.expect('no secret, nothing sent', NOT EXISTS (SELECT 1 FROM net.http_calls));

SET app.settings.push_webhook_secret = 'dry-run-secret';

-- Ada's code goes to the function with her Apple account id.
SET ROLE authenticated;
SET request.jwt.claim.sub = '00000000-0000-0000-0000-00000000090a';
SELECT public.save_apple_authorization('ada-code-1');
RESET ROLE;
SELECT pg_temp.expect('the code goes to apple-tokens with the secret',
  (SELECT count(*) = 1 FROM net.http_calls)
  AND (SELECT url = 'http://supabase-edge-functions:9000/apple-tokens'
          AND headers->>'x-webhook-secret' = 'dry-run-secret'
          AND body = jsonb_build_object(
            'type', 'exchange',
            'user_id', '00000000-0000-0000-0000-00000000090a',
            'apple_sub', '001234.ada.apple',
            'code', 'ada-code-1')
       FROM net.http_calls));
TRUNCATE net.http_calls;

-- Gus has no Apple identity; an empty code is refused.
SET ROLE authenticated;
SET request.jwt.claim.sub = '00000000-0000-0000-0000-00000000090b';
DO $$ BEGIN
  PERFORM public.save_apple_authorization('gus-code');
  RAISE EXCEPTION 'expected a refusal';
EXCEPTION WHEN insufficient_privilege THEN
  RAISE NOTICE 'an account without Apple sign-in is refused';
END $$;
SET request.jwt.claim.sub = '00000000-0000-0000-0000-00000000090a';
DO $$ BEGIN
  PERFORM public.save_apple_authorization('');
  RAISE EXCEPTION 'expected a refusal';
EXCEPTION WHEN invalid_parameter_value THEN
  RAISE NOTICE 'an empty code is refused';
END $$;

-- Clients never see or write tokens, nor call the function directly.
DO $$ BEGIN
  PERFORM 1 FROM public.apple_tokens;
  RAISE EXCEPTION 'expected a refusal';
EXCEPTION WHEN insufficient_privilege THEN
  RAISE NOTICE 'clients cannot read apple_tokens';
END $$;
DO $$ BEGIN
  INSERT INTO public.apple_tokens (user_id, refresh_token)
  VALUES ('00000000-0000-0000-0000-00000000090a', 'forged');
  RAISE EXCEPTION 'expected a refusal';
EXCEPTION WHEN insufficient_privilege THEN
  RAISE NOTICE 'clients cannot write apple_tokens';
END $$;
DO $$ BEGIN
  PERFORM private.call_apple_tokens('{"type":"revoke","refresh_token":"x"}');
  RAISE EXCEPTION 'expected a refusal';
EXCEPTION WHEN insufficient_privilege THEN
  RAISE NOTICE 'clients cannot call the function themselves';
END $$;
RESET ROLE;
SELECT pg_temp.expect('refused calls sent nothing', NOT EXISTS (SELECT 1 FROM net.http_calls));

-- The function (service role) stores the tokens it got from Apple.
SET ROLE service_role;
INSERT INTO public.apple_tokens (user_id, refresh_token) VALUES
 ('00000000-0000-0000-0000-00000000090a', 'ada-refresh'),
 ('00000000-0000-0000-0000-00000000090c', 'cy-refresh');
RESET ROLE;

-- Ada deletes her account: her token goes to the function to be revoked.
SET ROLE authenticated;
SET request.jwt.claim.sub = '00000000-0000-0000-0000-00000000090a';
SELECT public.delete_my_account();
RESET ROLE;
SELECT pg_temp.expect('deleting the account revokes its Apple token',
  (SELECT count(*) = 1 FROM net.http_calls)
  AND (SELECT url = 'http://supabase-edge-functions:9000/apple-tokens'
          AND headers->>'x-webhook-secret' = 'dry-run-secret'
          AND body = '{"type":"revoke","refresh_token":"ada-refresh"}'::jsonb
       FROM net.http_calls));
SELECT pg_temp.expect('and the token is gone from the database',
  NOT EXISTS (SELECT 1 FROM public.apple_tokens WHERE user_id = '00000000-0000-0000-0000-00000000090a'));
SELECT pg_temp.expect('another account keeps its token',
  EXISTS (SELECT 1 FROM public.apple_tokens WHERE user_id = '00000000-0000-0000-0000-00000000090c'));
TRUNCATE net.http_calls;

-- Gus never had an Apple token: deleting his account sends nothing.
SET ROLE authenticated;
SET request.jwt.claim.sub = '00000000-0000-0000-0000-00000000090b';
SELECT public.delete_my_account();
RESET ROLE;
SELECT pg_temp.expect('no Apple token, nothing to revoke', NOT EXISTS (SELECT 1 FROM net.http_calls));

-- Without the secret, deletion still works; the revoke is skipped.
RESET app.settings.push_webhook_secret;
SET ROLE authenticated;
SET request.jwt.claim.sub = '00000000-0000-0000-0000-00000000090c';
SELECT public.delete_my_account();
RESET ROLE;
SELECT pg_temp.expect('without the secret the account is still deleted',
  NOT EXISTS (SELECT 1 FROM auth.users WHERE id = '00000000-0000-0000-0000-00000000090c')
  AND NOT EXISTS (SELECT 1 FROM net.http_calls));
