type FAQDict = {
  heading: string;
  items: { question: string; answer: string }[];
};

export default function FAQSection({ dict }: { dict: FAQDict }) {
  const faqStructuredData = {
    "@context": "https://schema.org",
    "@type": "FAQPage",
    mainEntity: dict.items.map((item) => ({
      "@type": "Question",
      name: item.question,
      acceptedAnswer: {
        "@type": "Answer",
        text: item.answer,
      },
    })),
  };

  return (
    <section className="px-6 py-16 sm:py-24" aria-labelledby="faq-heading">
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{
          __html: JSON.stringify(faqStructuredData),
        }}
      />
      <div className="mx-auto max-w-2xl">
        <h2
          id="faq-heading"
          className="text-2xl font-semibold text-on-surface text-center sm:text-3xl"
        >
          {dict.heading}
        </h2>
        <dl className="mt-10 space-y-8">
          {dict.items.map((item) => (
            <div key={item.question}>
              <dt className="text-lg font-medium text-on-surface">
                {item.question}
              </dt>
              <dd className="mt-2 text-on-surface-variant leading-relaxed">
                {item.answer}
              </dd>
            </div>
          ))}
        </dl>
      </div>
    </section>
  );
}
