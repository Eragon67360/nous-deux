import type { Dictionary } from "@/lib/dictionaries";
import PhoneFrame from "./PhoneFrame";

type Share = Dictionary["home"]["chapters"]["share"];

// Which real screen illustrates each item: simulator captures of an invented
// couple (Alex and Camille), taken on a local copy of the backend.
const SCREENS: Record<string, string> = {
  calendar: "/screenshots/calendar.png",
  cycle: "/screenshots/cycle.png",
  position: "/screenshots/position.png",
  together: "/screenshots/nous.png",
  pings: "/screenshots/ping.png",
  lists: "/screenshots/lists.png",
};

/**
 * Chapter 3, range: the six things a couple shares, travelling sideways.
 * Every item uses the same label schema (name, then two plain facts) so the
 * rail reads as a collection, not a pitch.
 */
export default function ShareRail({ dict }: { dict: Share }) {
  return (
    <section
      className="nd-share"
      data-sc-act="pan"
      data-sc-span="3.2"
      data-folio="3"
      data-folio-title={dict.folio}
      aria-labelledby="ch-share"
    >
      <div data-sc-stage className="nd-share__stage">
        <ol className="nd-rail" data-sc-pan="0.04">
          <li className="nd-rail__lead">
            <h2 id="ch-share" className="sc-display sc-display--lg">
              {dict.heading}
            </h2>
            <p className="sc-lede">{dict.intro}</p>
          </li>
          {dict.items.map((item, i) => (
            <li key={item.id} className="nd-rail__item" style={{ ["--i" as string]: i }}>
              <PhoneFrame
                src={SCREENS[item.id] ?? SCREENS.calendar}
                alt=""
                sizes="(max-width: 700px) 52vw, 240px"
              />
              <h3 className="nd-rail__name">{item.name}</h3>
              <p className="nd-rail__facts">
                {item.facts.map((fact) => (
                  <span key={fact}>{fact}</span>
                ))}
              </p>
            </li>
          ))}
          <li className="nd-rail__note">
            <p className="sc-lede">{dict.outro}</p>
          </li>
        </ol>
      </div>
    </section>
  );
}
