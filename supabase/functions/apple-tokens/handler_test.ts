// Run from the repo root (no local Deno needed):
//   docker run --rm -v "$PWD/supabase/functions:/fn:ro" -w /fn denoland/deno:2.5.6 \
//     test --allow-env --allow-net=esm.sh,deno.land apple-tokens/
// Apple is a fake: the only network use is fetching the modules.

import {
  assert,
  assertEquals,
} from "https://deno.land/std@0.224.0/assert/mod.ts";
import * as jose from "https://esm.sh/jose@5";
import { type AppleKey, clientSecret } from "./apple.ts";
import { handle } from "./handler.ts";

const SECRET = "test-secret";
Deno.env.set("PUSH_WEBHOOK_SECRET", SECRET);

const { publicKey, privateKey } = await jose.generateKeyPair("ES256", {
  extractable: true,
});
const key: AppleKey = {
  keyId: "KEY123",
  privateKey: await jose.exportPKCS8(privateKey),
};

/// Plays Apple: answers /auth/token with a token for [sub], and records
/// every form it receives.
function fakeApple(sub: string, tokenStatus = 200) {
  const calls: { path: string; form: URLSearchParams }[] = [];
  const fetchFn = async (input: string | URL | Request, init?: RequestInit) => {
    const path = new URL(String(input)).pathname;
    calls.push({ path, form: new URLSearchParams(String(init?.body)) });
    if (path === "/auth/token") {
      if (tokenStatus !== 200) {
        return new Response('{"error":"invalid_grant"}', { status: tokenStatus });
      }
      const idToken = await new jose.SignJWT({ sub })
        .setProtectedHeader({ alg: "ES256" })
        .sign(privateKey);
      return Response.json({ refresh_token: "r-token", id_token: idToken });
    }
    return new Response("", { status: 200 });
  };
  return { calls, fetchFn: fetchFn as typeof fetch };
}

function request(body: unknown, secret = SECRET): Request {
  return new Request("http://functions/apple-tokens", {
    method: "POST",
    headers: { "x-webhook-secret": secret },
    body: JSON.stringify(body),
  });
}

const exchange = {
  type: "exchange",
  user_id: "u1",
  apple_sub: "apple-u1",
  code: "c-code",
};

Deno.test("the client secret is the JWT Apple expects", async () => {
  const jwt = await clientSecret(key, Date.UTC(2026, 10, 15));
  const { payload, protectedHeader } = await jose.jwtVerify(jwt, publicKey, {
    currentDate: new Date(Date.UTC(2026, 10, 15, 0, 1)),
  });
  assertEquals(protectedHeader, { alg: "ES256", kid: "KEY123" });
  assertEquals(payload.iss, "2Y57C77BK4");
  assertEquals(payload.sub, "app.nous-deux");
  assertEquals(payload.aud, "https://appleid.apple.com");
  assertEquals(payload.exp! - payload.iat!, 300);
});

Deno.test("requests without the database's secret are refused", async () => {
  const apple = fakeApple("apple-u1");
  const res = await handle(request(exchange, "wrong"), {
    key,
    saveToken: () => Promise.resolve(true),
    fetch: apple.fetchFn,
  });
  assertEquals(res.status, 403);
  assertEquals(apple.calls.length, 0);
});

Deno.test("exchange keeps the refresh token for the account", async () => {
  const apple = fakeApple("apple-u1");
  const saved: string[][] = [];
  const res = await handle(request(exchange), {
    key,
    saveToken: (u, t) => (saved.push([u, t]), Promise.resolve(true)),
    fetch: apple.fetchFn,
  });
  assertEquals(await res.json(), { ok: true });
  assertEquals(saved, [["u1", "r-token"]]);
  assertEquals(apple.calls.length, 1);
  const form = apple.calls[0].form;
  assertEquals(apple.calls[0].path, "/auth/token");
  assertEquals(form.get("client_id"), "app.nous-deux");
  assertEquals(form.get("code"), "c-code");
  assertEquals(form.get("grant_type"), "authorization_code");
  await jose.jwtVerify(form.get("client_secret")!, publicKey);
});

Deno.test("a code from another Apple account is revoked, not kept", async () => {
  const apple = fakeApple("someone-else");
  let saved = false;
  const res = await handle(request(exchange), {
    key,
    saveToken: () => ((saved = true), Promise.resolve(true)),
    fetch: apple.fetchFn,
  });
  assertEquals((await res.json()).ok, false);
  assert(!saved);
  assertEquals(apple.calls.map((c) => c.path), ["/auth/token", "/auth/revoke"]);
  assertEquals(apple.calls[1].form.get("token"), "r-token");
});

Deno.test("a token for an account deleted meanwhile is revoked", async () => {
  const apple = fakeApple("apple-u1");
  const res = await handle(request(exchange), {
    key,
    saveToken: () => Promise.resolve(false),
    fetch: apple.fetchFn,
  });
  assertEquals((await res.json()).ok, false);
  assertEquals(apple.calls.map((c) => c.path), ["/auth/token", "/auth/revoke"]);
});

Deno.test("Apple refusing the code stores nothing", async () => {
  const apple = fakeApple("apple-u1", 400);
  let saved = false;
  const res = await handle(request(exchange), {
    key,
    saveToken: () => ((saved = true), Promise.resolve(true)),
    fetch: apple.fetchFn,
  });
  assertEquals(await res.json(), { ok: false });
  assert(!saved);
});

Deno.test("revoke sends the refresh token to Apple", async () => {
  const apple = fakeApple("apple-u1");
  const res = await handle(
    request({ type: "revoke", refresh_token: "r-old" }),
    { key, saveToken: () => Promise.resolve(true), fetch: apple.fetchFn },
  );
  assertEquals(await res.json(), { ok: true });
  assertEquals(apple.calls.length, 1);
  const { path, form } = apple.calls[0];
  assertEquals(path, "/auth/revoke");
  assertEquals(form.get("client_id"), "app.nous-deux");
  assertEquals(form.get("token"), "r-old");
  assertEquals(form.get("token_type_hint"), "refresh_token");
  await jose.jwtVerify(form.get("client_secret")!, publicKey);
});

Deno.test("without the Apple key nothing is called", async () => {
  const apple = fakeApple("apple-u1");
  const res = await handle(request(exchange), {
    key: null,
    saveToken: () => Promise.resolve(true),
    fetch: apple.fetchFn,
  });
  assertEquals((await res.json()).ok, false);
  assertEquals(apple.calls.length, 0);
});
