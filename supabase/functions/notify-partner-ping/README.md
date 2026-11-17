# notify-partner-ping

Sends the partner a push notification when someone sends a little note
(`send_ping`), in the partner's app language: "Camille pense à toi",
"Alex says good night", and so on. For a note the sender wrote (kind
`custom`), the push only says there is one ("Camille t'a écrit un petit
mot", "Alex wrote you a little note"): the words stay out of the push, so
they never go through Google's or Apple's push servers. The app shows them
once it reads the note.

The database calls it on each `couple_pings` insert or update (migration
`20261111100000_push_webhooks.sql`), on the server's internal network only.
It refuses any request without the shared `x-webhook-secret`.

- Texts: `../_shared/i18n/{fr,en}.json`, read by `message.ts`. A language
  without a file there gets English.
- Tests: the command at the top of `message_test.ts`.
- Deploy: `scripts/deploy-functions.sh root@<server>`
- Settings (`PUSH_WEBHOOK_SECRET`, `FIREBASE_SERVICE_ACCOUNT_JSON`), checks
  and troubleshooting: [docs/SELF_HOSTING.md](../../../docs/SELF_HOSTING.md)
