# wake-partner-calendar

Asks a partner's phone to sync the phone calendars it follows
([docs/CALENDAR_SYNC.md](../../../docs/CALENDAR_SYNC.md)). Only the database
calls it, on the server's internal network, with the shared
`x-webhook-secret`: `request_partner_calendar_sync()` (migration
`20261117200000_calendar_follow.sql`) inserts a row in
`private.calendar_wakes` when someone opens the couple's calendar, at most
once in 20 minutes per partner and not when the partner synced in the last
10.

The push shows nothing and carries only `{ "type": "calendar_sync" }`: on iOS
a background push (`apns-push-type: background`, priority 5), which iOS may
delay or drop and never delivers to an app the person swiped away; on Android
a normal-priority data message. It skips anyone who no longer follows a
calendar or has no push token.

- Settings: `FIREBASE_SERVICE_ACCOUNT_JSON`, `PUSH_WEBHOOK_SECRET` and the
  service role key, as for the notify functions.
- Tests: the command at the top of `handler_test.ts`.
