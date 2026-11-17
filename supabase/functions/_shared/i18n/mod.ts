// The functions' push texts in every language the server speaks, and `t` to
// read them (docs/LOCALIZATION.md, phase 5). English is the reference and the
// fallback: a language that has no file here, or a key missing from one,
// reads in English.
//
// Adding a language: copy en.json to xx.json and translate the values, keep
// the {placeholders}, import it below, then deploy the functions
// (scripts/deploy-functions.sh). i18n_test.ts checks every file has exactly
// en.json's keys.

import en from "./en.json" with { type: "json" };
import fr from "./fr.json" with { type: "json" };

export type MessageKey = keyof typeof en;
type Catalog = Record<MessageKey, string>;
type Catalogs = { en: Catalog } & Record<string, Partial<Catalog>>;

const CATALOGS: Catalogs = { en, fr };

/** The language codes the server speaks, as stored in `profiles.language`. */
export const LANGUAGES: readonly string[] = Object.keys(CATALOGS);

/** Whether `key` is in the catalog (for keys built from data, like a ping's kind). */
export function isMessageKey(key: string): key is MessageKey {
  return Object.hasOwn(en, key);
}

/** A `t` reading `catalogs`; the functions use `t` below, tests use their own catalogs. */
export function translator(catalogs: Catalogs) {
  return (
    lang: string | null | undefined,
    key: MessageKey,
    params: Record<string, string> = {},
  ): string => {
    const own = lang && Object.hasOwn(catalogs, lang) ? catalogs[lang][key] : undefined;
    // A function replacer, so `$&` or `{name}` inside a param stays as written.
    return (own ?? catalogs.en[key]).replace(
      /\{(\w+)\}/g,
      (match, name: string) => Object.hasOwn(params, name) ? params[name] : match,
    );
  };
}

/** The text for `key` in `lang`, with `{placeholders}` filled from `params`. */
export const t = translator(CATALOGS);
