# Security

Nous Deux holds sensitive data: a couple's notes, calendar, cycle and, if they turn it on, their location. If you find a way to reach data that isn't yours, or anything else that weakens that protection, please report it privately. Reports in French or English are welcome.

## Report a vulnerability

Use GitHub's private reporting: [report a vulnerability](https://github.com/Eragon67360/nous-deux/security/advisories/new). Only the maintainer sees the report. If you can't use GitHub, write to the contact address in the [privacy policy](https://nous-deux.app/en/politique-de-confidentialite).

Please don't open a public issue for a security problem.

Say what you found, how to reproduce it, and what it lets someone do.

## Scope

- The iOS and Android apps, latest release.
- The backend at `api.nous-deux.app`: database rules (`supabase/migrations/`), edge functions (`supabase/functions/`), sign-in.
- The website `nous-deux.app`.
- The server stack in `infra/`.

## When testing

- Use only accounts you created. Don't read, change or delete other people's data. If you reach some by accident, stop there and report what you saw without keeping a copy.
- No denial of service, spam, social engineering or attacks on the hosting providers.
- Give us time to fix the problem before you publish anything about it.

## What to expect

Nous Deux is a free project run by one person, with no bug bounty. You'll get a reply within a week, news while the fix is under way, and credit in the published advisory if you want it.
