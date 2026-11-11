import "server-only";
import type { Locale } from "@/lib/i18n";
import { hasLocale as checkLocale } from "@/lib/i18n";

export type { Locale };
export const hasLocale = checkLocale;

import type frDict from "./dictionaries/fr.json";
export type Dictionary = typeof frDict;

const dictionaries = {
  fr: () => import("./dictionaries/fr.json").then((m) => m.default),
  en: () => import("./dictionaries/en.json").then((m) => m.default),
};

export async function getDictionary(locale: Locale): Promise<Dictionary> {
  return dictionaries[locale]() as Promise<Dictionary>;
}
