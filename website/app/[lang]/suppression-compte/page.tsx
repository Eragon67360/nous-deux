import Breadcrumbs from "@/components/Breadcrumbs";
import LocaleLink from "@/components/LocaleLink";
import { SITE_URL } from "@/lib/seo";
import { localizedPath } from "@/lib/i18n";
import type { Locale } from "@/lib/i18n";
import type { Metadata } from "next";
import { getDictionary, hasLocale } from "@/lib/dictionaries";
import { notFound } from "next/navigation";

const CONTACT_EMAIL = "thomas-moser@orange.fr";

type PageProps = { params: Promise<{ lang: string }> };

export async function generateMetadata({
  params,
}: PageProps): Promise<Metadata> {
  const { lang } = await params;
  if (!hasLocale(lang)) return {};
  const dict = await getDictionary(lang);
  const basePath = `/${lang}/suppression-compte`;
  return {
    title: dict.suppression.meta.title,
    description: dict.suppression.meta.description,
    alternates: {
      canonical: `${SITE_URL}${basePath}`,
      languages: {
        fr: `${SITE_URL}/fr/suppression-compte`,
        en: `${SITE_URL}/en/suppression-compte`,
      },
    },
  };
}

export default async function SuppressionComptePage({ params }: PageProps) {
  const { lang } = await params;
  if (!hasLocale(lang)) notFound();
  const dict = await getDictionary(lang);
  const s = dict.suppression;
  const basePath = `/${lang}/suppression-compte`;

  const suppressionPageStructuredData = {
    "@context": "https://schema.org",
    "@graph": [
      {
        "@type": "HowTo",
        name: s.meta.title,
        description: s.meta.description,
        inLanguage: lang,
        step: [
          {
            "@type": "HowToStep",
            position: 1,
            name: s.howToTitle,
            text: s.howToIntro,
          },
          {
            "@type": "HowToStep",
            position: 2,
            name: s.phoneNote,
            text: s.phoneNoteSuffix,
          },
          {
            "@type": "HowToStep",
            position: 3,
            name: s.processingNote,
            text: s.noteBody,
          },
        ],
      },
    ],
  };

  const breadcrumbItems = [
    { label: dict.breadcrumbs.home, href: localizedPath("/", lang) },
    {
      label: dict.breadcrumbs.accountDeletion,
      href: localizedPath("/suppression-compte", lang),
    },
  ];

  const linkClass =
    "text-primary underline hover:no-underline focus:outline-none focus:ring-2 focus:ring-primary rounded";

  return (
    <div className="min-h-screen bg-surface text-on-surface">
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{
          __html: JSON.stringify(suppressionPageStructuredData),
        }}
      />
      <div className="mx-auto max-w-3xl px-6 py-12 sm:px-8">
        <header className="mb-10">
          <Breadcrumbs items={breadcrumbItems} />
          <LocaleLink
            href="/"
            locale={lang as Locale}
            className="text-primary hover:underline focus:outline-none focus:ring-2 focus:ring-primary focus:ring-offset-2 focus:ring-offset-surface rounded"
          >
            {dict.common.siteName}
          </LocaleLink>
          <h1 className="mt-4 text-3xl font-semibold tracking-tight text-on-surface sm:text-4xl">
            {s.title}
          </h1>
          <hr className="mt-6 border-outline/50" />
        </header>

        <article className="space-y-6 text-on-surface-variant leading-relaxed">
          <p>{s.intro}</p>

          <section>
            <h2 className="mb-3 text-xl font-semibold text-on-surface">
              {s.howToTitle}
            </h2>
            <p className="mb-4">{s.howToIntro}</p>
            <p className="mb-4">
              <a
                href={`mailto:${CONTACT_EMAIL}?subject=${encodeURIComponent(s.emailSubject)}`}
                className="text-primary font-medium underline hover:no-underline focus:outline-none focus:ring-2 focus:ring-primary rounded"
              >
                {CONTACT_EMAIL}
              </a>
            </p>
            <p className="mb-4">
              <strong className="text-on-surface">{s.phoneNote}</strong>{" "}
              {s.phoneNoteSuffix}
            </p>
            <p>
              {s.processingNote}{" "}
              <LocaleLink
                href="/politique-de-confidentialite"
                locale={lang as Locale}
                className={linkClass}
              >
                {s.privacyLink}
              </LocaleLink>
              .
            </p>
          </section>

          <section>
            <h2 className="mb-3 text-xl font-semibold text-on-surface">
              {s.noteTitle}
            </h2>
            <p>{s.noteBody}</p>
          </section>
        </article>

        <footer className="mt-14 pt-8 border-t border-outline/50 flex flex-wrap gap-6">
          <LocaleLink
            href="/politique-de-confidentialite"
            locale={lang as Locale}
            className="text-primary hover:underline focus:outline-none focus:ring-2 focus:ring-primary focus:ring-offset-2 focus:ring-offset-surface rounded"
          >
            {s.footerPrivacy}
          </LocaleLink>
          <LocaleLink
            href="/"
            locale={lang as Locale}
            className="text-primary hover:underline focus:outline-none focus:ring-2 focus:ring-primary focus:ring-offset-2 focus:ring-offset-surface rounded"
          >
            {s.backHome}
          </LocaleLink>
        </footer>
      </div>
    </div>
  );
}
