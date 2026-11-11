import { SITE_URL } from "@/lib/seo";
import type { MetadataRoute } from "next";

const baseUrl = SITE_URL.replace(/\/$/, "");
const locales = ["fr", "en"] as const;

const routes = [
  {
    path: "",
    lastModified: new Date(),
    changeFrequency: "monthly" as const,
    priority: 1,
  },
  {
    path: "politique-de-confidentialite",
    lastModified: new Date("2026-02-11"),
    changeFrequency: "yearly" as const,
    priority: 0.5,
  },
  {
    path: "suppression-compte",
    lastModified: new Date(),
    changeFrequency: "yearly" as const,
    priority: 0.5,
  },
];

export default function sitemap(): MetadataRoute.Sitemap {
  const entries: MetadataRoute.Sitemap = [];
  for (const locale of locales) {
    for (const route of routes) {
      const path = route.path ? `/${locale}/${route.path}` : `/${locale}`;
      entries.push({
        url: `${baseUrl}${path}`,
        lastModified: route.lastModified,
        changeFrequency: route.changeFrequency,
        priority: route.priority,
      });
    }
  }
  return entries;
}
