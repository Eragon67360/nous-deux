import LocaleLink from "@/components/LocaleLink";
import type { Dictionary } from "@/lib/dictionaries";
import type { Locale } from "@/lib/i18n";

type Trust = Dictionary["home"]["chapters"]["trust"];

/** Chapter 4, the quietest one: what the app does not do, one line at a time. */
export default function TrustChapter({ dict, lang }: { dict: Trust; lang: Locale }) {
  return (
    <section
      className="sc-section nd-trust"
      data-sc-act="flow"
      data-folio="4"
      data-folio-title={dict.folio}
      aria-labelledby="ch-trust"
    >
      <div className="sc-wrap nd-trust__wrap">
        <h2 id="ch-trust" className="sc-display sc-display--lg" data-sc-in>
          {dict.heading}
        </h2>
        <ul className="nd-trust__points">
          {dict.points.map((point) => (
            <li key={point} className="nd-trust__point" data-sc-reveal="up" data-sc-reveal-at="0.12 0.42">
              <span className="nd-trust__text">{point}</span>
            </li>
          ))}
        </ul>
        <p className="sc-body nd-trust__more" data-sc-in>
          {dict.more}{" "}
          <LocaleLink href="/politique-de-confidentialite" locale={lang} className="nd-link">
            {dict.privacyLink}
          </LocaleLink>{" "}
          {dict.and}{" "}
          <LocaleLink href="/suppression-compte" locale={lang} className="nd-link">
            {dict.deletionLink}
          </LocaleLink>
          {dict.suffix}
        </p>
      </div>
    </section>
  );
}
