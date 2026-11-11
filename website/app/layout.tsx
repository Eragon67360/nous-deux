import { Geist_Mono, Manrope } from "next/font/google";
import "../vendor/scrollcraft/scrollcraft.css";
import "./globals.css";

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

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    // Font variables live on <html> so the :root design tokens can use them.
    <html
      className={`${manrope.variable} ${geistMono.variable}`}
    >
      <body className="font-sans antialiased">{children}</body>
    </html>
  );
}
