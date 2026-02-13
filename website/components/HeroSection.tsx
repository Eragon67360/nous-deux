export default function HeroSection() {
  return (
    <section className="min-h-[70vh] flex flex-col items-center justify-center px-6 py-16 sm:py-24">
      <div className="mx-auto max-w-2xl text-center">
        <h1 className="text-4xl font-semibold tracking-tight text-on-surface sm:text-5xl">
          Nous Deux
        </h1>
        <p className="mt-4 text-lg text-on-surface-variant">
          Application pour couples centrée sur la confidentialité : calendrier
          partagé, suivi des règles, position optionnelle.
        </p>
        <p className="mt-2 text-on-surface-variant">Gratuit, sans publicité.</p>
        <p className="mt-4 text-base text-on-surface-variant/90 max-w-xl mx-auto">
          Nous Deux est une application pour couples qui permet de partager un
          calendrier, de suivre les règles et, en option, de partager sa
          position en temps réel — sans publicité et avec des données partagées
          uniquement au sein du couple.
        </p>
        <div className="mt-10 flex flex-col items-center justify-center gap-4 sm:flex-row">
          <a
            href="https://play.google.com/apps/testing/com.nousdeux.android"
            target="_blank"
            rel="noopener noreferrer"
            className="inline-flex items-center justify-center rounded-xl bg-primary px-6 py-3 text-surface font-medium transition-opacity hover:opacity-90 focus:outline-none focus:ring-2 focus:ring-primary focus:ring-offset-2 focus:ring-offset-surface"
          >
            Google Play – test fermé
          </a>
          <span
            className="inline-flex items-center justify-center rounded-xl border border-outline px-6 py-3 text-on-surface-variant"
            aria-disabled="true"
          >
            Prochainement sur l’App Store
          </span>
        </div>
      </div>
    </section>
  );
}
