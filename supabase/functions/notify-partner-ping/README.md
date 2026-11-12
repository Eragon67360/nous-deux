# notify-partner-ping

Sends the partner a push notification when someone sends a little note
(`send_ping`), in the partner's app language: "Camille pense à toi",
"Alex says good night", and so on.

The database calls it on each `couple_pings` insert or update (migration
`20261111100000_push_webhooks.sql`), on the server's internal network only.
It refuses any request without the shared `x-webhook-secret`.

- Deploy: `scripts/deploy-functions.sh root@<server>`
- Settings (`PUSH_WEBHOOK_SECRET`, `FIREBASE_SERVICE_ACCOUNT_JSON`), checks
  and troubleshooting: [docs/SELF_HOSTING.md](../../../docs/SELF_HOSTING.md)
