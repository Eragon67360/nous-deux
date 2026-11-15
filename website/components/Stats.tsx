import Script from "next/script";
import { connection } from "next/server";

/**
 * Visit counts from Umami, self-hosted on Coolify at stats.nous-deux.app: no
 * cookies, no IP address kept. Renders only where UMAMI_WEBSITE_ID is set
 * (the Coolify app), so local runs and other builds aren't counted. Read at
 * request time, so changing it in Coolify needs a restart, not a rebuild.
 */
export default async function Stats() {
  await connection();
  const websiteId = process.env.UMAMI_WEBSITE_ID;
  if (!websiteId) return null;
  return (
    <Script
      src="https://stats.nous-deux.app/script.js"
      data-website-id={websiteId}
      strategy="afterInteractive"
    />
  );
}
