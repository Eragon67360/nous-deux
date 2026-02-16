import { Analytics } from "@vercel/analytics/next";
import {
  DEFAULT_OG,
  DEFAULT_TWITTER,
  getBaseStructuredData,
  SITE_NAME,
  SITE_URL,
} from "@/lib/seo";
import type { Locale } from "@/lib/i18n";
import type { Metadata } from "next";
import { getDictionary, hasLocale } from "@/lib/dictionaries";
import LanguageSwitcher from "@/components/LanguageSwitcher";
import LocaleLink from "@/components/LocaleLink";
import SetLangAttr from "@/components/SetLangAttr";

export async function generateStaticParams() {
  return [{ lang: "fr" }, { lang: "en" }];
}

export async function generateMetadata({
  params,
}: {
  params: Promise<{ lang: string }>;
}): Promise<Metadata> {
  const { lang } = await params;
  if (!hasLocale(lang)) return {};
  const dict = await getDictionary(lang);
  const siteName = dict.common.siteName;
  const title = `${siteName} – ${dict.home.meta.title}`;
  const description = dict.home.meta.description;
  const basePath = `/${lang}`;
  return {
    metadataBase: new URL(SITE_URL),
    title: {
      default: title,
      template: `%s | ${siteName}`,
    },
    description,
    keywords:
      lang === "fr"
        ? [
            "application couple",
            "calendrier partagé",
            "suivi des règles",
            "confidentialité",
            "Nous Deux",
          ]
        : [
            "couples app",
            "shared calendar",
            "period tracking",
            "privacy",
            "Nous Deux",
          ],
    robots: "index, follow",
    openGraph: {
      ...DEFAULT_OG,
      url: `${SITE_URL}${basePath}`,
      title,
      locale: lang === "fr" ? "fr_FR" : "en_US",
    },
    twitter: DEFAULT_TWITTER,
    alternates: {
      canonical: `${SITE_URL}${basePath}`,
      languages: {
        fr: `${SITE_URL}/fr`,
        en: `${SITE_URL}/en`,
      },
    },
  };
}

export default async function LangLayout({
  children,
  params,
}: {
  children: React.ReactNode;
  params: Promise<{ lang: string }>;
}) {
  const { lang } = await params;
  if (!hasLocale(lang)) {
    const { notFound } = await import("next/navigation");
    notFound();
  }
  const baseStructuredData = getBaseStructuredData(lang);
  const dict = await getDictionary(lang as Locale);
  return (
    <>
      <SetLangAttr lang={lang as Locale} />
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{
          __html: JSON.stringify(baseStructuredData),
        }}
      />
      <header className="sticky top-0 z-10 border-b border-outline/30 bg-surface/95 backdrop-blur supports-[backdrop-filter]:bg-surface/80">
        <div className="mx-auto flex max-w-5xl items-center justify-between px-6 py-3">
          <LocaleLink
            href="/"
            locale={lang as Locale}
            className="text-lg font-semibold text-on-surface hover:opacity-90 focus:outline-none focus:ring-2 focus:ring-primary focus:ring-offset-2 focus:ring-offset-surface rounded"
          >
            {dict.common.siteName}
          </LocaleLink>
          <LanguageSwitcher currentLocale={lang as Locale} />
        </div>
      </header>
      {children}
      <Analytics />
    </>
  );
}
