// Tell the partner that a period log was added. Called by the database on each
// period_logs insert (migration 20261111100000_push_webhooks.sql).
// Requires: SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, PUSH_WEBHOOK_SECRET,
// FIREBASE_SERVICE_ACCOUNT_JSON.
//
// The text stays vague on purpose: it goes through Apple's and Google's push
// services, and period data is health data.

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { fromDatabase, json, readServiceAccount, sendPush } from "../_shared/fcm.ts";

interface WebhookPayload {
  type: "INSERT" | "UPDATE" | "DELETE";
  table: string;
  record: { id: string } | null;
}

const BODIES: Record<"fr" | "en", (name: string) => string> = {
  fr: (n) => `${n} a mis à jour son suivi`,
  en: (n) => `${n} updated their tracking`,
};

Deno.serve(async (req) => {
  if (!fromDatabase(req)) return new Response("forbidden", { status: 403 });

  try {
    const payload: WebhookPayload = await req.json();
    if (payload.type !== "INSERT" || payload.table !== "period_logs" || !payload.record) {
      return json({ ok: true, skipped: "not a period_logs insert" });
    }

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    );

    // Trust the database, not the request body.
    const { data: log } = await supabase
      .from("period_logs")
      .select("user_id, couple_id")
      .eq("id", payload.record.id)
      .maybeSingle();
    if (!log) return json({ ok: true, skipped: "no such log" });

    const { data: couple } = await supabase
      .from("couples")
      .select("user1_id, user2_id")
      .eq("id", log.couple_id)
      .single();
    if (!couple) return json({ ok: true, skipped: "couple not found" });

    const isUser1 = couple.user1_id === log.user_id;
    const isUser2 = couple.user2_id === log.user_id;
    if (!isUser1 && !isUser2) return json({ ok: true, skipped: "author not in couple" });
    const partnerId = isUser1 ? couple.user2_id : couple.user1_id;
    if (!partnerId) return json({ ok: true, skipped: "no partner" });

    const { data: people } = await supabase
      .from("profiles")
      .select("id, username, language, fcm_token, share_cycle")
      .in("id", [log.user_id, partnerId]);
    const author = people?.find((p) => p.id === log.user_id);
    const partner = people?.find((p) => p.id === partnerId);
    // The author chose not to share their cycle: the partner hears nothing.
    if (author?.share_cycle === false) return json({ ok: true, skipped: "cycle not shared" });
    if (!partner?.fcm_token) return json({ ok: true, skipped: "partner has no fcm_token" });

    const sa = readServiceAccount();
    if (!sa) return json({ ok: true, skipped: "FIREBASE_SERVICE_ACCOUNT_JSON not set" });

    const lang = partner.language === "en" ? "en" : "fr";
    const name = author?.username?.trim() ||
      (lang === "fr" ? "Votre partenaire" : "Your partner");
    const result = await sendPush(sa, {
      token: partner.fcm_token,
      title: "Nous Deux",
      body: BODIES[lang](name),
      data: { type: "period" },
    });
    if (!result.ok) console.error("FCM error", result.detail);
    return json({ ok: result.ok });
  } catch (e) {
    console.error("notify-partner-period failed", e);
    return json({ ok: false });
  }
});
