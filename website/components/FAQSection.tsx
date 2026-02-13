const FAQ_ITEMS = [
  {
    question: "Nous Deux est-il gratuit ?",
    answer:
      "Oui. Nous Deux est une application gratuite et sans publicité, centrée sur la vie de couple : calendrier partagé, suivi des règles, partage de position optionnel.",
  },
  {
    question: "Mes données sont-elles partagées en dehors du couple ?",
    answer:
      "Non. Les données sont partagées uniquement au sein de votre couple (calendrier, suivi des règles, position si vous l'activez). Aucune revente, aucun ciblage. Consultez notre politique de confidentialité pour le détail.",
  },
  {
    question: "Comment supprimer mon compte Nous Deux ?",
    answer:
      "Envoyez un e-mail à l'adresse indiquée sur la page Suppression du compte en précisant votre numéro de téléphone associé au compte. La demande est traitée dans les meilleurs délais.",
  },
] as const;

const faqStructuredData = {
  "@context": "https://schema.org",
  "@type": "FAQPage",
  mainEntity: FAQ_ITEMS.map((item) => ({
    "@type": "Question",
    name: item.question,
    acceptedAnswer: {
      "@type": "Answer",
      text: item.answer,
    },
  })),
};

export default function FAQSection() {
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
          Questions fréquentes
        </h2>
        <dl className="mt-10 space-y-8">
          {FAQ_ITEMS.map((item) => (
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
