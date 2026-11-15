import type { Locale } from "@/lib/i18n";

/** The app screens shown on the site: the app in the page's language. */
export type Screen =
  | "calendar"
  | "merge-me"
  | "merge-partner"
  | "cycle"
  | "position"
  | "nous"
  | "ping"
  | "lists";

/**
 * Path of an app capture (Alex and Camille, invented, taken on the local
 * backend; see public/screenshots/README.md). French captures sit at the
 * root, English ones in en/.
 */
export function screenshot(lang: Locale, screen: Screen): string {
  return lang === "en"
    ? `/screenshots/en/${screen}.png`
    : `/screenshots/${screen}.png`;
}
