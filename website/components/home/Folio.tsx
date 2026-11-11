"use client";

import { useEffect, useState } from "react";
import LanguageSwitcher from "@/components/LanguageSwitcher";
import LocaleLink from "@/components/LocaleLink";
import type { Locale } from "@/lib/i18n";

/**
 * The margin folio: wordmark, the chapter you are in, and the language switch.
 * Chapters are any element carrying `data-folio` (number) and
 * `data-folio-title`. The label follows the chapter crossing the middle of
 * the viewport.
 */
export default function Folio({
  lang,
  siteName,
  coverTitle,
}: {
  lang: Locale;
  siteName: string;
  coverTitle: string;
}) {
  const [current, setCurrent] = useState<{ n: string; title: string }>({
    n: "0",
    title: coverTitle,
  });

  useEffect(() => {
    const chapters = Array.from(
      document.querySelectorAll<HTMLElement>("[data-folio]"),
    );
    const io = new IntersectionObserver(
      (entries) => {
        for (const entry of entries) {
          if (!entry.isIntersecting) continue;
          const el = entry.target as HTMLElement;
          setCurrent({
            n: el.dataset.folio ?? "0",
            title: el.dataset.folioTitle ?? coverTitle,
          });
        }
      },
      { rootMargin: "-50% 0px -50% 0px" },
    );
    chapters.forEach((el) => io.observe(el));
    return () => io.disconnect();
  }, [coverTitle]);

  const label =
    current.n === "0" ? current.title : `${current.n.padStart(2, "0")} · ${current.title}`;

  return (
    <header className="nd-folio">
      <div className="nd-folio__left">
        <LocaleLink href="/" locale={lang} className="nd-folio__mark">
          {siteName}
        </LocaleLink>
        <p className="nd-folio__chapter" aria-hidden="true">
          {label}
        </p>
      </div>
      <LanguageSwitcher currentLocale={lang} />
    </header>
  );
}
