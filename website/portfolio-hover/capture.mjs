// Captures the real Nous Deux website for the portfolio hover video.
// Run: HOVER_KIT_DIR=<portfolio>/resources/hover-videos/kit HOVER_KIT_DEPS=<deps>/package.json node capture.mjs
// The app screens shown in the video are the real screenshots in ../public/screenshots (used by the site).
import { writeFileSync, mkdirSync } from "node:fs";
const { openBrowser, warmUp, shoot, box } = await import(`${process.env.HOVER_KIT_DIR}/capture.mjs`);

const dir = new URL("./captures", import.meta.url).pathname;
mkdirSync(`${dir}/scroll`, { recursive: true });
const SITE = "https://nous-deux-website.vercel.app";
const SCROLL_FRAMES = 20;
const { browser, page } = await openBrowser();
const layout = {};

await page.goto(SITE, { waitUntil: "networkidle" });
await warmUp(page);
await shoot(page, dir, "home", { full: false });

// Scroll to the feature cards: centre the three cards under the sticky header.
const cards = await page.evaluate(() => {
  const ul = document.querySelector("section[aria-labelledby=features-heading] ul");
  const r = ul.getBoundingClientRect();
  return { top: r.top + scrollY, h: r.height };
});
const target = Math.round(cards.top + cards.h / 2 - (800 + 57) / 2);
layout.scrollTarget = target;
layout.scrollFrames = SCROLL_FRAMES;
// One real viewport capture per scroll step (the header is sticky, so a full-page shot would not match).
for (let i = 1; i <= SCROLL_FRAMES; i++) {
  await page.evaluate((y) => window.scrollTo({ top: y, behavior: "instant" }), Math.round((target * i) / SCROLL_FRAMES));
  await page.waitForTimeout(120);
  await page.screenshot({ path: `${dir}/scroll/${String(i).padStart(2, "0")}.jpg`, type: "jpeg", quality: 82 });
}
await page.waitForTimeout(500);
await shoot(page, dir, "features", { full: false });
layout.calendarPhone = await box(page, 'img[src*="calendar"]');
layout.calendarCard = await box(page, "section[aria-labelledby=features-heading] li");

writeFileSync(`${dir}/layout.js`, `window.LAYOUT = ${JSON.stringify(layout, null, 2)};\n`);
console.log(layout);
await browser.close();
