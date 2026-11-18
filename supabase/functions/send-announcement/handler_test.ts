// Run from the repo root (no local Deno needed):
//   docker run --rm -v "$PWD/supabase/functions:/fn:ro" -w /fn denoland/deno:2.5.6 \
//     test --allow-read=. --allow-env --allow-net=esm.sh,deno.land send-announcement/
// The database and FCM are fakes: the only network use is fetching the modules.

import { assertEquals } from "https://deno.land/std@0.224.0/assert/mod.ts";
import { type Content, type Deps, handleAnnouncement, type Recipient, type Stored } from "./handler.ts";

const SECRET = "test-secret";
Deno.env.set("PUSH_WEBHOOK_SECRET", SECRET);

const SLUG = "2026-11-20-listes";
const CONTENT: Content = {
  fr: { title: "Les listes partagées sont là", body: "Courses, idées de sorties." },
  en: { title: "Shared lists are here", body: "Groceries, date ideas." },
};

function request(body: unknown, secret: string | null = SECRET): Request {
  const headers: Record<string, string> = { "Content-Type": "application/json" };
  if (secret !== null) headers["x-webhook-secret"] = secret;
  return new Request("http://functions/send-announcement", {
    method: "POST",
    headers,
    body: typeof body === "string" ? body : JSON.stringify(body),
  });
}

interface Push {
  token: string;
  title: string;
  body: string;
  data: Record<string, string>;
}

/// A database with one row per slug, and an FCM that refuses the tokens in
/// `stale` as unregistered and those in `broken` with a server error.
function fakes(options: {
  stored?: Record<string, Stored>;
  testers?: Recipient[];
  recipients?: Recipient[];
  optedOut?: number;
  stale?: string[];
  broken?: string[];
} = {}) {
  // Copies, so a send in one test doesn't mark the shared rows sent.
  const rows: Record<string, Stored> = Object.fromEntries(
    Object.entries(options.stored ?? {}).map(([slug, row]) => [slug, { ...row }]),
  );
  const pushes: Push[] = [];
  const cleared: string[] = [];
  const deps: Deps = {
    findBySlug: (slug) => Promise.resolve(rows[slug] ?? null),
    saveTested: (slug, content) => {
      rows[slug] = { content, tested_at: "2026-11-20T18:00:00Z", sent_at: null };
      return Promise.resolve();
    },
    markSent: (slug) => {
      const row = rows[slug];
      if (!row || row.sent_at) return Promise.resolve(null);
      row.sent_at = "2026-11-20T18:30:00Z";
      return Promise.resolve("row-id-1");
    },
    testers: () => Promise.resolve(options.testers ?? []),
    recipients: () => Promise.resolve(options.recipients ?? []),
    optedOutCount: () => Promise.resolve(options.optedOut ?? 0),
    clearToken: (token) => {
      cleared.push(token);
      return Promise.resolve();
    },
    sendPush: (token, title, body, data) => {
      pushes.push({ token, title, body, data });
      if (options.stale?.includes(token)) {
        return Promise.resolve({
          ok: false,
          detail: JSON.stringify({
            error: { code: 404, details: [{ errorCode: "UNREGISTERED" }] },
          }),
        });
      }
      if (options.broken?.includes(token)) {
        return Promise.resolve({ ok: false, detail: '{"error":{"code":500}}' });
      }
      return Promise.resolve({ ok: true });
    },
  };
  return { deps, rows, pushes, cleared };
}

const tested: Stored = { content: CONTENT, tested_at: "2026-11-20T18:00:00Z", sent_at: null };

async function call(body: unknown, deps: Deps, secret: string | null = SECRET) {
  const res = await handleAnnouncement(request(body, secret), deps);
  return { status: res.status, body: res.status === 200 ? await res.json() : null };
}

Deno.test("without the secret, nothing happens", async () => {
  const { deps, pushes } = fakes({ testers: [{ token: "thomas", language: "fr" }] });
  assertEquals((await call({ action: "test", slug: SLUG, content: CONTENT }, deps, null)).status, 403);
  assertEquals((await call({ action: "test", slug: SLUG, content: CONTENT }, deps, "wrong")).status, 403);
  assertEquals(pushes.length, 0);
});

