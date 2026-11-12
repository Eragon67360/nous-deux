import type { Dictionary } from "@/lib/dictionaries";
import PhoneFrame from "./PhoneFrame";

type Merge = Dictionary["home"]["chapters"]["merge"];

/**
 * Chapter 2, the peak and the site's signature move: two phones drift in from
 * opposite edges under the reader's hand and lock into one shared screen.
 * Pure CSS driven by the engine's act progress (`--sc-p`), see home.css
 * (.nd-merge). Under reduced motion the phones hold their merged position and
 * only the words cross-fade.
 */
export default function MergeChapter({ dict }: { dict: Merge }) {
  return (
    <section
      className="nd-merge"
      data-sc-act="pin"
      data-sc-span="3.6"
      data-folio="2"
      data-folio-title={dict.folio}
      aria-labelledby="ch-merge"
    >
      <div data-sc-stage className="nd-merge__stage">
        <h2 id="ch-merge" className="sc-display sc-display--lg nd-merge__title">
          <span className="nd-merge__before" data-sc-cue="0 0.5 0">
            {dict.before}
          </span>{" "}
          <span className="nd-merge__after" data-sc-cue="0.58 1 0.1 0">
            {dict.after}
          </span>
        </h2>
        <div className="nd-merge__phones">
          <div className="nd-merge__phone nd-merge__phone--left">
            <PhoneFrame src="/screenshots/calendar.png" alt={dict.leftAlt} />
            <span className="nd-merge__who" aria-hidden="true">
              {dict.labelMe}
            </span>
          </div>
          <div className="nd-merge__phone nd-merge__phone--right">
            <PhoneFrame src="/screenshots/screenshot_3.png" alt={dict.rightAlt} />
            <span className="nd-merge__who" aria-hidden="true">
              {dict.labelYou}
            </span>
          </div>
          <div className="nd-merge__phone nd-merge__phone--merged">
            <span className="nd-merge__dot" aria-hidden="true" />
            <PhoneFrame src="/screenshots/calendar.png" alt={dict.mergedAlt} />
          </div>
        </div>
        <p className="sc-body nd-merge__body" data-sc-cue="0.66 1 0.1 0">
          {dict.body}
        </p>
      </div>
    </section>
  );
}
