// Run from the repo root (no local Deno needed):
//   docker run --rm -v "$PWD/supabase/functions:/fn:ro" -w /fn denoland/deno:2.5.6 \
//     test --allow-read=. --allow-env --allow-net=esm.sh,deno.land _shared/
// Google is faked: the only network use is fetching the modules.

import { assertEquals } from "https://deno.land/std@0.224.0/assert/mod.ts";
import * as jose from "https://esm.sh/jose@5";
import { type FirebaseServiceAccount, isStaleToken, sendPush } from "./fcm.ts";

function fcmError(code: number, status: string, errorCode: string, message: string) {
  return JSON.stringify({
    error: {
      code,
      message,
      status,
      details: [{ "@type": "type.googleapis.com/google.firebase.fcm.v1.FcmError", errorCode }],
    },
  });
}

Deno.test("an unregistered token is stale", () => {
  assertEquals(
    isStaleToken(fcmError(404, "NOT_FOUND", "UNREGISTERED", "Requested entity was not found.")),
    true,
  );
});

Deno.test("a token FCM calls invalid is stale", () => {
  assertEquals(
    isStaleToken(
      fcmError(
        400,
        "INVALID_ARGUMENT",
        "INVALID_ARGUMENT",
        "The registration token is not a valid FCM registration token",
      ),
    ),
    true,
  );
});

Deno.test("another invalid argument isn't about the token", () => {
  assertEquals(
    isStaleToken(fcmError(400, "INVALID_ARGUMENT", "INVALID_ARGUMENT", "Invalid JSON payload")),
    false,
  );
});

Deno.test("server errors, quotas and no answer keep the token", () => {
  assertEquals(isStaleToken(fcmError(500, "INTERNAL", "INTERNAL", "Internal error")), false);
  assertEquals(
    isStaleToken(fcmError(429, "RESOURCE_EXHAUSTED", "QUOTA_EXCEEDED", "Quota exceeded")),
    false,
  );
  assertEquals(isStaleToken("not json"), false);
  assertEquals(isStaleToken(undefined), false);
});

async function fakeAccount(email: string): Promise<FirebaseServiceAccount> {
  const { privateKey } = await jose.generateKeyPair("RS256", { extractable: true });
  return {
    project_id: "nous-deux-test",
    private_key: await jose.exportPKCS8(privateKey),
    client_email: email,
  };
}

Deno.test("one access token serves many pushes", async () => {
  const sa = await fakeAccount("many@test.iam.gserviceaccount.com");
  const realFetch = globalThis.fetch;
  let tokenRequests = 0;
  let pushes = 0;
  globalThis.fetch = (input: string | URL | Request) => {
    const url = String(input instanceof Request ? input.url : input);
    if (url.startsWith("https://oauth2.googleapis.com/")) {
      tokenRequests++;
      return Promise.resolve(Response.json({ access_token: "tok", expires_in: 3600 }));
    }
    pushes++;
    return Promise.resolve(Response.json({ name: "projects/x/messages/1" }));
  };
  try {
    for (let i = 0; i < 3; i++) {
      const result = await sendPush(sa, { token: `t${i}`, title: "T", body: "B" });
      assertEquals(result.ok, true);
    }
  } finally {
    globalThis.fetch = realFetch;
  }
  assertEquals(pushes, 3);
  assertEquals(tokenRequests, 1);
});

Deno.test("a token about to expire is fetched again", async () => {
  const sa = await fakeAccount("short@test.iam.gserviceaccount.com");
  const realFetch = globalThis.fetch;
  let tokenRequests = 0;
  globalThis.fetch = (input: string | URL | Request) => {
    const url = String(input instanceof Request ? input.url : input);
    if (url.startsWith("https://oauth2.googleapis.com/")) {
      tokenRequests++;
      // Less than the 5 minutes kept in reserve: never reused.
      return Promise.resolve(Response.json({ access_token: "tok", expires_in: 120 }));
    }
    return Promise.resolve(Response.json({}));
  };
  try {
    await sendPush(sa, { token: "a", title: "T", body: "B" });
    await sendPush(sa, { token: "b", title: "T", body: "B" });
  } finally {
    globalThis.fetch = realFetch;
  }
  assertEquals(tokenRequests, 2);
});
