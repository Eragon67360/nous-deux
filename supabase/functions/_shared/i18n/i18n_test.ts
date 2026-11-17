// Run from the repo root (no local Deno needed):
//   docker run --rm -v "$PWD/supabase/functions:/fn:ro" -w /fn denoland/deno:2.5.6 \
//     test --allow-read=. --allow-net=deno.land _shared/ notify-partner-ping/ notify-partner-period/
// Reads this folder's language files; the only network use is fetching the
// assertions module.

import { assert, assertEquals } from "https://deno.land/std@0.224.0/assert/mod.ts";
import en from "./en.json" with { type: "json" };
import { isMessageKey, LANGUAGES, t, translator } from "./mod.ts";

const here = new URL(".", import.meta.url);

/** Every `xx.json` in this folder, parsed, by language code. */
async function languageFiles(): Promise<Map<string, Record<string, unknown>>> {
  const files = new Map<string, Record<string, unknown>>();
  for await (const entry of Deno.readDir(here)) {
    if (!entry.isFile || !entry.name.endsWith(".json")) continue;
    const text = await Deno.readTextFile(new URL(entry.name, here));
    files.set(entry.name.slice(0, -".json".length), JSON.parse(text));
  }
  return files;
}

const placeholders = (s: string) => [...s.matchAll(/\{(\w+)\}/g)].map((m) => m[1]).sort();

Deno.test("every language file has exactly the keys of en.json", async () => {
  const reference = Object.keys(en).sort();
  for (const [lang, catalog] of await languageFiles()) {
    assertEquals(Object.keys(catalog).sort(), reference, `${lang}.json`);
  }
});

Deno.test("every text is a string with the placeholders of its English one", async () => {
  for (const [lang, catalog] of await languageFiles()) {
    for (const [key, text] of Object.entries(catalog)) {
      assert(typeof text === "string" && text.trim() !== "", `${lang}.json: ${key} is empty`);
      if (!isMessageKey(key)) continue; // reported by the keys test
      assertEquals(placeholders(text), placeholders(en[key]), `${lang}.json: ${key}`);
    }
  }
});

Deno.test("every language file is in the catalog, and only those", async () => {
  assertEquals([...LANGUAGES].sort(), [...(await languageFiles()).keys()].sort());
  assert(LANGUAGES.includes("en") && LANGUAGES.includes("fr"));
});

Deno.test("a language the catalog doesn't have reads in English", () => {
  for (const lang of ["de", "es", "", null, undefined, "__proto__", "constructor", "toString"]) {
    assertEquals(t(lang, "push.partner"), "Your partner", String(lang));
    assertEquals(t(lang, "ping.kiss", { name: "Lena" }), "Lena sends you a kiss", String(lang));
  }
});

Deno.test("a key missing from a language reads in English", () => {
  const partial = translator({ en, de: { "push.partner": "Dein Partner" } });
  assertEquals(partial("de", "push.partner"), "Dein Partner");
  assertEquals(partial("de", "ping.kiss", { name: "Lena" }), "Lena sends you a kiss");
});

Deno.test("params fill the placeholders as written", () => {
  assertEquals(t("fr", "ping.kiss", { name: "Camille" }), "Camille t'envoie un bisou");
  assertEquals(
    t("fr", "ping.kiss", { name: "Zoé $& $1 {name}" }),
    "Zoé $& $1 {name} t'envoie un bisou",
  );
  // A placeholder without a param stays visible rather than vanishing.
  assertEquals(t("en", "ping.kiss"), "{name} sends you a kiss");
});

Deno.test("only the catalog's keys are message keys", () => {
  assert(isMessageKey("ping.kiss"));
  assert(isMessageKey("push.title"));
  for (const key of ["ping.hug", "", "toString", "constructor", "__proto__"]) {
    assert(!isMessageKey(key), key);
  }
});
