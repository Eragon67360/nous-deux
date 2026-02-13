import { Analytics } from "@vercel/analytics/next";
import {
  DEFAULT_OG,
  DEFAULT_TWITTER,
  getBaseStructuredData,
  SITE_DESCRIPTION,
  SITE_NAME,
  SITE_URL,
} from "@/lib/seo";
import type { Metadata } from "next";
import { DM_Sans, Geist_Mono } from "next/font/google";
import "./globals.css";

const dmSans = DM_Sans({
  variable: "--font-dm-sans",
  subsets: ["latin"],
  display: "swap",
});

const geistMono = Geist_Mono({
  variable: "--font-geist-mono",
  subsets: ["latin"],
});

const defaultTitle = `${SITE_NAME} – Application pour couples`;

export const metadata: Metadata = {
  metadataBase: new URL(SITE_URL),
  title: {
    default: defaultTitle,
    template: `%s | ${SITE_NAME}`,
  },
  description: SITE_DESCRIPTION,
  keywords: [
    "application couple",
    "calendrier partagé",
    "suivi des règles",
    "confidentialité",
    "Nous Deux",
  ],
  robots: "index, follow",
  openGraph: {
    ...DEFAULT_OG,
    url: SITE_URL,
    title: defaultTitle,
  },
  twitter: DEFAULT_TWITTER,
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  const baseStructuredData = getBaseStructuredData();
  return (
    <html lang="fr">
      <body
        className={`${dmSans.variable} ${geistMono.variable} font-sans antialiased`}
      >
        <script
          type="application/ld+json"
          dangerouslySetInnerHTML={{
            __html: JSON.stringify(baseStructuredData),
          }}
        />
        {children}
        <Analytics />
      </body>
    </html>
  );
}
