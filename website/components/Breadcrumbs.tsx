import Link from "next/link";
import { SITE_URL } from "@/lib/seo";

export type BreadcrumbItem = {
  label: string;
  href: string;
};

type BreadcrumbsProps = {
  items: BreadcrumbItem[];
};

/** Renders breadcrumb nav and BreadcrumbList JSON-LD. */
export default function Breadcrumbs({ items }: BreadcrumbsProps) {
  const breadcrumbListStructuredData = {
    "@context": "https://schema.org",
    "@type": "BreadcrumbList",
    itemListElement: items.map((item, index) => ({
      "@type": "ListItem",
      position: index + 1,
      name: item.label,
      item: item.href.startsWith("http")
        ? item.href
        : `${SITE_URL}${item.href}`,
    })),
  };

  return (
    <>
      <nav
        aria-label="Fil d'Ariane"
        className="mb-6 text-sm text-on-surface-variant"
      >
        <ol className="flex flex-wrap items-center gap-x-2 gap-y-1">
          {items.map((item, index) => (
            <li key={item.href} className="flex items-center gap-x-2">
              {index > 0 && (
                <span aria-hidden className="text-outline">
                  /
                </span>
              )}
              {index === items.length - 1 ? (
                <span className="text-on-surface font-medium">
                  {item.label}
                </span>
              ) : (
                <Link
                  href={item.href}
                  className="text-primary hover:underline focus:outline-none focus:ring-2 focus:ring-primary focus:ring-offset-2 focus:ring-offset-surface rounded"
                >
                  {item.label}
                </Link>
              )}
            </li>
          ))}
        </ol>
      </nav>
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{
          __html: JSON.stringify(breadcrumbListStructuredData),
        }}
      />
    </>
  );
}
