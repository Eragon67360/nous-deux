import AgendasChapter from "@/components/home/AgendasChapter";
import Colophon from "@/components/home/Colophon";
import FaqChapter from "@/components/home/FaqChapter";
import Folio from "@/components/home/Folio";
import MergeChapter from "@/components/home/MergeChapter";
import ScrollCraftMount from "@/components/home/ScrollCraftMount";
import ShareRail from "@/components/home/ShareRail";
import TitlePage from "@/components/home/TitlePage";
import TrustChapter from "@/components/home/TrustChapter";
import "@/components/home/home.css";
import { getDictionary, hasLocale } from "@/lib/dictionaries";
import { pageMetadata } from "@/lib/seo";
import { notFound } from "next/navigation";
import type { Metadata } from "next";

type PageProps = { params: Promise<{ lang: string }> };

export async function generateMetadata({
  params,
}: PageProps): Promise<Metadata> {
  const { lang } = await params;
  if (!hasLocale(lang)) return {};
  const dict = await getDictionary(lang);
  return pageMetadata({
    lang,
    path: "",
    title: `${dict.common.siteName} · ${dict.home.meta.title}`,
    description: dict.home.meta.description,
  });
}

export default async function Home({ params }: PageProps) {
  const { lang } = await params;
  if (!hasLocale(lang)) notFound();
  const dict = await getDictionary(lang);
  const home = dict.home;
  return (
    <>
      <div className="sc-grain" aria-hidden="true" />
      <Folio
        lang={lang}
        siteName={dict.common.siteName}
        coverTitle={home.folio.titlePage}
      />
      <main id="home">
        <TitlePage dict={home.hero} cover={home.folio.titlePage} lang={lang} />
        <AgendasChapter dict={home.chapters.agendas} lang={lang} />
        <MergeChapter dict={home.chapters.merge} lang={lang} />
        <ShareRail dict={home.chapters.share} lang={lang} />
        <TrustChapter dict={home.chapters.trust} lang={lang} />
        <FaqChapter dict={home.chapters.faq} />
        <Colophon dict={home.chapters.close} footer={dict.footer} lang={lang} />
      </main>
      <ScrollCraftMount rootId="home" />
    </>
  );
}
