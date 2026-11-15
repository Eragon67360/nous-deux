import { locales } from "@/lib/i18n";
import {
  POLICY_LAST_UPDATED_ISO,
  languageAlternates,
  pageUrl,
} from "@/lib/seo";
import type { MetadataRoute } from "next";

/**
 * Each page with the date its content last changed. Search engines trust
 * lastmod only while it stays accurate, so change a date with the content,
 * not on every build.
 */
const routes = [
  { path: "", lastModified: "2026-11-15" },
  { path: "/beta", lastModified: "2026-11-15" },
  {
    path: "/politique-de-confidentialite",
    lastModified: POLICY_LAST_UPDATED_ISO,
  },
  { path: "/suppression-compte", lastModified: "2026-11-14" },
];

export default function sitemap(): MetadataRoute.Sitemap {
  return locales.flatMap((lang) =>
    routes.map((route) => ({
      url: pageUrl(lang, route.path),
      lastModified: route.lastModified,
      alternates: { languages: languageAlternates(route.path) },
    })),
  );
}
