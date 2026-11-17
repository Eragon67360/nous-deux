// Push a little note to the partner. Called by the database on each
// couple_pings insert or update (migration 20261111100000_push_webhooks.sql).
// A note the sender wrote (kind "custom") is announced without its words:
// the text never goes into the push, so it never reaches Google's or
// Apple's push servers. This function doesn't even read it.
// Requires: SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, PUSH_WEBHOOK_SECRET,
// FIREBASE_SERVICE_ACCOUNT_JSON.

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { fromDatabase, json } from "../_shared/database.ts";
import { readServiceAccount, sendPush } from "../_shared/fcm.ts";
import { pingPush } from "./message.ts";

interface PingRecord {
  couple_id: string;
  sender_id: string;
  kind: string;
  sent_at: string;
}

interface WebhookPayload {
  type: "INSERT" | "UPDATE" | "DELETE";
  table: string;
  record: PingRecord | null;
}

Deno.serve(async (req) => {
  if (!fromDatabase(req)) return new Response("forbidden", { status: 403 });

  try {
    const payload: WebhookPayload = await req.json();
    const hint = payload.record;
    if (
      payload.table !== "couple_pings" ||
      (payload.type !== "INSERT" && payload.type !== "UPDATE") ||
      !hint
    ) {
      return json({ ok: true, skipped: "not a ping write" });
    }

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    );

    // Trust the database, not the request body. Never select `text`: the
    // words of a written note stay out of the push.
    const { data: ping } = await supabase
      .from("couple_pings")
      .select("couple_id, sender_id, kind, sent_at")
      .eq("couple_id", hint.couple_id)
      .eq("sender_id", hint.sender_id)
      .maybeSingle();
    if (!ping) return json({ ok: true, skipped: "no such ping" });
    const record = ping as PingRecord;

    const { data: couple } = await supabase
      .from("couples")
      .select("user1_id, user2_id")
      .eq("id", record.couple_id)
      .single();
    if (!couple) return json({ ok: true, skipped: "couple not found" });

    const isUser1 = couple.user1_id === record.sender_id;
    const isUser2 = couple.user2_id === record.sender_id;
    if (!isUser1 && !isUser2) return json({ ok: true, skipped: "sender not in couple" });
    const partnerId = isUser1 ? couple.user2_id : couple.user1_id;
    if (!partnerId) return json({ ok: true, skipped: "no partner" });

    const { data: people } = await supabase
      .from("profiles")
      .select("id, username, language, fcm_token")
      .in("id", [record.sender_id, partnerId]);
    const sender = people?.find((p) => p.id === record.sender_id);
    const partner = people?.find((p) => p.id === partnerId);
    if (!partner?.fcm_token) {
      return json({ ok: true, skipped: "partner has no fcm_token" });
    }

    const sa = readServiceAccount();
    if (!sa) return json({ ok: true, skipped: "FIREBASE_SERVICE_ACCOUNT_JSON not set" });

    const text = pingPush(partner.language, sender?.username, record.kind);
    if (!text) return json({ ok: true, skipped: "unknown kind" });

    const result = await sendPush(sa, {
      token: partner.fcm_token,
      ...text,
      data: { type: "ping", kind: record.kind, sent_at: record.sent_at },
    });
    if (!result.ok) console.error("FCM error", result.detail);
    return json({ ok: result.ok });
  } catch (e) {
    console.error("notify-partner-ping failed", e);
    return json({ ok: false });
  }
});
