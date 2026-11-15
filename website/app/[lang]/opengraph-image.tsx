import { readFile } from "node:fs/promises";
import { join } from "node:path";
import { ImageResponse } from "next/og";
import { getDictionary, hasLocale } from "@/lib/dictionaries";
import { type Locale, locales } from "@/lib/i18n";

/**
 * The preview card when a page is shared (X, Instagram, messaging apps), one
 * per language, drawn like the home cover: "Nous Deux" in Manrope ExtraLight,
 * "Deux" in gold, the rings behind, an app capture on the right. Built once
 * at build time from the dictionary and public/screenshots.
 */
export const alt = "Nous Deux";
export const size = { width: 1200, height: 630 };
export const contentType = "image/png";
export const dynamic = "force-static";

export function generateStaticParams() {
  return locales.map((lang) => ({ lang }));
}

const CANVAS = "#1c1917";
const CREAM = "#f5f0eb";
const GOLD = "#c4a77d";
const ROSE = "#ff8fa3";

export default async function Image({
  params,
}: {
  params: Promise<{ lang: string }>;
}) {
  const { lang: raw } = await params;
  const lang: Locale = hasLocale(raw) ? raw : "fr";
  const dict = await getDictionary(lang);
  // Literal folders, so the build traces only these files (see lib/screenshots.ts
  // for where each language's captures live).
  const [extraLight, regular, capture] = await Promise.all([
    readFile(join(process.cwd(), "assets/fonts/Manrope-ExtraLight.ttf")),
    readFile(join(process.cwd(), "assets/fonts/Manrope-Regular.ttf")),
    readFile(
      join(
        process.cwd(),
        "public/screenshots",
        lang === "en" ? "en/calendar.png" : "calendar.png",
      ),
    ),
  ]);
  const captureSrc = `data:image/png;base64,${capture.toString("base64")}`;

  return new ImageResponse(
    <div
      style={{
        width: "100%",
        height: "100%",
        display: "flex",
        position: "relative",
        backgroundColor: CANVAS,
        backgroundImage: `radial-gradient(circle at 70% 42%, rgba(196,167,125,0.18), rgba(28,25,23,0) 55%)`,
        fontFamily: "Manrope",
        color: CREAM,
      }}
    >
      {/* The rings, large and faint, as on the cover. */}
      <svg
        width="760"
        height="481"
        viewBox="0 0 120 76"
        style={{ position: "absolute", right: -150, top: 70, opacity: 0.5 }}
      >
        <circle
          cx="46"
          cy="38"
          r="30"
          fill="none"
          stroke={GOLD}
          strokeWidth="0.6"
        />
        <circle
          cx="74"
          cy="38"
          r="30"
          fill="none"
          stroke={CREAM}
          strokeWidth="0.6"
        />
        <circle cx="60" cy="38" r="0.9" fill={ROSE} />
      </svg>

      <div
        style={{
          display: "flex",
          flexDirection: "column",
          justifyContent: "space-between",
          padding: "64px 0 60px 80px",
          width: 760,
        }}
      >
        <div
          style={{
            display: "flex",
            fontSize: 22,
            letterSpacing: 4,
            textTransform: "uppercase",
            color: GOLD,
          }}
        >
          nous-deux.app
        </div>
        <div style={{ display: "flex", flexDirection: "column", width: 600 }}>
          <div
            style={{
              display: "flex",
              fontSize: 168,
              fontWeight: 200,
              lineHeight: 0.84,
              letterSpacing: -7,
            }}
          >
            {dict.home.hero.word1}
          </div>
          <div
            style={{
              display: "flex",
              justifyContent: "flex-end",
              fontSize: 168,
              fontWeight: 200,
              lineHeight: 0.84,
              letterSpacing: -7,
              color: GOLD,
            }}
          >
            {dict.home.hero.word2}
          </div>
        </div>
        <div
          style={{
            display: "flex",
            flexDirection: "column",
            borderTop: `1px solid rgba(245,240,235,0.18)`,
            paddingTop: 22,
            width: 600,
          }}
        >
          <div style={{ display: "flex", fontSize: 34, color: CREAM }}>
            {dict.home.meta.title}
          </div>
        </div>
      </div>

      <img
        src={captureSrc}
        width={258}
        height={559}
        alt=""
        style={{
          position: "absolute",
          right: 120,
          top: 36,
          borderRadius: 36,
          border: `1px solid rgba(245,240,235,0.22)`,
        }}
      />
    </div>,
    {
      ...size,
      fonts: [
        { name: "Manrope", data: extraLight, weight: 200, style: "normal" },
        { name: "Manrope", data: regular, weight: 400, style: "normal" },
      ],
    },
  );
}
