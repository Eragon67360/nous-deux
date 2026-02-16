import FAQSection from "@/components/FAQSection";
import Footer from "@/components/Footer";
import FeaturesSection from "@/components/FeaturesSection";
import HeroSection from "@/components/HeroSection";
import PrivacySection from "@/components/PrivacySection";
import { getDictionary, hasLocale } from "@/lib/dictionaries";
import { notFound } from "next/navigation";
import type { Metadata } from "next";

type PageProps = { params: Promise<{ lang: string }> };

export async function generateMetadata({
  params,
}: PageProps): Promise<Metadata> {
  const { lang } = await params;
  if (!hasLocale(lang)) return {};
  return {
    alternates: { canonical: `/${lang}` },
  };
}

export default async function Home({ params }: PageProps) {
  const { lang } = await params;
  if (!hasLocale(lang)) notFound();
  const dict = await getDictionary(lang);
  return (
    <div className="min-h-screen bg-surface text-on-surface flex flex-col">
      <main className="flex-1">
        <HeroSection dict={dict.home.hero} />
        <FeaturesSection
          dict={dict.home.features}
          imageFallback={dict.featureCard.imageFallback}
        />
        <PrivacySection dict={dict.home.privacy} lang={lang} />
        <FAQSection dict={dict.home.faq} />
      </main>
      <Footer lang={lang} dict={dict} />
    </div>
  );
}