Deno.test("a malformed request is refused", async () => {
  const { deps } = fakes();
  assertEquals((await call("not json", deps)).body, { ok: false, error: "bad_request" });
  assertEquals((await call({ action: "shout", slug: SLUG, content: CONTENT }, deps)).body, {
    ok: false,
    error: "bad_request",
  });
  assertEquals((await call({ action: "test", slug: SLUG }, deps)).body, {
    ok: false,
    error: "bad_request",
  });
});

Deno.test("each check of the message file", async () => {
  const { deps, pushes } = fakes({ testers: [{ token: "thomas", language: "fr" }] });
  const cases: [unknown, string][] = [
    [{ slug: "Listes", content: CONTENT }, "bad_slug"],
    [{ slug: SLUG, content: { fr: CONTENT.fr } }, "missing_language:en"],
    [{ slug: SLUG, content: { ...CONTENT, de: CONTENT.en } }, "unknown_language:de"],
    [{ slug: SLUG, content: { ...CONTENT, fr: { title: "x".repeat(61), body: "B" } } }, "title_too_long:fr"],
    [{ slug: SLUG, content: { ...CONTENT, en: { title: "Hi", body: "  " } } }, "empty:en"],
    [{ slug: SLUG, content: { ...CONTENT, en: { title: "Hi" } } }, "empty:en"],
    [{ slug: SLUG, content: { ...CONTENT, fr: { title: "T", body: "x".repeat(281) } } }, "body_too_long:fr"],
  ];
  for (const [body, error] of cases) {
    const answer = await call({ action: "test", ...(body as object) }, deps);
    assertEquals(answer.body, { ok: false, error });
  }
  assertEquals(pushes.length, 0);
});

Deno.test("60 characters fit in a title, emoji counted once", async () => {
  const { deps } = fakes({ testers: [{ token: "thomas", language: "fr" }] });
  const title = "é".repeat(59) + "🎉";
  const answer = await call({ action: "test", slug: SLUG, content: { ...CONTENT, fr: { title, body: "B" } } }, deps);
  assertEquals(answer.body.ok, true);
});

Deno.test("a test needs a tester", async () => {
  const { deps, rows } = fakes();
  assertEquals((await call({ action: "test", slug: SLUG, content: CONTENT }, deps)).body, {
    ok: false,
    error: "no_testers",
  });
  assertEquals(rows[SLUG], undefined);
});

Deno.test("a test goes to the testers only, in their language, and is saved", async () => {
  const { deps, pushes, rows } = fakes({
    testers: [{ token: "thomas", language: "fr" }, { token: "team-en", language: "en" }],
    recipients: [{ token: "everyone", language: "fr" }],
  });
  const answer = await call({ action: "test", slug: SLUG, content: CONTENT }, deps);
  assertEquals(answer.body, { ok: true, sent: 2, failed: 0 });
  assertEquals(pushes.map((p) => [p.token, p.title]), [
    ["thomas", CONTENT.fr.title],
    ["team-en", CONTENT.en.title],
  ]);
  assertEquals(pushes[0].data, { type: "announcement", id: "test" });
  assertEquals(rows[SLUG].tested_at !== null && rows[SLUG].sent_at === null, true);
});

Deno.test("a message already sent can't be tested again", async () => {
  const { deps, pushes } = fakes({
    stored: { [SLUG]: { ...tested, sent_at: "2026-11-20T18:30:00Z" } },
    testers: [{ token: "thomas", language: "fr" }],
  });
  assertEquals((await call({ action: "test", slug: SLUG, content: CONTENT }, deps)).body, {
    ok: false,
    error: "already_sent",
  });
  assertEquals(pushes.length, 0);
});

Deno.test("no preview before a test", async () => {
  const { deps } = fakes();
  assertEquals((await call({ action: "preview", slug: SLUG, content: CONTENT }, deps)).body, {
    ok: false,
    error: "not_tested",
  });
});

Deno.test("a file edited after its test must be tested again", async () => {
  const { deps, pushes } = fakes({
    stored: { [SLUG]: tested },
    recipients: [{ token: "everyone", language: "fr" }],
  });
  const edited = { ...CONTENT, fr: { ...CONTENT.fr, body: "Autre chose." } };
  for (const action of ["preview", "send"]) {
    assertEquals((await call({ action, slug: SLUG, content: edited }, deps)).body, {
      ok: false,
      error: "changed_since_test",
    });
  }
  assertEquals(pushes.length, 0);
});

