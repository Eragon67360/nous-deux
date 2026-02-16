import Link from "next/link";
import type { Locale } from "@/lib/i18n";
import { localizedPath } from "@/lib/i18n";

type LocaleLinkProps = {
  href: string;
  locale: Locale;
  children: React.ReactNode;
  className?: string;
};

export default function LocaleLink({
  href,
  locale,
  children,
  className,
}: LocaleLinkProps) {
  return (
    <Link href={localizedPath(href, locale)} className={className}>
      {children}
    </Link>
  );
}
