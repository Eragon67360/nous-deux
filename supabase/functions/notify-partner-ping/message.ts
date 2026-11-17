// What the partner's phone shows for a little note, in their app language.

// Same wording as the app (lib/core/constants/nous_strings.dart).
const BODIES: Record<"fr" | "en", Record<string, (name: string) => string>> = {
  fr: {
    thinking_of_you: (n) => `${n} pense à toi`,
    good_night: (n) => `${n} te souhaite bonne nuit`,
    on_my_way: (n) => `${n} arrive`,
    miss_you: (n) => `${n} : tu me manques`,
    kiss: (n) => `${n} t'envoie un bisou`,
    custom: (n) => `${n} t'a écrit un petit mot`,
  },
  en: {
    thinking_of_you: (n) => `${n} is thinking of you`,
    good_night: (n) => `${n} says good night`,
    on_my_way: (n) => `${n} is on the way`,
    miss_you: (n) => `${n} misses you`,
    kiss: (n) => `${n} sends you a kiss`,
    custom: (n) => `${n} wrote you a little note`,
  },
};

/** The push for a note of `kind` from `senderName`, or null for a kind it doesn't know. */
export function pingPush(
  language: string | null | undefined,
  senderName: string | null | undefined,
  kind: string,
): { title: string; body: string } | null {
  const lang = language === "en" ? "en" : "fr";
  const name = senderName?.trim() ||
    (lang === "fr" ? "Votre partenaire" : "Your partner");
  const body = BODIES[lang][kind]?.(name);
  if (!body) return null;
  return { title: "Nous Deux", body };
}
