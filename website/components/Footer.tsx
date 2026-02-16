import type { Locale } from "@/lib/i18n";
import LocaleLink from "./LocaleLink";

const GITHUB_REPO = "https://github.com/Eragon67360/nous-deux";

const linkClass =
  "text-primary hover:underline focus:outline-none focus:ring-2 focus:ring-primary focus:ring-offset-2 focus:ring-offset-surface rounded";

type FooterProps = {
  lang: Locale;
  dict: {
    footer: {
      ariaLabel: string;
      privacy: string;
      accountDeletion: string;
      github: string;
    };
  };
};

export default function Footer({ lang, dict }: FooterProps) {
  return (
    <footer className="border-t border-outline/30 px-6 py-10 sm:py-12">
      <nav
        className="mx-auto flex max-w-5xl flex-col items-center justify-center gap-4 sm:flex-row sm:gap-8"
        aria-label={dict.footer.ariaLabel}
      >
        <LocaleLink
          href="/politique-de-confidentialite"
          locale={lang}
          className={linkClass}
        >
          {dict.footer.privacy}
        </LocaleLink>
        <LocaleLink
          href="/suppression-compte"
          locale={lang}
          className={linkClass}
        >
          {dict.footer.accountDeletion}
        </LocaleLink>
        <a
          href={GITHUB_REPO}
          target="_blank"
          rel="noopener noreferrer"
          className={linkClass}
        >
          {dict.footer.github}
        </a>
      </nav>
    </footer>
  );
}
