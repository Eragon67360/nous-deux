// What the partner's phone shows for a little note, in their app language.
// The texts are in ../_shared/i18n/, with the same wording as the app
// (lib/core/constants/nous_strings.dart).

import { isMessageKey, t } from "../_shared/i18n/mod.ts";

/** The push for a note of `kind` from `senderName`, or null for a kind it doesn't know. */
export function pingPush(
  language: string | null | undefined,
  senderName: string | null | undefined,
  kind: string,
): { title: string; body: string } | null {
  const key = `ping.${kind}`;
  if (!isMessageKey(key)) return null;
  const name = senderName?.trim() || t(language, "push.partner");
  return { title: t(language, "push.title"), body: t(language, key, { name }) };
}
