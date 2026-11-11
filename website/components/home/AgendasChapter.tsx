import type { Dictionary } from "@/lib/dictionaries";
import PhoneFrame from "./PhoneFrame";

type Agendas = Dictionary["home"]["chapters"]["agendas"];

/** Chapter 1, recognition: the everyday back-and-forth, one real screen in its own column. */
export default function AgendasChapter({ dict }: { dict: Agendas }) {
  return (
    <section
      className="sc-section nd-agendas"
      data-sc-act="flow"
      data-folio="1"
      data-folio-title={dict.folio}
      aria-labelledby="ch-agendas"
    >
      <div className="sc-wrap nd-spread">
        <div className="nd-spread__text sc-stack" data-sc-in data-sc-stagger="70">
          <h2 id="ch-agendas" className="sc-display sc-display--lg nd-quote">
            {dict.heading}
          </h2>
          <p className="sc-lede">{dict.body}</p>
          <p className="sc-body">{dict.body2}</p>
        </div>
        <figure className="nd-spread__media" data-sc-in>
          <PhoneFrame src="/screenshots/calendar.png" alt={dict.imageAlt} />
          <figcaption className="nd-caption">{dict.caption}</figcaption>
        </figure>
      </div>
    </section>
  );
}
