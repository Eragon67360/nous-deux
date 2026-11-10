# notify-partner-ping

Sends the partner a push notification when someone sends a little note
(`send_ping`), in the partner's app language: "Camille pense à toi",
"Alex says good night", and so on.

## Deploy

```bash
supabase functions deploy notify-partner-ping
```

It reuses the `FIREBASE_SERVICE_ACCOUNT_JSON` secret already set for
`notify-partner-period` (see that README if it isn't set yet).

## Database Webhook

In the Supabase Dashboard, **Database → Webhooks**, create:

- **Table**: `couple_pings`
- **Events**: Insert **and** Update (each person has one row; sending again
  updates it)
- **Type**: Supabase Edge Functions
- **Function**: `notify-partner-ping`
- **HTTP Headers**: the service role auth header (default)
