import LocaleLink from "@/components/LocaleLink";
import { getDictionary, hasLocale } from "@/lib/dictionaries";
import type { Locale } from "@/lib/i18n";
import { headers } from "next/headers";

export default async function NotFound() {
  const headersList = await headers();
  const pathname = headersList.get("x-pathname") ?? "";
  const segment = pathname.split("/")[1];
  const locale: Locale = hasLocale(segment) ? segment : "fr";
  const dict = await getDictionary(locale);
  return (
    <div className="min-h-screen bg-surface text-on-surface flex flex-col items-center justify-center px-6">
      <main className="text-center">
        <h1 className="text-3xl font-semibold tracking-tight text-on-surface sm:text-4xl">
          {dict.notFound.title}
        </h1>
        <p className="mt-4 text-on-surface-variant">
          {dict.notFound.description}
        </p>
        <LocaleLink
          href="/"
          locale={locale}
          className="mt-8 inline-block bg-primary px-6 py-3 text-surface font-medium transition-opacity hover:opacity-90 focus:outline-none focus:ring-2 focus:ring-primary focus:ring-offset-2 focus:ring-offset-surface rounded"
        >
          {dict.notFound.backHome}
        </LocaleLink>
      </main>
    </div>
  );
}
