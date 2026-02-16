"use client";

import { usePathname, useRouter } from "next/navigation";
import type { Locale } from "@/lib/i18n";
import { pathWithoutLocale } from "@/lib/i18n";

const COOKIE_MAX_AGE = 60 * 60 * 24 * 365;

function setLocaleCookie(locale: Locale) {
  document.cookie = `NEXT_LOCALE=${locale}; path=/; max-age=${COOKIE_MAX_AGE}; SameSite=Lax`;
  if (typeof window !== "undefined") {
    try {
      window.localStorage.setItem("NEXT_LOCALE", locale);
    } catch {
      // ignore
    }
  }
}

type LanguageSwitcherProps = {
  currentLocale: Locale;
};

export default function LanguageSwitcher({
  currentLocale,
}: LanguageSwitcherProps) {
  const router = useRouter();
  const pathname = usePathname();
  const pathWithoutLang = pathWithoutLocale(pathname);

  function switchTo(locale: Locale) {
    if (locale === currentLocale) return;
    setLocaleCookie(locale);
    const newPath =
      locale === "fr"
        ? `/fr${pathWithoutLang === "/" ? "" : pathWithoutLang}`
        : `/en${pathWithoutLang === "/" ? "" : pathWithoutLang}`;
    router.push(newPath);
  }

  const baseClass =
    "px-3 py-1.5 text-sm font-medium rounded-md transition-colors duration-200 focus:outline-none focus:ring-2 focus:ring-primary focus:ring-offset-2 focus:ring-offset-surface";
  const activeClass = "bg-primary text-surface";
  const inactiveClass =
    "text-on-surface-variant hover:text-on-surface hover:bg-surface-container/50";

  return (
    <div
      className="flex items-center gap-1"
      role="group"
      aria-label="Choisir la langue"
    >
      <button
        type="button"
        onClick={() => switchTo("fr")}
        className={`${baseClass} ${currentLocale === "fr" ? activeClass : inactiveClass}`}
        aria-pressed={currentLocale === "fr"}
        lang="fr"
      >
        FR
      </button>
      <button
        type="button"
        onClick={() => switchTo("en")}
        className={`${baseClass} ${currentLocale === "en" ? activeClass : inactiveClass}`}
        aria-pressed={currentLocale === "en"}
        lang="en"
      >
        EN
      </button>
    </div>
  );
}
