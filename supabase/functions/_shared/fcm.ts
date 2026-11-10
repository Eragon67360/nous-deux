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

async function getAccessToken(sa: FirebaseServiceAccount): Promise<string> {
  const key = await jose.importPKCS8(sa.private_key, "RS256");
  const jwt = await new jose.SignJWT({})
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
  return (await res.json()).access_token;
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
  const accessToken = await getAccessToken(sa);
  const res = await fetch(
    `https://fcm.googleapis.com/v1/projects/${sa.project_id}/messages:send`,
    {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${accessToken}`,
      },
      body: JSON.stringify({
        message: {
          token: message.token,
          notification: { title: message.title, body: message.body },
          data: message.data ?? {},
          apns: { payload: { aps: { sound: "default" } } },
        },
      }),
    },
  );
  return res.ok ? { ok: true } : { ok: false, detail: await res.text() };
}

export function json(body: unknown): Response {
  return new Response(JSON.stringify(body), {
    headers: { "Content-Type": "application/json" },
    status: 200,
  });
}
