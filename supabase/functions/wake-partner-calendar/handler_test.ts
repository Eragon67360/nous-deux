// Run from the repo root (no local Deno needed):
//   docker run --rm -v "$PWD/supabase/functions:/fn:ro" -w /fn denoland/deno:2.5.6 \
//     test --allow-env --allow-net=esm.sh,deno.land wake-partner-calendar/
// The database and FCM are fakes: the only network use is fetching the modules.

import { assertEquals } from "https://deno.land/std@0.224.0/assert/mod.ts";
import { backgroundMessage } from "../_shared/fcm.ts";
import { type Deps, handleWake, type Profile } from "./handler.ts";

const SECRET = "test-secret";
Deno.env.set("PUSH_WEBHOOK_SECRET", SECRET);

const BEN = "00000000-0000-0000-0000-00000000093b";

function wakeRequest(body: unknown, secret: string | null = SECRET): Request {
  const headers: Record<string, string> = { "Content-Type": "application/json" };
  if (secret !== null) headers["x-webhook-secret"] = secret;
  return new Request("http://functions/wake-partner-calendar", {
    method: "POST",
    headers,
    body: typeof body === "string" ? body : JSON.stringify(body),
  });
}

const row = {
  type: "INSERT",
  table: "calendar_wakes",
  schema: "private",
  record: { id: "w1", user_id: BEN, sent_at: "2026-11-17T20:00:00Z" },
  old_record: null,
};

function fakeDeps(profile: Profile | null) {
  const sent: { token: string; data: Record<string, string> }[] = [];
  const asked: string[] = [];
  const deps: Deps = {
    loadProfile: (userId) => {
      asked.push(userId);
      return Promise.resolve(profile);
    },
    sendBackgroundPush: (token, data) => {
      sent.push({ token, data });
      return Promise.resolve({ ok: true });
    },
  };
  return { deps, sent, asked };
}

const following: Profile = {
  fcm_token: "tok-ben",
  calendar_sync_device: "7c9e6679-7425-40de-944b-e07fc1f90ae7",
};

Deno.test("backgroundMessage is a silent, low-priority data push", () => {
  assertEquals(backgroundMessage("tok", { type: "calendar_sync" }), {
    token: "tok",
    data: { type: "calendar_sync" },
    android: { priority: "normal" },
    apns: {
      headers: { "apns-push-type": "background", "apns-priority": "5" },
      payload: { aps: { "content-available": 1 } },
    },
  });
});

Deno.test("refuses a request without the database's secret", async () => {
  const { deps, sent } = fakeDeps(following);
  assertEquals((await handleWake(wakeRequest(row, null), deps)).status, 403);
  assertEquals((await handleWake(wakeRequest(row, "wrong"), deps)).status, 403);
  assertEquals(sent.length, 0);
});

Deno.test("wakes the partner's phone once, with only the type", async () => {
  const { deps, sent, asked } = fakeDeps(following);
  const res = await handleWake(wakeRequest(row), deps);
  assertEquals(await res.json(), { ok: true });
  assertEquals(asked, [BEN]);
  assertEquals(sent, [{ token: "tok-ben", data: { type: "calendar_sync" } }]);
});

Deno.test("skips someone who follows no calendar any more", async () => {
  const { deps, sent } = fakeDeps({ ...following, calendar_sync_device: null });
  const res = await handleWake(wakeRequest(row), deps);
  assertEquals(await res.json(), { ok: true, skipped: "not following" });
  assertEquals(sent.length, 0);
});

Deno.test("skips someone without a push token", async () => {
  const { deps, sent } = fakeDeps({ ...following, fcm_token: null });
  const res = await handleWake(wakeRequest(row), deps);
  assertEquals(await res.json(), { ok: true, skipped: "no token" });
  assertEquals(sent.length, 0);
});

Deno.test("skips a deleted account", async () => {
  const { deps, sent } = fakeDeps(null);
  const res = await handleWake(wakeRequest(row), deps);
  assertEquals(await res.json(), { ok: true, skipped: "no profile" });
  assertEquals(sent.length, 0);
});

Deno.test("skips a body that is not a wake", async () => {
  const { deps, sent } = fakeDeps(following);
  for (const body of ["not json", { ...row, record: null }, { ...row, record: { user_id: 3 } }]) {
    const res = await handleWake(wakeRequest(body), deps);
    assertEquals((await res.json()).skipped, "not a wake");
  }
  assertEquals(sent.length, 0);
});
