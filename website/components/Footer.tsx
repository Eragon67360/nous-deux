import Link from "next/link";

const GITHUB_REPO = "https://github.com/Eragon67360/nous-deux";

export default function Footer() {
  return (
    <footer className="border-t border-outline/30 px-6 py-10 sm:py-12">
      <nav
        className="mx-auto flex max-w-5xl flex-col items-center justify-center gap-4 sm:flex-row sm:gap-8"
        aria-label="Pied de page"
      >
        <Link
          href="/politique-de-confidentialite"
          className="text-primary hover:underline focus:outline-none focus:ring-2 focus:ring-primary focus:ring-offset-2 focus:ring-offset-surface rounded"
        >
          Politique de confidentialité
        </Link>
        <Link
          href="/suppression-compte"
          className="text-primary hover:underline focus:outline-none focus:ring-2 focus:ring-primary focus:ring-offset-2 focus:ring-offset-surface rounded"
        >
          Suppression du compte
        </Link>
        <a
          href={GITHUB_REPO}
          target="_blank"
          rel="noopener noreferrer"
          className="text-primary hover:underline focus:outline-none focus:ring-2 focus:ring-primary focus:ring-offset-2 focus:ring-offset-surface rounded"
        >
          GitHub
        </a>
      </nav>
    </footer>
  );
}
