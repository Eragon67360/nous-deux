# notify-partner-period

Edge Function that sends a push notification to the partner when a period log is inserted.

## Deploy

```bash
supabase functions deploy notify-partner-period
```

## Secrets

The function uses **FCM HTTP v1** with a **Firebase service account**. Set the secret with the **entire** service account JSON (as a single string).

### 1. Get the service account JSON

1. Open [Firebase Console](https://console.firebase.google.com/) → your project.
2. Go to **Project settings** (gear) → **Service accounts**.
3. Click **Generate new private key** and download the JSON file.

### 2. Set the secret in Supabase

Store the **whole JSON** in the `FIREBASE_SERVICE_ACCOUNT_JSON` secret. From the project root:

```bash
# Option A: from file (recommended)
supabase secrets set FIREBASE_SERVICE_ACCOUNT_JSON="$(cat path/to/your-service-account.json)"

# Option B: paste the JSON (escape or quote for your shell)
supabase secrets set FIREBASE_SERVICE_ACCOUNT_JSON='{"type":"service_account",...}'
```

Use the exact secret name: `FIREBASE_SERVICE_ACCOUNT_JSON`. The function parses it to obtain `project_id`, `client_email`, and `private_key` to request an OAuth2 access token and call the FCM v1 API. The legacy server key is not used.

## Database Webhook

1. In Supabase Dashboard go to **Database** → **Webhooks** (or **Integrations** → **Webhooks**).
2. Create a new webhook:
   - **Table**: `period_logs`
   - **Events**: Insert
   - **Type**: Supabase Edge Functions
   - **Function**: `notify-partner-period`
   - **HTTP Headers**: Add auth header with service role key (or leave default).

After this, every INSERT into `period_logs` will trigger the function, which looks up the partner's FCM token and sends a push notification.
