export default function PrivacySection() {
  return (
    <section className="px-6 py-16 sm:py-24" aria-labelledby="privacy-heading">
      <div className="mx-auto max-w-2xl text-center">
        <h2
          id="privacy-heading"
          className="text-2xl font-semibold text-on-surface sm:text-3xl"
        >
          Gratuit, sans publicité
        </h2>
        <p className="mt-4 text-on-surface-variant leading-relaxed">
          Données minimales, partagées uniquement au sein de votre couple.
          Aucune revente, aucun ciblage. Une application pensée pour la
          confidentialité.
        </p>
      </div>
    </section>
  );
}
