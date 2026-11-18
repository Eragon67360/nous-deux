// FCM HTTP v1 helpers shared by the notify-* Edge Functions.
// Needs the FIREBASE_SERVICE_ACCOUNT_JSON secret (the whole service account JSON).

import * as jose from "https://esm.sh/jose@5";

export interface FirebaseServiceAccount {
  project_id: string;
  private_key: string;
  client_email: string;
}

export function readServiceAccount(): FirebaseServiceAccount | null {
  const raw = Deno.env.get("FIREBASE_SERVICE_ACCOUNT_JSON");
  if (!raw) return null;
  return JSON.parse(raw) as FirebaseServiceAccount;
}

/// The last access token per service account, reused until 5 minutes before
/// it expires: a message to everyone sends many pushes in one run.
const tokens = new Map<string, { token: string; expiresAt: number }>();
const RESERVE_MS = 5 * 60 * 1000;

async function getAccessToken(sa: FirebaseServiceAccount): Promise<string> {
  const cached = tokens.get(sa.client_email);
  if (cached && Date.now() < cached.expiresAt - RESERVE_MS) return cached.token;
  const fresh = await requestAccessToken(sa);
  tokens.set(sa.client_email, {
    token: fresh.access_token,
    expiresAt: Date.now() + fresh.expires_in * 1000,
  });
  return fresh.access_token;
}

async function requestAccessToken(
  sa: FirebaseServiceAccount,
): Promise<{ access_token: string; expires_in: number }> {
  const key = await jose.importPKCS8(sa.private_key, "RS256");
  // Google refuses a token request without the scope ("invalid_scope").
  const jwt = await new jose.SignJWT({
    scope: "https://www.googleapis.com/auth/firebase.messaging",
  })
    .setProtectedHeader({ alg: "RS256", typ: "JWT" })
    .setIssuer(sa.client_email)
    .setSubject(sa.client_email)
    .setAudience("https://oauth2.googleapis.com/token")
    .setIssuedAt()
    .setExpirationTime("1h")
    .sign(key);
  const res = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion: jwt,
    }),
  });
  if (!res.ok) {
    throw new Error(`OAuth2 token failed: ${res.status} ${await res.text()}`);
  }
  const body = await res.json();
  return { access_token: body.access_token, expires_in: Number(body.expires_in) || 0 };
}

export async function sendPush(
  sa: FirebaseServiceAccount,
  message: {
    token: string;
    title: string;
    body: string;
    data?: Record<string, string>;
  },
): Promise<{ ok: boolean; detail?: string }> {
  return await postMessage(sa, {
    token: message.token,
    notification: { title: message.title, body: message.body },
    data: message.data ?? {},
    apns: { payload: { aps: { sound: "default" } } },
  });
}

/// Whether FCM's answer to a push says the token will never work again: the
/// app was uninstalled (UNREGISTERED), or the token isn't one at all. Other
/// failures (server errors, quotas) keep the token.
export function isStaleToken(detail: string | undefined): boolean {
  if (!detail) return false;
  let error: { message?: string; details?: { errorCode?: string }[] } | undefined;
  try {
    error = JSON.parse(detail)?.error;
  } catch {
    return false;
  }
  const codes = (error?.details ?? []).map((d) => d.errorCode);
  if (codes.includes("UNREGISTERED")) return true;
  return codes.includes("INVALID_ARGUMENT") &&
    /registration token/i.test(error?.message ?? "");
}

/// A push that shows nothing and asks the app to do some work: background
/// and low priority on iOS (Apple throttles these, a few an hour at most),
/// normal priority on Android.
export function backgroundMessage(token: string, data: Record<string, string>) {
  return {
    token,
    data,
    android: { priority: "normal" },
    apns: {
      headers: { "apns-push-type": "background", "apns-priority": "5" },
      payload: { aps: { "content-available": 1 } },
    },
  };
}

export async function sendBackgroundPush(
  sa: FirebaseServiceAccount,
  token: string,
  data: Record<string, string>,
): Promise<{ ok: boolean; detail?: string }> {
  return await postMessage(sa, backgroundMessage(token, data));
}

async function postMessage(
  sa: FirebaseServiceAccount,
  message: Record<string, unknown>,
): Promise<{ ok: boolean; detail?: string }> {
  const accessToken = await getAccessToken(sa);
  const res = await fetch(
    `https://fcm.googleapis.com/v1/projects/${sa.project_id}/messages:send`,
    {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${accessToken}`,
      },
      body: JSON.stringify({ message }),
    },
  );
  return res.ok ? { ok: true } : { ok: false, detail: await res.text() };
}
