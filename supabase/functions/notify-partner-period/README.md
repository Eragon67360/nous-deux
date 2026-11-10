# notify-partner-period

Tells the partner that a period log was added. The text stays vague ("Camille
a mis à jour son suivi") because it passes through Apple's and Google's push
services, and period data is health data.

The database calls it on each `period_logs` insert (migration
`20261111100000_push_webhooks.sql`), on the server's internal network only.
It refuses any request without the shared `x-webhook-secret`.

- Deploy: `scripts/deploy-functions.sh root@<server>`
- Settings (`PUSH_WEBHOOK_SECRET`, `FIREBASE_SERVICE_ACCOUNT_JSON`), checks
  and troubleshooting: [docs/SELF_HOSTING.md](../../../docs/SELF_HOSTING.md)
