import "server-only";
import type { Locale } from "@/lib/i18n";
import { hasLocale as checkLocale } from "@/lib/i18n";

export type { Locale };
export const hasLocale = checkLocale;

import type enDict from "./dictionaries/en.json";
import type frDict from "./dictionaries/fr.json";

/** The site's copy. English is the reference other languages are translated from. */
export type Dictionary = typeof enDict;

/**
 * Every key of every language. Each dictionary must have all of them, so a key
 * missing in any language fails `tsc` and `next build`. A new language adds its
 * type here and its loader below.
 */
type FullShape = typeof enDict & typeof frDict;

const dictionaries = {
  fr: () => import("./dictionaries/fr.json").then((m) => m.default),
  en: () => import("./dictionaries/en.json").then((m) => m.default),
} satisfies Record<Locale, () => Promise<FullShape>>;

export async function getDictionary(locale: Locale): Promise<Dictionary> {
  return dictionaries[locale]();
}
