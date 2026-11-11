import LanguageSwitcher from "@/components/LanguageSwitcher";
import LocaleLink from "@/components/LocaleLink";
import type { Locale } from "@/lib/i18n";

/** Header for the reading pages (policy, account deletion, not found). */
export default function SiteHeader({
  lang,
  siteName,
}: {
  lang: Locale;
  siteName: string;
}) {
  return (
    <header className="border-b border-outline/30">
      <div className="mx-auto flex max-w-3xl items-center justify-between px-6 py-5">
        <LocaleLink
          href="/"
          locale={lang}
          className="font-display text-2xl leading-none text-on-surface no-underline"
        >
          {siteName}
        </LocaleLink>
        <LanguageSwitcher currentLocale={lang} />
      </div>
    </header>
  );
}
