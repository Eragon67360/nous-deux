# Messages to everyone (Nouveautés)

Each file here is one message from the team. It arrives as a push to everyone who has « Nouveautés de l'app » on, and stays in Paramètres › Nouveautés for everyone, including people who join later. Design and decisions: `docs/NOUVEAUTES.md`.

## The file

`announcements/2026-11-20-listes.json`. The name is the date, then lowercase words with dashes; it is the message's id, and a file is sent only once.

```json
{
  "fr": { "title": "Les listes partagées sont là", "body": "Courses, idées de sorties : ajoutez, cochez, l'autre voit tout de suite." },
  "en": { "title": "Shared lists are here", "body": "Groceries, date ideas: add, tick, and the other sees it at once." }
}
```

- **Languages:** one entry per app language, no more and no less: FR and EN today, ES once Spanish ships (`supabase/functions/_shared/i18n/mod.ts` lists them). Each person gets the language chosen in their app.
- **Length:** a title of 60 characters at most, a body of 280 at most.
- **Wording:** gender-neutral, signed by the team (the app adds « L'équipe Nous Deux »). No personal data.

## Sending

Run from the repo root:

```bash
scripts/announce.sh nous-deux announcements/2026-11-20-listes.json --test
```

```bash
scripts/announce.sh nous-deux announcements/2026-11-20-listes.json
```

1. **`--test`** sends to the team's accounts only (the `announcement_testers` table) and records nothing in Nouveautés.
2. **Without it**, the script shows each language's text and how many people it will reach, then sends when you type `ENVOYER`.

Sending to everyone is refused when there was no test, or when the file changed after its test (run `--test` again). A file already sent is refused too. `local` instead of `nous-deux` targets a local stack.

Adding a team account to the tests (once, as `postgres`): `INSERT INTO public.announcement_testers VALUES ('<profile id>');`.
