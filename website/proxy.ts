import { match } from "@formatjs/intl-localematcher";
import Negotiator from "negotiator";
import { NextResponse } from "next/server";
import type { NextRequest } from "next/server";
import { type Locale, defaultLocale, hasLocale, locales } from "@/lib/i18n";

function getLocale(request: NextRequest): Locale {
  const cookieLocale = request.cookies.get("NEXT_LOCALE")?.value;
  if (cookieLocale && hasLocale(cookieLocale)) return cookieLocale;

  const acceptLanguage = request.headers.get("accept-language") ?? "";
  const negotiator = new Negotiator({
    headers: { "accept-language": acceptLanguage },
  });
  const languages = negotiator.languages();
  const matched = match(languages, [...locales], defaultLocale);
  return (matched ?? defaultLocale) as Locale;
}

export function proxy(request: NextRequest) {
  const { pathname } = request.nextUrl;

  const pathnameHasLocale = locales.some(
    (locale) => pathname.startsWith(`/${locale}/`) || pathname === `/${locale}`,
  );

  if (pathnameHasLocale) {
    const requestHeaders = new Headers(request.headers);
    requestHeaders.set("x-pathname", pathname);
    const response = NextResponse.next({
      request: { headers: requestHeaders },
    });
    const localeFromPath = pathname.split("/")[1];
    if (hasLocale(localeFromPath)) {
      response.cookies.set("NEXT_LOCALE", localeFromPath, {
        path: "/",
        maxAge: 60 * 60 * 24 * 365,
      });
    }
    return response;
  }

  const locale = getLocale(request);
  const newUrl = request.nextUrl.clone();
  newUrl.pathname = `/${locale}${pathname}`;

  const response = NextResponse.redirect(newUrl);
  response.cookies.set("NEXT_LOCALE", locale, {
    path: "/",
    maxAge: 60 * 60 * 24 * 365,
  });
  return response;
}

export const config = {
  matcher: [
    "/((?!_next|api|favicon.ico|sitemap.xml|robots.txt|.*\\.(?:ico|png|jpg|jpeg|gif|webp|svg)$).*)",
  ],
};
