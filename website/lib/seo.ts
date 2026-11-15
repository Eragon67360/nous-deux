/**
 * Centralized SEO and site configuration for metadata, robots, sitemap, and JSON-LD.
 */
import type { Metadata } from "next";
import { type Locale, locales } from "@/lib/i18n";

/**
 * The public address, for canonical links, hreflang, the sitemap, robots.txt
 * and JSON-LD. Fixed on purpose, not read from the environment: every build,
 * a local one or a preview included, should point search engines to the real
 * site. No trailing slash: callers append "/fr/…".
 */
export const SITE_URL = "https://nous-deux.app";

export const SITE_NAME = "Nous Deux";

/** When the privacy policy last changed: the policy page and the sitemap. */
export const POLICY_LAST_UPDATED_ISO = "2026-11-15";

/** Absolute URL of a page in one language; `path` is "" for home or "/beta". */
export function pageUrl(lang: Locale, path: string): string {
  return `${SITE_URL}/${lang}${path}`;
}

/**
 * hreflang links for a page: every language, plus x-default for everyone
 * else, who reads English best (the app follows the same rule).
 */
export function languageAlternates(path: string): Record<string, string> {
  return {
    ...Object.fromEntries(locales.map((l) => [l, pageUrl(l, path)])),
    "x-default": pageUrl("en", path),
  };
}

/**
 * Per-page metadata: canonical, hreflang, Open Graph and Twitter all point to
 * this page in this language. Next.js replaces `alternates` and `openGraph`
 * as a whole when a page sets them, so every page builds all of it here
 * instead of inheriting half of it from the layout. That includes the share
 * image drawn by app/[lang]/opengraph-image.tsx: nested pages that set
 * `openGraph` lose the inherited one.
 */
export function pageMetadata({
  lang,
  path,
  title,
  description,
}: {
  lang: Locale;
  path: string;
  /** The full title, used as is: "Rejoindre la bêta | Nous Deux". */
  title: string;
  description: string;
}): Metadata {
  const url = pageUrl(lang, path);
  const image = {
    url: pageUrl(lang, "/opengraph-image"),
    width: 1200,
    height: 630,
    alt: SITE_NAME,
  };
  return {
    title: { absolute: title },
    description,
    alternates: { canonical: url, languages: languageAlternates(path) },
    openGraph: {
      type: "website",
      siteName: SITE_NAME,
      url,
      title,
      description,
      locale: lang === "fr" ? "fr_FR" : "en_US",
      alternateLocale: lang === "fr" ? "en_US" : "fr_FR",
      images: [image],
    },
    twitter: {
      card: "summary_large_image",
      title,
      description,
      images: [image],
    },
  };
}

/** Base Organization + WebSite JSON-LD for every page. */
export function getBaseStructuredData(locale: Locale, description: string) {
  return {
    "@context": "https://schema.org",
    "@graph": [
      {
        "@type": "Organization",
        "@id": `${SITE_URL}/#organization`,
        name: SITE_NAME,
        url: SITE_URL,
        description,
      },
      {
        "@type": "WebSite",
        "@id": `${SITE_URL}/#website`,
        name: SITE_NAME,
        url: SITE_URL,
        inLanguage: locale,
        publisher: { "@id": `${SITE_URL}/#organization` },
      },
    ],
  };
}
