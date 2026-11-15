// Sign in with Apple REST calls: exchange an authorization code for a refresh
// token, and revoke that token. Both authenticate with a client secret, a JWT
// signed with our Sign in with Apple key.
// https://developer.apple.com/documentation/sign_in_with_apple/sign_in_with_apple_rest_api

import * as jose from "https://esm.sh/jose@5";

export const APPLE_TEAM_ID = "2Y57C77BK4";
/// The iOS app's bundle id: native sign-ins are issued to it.
export const APPLE_CLIENT_ID = "app.nous-deux";
const APPLE = "https://appleid.apple.com";

export interface AppleKey {
  keyId: string;
  /// The .p8 file's contents (PKCS #8, PEM).
  privateKey: string;
}

export type Fetch = typeof fetch;

/// APPLE_SIGN_IN_KEY is the .p8 file's contents. On one line, as an
/// environment value, its line breaks are written as \n.
export function readAppleKey(): AppleKey | null {
  const keyId = Deno.env.get("APPLE_SIGN_IN_KEY_ID");
  const privateKey = Deno.env.get("APPLE_SIGN_IN_KEY")?.replaceAll("\\n", "\n");
  return keyId && privateKey ? { keyId, privateKey } : null;
}

export async function clientSecret(
  key: AppleKey,
  now = Date.now(),
): Promise<string> {
  const iat = Math.floor(now / 1000);
  return await new jose.SignJWT({})
    .setProtectedHeader({ alg: "ES256", kid: key.keyId })
    .setIssuer(APPLE_TEAM_ID)
    .setSubject(APPLE_CLIENT_ID)
    .setAudience(APPLE)
    .setIssuedAt(iat)
    .setExpirationTime(iat + 300)
    .sign(await jose.importPKCS8(key.privateKey, "ES256"));
}

/// Retries network errors and Apple's 5xx answers twice, a second then two
/// apart: a revocation that fails here is not tried again later.
async function post(
  fetchFn: Fetch,
  key: AppleKey,
  path: string,
  fields: Record<string, string>,
  retryDelaysMs = [1000, 2000],
): Promise<Response> {
  for (let attempt = 0; ; attempt++) {
    const last = attempt >= retryDelaysMs.length;
    try {
      const res = await fetchFn(`${APPLE}${path}`, {
        method: "POST",
        headers: { "Content-Type": "application/x-www-form-urlencoded" },
        body: new URLSearchParams({
          client_id: APPLE_CLIENT_ID,
          client_secret: await clientSecret(key),
          ...fields,
        }),
      });
      if (res.status < 500 || last) return res;
    } catch (e) {
      if (last) throw e;
    }
    await new Promise((r) => setTimeout(r, retryDelaysMs[attempt]));
  }
}

/// Apple's error bodies are small JSON like {"error":"invalid_grant"} and
/// never hold tokens, so they are safe to log.
async function failure(what: string, res: Response): Promise<Error> {
  return new Error(`${what}: ${res.status} ${(await res.text()).slice(0, 200)}`);
}

/// Returns the refresh token and the Apple account it belongs to.
export async function exchangeCode(
  key: AppleKey,
  code: string,
  fetchFn: Fetch = fetch,
): Promise<{ refreshToken: string; appleSub: string }> {
  // No retry: an authorization code works once, and Apple may have used it.
  const res = await post(fetchFn, key, "/auth/token", {
    code,
    grant_type: "authorization_code",
  }, []);
  if (!res.ok) throw await failure("Apple code exchange failed", res);
  const body = await res.json();
  const sub = typeof body.id_token === "string"
    ? jose.decodeJwt(body.id_token).sub
    : undefined;
  if (typeof body.refresh_token !== "string" || !sub) {
    throw new Error("Apple sent no refresh token or account id");
  }
  return { refreshToken: body.refresh_token, appleSub: sub };
}

export async function revokeToken(
  key: AppleKey,
  refreshToken: string,
  fetchFn: Fetch = fetch,
  retryDelaysMs?: number[],
): Promise<void> {
  const res = await post(fetchFn, key, "/auth/revoke", {
    token: refreshToken,
    token_type_hint: "refresh_token",
  }, retryDelaysMs);
  if (!res.ok) throw await failure("Apple token revocation failed", res);
}
