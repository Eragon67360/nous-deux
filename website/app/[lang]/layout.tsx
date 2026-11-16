import { getBaseStructuredData, SITE_URL } from "@/lib/seo";
import type { Metadata } from "next";
import { Geist_Mono, Manrope } from "next/font/google";
import { notFound } from "next/navigation";
import { getDictionary, hasLocale } from "@/lib/dictionaries";
import Stats from "@/components/Stats";
import "../globals.css";

// The app's one font: light weights for display, regular for text.
const manrope = Manrope({
  variable: "--font-manrope",
  subsets: ["latin"],
  display: "swap",
});

const geistMono = Geist_Mono({
  variable: "--font-geist-mono",
  subsets: ["latin"],
});

export async function generateStaticParams() {
  return [{ lang: "fr" }, { lang: "en" }];
}

/**
 * Defaults for pages that set nothing themselves (the not-found page). Every
 * other page builds its own canonical, hreflang and share tags with
 * pageMetadata() from lib/seo.ts.
 */
export async function generateMetadata({
  params,
}: {
  params: Promise<{ lang: string }>;
}): Promise<Metadata> {
  const { lang } = await params;
  if (!hasLocale(lang)) return {};
  const dict = await getDictionary(lang);
  return {
    metadataBase: new URL(SITE_URL),
    title: `${dict.common.siteName} · ${dict.home.meta.title}`,
    description: dict.home.meta.description,
  };
}

/**
 * The root layout lives in [lang] so the server sends <html lang="fr|en">:
 * crawlers and screen readers get the language before any script runs.
 */
export default async function LangLayout({
  children,
  params,
}: {
  children: React.ReactNode;
  params: Promise<{ lang: string }>;
}) {
  const { lang } = await params;
  if (!hasLocale(lang)) notFound();
  const dict = await getDictionary(lang);
  const baseStructuredData = getBaseStructuredData(
    lang,
    dict.home.meta.description,
  );
  return (
    // Font variables live on <html> so the :root design tokens can use them.
    <html lang={lang} className={`${manrope.variable} ${geistMono.variable}`}>
      <body className="font-sans antialiased">
        <script
          type="application/ld+json"
          dangerouslySetInnerHTML={{
            __html: JSON.stringify(baseStructuredData),
          }}
        />
        {children}
        <Stats />
      </body>
    </html>
  );
}
