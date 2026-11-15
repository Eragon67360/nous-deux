import Breadcrumbs from "@/components/Breadcrumbs";
import SiteHeader from "@/components/SiteHeader";
import LocaleLink from "@/components/LocaleLink";
import { SITE_URL } from "@/lib/seo";
import { localizedPath } from "@/lib/i18n";
import type { Locale } from "@/lib/i18n";
import type { Metadata } from "next";
import { getDictionary, hasLocale } from "@/lib/dictionaries";
import { notFound } from "next/navigation";

const CONTACT_EMAIL = "thomas-moser@orange.fr";
// Testers join the group first; the testing link only accepts its members.
const TESTERS_GROUP_URL = "https://groups.google.com/g/testeurs-nous-deux";
const PLAY_TESTING_URL =
  "https://play.google.com/apps/testing/com.nousdeux.android";
const STEP_LINKS = [TESTERS_GROUP_URL, PLAY_TESTING_URL];

type PageProps = { params: Promise<{ lang: string }> };

export async function generateMetadata({
  params,
}: PageProps): Promise<Metadata> {
  const { lang } = await params;
  if (!hasLocale(lang)) return {};
  const dict = await getDictionary(lang);
  return {
    title: dict.beta.meta.title,
    description: dict.beta.meta.description,
    alternates: {
      canonical: `${SITE_URL}/${lang}/beta`,
      languages: {
        fr: `${SITE_URL}/fr/beta`,
        en: `${SITE_URL}/en/beta`,
      },
    },
  };
}

export default async function BetaPage({ params }: PageProps) {
  const { lang } = await params;
  if (!hasLocale(lang)) notFound();
  const dict = await getDictionary(lang);
  const b = dict.beta;

  const structuredData = {
    "@context": "https://schema.org",
    "@type": "HowTo",
    name: b.meta.title,
    description: b.meta.description,
    inLanguage: lang,
    step: b.steps.map((step, i) => ({
      "@type": "HowToStep",
      position: i + 1,
      text: step.text,
      ...(STEP_LINKS[i] ? { url: STEP_LINKS[i] } : {}),
    })),
  };

  const breadcrumbItems = [
    { label: dict.breadcrumbs.home, href: localizedPath("/", lang) },
    { label: dict.breadcrumbs.beta, href: localizedPath("/beta", lang) },
  ];

  const linkClass =
    "text-primary underline hover:no-underline focus:outline-none focus:ring-2 focus:ring-primary rounded";
  const actionClass =
    "inline-block rounded-md border border-primary px-4 py-2 font-medium text-primary no-underline hover:bg-primary hover:text-surface focus:outline-none focus:ring-2 focus:ring-primary focus:ring-offset-2 focus:ring-offset-surface";
  const h2Class = "mb-3 text-3xl font-normal font-display text-on-surface";

  return (
    <div className="min-h-screen bg-surface text-on-surface">
      <SiteHeader lang={lang as Locale} siteName={dict.common.siteName} />
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{ __html: JSON.stringify(structuredData) }}
      />
      <div className="mx-auto max-w-3xl px-6 py-12 sm:px-8">
        <header className="mb-10">
          <Breadcrumbs items={breadcrumbItems} />
          <h1 className="mt-6 font-display text-5xl font-light leading-[1.02] tracking-tight text-on-surface sm:text-6xl">
            {b.title}
          </h1>
          <hr className="mt-6 border-outline/50" />
        </header>

        <article className="space-y-8 text-on-surface-variant leading-relaxed">
          <p className="text-lg">{b.intro}</p>

          <section>
            <h2 className={h2Class}>{b.stepsTitle}</h2>
            <ol className="list-decimal space-y-5 pl-6">
              {b.steps.map((step, i) => (
                <li key={step.text}>
                  <p>{step.text}</p>
                  {step.link && STEP_LINKS[i] ? (
                    <p className="mt-3">
                      <a
                        href={STEP_LINKS[i]}
                        target="_blank"
                        rel="noopener noreferrer"
                        className={actionClass}
                      >
                        {step.link}
                      </a>
                    </p>
                  ) : null}
                </li>
              ))}
            </ol>
          </section>

          <section>
            <h2 className={h2Class}>{b.stayTitle}</h2>
            <p>{b.stayBody}</p>
          </section>

          <section>
            <h2 className={h2Class}>{b.languageTitle}</h2>
            <p>{b.languageBody}</p>
          </section>

          <section>
            <h2 className={h2Class}>{b.iphoneTitle}</h2>
            <p>{b.iphoneBody}</p>
          </section>

          <section>
            <h2 className={h2Class}>{b.feedbackTitle}</h2>
            <p>
              {b.feedbackBody}{" "}
              <a
                href={`mailto:${CONTACT_EMAIL}?subject=${encodeURIComponent(b.feedbackSubject)}`}
                className={linkClass}
              >
                {CONTACT_EMAIL}
              </a>
            </p>
          </section>

          <section>
            <h2 className={h2Class}>{b.dataTitle}</h2>
            <p className="mb-3">{b.dataBody}</p>
            <p>
              <LocaleLink
                href="/politique-de-confidentialite"
                locale={lang as Locale}
                className={linkClass}
              >
                {b.privacyLink}
              </LocaleLink>
            </p>
          </section>

          <section>
            <h2 className={h2Class}>{b.leaveTitle}</h2>
            <p>{b.leaveBody}</p>
          </section>
        </article>

        <footer className="mt-14 pt-8 border-t border-outline/50">
          <LocaleLink
            href="/"
            locale={lang as Locale}
            className="text-primary hover:underline focus:outline-none focus:ring-2 focus:ring-primary focus:ring-offset-2 focus:ring-offset-surface rounded"
          >
            {b.backHome}
          </LocaleLink>
        </footer>
      </div>
    </div>
  );
}
