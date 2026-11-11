export const locales = ["fr", "en"] as const;
export type Locale = (typeof locales)[number];

export const defaultLocale: Locale = "fr";

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
