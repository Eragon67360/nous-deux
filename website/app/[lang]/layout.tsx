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
  const title = `${siteName} · ${dict.home.meta.title}`;
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
  return (
    <>
      <SetLangAttr lang={lang as Locale} />
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{
          __html: JSON.stringify(baseStructuredData),
        }}
      />
      {children}
      <Analytics />
    </>
  );
}
