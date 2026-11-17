// Run from the repo root (no local Deno needed):
//   docker run --rm -v "$PWD/supabase/functions:/fn:ro" -w /fn denoland/deno:2.5.6 \
//     test --allow-read=. --allow-net=deno.land _shared/ notify-partner-ping/ notify-partner-period/
// The only network use is fetching the assertions module.

import { assertEquals } from "https://deno.land/std@0.224.0/assert/mod.ts";
import { periodPush } from "./message.ts";

// Today's texts, byte for byte. Changing one changes what partners receive.
Deno.test("the update reads as today in fr", () => {
  assertEquals(periodPush("fr", "Camille"), {
    title: "Nous Deux",
    body: "Camille a mis à jour son suivi",
  });
  assertEquals(periodPush("fr", null), {
    title: "Nous Deux",
    body: "Votre partenaire a mis à jour son suivi",
  });
});

Deno.test("the update reads as today in en", () => {
  assertEquals(periodPush("en", "Camille"), {
    title: "Nous Deux",
    body: "Camille updated their tracking",
  });
  assertEquals(periodPush("en", null), {
    title: "Nous Deux",
    body: "Your partner updated their tracking",
  });
});

Deno.test("a language the server doesn't speak reads in English", () => {
  for (const lang of ["de", "es", "", null, undefined]) {
    assertEquals(periodPush(lang, "Camille"), {
      title: "Nous Deux",
      body: "Camille updated their tracking",
    });
    assertEquals(periodPush(lang, null).body, "Your partner updated their tracking");
  }
});

Deno.test("the author's name is trimmed, and a blank one is the fallback", () => {
  assertEquals(periodPush("fr", "  Camille ").body, "Camille a mis à jour son suivi");
  assertEquals(periodPush("fr", " ").body, "Votre partenaire a mis à jour son suivi");
  assertEquals(periodPush("en", undefined).body, "Your partner updated their tracking");
  assertEquals(periodPush("en", "Zoé $& {name}").body, "Zoé $& {name} updated their tracking");
});
