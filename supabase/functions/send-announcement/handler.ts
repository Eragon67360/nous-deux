// A message from the team to everyone (docs/NOUVEAUTES.md). Only
// scripts/announce.sh calls this, from the server, with PUSH_WEBHOOK_SECRET.
//
// - "test" pushes the message to the team's accounts and saves it as a
//   draft, which nobody else sees.
// - "preview" says how many people a send would reach.
// - "send" records the message, so the app lists it, and pushes it to
//   everyone who has app-news pushes on, in their app language.
//
// Preview and send need a test of the very same text first, and a message
// is sent at most once: the database decides when two runs race.

import { fromDatabase, json } from "../_shared/database.ts";
import { isStaleToken } from "../_shared/fcm.ts";
import { LANGUAGES } from "../_shared/i18n/mod.ts";

export interface Texts {
  title: string;
  body: string;
}

/** One title and body per app language. */
export type Content = Record<string, Texts>;

export interface Stored {
  content: Content;
  tested_at: string | null;
  sent_at: string | null;
}

export interface Recipient {
  token: string;
  language: string | null;
}

export interface Deps {
  findBySlug: (slug: string) => Promise<Stored | null>;
  /** Saves the draft with its tested text, tested_at = now. */
  saveTested: (slug: string, content: Content) => Promise<void>;
  /** Sets sent_at where it is still null; the row's id, or null when another run sent it. */
  markSent: (slug: string) => Promise<string | null>;
  /** The team's accounts that have a push token. */
  testers: () => Promise<Recipient[]>;
  /** Everyone with a push token and app-news pushes on. */
  recipients: () => Promise<Recipient[]>;
  /** How many accounts turned app-news pushes off. */
  optedOutCount: () => Promise<number>;
  clearToken: (token: string) => Promise<void>;
  sendPush: (
    token: string,
    title: string,
    body: string,
    data: Record<string, string>,
  ) => Promise<{ ok: boolean; detail?: string }>;
}

export const MAX_TITLE = 60;
export const MAX_BODY = 280;
const SLUG = /^[0-9]{4}-[0-9]{2}-[0-9]{2}-[a-z0-9-]+$/;
const ACTIONS = ["test", "preview", "send"] as const;
type Action = typeof ACTIONS[number];
/** Pushes in flight at once. */
const BATCH = 20;

/** Characters as people count them: an emoji is one. */
function length(text: string): number {
  return [...text].length;
}

/** The first thing wrong with a message file, or null when it can be sent. */
export function checkContent(slug: string, content: Record<string, unknown>): string | null {
  if (!SLUG.test(slug)) return "bad_slug";
  for (const lang of Object.keys(content)) {
    if (!LANGUAGES.includes(lang)) return `unknown_language:${lang}`;
  }
  for (const lang of LANGUAGES) {
    const texts = content[lang] as Partial<Texts> | undefined;
    if (!texts || typeof texts !== "object") return `missing_language:${lang}`;
    const { title, body } = texts;
    if (typeof title !== "string" || typeof body !== "string" || !title.trim() || !body.trim()) {
      return `empty:${lang}`;
    }
    if (length(title) > MAX_TITLE) return `title_too_long:${lang}`;
    if (length(body) > MAX_BODY) return `body_too_long:${lang}`;
  }
  return null;
}

/** The texts in a fixed order, so the same message compares equal however its keys are ordered. */
function canonical(content: Content): string {
  return JSON.stringify(
    Object.keys(content).sort().map((lang) => [lang, content[lang].title, content[lang].body]),
  );
}

function textsFor(content: Content, language: string | null): Texts {
  return (language && Object.hasOwn(content, language)) ? content[language] : content.en;
}

async function pushAll(
  deps: Deps,
  people: Recipient[],
  content: Content,
  data: Record<string, string>,
): Promise<{ sent: number; failed: number; stale: number }> {
  let sent = 0, failed = 0, stale = 0;
  for (let i = 0; i < people.length; i += BATCH) {
    await Promise.all(people.slice(i, i + BATCH).map(async ({ token, language }) => {
      const { title, body } = textsFor(content, language);
      // A push that throws (network, Google's sign-in) fails alone.
      const result = await deps.sendPush(token, title, body, data)
        .catch(() => ({ ok: false, detail: undefined }));
      if (result.ok) {
        sent++;
        return;
      }
      failed++;
      if (isStaleToken(result.detail)) {
        // A token that can't be cleared now stays for the next send.
        const cleared = await deps.clearToken(token).then(() => true, () => false);
        if (cleared) stale++;
      }
    }));
  }
  // FCM's answers can name the tokens; log only the counts.
  if (failed) console.error(`send-announcement: ${failed} pushes refused, ${stale} stale tokens cleared`);
  return { sent, failed, stale };
}

/// One entry per push token: a phone signed into two accounts keeps its
/// token on both profiles, and gets the message once, in the first one's
/// language (index.ts lists the most recently updated profile first).
function uniqueTokens(people: Recipient[]): Recipient[] {
  const seen = new Set<string>();
  return people.filter(({ token }) => !seen.has(token) && !!seen.add(token));
}

/** Why a tested draft can't go to everyone yet, or null when it can. */
function notReady(stored: Stored | null, content: Content): string | null {
  if (stored?.sent_at) return "already_sent";
  if (!stored?.tested_at) return "not_tested";
  if (canonical(stored.content) !== canonical(content)) return "changed_since_test";
  return null;
}

export async function handleAnnouncement(req: Request, deps: Deps): Promise<Response> {
  if (!fromDatabase(req)) return new Response("forbidden", { status: 403 });

  let payload: { action?: unknown; slug?: unknown; content?: unknown };
  try {
    payload = await req.json();
  } catch {
    return json({ ok: false, error: "bad_request" });
  }
  const { action, slug, content } = payload ?? {};
  if (
    !ACTIONS.includes(action as Action) || typeof slug !== "string" ||
    !content || typeof content !== "object" || Array.isArray(content)
  ) {
    return json({ ok: false, error: "bad_request" });
  }
  const problem = checkContent(slug, content as Record<string, unknown>);
  if (problem) return json({ ok: false, error: problem });
  // Only the checked languages' titles and bodies go further.
  const message: Content = Object.fromEntries(
    LANGUAGES.map((lang) => {
      const { title, body } = (content as Content)[lang];
      return [lang, { title, body }];
    }),
  );

  const stored = await deps.findBySlug(slug);

  if (action === "test") {
    if (stored?.sent_at) return json({ ok: false, error: "already_sent" });
    const testers = uniqueTokens(await deps.testers());
    if (!testers.length) return json({ ok: false, error: "no_testers" });
    await deps.saveTested(slug, message);
    const { sent, failed } = await pushAll(deps, testers, message, {
      type: "announcement",
      id: "test",
    });
    return json({ ok: true, sent, failed });
  }

  const blocked = notReady(stored, message);
  if (blocked) return json({ ok: false, error: blocked });

  if (action === "preview") {
    const [recipients, optedOut] = await Promise.all([deps.recipients(), deps.optedOutCount()]);
    return json({ ok: true, recipients: uniqueTokens(recipients).length, opted_out: optedOut });
  }

  // Read who gets it first: once marked sent, the message can't be sent again.
  const recipients = uniqueTokens(await deps.recipients());
  const id = await deps.markSent(slug);
  if (!id) return json({ ok: false, error: "already_sent" });
  const { sent, failed, stale } = await pushAll(deps, recipients, message, {
    type: "announcement",
    id,
  });
  return json({ ok: true, sent, failed, stale_removed: stale });
}
