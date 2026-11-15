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

Coolify (`coolify.thomasmoserdev.com`) builds this folder's `Dockerfile` and runs the container on the Hetzner server in Germany that also runs the backend (`api.nous-deux.app`). `next.config.ts` sets `output: "standalone"`, so the image holds only the Node server, `public/` and the static assets. Its public address is the `SITE_URL` constant in `lib/seo.ts`. The one environment variable, `UMAMI_WEBSITE_ID`, is set only on the Coolify app: it turns on the visit counts from Umami (`stats.nous-deux.app`, also on Coolify, cookie-free; see `components/Stats.tsx`). Without it, nothing is counted.

Coolify application settings:

| Setting     | Value                                                                    |
| ----------- | ------------------------------------------------------------------------ |
| Source      | Public repository `Eragon67360/nous-deux`, branch `main`                 |
| Build pack  | Dockerfile, base directory `/website`, Dockerfile location `/Dockerfile` |
| Port        | 3000                                                                     |
| Domains     | `https://nous-deux.app,https://www.nous-deux.app`, 308 to non-www        |
| Healthcheck | dashboard check off; the image's `HEALTHCHECK` fetches `/robots.txt`     |
| Environment | `UMAMI_WEBSITE_ID`, the website's ID in Umami (runtime only)             |

The app is `nous-deux-website` in Coolify. A GitHub webhook on the repository (push events, to Coolify's manual GitHub endpoint, signed with the secret shown on the app's Webhooks page) redeploys it on every push to `main`, app-only releases included. Images resized by `next/image` (through sharp) are cached inside the container and made again on demand after a deploy.

DNS for `nous-deux.app` is in Hetzner DNS. The apex and `www` point at the server like `api` does: `A 5.75.147.14`, `AAAA 2a01:4f8:1c16:f769::1`.

To try the image locally:

```bash
docker build -t nous-deux-website .
```

```bash
docker run --rm -p 3000:3000 nous-deux-website
```
