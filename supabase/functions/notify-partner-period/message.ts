// What the partner's phone shows when a period log is added, in their app
// language (texts in ../_shared/i18n/). The text stays vague on purpose: it
// goes through Apple's and Google's push services, and period data is health
// data.

import { t } from "../_shared/i18n/mod.ts";

/** The push telling the partner that `authorName` updated their tracking. */
export function periodPush(
  language: string | null | undefined,
  authorName: string | null | undefined,
): { title: string; body: string } {
  const name = authorName?.trim() || t(language, "push.partner");
  return { title: t(language, "push.title"), body: t(language, "period.updated", { name }) };
}
