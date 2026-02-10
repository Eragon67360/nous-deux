import Link from "next/link";

export default function Home() {
  return (
    <div className="min-h-screen bg-surface text-on-surface flex flex-col items-center justify-center px-6">
      <main className="mx-auto max-w-2xl text-center">
        <h1 className="text-4xl font-semibold tracking-tight text-on-surface sm:text-5xl">
          Nous Deux
        </h1>
        <p className="mt-4 text-lg text-on-surface-variant">
          Application couple centrée sur la confidentialité : calendrier
          partagé, suivi des règles, position optionnelle.
        </p>
        <p className="mt-2 text-on-surface-variant">
          Gratuit, sans publicité.
        </p>
        <nav className="mt-10 flex flex-col items-center gap-4 sm:flex-row sm:justify-center sm:gap-6">
          <Link
            href="/politique-de-confidentialite"
            className="inline-flex items-center justify-center rounded-xl bg-primary px-6 py-3 text-surface font-medium transition-opacity hover:opacity-90 focus:outline-none focus:ring-2 focus:ring-primary focus:ring-offset-2 focus:ring-offset-surface"
          >
            Politique de confidentialité
          </Link>
          <Link
            href="/suppression-compte"
            className="text-primary hover:underline focus:outline-none focus:ring-2 focus:ring-primary focus:ring-offset-2 focus:ring-offset-surface rounded"
          >
            Suppression du compte
          </Link>
        </nav>
      </main>
    </div>
  );
}
