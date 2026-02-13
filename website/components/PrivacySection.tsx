import Link from "next/link";

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
          confidentialité. Consultez notre{" "}
          <Link
            href="/politique-de-confidentialite"
            className="text-primary underline hover:no-underline focus:outline-none focus:ring-2 focus:ring-primary focus:ring-offset-2 focus:ring-offset-surface rounded"
          >
            politique de confidentialité
          </Link>{" "}
          et la page{" "}
          <Link
            href="/suppression-compte"
            className="text-primary underline hover:no-underline focus:outline-none focus:ring-2 focus:ring-primary focus:ring-offset-2 focus:ring-offset-surface rounded"
          >
            suppression du compte
          </Link>
          .
        </p>
      </div>
    </section>
  );
}
