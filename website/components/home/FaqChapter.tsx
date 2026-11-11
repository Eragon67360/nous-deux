import type { Dictionary } from "@/lib/dictionaries";

type Faq = Dictionary["home"]["chapters"]["faq"];

/** Chapter 5: plain answers in native disclosure widgets. */
export default function FaqChapter({ dict }: { dict: Faq }) {
  return (
    <section
      className="sc-section nd-faq"
      data-sc-act="flow"
      data-folio="5"
      data-folio-title={dict.folio}
      aria-labelledby="ch-faq"
    >
      <div className="sc-wrap nd-faq__wrap">
        <h2 id="ch-faq" className="sc-display sc-display--md">
          {dict.heading}
        </h2>
        <div className="nd-faq__list" data-sc-in data-sc-stagger="50">
          {dict.items.map((item) => (
            <details key={item.question} className="nd-faq__item">
              <summary className="nd-faq__q">{item.question}</summary>
              <p className="sc-body nd-faq__a">{item.answer}</p>
            </details>
          ))}
        </div>
      </div>
    </section>
  );
}
