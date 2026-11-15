import LocaleLink from "@/components/LocaleLink";
import type { Dictionary } from "@/lib/dictionaries";
import type { Locale } from "@/lib/i18n";
import RingsMark from "./RingsMark";

type Hero = Dictionary["home"]["hero"];

/**
 * The cover. Type on the ground, no screenshots above the fold (chaptered
 * editorial). Depth comes from four planes moving at different rates:
 * the evening glow, the large rings, "Nous" and "Deux".
 */
export default function TitlePage({
  dict,
  cover,
  lang,
}: {
  dict: Hero;
  cover: string;
  lang: Locale;
}) {
  return (
    <section className="nd-title" data-sc-act="flow" data-folio="0" data-folio-title={cover}>
      <div className="nd-title__glow" data-sc-parallax="-1.6" aria-hidden="true" />
      <div className="nd-title__rings" data-sc-parallax="-0.9" aria-hidden="true">
        <RingsMark strokeWidth={1.2} />
      </div>
      <h1 className="nd-title__h1">
        <span className="nd-title__word nd-title__word--nous" data-sc-parallax="-0.45">
          {dict.word1}
        </span>{" "}
        <span className="nd-title__word nd-title__word--deux" data-sc-parallax="0.55">
          {dict.word2}
        </span>
      </h1>
      <div className="nd-title__foot">
        <p className="nd-title__line">{dict.line}</p>
        <ul className="nd-stores" aria-label={dict.storesLabel}>
          <li>
            <span className="nd-store" aria-disabled="true">
              <span className="nd-store__name">{dict.appStore}</span>
              <span className="nd-store__soon">{dict.soon}</span>
            </span>
          </li>
          {/* The Android beta is open: this badge leads to the join page. */}
          <li>
            <LocaleLink href="/beta" locale={lang} className="nd-store nd-store--live">
              <span className="nd-store__name">{dict.googlePlay}</span>
              <span className="nd-store__soon">{dict.join}</span>
            </LocaleLink>
          </li>
        </ul>
      </div>
    </section>
  );
}
