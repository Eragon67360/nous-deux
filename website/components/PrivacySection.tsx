import LocaleLink from "./LocaleLink";
import type { Locale } from "@/lib/i18n";

type PrivacyDict = {
  heading: string;
  paragraph: string;
  privacyLink: string;
  and: string;
  accountDeletionLink: string;
  suffix: string;
};

export default function PrivacySection({
  dict,
  lang,
}: {
  dict: PrivacyDict;
  lang: Locale;
}) {
  return (
    <section className="px-6 py-16 sm:py-24" aria-labelledby="privacy-heading">
      <div className="mx-auto max-w-2xl text-center">
        <h2
          id="privacy-heading"
          className="text-2xl font-semibold text-on-surface sm:text-3xl"
        >
          {dict.heading}
        </h2>
        <p className="mt-4 text-on-surface-variant leading-relaxed">
          {dict.paragraph}{" "}
          <LocaleLink
            href="/politique-de-confidentialite"
            locale={lang}
            className="text-primary underline hover:no-underline focus:outline-none focus:ring-2 focus:ring-primary focus:ring-offset-2 focus:ring-offset-surface rounded"
          >
            {dict.privacyLink}
          </LocaleLink>{" "}
          {dict.and}{" "}
          <LocaleLink
            href="/suppression-compte"
            locale={lang}
            className="text-primary underline hover:no-underline focus:outline-none focus:ring-2 focus:ring-primary focus:ring-offset-2 focus:ring-offset-surface rounded"
          >
            {dict.accountDeletionLink}
          </LocaleLink>
          {dict.suffix}
        </p>
      </div>
    </section>
  );
}
