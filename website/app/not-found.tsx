import Link from "next/link";

export default function NotFound() {
  return (
    <div className="min-h-screen bg-surface text-on-surface flex flex-col items-center justify-center px-6">
      <main className="text-center">
        <h1 className="text-3xl font-semibold tracking-tight text-on-surface sm:text-4xl">
          Page introuvable
        </h1>
        <p className="mt-4 text-on-surface-variant">
          La page que vous recherchez n’existe pas ou a été déplacée.
        </p>
        <Link
          href="/fr"
          className="mt-8 inline-block rounded-xl bg-primary px-6 py-3 text-surface font-medium transition-opacity hover:opacity-90 focus:outline-none focus:ring-2 focus:ring-primary focus:ring-offset-2 focus:ring-offset-surface"
        >
          Retour à l’accueil
        </Link>
      </main>
    </div>
  );
}
