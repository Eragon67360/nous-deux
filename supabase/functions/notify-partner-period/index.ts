// Notify partner when a period log is created (Database Webhook → this function).
// Requires: SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY (auto), FIREBASE_SERVICE_ACCOUNT_JSON (FCM v1).

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import * as jose from "https://esm.sh/jose@5";

interface FirebaseServiceAccount {
  type: string;
  project_id: string;
  private_key_id: string;
  private_key: string;
  client_email: string;
  client_id: string;
  auth_uri: string;
  token_uri: string;
  auth_provider_x509_cert_url: string;
  client_x509_cert_url: string;
}

interface PeriodLogRecord {
  id: string;
  user_id: string;
  couple_id: string;
  start_date: string;
  end_date?: string;
  mood?: string;
  symptoms?: string[];
  notes?: string;
  created_at: string;
  updated_at: string;
}

interface WebhookPayload {
  type: "INSERT" | "UPDATE" | "DELETE";
  table: string;
  record: PeriodLogRecord;
  schema: string;
  old_record: PeriodLogRecord | null;
}

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

async function getAccessToken(sa: FirebaseServiceAccount): Promise<string> {
  const key = await jose.importPKCS8(sa.private_key, "RS256");
  const jwt = await new jose.SignJWT({})
    .setProtectedHeader({ alg: "RS256", typ: "JWT" })
    .setIssuer(sa.client_email)
    .setSubject(sa.client_email)
    .setAudience("https://oauth2.googleapis.com/token")
    .setIssuedAt()
    .setExpirationTime("1h")
    .sign(key);
  const res = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion: jwt,
    }),
  });
  if (!res.ok) {
    const text = await res.text();
    throw new Error(`OAuth2 token failed: ${res.status} ${text}`);
  }
  const data = await res.json();
  return data.access_token;
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const payload: WebhookPayload = await req.json();
    if (payload.type !== "INSERT" || payload.table !== "period_logs") {
      return new Response(
        JSON.stringify({ ok: true, skipped: "not an INSERT on period_logs" }),
        {
          headers: { ...corsHeaders, "Content-Type": "application/json" },
          status: 200,
        }
      );
    }

    const record = payload.record;
    const userId = record.user_id;
    const coupleId = record.couple_id;

    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const supabase = createClient(supabaseUrl, serviceRoleKey);

    const { data: couple, error: coupleError } = await supabase
      .from("couples")
      .select("user1_id, user2_id")
      .eq("id", coupleId)
      .single();

    if (coupleError || !couple) {
      return new Response(
        JSON.stringify({ ok: false, error: "couple not found" }),
        {
          headers: { ...corsHeaders, "Content-Type": "application/json" },
          status: 200,
        }
      );
    }

    const partnerId =
      couple.user1_id === userId ? couple.user2_id : couple.user1_id;
    if (!partnerId) {
      return new Response(
        JSON.stringify({ ok: true, skipped: "no partner in couple" }),
        {
          headers: { ...corsHeaders, "Content-Type": "application/json" },
          status: 200,
        }
      );
    }

    const { data: profile, error: profileError } = await supabase
      .from("profiles")
      .select("fcm_token")
      .eq("id", partnerId)
      .single();

    if (profileError || !profile?.fcm_token) {
      return new Response(
        JSON.stringify({ ok: true, skipped: "partner has no fcm_token" }),
        {
          headers: { ...corsHeaders, "Content-Type": "application/json" },
          status: 200,
        }
      );
    }

    const saJson = Deno.env.get("FIREBASE_SERVICE_ACCOUNT_JSON");
    if (!saJson) {
      return new Response(
        JSON.stringify({
          ok: true,
          skipped: "FIREBASE_SERVICE_ACCOUNT_JSON not set",
        }),
        {
          headers: { ...corsHeaders, "Content-Type": "application/json" },
          status: 200,
        }
      );
    }

    let sa: FirebaseServiceAccount;
    try {
      sa = JSON.parse(saJson) as FirebaseServiceAccount;
    } catch {
      return new Response(
        JSON.stringify({
          ok: false,
          error: "FIREBASE_SERVICE_ACCOUNT_JSON is invalid JSON",
        }),
        {
          headers: { ...corsHeaders, "Content-Type": "application/json" },
          status: 200,
        }
      );
    }

    const accessToken = await getAccessToken(sa);
    const fcmUrl = `https://fcm.googleapis.com/v1/projects/${sa.project_id}/messages:send`;
    const fcmRes = await fetch(fcmUrl, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${accessToken}`,
      },
      body: JSON.stringify({
        message: {
          token: profile.fcm_token,
          notification: {
            title: "Règles",
            body: "Votre partenaire a enregistré un suivi de règles.",
          },
        },
      }),
    });

    if (!fcmRes.ok) {
      const text = await fcmRes.text();
      return new Response(JSON.stringify({ ok: false, fcm: text }), {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 200,
      });
    }

    return new Response(JSON.stringify({ ok: true }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 200,
    });
  } catch (e) {
    return new Response(JSON.stringify({ ok: false, error: String(e) }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 200,
    });
  }
});
