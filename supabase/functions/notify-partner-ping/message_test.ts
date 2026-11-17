// Run from the repo root (no local Deno needed):
//   docker run --rm -v "$PWD/supabase/functions:/fn:ro" -w /fn denoland/deno:2.5.6 \
//     test --allow-read=. --allow-net=deno.land _shared/ notify-partner-ping/ notify-partner-period/
// The only network use is fetching the assertions module.

import { assertEquals } from "https://deno.land/std@0.224.0/assert/mod.ts";
import { pingPush } from "./message.ts";

// Today's texts, byte for byte: a plain space before « : » and straight
// apostrophes. Changing one of these changes what partners receive.
const NAMED = {
  fr: {
    thinking_of_you: "Camille pense à toi",
    good_night: "Camille te souhaite bonne nuit",
    on_my_way: "Camille arrive",
    miss_you: "Camille : tu me manques",
    kiss: "Camille t'envoie un bisou",
    custom: "Camille t'a écrit un petit mot",
  },
  en: {
    thinking_of_you: "Camille is thinking of you",
    good_night: "Camille says good night",
    on_my_way: "Camille is on the way",
    miss_you: "Camille misses you",
    kiss: "Camille sends you a kiss",
    custom: "Camille wrote you a little note",
  },
};

const UNNAMED = {
  fr: {
    thinking_of_you: "Votre partenaire pense à toi",
    good_night: "Votre partenaire te souhaite bonne nuit",
    on_my_way: "Votre partenaire arrive",
    miss_you: "Votre partenaire : tu me manques",
    kiss: "Votre partenaire t'envoie un bisou",
    custom: "Votre partenaire t'a écrit un petit mot",
  },
  en: {
    thinking_of_you: "Your partner is thinking of you",
    good_night: "Your partner says good night",
    on_my_way: "Your partner is on the way",
    miss_you: "Your partner misses you",
    kiss: "Your partner sends you a kiss",
    custom: "Your partner wrote you a little note",
  },
};

for (const lang of ["fr", "en"] as const) {
  Deno.test(`every note reads as today in ${lang}`, () => {
    for (const [kind, body] of Object.entries(NAMED[lang])) {
      assertEquals(pingPush(lang, "Camille", kind), { title: "Nous Deux", body });
    }
  });

  Deno.test(`a note from a sender without a name reads as today in ${lang}`, () => {
    for (const [kind, body] of Object.entries(UNNAMED[lang])) {
      assertEquals(pingPush(lang, null, kind), { title: "Nous Deux", body });
      assertEquals(pingPush(lang, undefined, kind), { title: "Nous Deux", body });
      assertEquals(pingPush(lang, "   ", kind), { title: "Nous Deux", body });
    }
  });
}

Deno.test("the sender's name is trimmed and kept as written", () => {
  assertEquals(pingPush("fr", "  Camille  ", "kiss")?.body, "Camille t'envoie un bisou");
  // Characters that mean something to String.replace stay literal.
  assertEquals(
    pingPush("en", "Zoé $& $1 {name}", "kiss")?.body,
    "Zoé $& $1 {name} sends you a kiss",
  );
});

Deno.test("a kind it doesn't know sends nothing", () => {
  assertEquals(pingPush("fr", "Camille", "hug"), null);
  assertEquals(pingPush("en", "Camille", ""), null);
});