Deno.test("the same text in another key order is the tested one", async () => {
  const { deps } = fakes({ stored: { [SLUG]: tested }, recipients: [] });
  const reordered = {
    en: { body: CONTENT.en.body, title: CONTENT.en.title },
    fr: { body: CONTENT.fr.body, title: CONTENT.fr.title },
  };
  assertEquals((await call({ action: "preview", slug: SLUG, content: reordered }, deps)).body.ok, true);
});

Deno.test("the preview counts who gets it and who turned it off", async () => {
  const { deps, pushes } = fakes({
    stored: { [SLUG]: tested },
    recipients: [{ token: "a", language: "fr" }, { token: "b", language: "en" }],
    optedOut: 3,
  });
  assertEquals((await call({ action: "preview", slug: SLUG, content: CONTENT }, deps)).body, {
    ok: true,
    recipients: 2,
    opted_out: 3,
  });
  assertEquals(pushes.length, 0);
});

Deno.test("the send reaches everyone once, in their language, English when theirs is missing", async () => {
  const { deps, pushes, rows } = fakes({
    stored: { [SLUG]: tested },
    recipients: [
      { token: "camille", language: "fr" },
      { token: "alex", language: "en" },
      { token: "lucia", language: "es" },
      { token: "unknown", language: null },
    ],
  });
  const answer = await call({ action: "send", slug: SLUG, content: CONTENT }, deps);
  assertEquals(answer.body, { ok: true, sent: 4, failed: 0, stale_removed: 0 });
  assertEquals(pushes.map((p) => [p.token, p.title]), [
    ["camille", CONTENT.fr.title],
    ["alex", CONTENT.en.title],
    ["lucia", CONTENT.en.title],
    ["unknown", CONTENT.en.title],
  ]);
  assertEquals(pushes[1].body, CONTENT.en.body);
  assertEquals(pushes[0].data, { type: "announcement", id: "row-id-1" });
  assertEquals(rows[SLUG].sent_at !== null, true);
});

Deno.test("a stale token is cleared and the send carries on", async () => {
  const { deps, pushes, cleared } = fakes({
    stored: { [SLUG]: tested },
    recipients: [
      { token: "gone", language: "fr" },
      { token: "down", language: "fr" },
      { token: "fine", language: "en" },
    ],
    stale: ["gone"],
    broken: ["down"],
  });
  const answer = await call({ action: "send", slug: SLUG, content: CONTENT }, deps);
  assertEquals(answer.body, { ok: true, sent: 1, failed: 2, stale_removed: 1 });
  assertEquals(cleared, ["gone"]);
  assertEquals(pushes.length, 3);
});

Deno.test("a second send is refused and pushes nothing", async () => {
  const { deps, pushes } = fakes({
    stored: { [SLUG]: tested },
    recipients: [{ token: "camille", language: "fr" }],
  });
  assertEquals((await call({ action: "send", slug: SLUG, content: CONTENT }, deps)).body.ok, true);
  assertEquals((await call({ action: "send", slug: SLUG, content: CONTENT }, deps)).body, {
    ok: false,
    error: "already_sent",
  });
  assertEquals(pushes.length, 1);
});

Deno.test("when two sends race, the database's answer decides", async () => {
  const { deps, pushes } = fakes({
    stored: { [SLUG]: tested },
    recipients: [{ token: "camille", language: "fr" }],
  });
  // Another run marked it sent between this run's check and its update.
  const racing: Deps = { ...deps, markSent: () => Promise.resolve(null) };
  assertEquals((await call({ action: "send", slug: SLUG, content: CONTENT }, racing)).body, {
    ok: false,
    error: "already_sent",
  });
  assertEquals(pushes.length, 0);
});

Deno.test("many recipients all get it", async () => {
  const recipients = Array.from({ length: 45 }, (_, i) => ({ token: `t${i}`, language: "fr" }));
  const { deps, pushes } = fakes({ stored: { [SLUG]: tested }, recipients });
  const answer = await call({ action: "send", slug: SLUG, content: CONTENT }, deps);
  assertEquals(answer.body.sent, 45);
  assertEquals(new Set(pushes.map((p) => p.token)).size, 45);
});
