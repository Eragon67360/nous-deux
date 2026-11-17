// Wakes a partner's phone so it syncs the calendars it follows. Only the
// database calls it; see handler.ts.
// Requires: SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, PUSH_WEBHOOK_SECRET,
// FIREBASE_SERVICE_ACCOUNT_JSON.

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { json } from "../_shared/database.ts";
import { readServiceAccount, sendBackgroundPush } from "../_shared/fcm.ts";
import { handleWake } from "./handler.ts";

const supabase = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
);

Deno.serve((req) => {
  const sa = readServiceAccount();
  if (!sa) {
    console.error("wake-partner-calendar: FIREBASE_SERVICE_ACCOUNT_JSON is not set");
    return json({ ok: false, skipped: "no service account" });
  }
  return handleWake(req, {
    loadProfile: async (userId) => {
      const { data, error } = await supabase
        .from("profiles")
        .select("fcm_token, calendar_sync_device")
        .eq("id", userId)
        .maybeSingle();
      if (error) throw new Error(`reading the profile failed: ${error.message}`);
      return data;
    },
    sendBackgroundPush: (token, data) => sendBackgroundPush(sa, token, data),
  });
});
