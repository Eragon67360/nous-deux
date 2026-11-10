# notify-partner-ping

Sends the partner a push notification when someone sends a little note
(`send_ping`), in the partner's app language: "Camille pense à toi",
"Alex says good night", and so on.

## Deploy

```bash
supabase functions deploy notify-partner-ping
```

It reuses the `FIREBASE_SERVICE_ACCOUNT_JSON` secret already set for
`notify-partner-period` (see that README if it isn't set yet), and needs
its own webhook secret so only the database can call it:

```bash
PING_WEBHOOK_SECRET="$(openssl rand -hex 32)"
echo "$PING_WEBHOOK_SECRET"   # keep it for the webhook header below
supabase secrets set PING_WEBHOOK_SECRET="$PING_WEBHOOK_SECRET"
```
 The function refuses any request
without it (`verify_jwt` is off for this function in `config.toml`, since
the secret replaces the JWT check).

## Database Webhook

In the Supabase Dashboard, **Database → Webhooks**, create:

- **Table**: `couple_pings`
- **Events**: Insert **and** Update (each person has one row; sending again
  updates it)
- **Type**: Supabase Edge Functions
- **Function**: `notify-partner-ping`
- **HTTP Headers**: add `x-webhook-secret` with the `PING_WEBHOOK_SECRET`
  value
