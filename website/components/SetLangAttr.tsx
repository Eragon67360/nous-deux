"use client";

import { useEffect } from "react";
import type { Locale } from "@/lib/i18n";

export default function SetLangAttr({ lang }: { lang: Locale }) {
  useEffect(() => {
    document.documentElement.lang = lang;
  }, [lang]);
  return null;
}
