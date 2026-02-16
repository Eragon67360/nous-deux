import Breadcrumbs from "@/components/Breadcrumbs";
import LocaleLink from "@/components/LocaleLink";
import { SITE_URL } from "@/lib/seo";
import { localizedPath } from "@/lib/i18n";
import type { Locale } from "@/lib/i18n";
import type { Metadata } from "next";
import { getDictionary, hasLocale } from "@/lib/dictionaries";
import { notFound } from "next/navigation";

const POLICY_LAST_UPDATED_ISO = "2026-02-11";
const GITHUB_REPO = "https://github.com/Eragon67360/nous-deux";

type PageProps = { params: Promise<{ lang: string }> };

export async function generateMetadata({
  params,
}: PageProps): Promise<Metadata> {
  const { lang } = await params;
  if (!hasLocale(lang)) return {};
  const dict = await getDictionary(lang);
  const basePath = `/${lang}/politique-de-confidentialite`;
  return {
    title: dict.policy.meta.title,
    description: dict.policy.meta.description,
    alternates: {
      canonical: `${SITE_URL}${basePath}`,
      languages: {
        fr: `${SITE_URL}/fr/politique-de-confidentialite`,
        en: `${SITE_URL}/en/politique-de-confidentialite`,
      },
    },
  };
}

export default async function PolitiqueDeConfidentialitePage({
  params,
}: PageProps) {
  const { lang } = await params;
  if (!hasLocale(lang)) notFound();
  const dict = await getDictionary(lang);
  const p = dict.policy;
  const basePath = `/${lang}/politique-de-confidentialite`;

  const policyPageStructuredData = {
    "@context": "https://schema.org",
    "@graph": [
      {
        "@type": "WebPage",
        "@id": `${SITE_URL}${basePath}#webpage`,
        url: `${SITE_URL}${basePath}`,
        name: `${p.meta.title} – ${dict.common.siteName}`,
        datePublished: p.effectiveDateISO,
        dateModified: POLICY_LAST_UPDATED_ISO,
        description: p.meta.description,
        inLanguage: lang,
      },
    ],
  };

  const breadcrumbItems = [
    { label: dict.breadcrumbs.home, href: localizedPath("/", lang) },
    {
      label: dict.breadcrumbs.privacy,
      href: localizedPath("/politique-de-confidentialite", lang),
    },
  ];

  const linkClass =
    "text-primary underline hover:no-underline focus:outline-none focus:ring-2 focus:ring-primary rounded";

  return (
    <div className="min-h-screen bg-surface text-on-surface">
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{
          __html: JSON.stringify(policyPageStructuredData),
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
            {p.meta.title}
          </h1>
          <p className="mt-2 text-on-surface-variant">
            {p.lastUpdated} {p.effectiveDate}
          </p>
          <hr className="mt-6 border-outline/50" />
        </header>

        <article className="space-y-8 text-on-surface-variant leading-relaxed">
          <section>
            <h2 className="mb-3 text-xl font-semibold text-on-surface">
              {p.sections.editor.title}
            </h2>
            <p>
              {p.sections.editor.body}{" "}
              <a
                href={GITHUB_REPO}
                target="_blank"
                rel="noopener noreferrer"
                className={linkClass}
              >
                github.com/Eragon67360/nous-deux
              </a>
              .
            </p>
          </section>

          <section>
            <h2 className="mb-3 text-xl font-semibold text-on-surface">
              {p.sections.dataCollected.title}
            </h2>
            <p className="mb-4">{p.sections.dataCollected.intro}</p>
            <ul className="list-disc space-y-2 pl-6">
              {p.sections.dataCollected.items.map((item) => (
                <li key={item.label}>
                  <strong className="text-on-surface">{item.label}</strong>:{" "}
                  {item.text}
                </li>
              ))}
            </ul>
          </section>

          <section>
            <h2 className="mb-3 text-xl font-semibold text-on-surface">
              {p.sections.purposes.title}
            </h2>
            <p>{p.sections.purposes.body}</p>
          </section>

          <section>
            <h2 className="mb-3 text-xl font-semibold text-on-surface">
              {p.sections.legalBasis.title}
            </h2>
            <p>{p.sections.legalBasis.body}</p>
          </section>

          <section>
            <h2 className="mb-3 text-xl font-semibold text-on-surface">
              {p.sections.hosting.title}
            </h2>
            <p className="mb-4">{p.sections.hosting.intro}</p>
            <ul className="list-disc space-y-2 pl-6">
              {p.sections.hosting.items.map((item) => (
                <li key={item.label}>
                  <strong className="text-on-surface">{item.label}</strong>:{" "}
                  {item.text}
                </li>
              ))}
            </ul>
          </section>

          <section>
            <h2 className="mb-3 text-xl font-semibold text-on-surface">
              {p.sections.retention.title}
            </h2>
            <p>{p.sections.retention.body}</p>
          </section>

          <section>
            <h2 className="mb-3 text-xl font-semibold text-on-surface">
              {p.sections.rights.title}
            </h2>
            <p className="mb-4">{p.sections.rights.intro}</p>
            <ul className="list-disc space-y-2 pl-6">
              {p.sections.rights.rightsList.map((right) => (
                <li key={right}>{right}</li>
              ))}
            </ul>
            <p className="mt-4">
              {p.sections.rights.deletionText}{" "}
              <LocaleLink
                href="/suppression-compte"
                locale={lang as Locale}
                className={linkClass}
              >
                {p.sections.rights.deletionLink}
              </LocaleLink>
              .
            </p>
            <p className="mt-4">
              {p.sections.rights.otherRightsText}
              <a
                href="https://www.cnil.fr"
                target="_blank"
                rel="noopener noreferrer"
                className={linkClass}
              >
                {p.sections.rights.cnilUrl}
              </a>
              {p.sections.rights.otherRightsSuffix}
            </p>
          </section>

          <section>
            <h2 className="mb-3 text-xl font-semibold text-on-surface">
              {p.sections.changes.title}
            </h2>
            <p>{p.sections.changes.body}</p>
          </section>

          <section>
            <h2 className="mb-3 text-xl font-semibold text-on-surface">
              {p.sections.effective.title}
            </h2>
            <p>
              {p.sections.effective.body} {p.effectiveDate}.
            </p>
          </section>
        </article>

        <footer className="mt-14 pt-8 border-t border-outline/50">
          <LocaleLink
            href="/"
            locale={lang as Locale}
            className="text-primary hover:underline focus:outline-none focus:ring-2 focus:ring-primary focus:ring-offset-2 focus:ring-offset-surface rounded"
          >
            {p.backHome}
          </LocaleLink>
        </footer>
      </div>
    </div>
  );
}
