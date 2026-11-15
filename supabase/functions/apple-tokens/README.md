# apple-tokens

Revokes Sign in with Apple when an account is deleted (App Store guideline
5.1.1(v)). Only the database calls it, on the server's internal network, with
the shared `x-webhook-secret` (migration
`20261115200000_apple_token_revocation.sql`):

- `exchange`: after an Apple sign-in, `save_apple_authorization()` sends the
  one-time authorization code and the account's Apple id. The function trades
  the code for a refresh token and keeps it in `public.apple_tokens`, unless
  the token belongs to another Apple account or the account is already gone;
  then it revokes it at once.
- `revoke`: the account was deleted, so its `apple_tokens` row was too; the
  delete trigger sends the token, and the function revokes it with Apple.

- Settings: `APPLE_SIGN_IN_KEY_ID`, `APPLE_SIGN_IN_KEY` (the `.p8`), plus the
  push functions' `PUSH_WEBHOOK_SECRET` and service role key. Setup and
  troubleshooting: [docs/SELF_HOSTING.md](../../../docs/SELF_HOSTING.md).
- Deploy: `scripts/deploy-functions.sh root@<server>`
- Tests (Apple faked, no local Deno needed): see `handler_test.ts`.
