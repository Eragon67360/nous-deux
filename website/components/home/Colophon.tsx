import LocaleLink from "@/components/LocaleLink";
import type { Dictionary } from "@/lib/dictionaries";
import type { Locale } from "@/lib/i18n";
import RingsMark from "./RingsMark";

type Close = Dictionary["home"]["chapters"]["close"];
type Footer = Dictionary["footer"];

const BUY_ME_A_COFFEE_URL = "https://buymeacoffee.com/thomasmoser";
const GITHUB_REPO = "https://github.com/Eragon67360/nous-deux";

/**
 * The colophon. The page ends here and holds: the mark settles small, the
 * availability line, and the one live action set as running text.
 */
export default function Colophon({
  dict,
  footer,
  lang,
}: {
  dict: Close;
  footer: Footer;
  lang: Locale;
}) {
  return (
    <section
      className="nd-close"
      data-sc-act="pin"
      data-sc-span="1.3"
      data-folio="6"
      data-folio-title={dict.folio}
      aria-labelledby="ch-close"
    >
      <div data-sc-stage className="nd-close__stage">
        <div className="nd-close__rings" aria-hidden="true">
          <RingsMark strokeWidth={1.2} />
        </div>
        <div className="nd-close__inner">
          <RingsMark className="nd-close__mark" />
          <h2 id="ch-close" className="sc-display sc-display--md" data-sc-cue="0.04">
            {dict.heading}
          </h2>
          <p className="sc-lede nd-close__support" data-sc-cue="0.08">
            {dict.support}{" "}
            <a href={BUY_ME_A_COFFEE_URL} target="_blank" rel="noopener noreferrer" className="nd-link">
              {dict.supportLink}
            </a>
            {dict.supportSuffix}
          </p>
        </div>
        <footer className="nd-close__foot">
          <nav aria-label={footer.ariaLabel}>
            <LocaleLink href="/politique-de-confidentialite" locale={lang} className="nd-link">
              {footer.privacy}
            </LocaleLink>
            <LocaleLink href="/suppression-compte" locale={lang} className="nd-link">
              {footer.accountDeletion}
            </LocaleLink>
            <a href={GITHUB_REPO} target="_blank" rel="noopener noreferrer" className="nd-link">
              {dict.source}
            </a>
          </nav>
        </footer>
      </div>
    </section>
  );
}
