import type { Metadata } from "next";
import Link from "next/link";

export const metadata: Metadata = {
  title: "Suppression du compte – Nous Deux",
  description:
    "Comment demander la suppression de votre compte et de vos données dans l'application Nous Deux.",
};

const CONTACT_EMAIL = "thomas-moser@orange.fr";

export default function SuppressionComptePage() {
  return (
    <div className="min-h-screen bg-surface text-on-surface">
      <div className="mx-auto max-w-3xl px-6 py-12 sm:px-8">
        <header className="mb-10">
          <Link
            href="/"
            className="text-primary hover:underline focus:outline-none focus:ring-2 focus:ring-primary focus:ring-offset-2 focus:ring-offset-surface rounded"
          >
            Nous Deux
          </Link>
          <h1 className="mt-4 text-3xl font-semibold tracking-tight text-on-surface sm:text-4xl">
            Suppression du compte
          </h1>
          <hr className="mt-6 border-outline/50" />
        </header>

        <article className="space-y-6 text-on-surface-variant leading-relaxed">
          <p>
            La suppression du compte directement depuis l’application n’est pas
            encore disponible. En attendant cette fonctionnalité, vous pouvez
            demander la suppression de votre compte et de vos données de la
            manière suivante.
          </p>

          <section>
            <h2 className="mb-3 text-xl font-semibold text-on-surface">
              Comment demander la suppression de mon compte ?
            </h2>
            <p className="mb-4">
              Envoyez un e-mail à l’adresse suivante pour demander la
              suppression de votre compte et de vos données personnelles :
            </p>
            <p className="mb-4">
              <a
                href={`mailto:${CONTACT_EMAIL}?subject=Demande de suppression de compte - Nous Deux`}
                className="text-primary font-medium underline hover:no-underline focus:outline-none focus:ring-2 focus:ring-primary rounded"
              >
                {CONTACT_EMAIL}
              </a>
            </p>
            <p className="mb-4">
              <strong className="text-on-surface">
                Merci d’indiquer votre numéro de téléphone
              </strong>{" "}
              (celui associé à votre compte ou utilisé pour vous connecter)
              dans votre message. Cela nous permet d’identifier votre compte et
              de traiter votre demande correctement.
            </p>
            <p>
              Nous nous engageons à traiter votre demande dans les meilleurs
              délais. Une fois le compte supprimé, les données associées sont
              effacées conformément à notre{" "}
              <Link
                href="/politique-de-confidentialite"
                className="text-primary underline hover:no-underline focus:outline-none focus:ring-2 focus:ring-primary rounded"
              >
                politique de confidentialité
              </Link>
              .
            </p>
          </section>

          <section>
            <h2 className="mb-3 text-xl font-semibold text-on-surface">
              À noter
            </h2>
            <p>
              Cette procédure est une solution temporaire. Une option de
              suppression du compte directement depuis l’application sera
              proposée dans une prochaine version.
            </p>
          </section>
        </article>

        <footer className="mt-14 pt-8 border-t border-outline/50 flex flex-wrap gap-6">
          <Link
            href="/politique-de-confidentialite"
            className="text-primary hover:underline focus:outline-none focus:ring-2 focus:ring-primary focus:ring-offset-2 focus:ring-offset-surface rounded"
          >
            Politique de confidentialité
          </Link>
          <Link
            href="/"
            className="text-primary hover:underline focus:outline-none focus:ring-2 focus:ring-primary focus:ring-offset-2 focus:ring-offset-surface rounded"
          >
            Retour à l’accueil
          </Link>
        </footer>
      </div>
    </div>
  );
}
