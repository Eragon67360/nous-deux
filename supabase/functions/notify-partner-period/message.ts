// What the partner's phone shows when a period log is added. The text stays
// vague on purpose: it goes through Apple's and Google's push services, and
// period data is health data.

const BODIES: Record<"fr" | "en", (name: string) => string> = {
  fr: (n) => `${n} a mis à jour son suivi`,
  en: (n) => `${n} updated their tracking`,
};

/** The push telling the partner that `authorName` updated their tracking. */
export function periodPush(
  language: string | null | undefined,
  authorName: string | null | undefined,
): { title: string; body: string } {
  const lang = language === "en" ? "en" : "fr";
  const name = authorName?.trim() ||
    (lang === "fr" ? "Votre partenaire" : "Your partner");
  return { title: "Nous Deux", body: BODIES[lang](name) };
}
