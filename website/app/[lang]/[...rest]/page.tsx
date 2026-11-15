import { notFound } from "next/navigation";

// Any other path under /fr or /en: the root layout lives in [lang], so the
// not-found page has to be reached from inside it to get <html lang>.
export default function CatchAll() {
  notFound();
}
