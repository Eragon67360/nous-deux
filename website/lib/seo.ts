/**
 * Centralized SEO and site configuration for metadata, robots, sitemap, and JSON-LD.
 */

export const SITE_URL =
  process.env.NEXT_PUBLIC_SITE_URL ?? "https://nous-deux-website.vercel.app/";

export const SITE_NAME = "Nous Deux";
export const SITE_DESCRIPTION =
  "Nous Deux est une application pour couples centrée sur la confidentialité : calendrier partagé, suivi des règles, position optionnelle. Gratuit, sans publicité.";

export const DEFAULT_OG = {
  type: "website" as const,
  locale: "fr_FR",
  siteName: SITE_NAME,
  description: SITE_DESCRIPTION,
};

export const DEFAULT_TWITTER = {
  card: "summary_large_image" as const,
  title: `${SITE_NAME} – Application pour couples`,
  description: SITE_DESCRIPTION,
};

/** Base Organization + WebSite JSON-LD for layout or home. */
export function getBaseStructuredData(locale: string = "fr") {
  return {
    "@context": "https://schema.org",
    "@graph": [
      {
        "@type": "Organization",
        "@id": `${SITE_URL}/#organization`,
        name: SITE_NAME,
        url: SITE_URL,
        description: SITE_DESCRIPTION,
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
