// What the database asks of apple-tokens (migration
// 20261115200000_apple_token_revocation.sql):
// - exchange: after a Sign in with Apple, turn the authorization code into a
//   refresh token and keep it for the account;
// - revoke: the account was deleted, revoke the token it had.

import { fromDatabase, json } from "../_shared/database.ts";
import {
  type AppleKey,
  exchangeCode,
  type Fetch,
  revokeToken,
} from "./apple.ts";

export interface Deps {
  key: AppleKey | null;
  /// Stores the account's token; false when the account no longer exists.
  saveToken: (userId: string, refreshToken: string) => Promise<boolean>;
  fetch?: Fetch;
}

type Job =
  | { type: "exchange"; user_id: string; apple_sub: string; code: string }
  | { type: "revoke"; refresh_token: string };

export async function handle(req: Request, deps: Deps): Promise<Response> {
  if (!fromDatabase(req)) return new Response("forbidden", { status: 403 });
  if (!deps.key) {
    console.error("apple-tokens: APPLE_SIGN_IN_KEY_ID or APPLE_SIGN_IN_KEY is not set");
    return json({ ok: false, skipped: "Apple key not set" });
  }
  const key = deps.key;
  const fetchFn = deps.fetch ?? fetch;

  let body: Job;
  try {
    body = await req.json();
  } catch {
    return json({ ok: false, skipped: "not JSON" });
  }
  if (typeof body !== "object" || body === null) {
    return json({ ok: false, skipped: "not a job" });
  }

  try {
    if (body.type === "exchange") {
      const token = await exchangeCode(key, body.code, fetchFn);
      // Only keep a token for the caller's own Apple account. Anything else
      // is revoked at once, so no stray authorization is left behind.
      if (token.appleSub !== body.apple_sub) {
        await revokeToken(key, token.refreshToken, fetchFn);
        return json({ ok: false, skipped: "code from another Apple account" });
      }
      let saved: boolean;
      try {
        saved = await deps.saveToken(body.user_id, token.refreshToken);
      } catch (e) {
        // A token we can't keep could never be revoked later.
        await revokeToken(key, token.refreshToken, fetchFn);
        throw e;
      }
      if (!saved) {
        await revokeToken(key, token.refreshToken, fetchFn);
        return json({ ok: false, skipped: "account deleted meanwhile" });
      }
      return json({ ok: true });
    }
    if (body.type === "revoke") {
      await revokeToken(key, body.refresh_token, fetchFn);
      return json({ ok: true });
    }
    return json({ ok: false, skipped: "unknown type" });
  } catch (e) {
    console.error(`apple-tokens ${body.type}:`, (e as Error).message);
    return json({ ok: false });
  }
}
