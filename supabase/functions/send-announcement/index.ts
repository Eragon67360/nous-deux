// Sends a message from the team to everyone; see handler.ts. Only
// scripts/announce.sh calls it, from the server.
// Requires: SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, PUSH_WEBHOOK_SECRET,
// FIREBASE_SERVICE_ACCOUNT_JSON.

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { json } from "../_shared/database.ts";
import { readServiceAccount, sendPush } from "../_shared/fcm.ts";
import { type Content, handleAnnouncement, type Recipient } from "./handler.ts";

const supabase = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
);

/** PostgREST answers at most this many rows at once. */
const PAGE = 1000;

function fail(what: string, error: { message: string }): never {
  throw new Error(`${what} failed: ${error.message}`);
}

async function allRecipients(): Promise<Recipient[]> {
  const people: Recipient[] = [];
  for (let from = 0;; from += PAGE) {
    const { data, error } = await supabase
      .from("profiles")
      .select("fcm_token, language")
      .eq("announcements_push", true)
      .not("fcm_token", "is", null)
      // Newest first: a token on two profiles keeps the latest one's language.
      .order("updated_at", { ascending: false })
      .order("id")
      .range(from, from + PAGE - 1);
    if (error) fail("reading the recipients", error);
    people.push(...data.map((p) => ({ token: p.fcm_token as string, language: p.language })));
    if (data.length < PAGE) return people;
  }
}

Deno.serve(async (req) => {
  const sa = readServiceAccount();
  if (!sa) {
    console.error("send-announcement: FIREBASE_SERVICE_ACCOUNT_JSON is not set");
    return json({ ok: false, error: "no_service_account" });
  }
  try {
    return await handleAnnouncement(req, {
      findBySlug: async (slug) => {
        const { data, error } = await supabase
          .from("announcements")
          .select("content, tested_at, sent_at")
          .eq("slug", slug)
          .maybeSingle();
        if (error) fail("reading the message", error);
        return data;
      },
      saveTested: async (slug: string, content: Content) => {
        const { error } = await supabase
          .from("announcements")
          .upsert({ slug, content, tested_at: new Date().toISOString() }, { onConflict: "slug" });
        if (error) fail("saving the test", error);
      },
      markSent: async (slug) => {
        const { data, error } = await supabase
          .from("announcements")
          .update({ sent_at: new Date().toISOString() })
          .eq("slug", slug)
          .is("sent_at", null)
          .select("id")
          .maybeSingle();
        if (error) fail("marking the message sent", error);
        return data?.id ?? null;
      },
      testers: async () => {
        const { data, error } = await supabase
          .from("announcement_testers")
          .select("profiles(fcm_token, language)");
        if (error) fail("reading the testers", error);
        return data
          .map((row) => row.profiles as unknown as { fcm_token: string | null; language: string })
          .filter((p) => p?.fcm_token)
          .map((p) => ({ token: p.fcm_token as string, language: p.language }));
      },
      recipients: allRecipients,
      optedOutCount: async () => {
        const { count, error } = await supabase
          .from("profiles")
          .select("id", { count: "exact", head: true })
          .eq("announcements_push", false);
        if (error) fail("counting opt-outs", error);
        return count ?? 0;
      },
      clearToken: async (token) => {
        const { error } = await supabase
          .from("profiles")
          .update({ fcm_token: null })
          .eq("fcm_token", token);
        if (error) fail("clearing a stale token", error);
      },
      sendPush: (token, title, body, data) => sendPush(sa, { token, title, body, data }),
    });
  } catch (e) {
    console.error("send-announcement failed:", e instanceof Error ? e.message : "unknown error");
    return json({ ok: false, error: "server_error" });
  }
});
