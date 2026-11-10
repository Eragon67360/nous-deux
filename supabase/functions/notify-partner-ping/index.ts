// Push a little note to the partner (Database Webhook on couple_pings → this function).
// Requires: SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY (automatic), FIREBASE_SERVICE_ACCOUNT_JSON.

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { json, readServiceAccount, sendPush } from "../_shared/fcm.ts";

type PingKind =
  | "thinking_of_you"
  | "good_night"
  | "on_my_way"
  | "miss_you"
  | "kiss";

interface PingRecord {
  couple_id: string;
  sender_id: string;
  kind: PingKind;
  sent_at: string;
}

interface WebhookPayload {
  type: "INSERT" | "UPDATE" | "DELETE";
  table: string;
  record: PingRecord | null;
}

// Same wording as the app (lib/core/constants/nous_strings.dart).
const BODIES: Record<"fr" | "en", Record<PingKind, (name: string) => string>> = {
  fr: {
    thinking_of_you: (n) => `${n} pense à toi`,
    good_night: (n) => `${n} te souhaite bonne nuit`,
    on_my_way: (n) => `${n} arrive`,
    miss_you: (n) => `${n} : tu me manques`,
    kiss: (n) => `${n} t'envoie un bisou`,
  },
  en: {
    thinking_of_you: (n) => `${n} is thinking of you`,
    good_night: (n) => `${n} says good night`,
    on_my_way: (n) => `${n} is on the way`,
    miss_you: (n) => `${n} misses you`,
    kiss: (n) => `${n} sends you a kiss`,
  },
};

Deno.serve(async (req) => {
  try {
    const payload: WebhookPayload = await req.json();
    const record = payload.record;
    if (
      payload.table !== "couple_pings" ||
      (payload.type !== "INSERT" && payload.type !== "UPDATE") ||
      !record
    ) {
      return json({ ok: true, skipped: "not a ping write" });
    }

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    );

    const { data: couple } = await supabase
      .from("couples")
      .select("user1_id, user2_id")
      .eq("id", record.couple_id)
      .single();
    if (!couple) return json({ ok: true, skipped: "couple not found" });

    const partnerId = couple.user1_id === record.sender_id
      ? couple.user2_id
      : couple.user1_id;
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

    const lang = partner.language === "en" ? "en" : "fr";
    const name = sender?.username?.trim() ||
      (lang === "fr" ? "Votre partenaire" : "Your partner");
    const body = BODIES[lang][record.kind]?.(name);
    if (!body) return json({ ok: true, skipped: `unknown kind ${record.kind}` });

    const result = await sendPush(sa, {
      token: partner.fcm_token,
      title: "Nous Deux",
      body,
      data: { type: "ping", kind: record.kind, sent_at: record.sent_at },
    });
    return json(result);
  } catch (e) {
    return json({ ok: false, error: String(e) });
  }
});
