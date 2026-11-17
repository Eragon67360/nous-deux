export const locales = ["fr", "en"] as const;
export type Locale = (typeof locales)[number];

/**
 * The language for visitors whose browser accepts none of `locales` (or sends
 * no preference): English, like x-default and the app. Only the proxy's
 * negotiation reads it; a remembered choice (the NEXT_LOCALE cookie) wins.
 */
export const defaultLocale: Locale = "en";

export function hasLocale(locale: string): locale is Locale {
  return locales.includes(locale as Locale);
}

/** Path without leading locale segment (e.g. /fr/foo -> /foo). */
export function pathWithoutLocale(pathname: string): string {
  for (const locale of locales) {
    if (pathname === `/${locale}`) return "/";
    if (pathname.startsWith(`/${locale}/`))
      return pathname.slice(locale.length + 1) || "/";
  }
  return pathname;
}

/** Build href for a path in the given locale (e.g. /politique-de-confidentialite, fr -> /fr/politique-de-confidentialite). */
export function localizedPath(path: string, lang: Locale): string {
  const normalized =
    path === "/" ? "" : path.startsWith("/") ? path : `/${path}`;
  return `/${lang}${normalized}`;
}
