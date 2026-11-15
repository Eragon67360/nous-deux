# Nous Deux website

The public site at https://nous-deux.app, in French and English: the home page, the Android beta page, the privacy policy and the account deletion page. Next.js 16 and Tailwind 4.

## Working on it

```bash
npm ci
npm run dev
```

- Copy lives in `lib/dictionaries/{fr,en}.json`, the privacy policy included (under `policy`). Change both languages.
- Before a PR: `npx tsc --noEmit`, `npm run lint`, and `npx prettier --write` on the files you touched.

## Hosting

Coolify (`coolify.thomasmoserdev.com`) builds this folder's `Dockerfile` and runs the container on the Hetzner server in Germany that also runs the backend (`api.nous-deux.app`). `next.config.ts` sets `output: "standalone"`, so the image holds only the Node server, `public/` and the static assets. The site needs no environment variables: its public address is the `SITE_URL` constant in `lib/seo.ts`.

Until the DNS switch, Vercel still serves nous-deux.app from `main`.

Coolify application settings:

| Setting     | Value                                                                    |
| ----------- | ------------------------------------------------------------------------ |
| Source      | GitHub App, repository `Eragon67360/nous-deux`, branch `main`            |
| Build pack  | Dockerfile, base directory `/website`, Dockerfile location `/Dockerfile` |
| Port        | 3000                                                                     |
| Domains     | `https://nous-deux.app,https://www.nous-deux.app`, redirect to non-www   |
| Healthcheck | dashboard check off; the image's `HEALTHCHECK` fetches `/robots.txt`     |

Each push to `main` (a `dev` → `main` release) redeploys the site. Images resized by `next/image` (through sharp) are cached inside the container and made again on demand after a deploy.

DNS for `nous-deux.app` is in Hetzner DNS. The apex and `www` point at the server like `api` does: `A 5.75.147.14`, `AAAA 2a01:4f8:1c16:f769::1`.

To try the image locally:

```bash
docker build -t nous-deux-website .
```

```bash
docker run --rm -p 3000:3000 nous-deux-website
```
