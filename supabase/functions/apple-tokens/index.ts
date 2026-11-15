// Keeps the Apple refresh token of each Apple-signed-in account and revokes
// it when the account is deleted (App Store guideline 5.1.1(v)). Only the
// database calls it; see handler.ts.
// Requires: SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, PUSH_WEBHOOK_SECRET,
// APPLE_SIGN_IN_KEY_ID, APPLE_SIGN_IN_KEY.

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { readAppleKey } from "./apple.ts";
import { handle } from "./handler.ts";

const supabase = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
);

Deno.serve((req) =>
  handle(req, {
    key: readAppleKey(),
    saveToken: async (userId, refreshToken) => {
      const { error } = await supabase.from("apple_tokens").upsert({
        user_id: userId,
        refresh_token: refreshToken,
        updated_at: new Date().toISOString(),
      });
      // 23503: the account is gone (foreign key), nothing to keep.
      if (error?.code === "23503") return false;
      if (error) throw new Error(`saving the token failed: ${error.message}`);
      return true;
    },
  })
);
