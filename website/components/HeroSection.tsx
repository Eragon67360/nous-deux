type HeroDict = {
  title: string;
  tagline: string;
  free: string;
  description: string;
  googlePlay: string;
  appStoreComing: string;
};

export default function HeroSection({ dict }: { dict: HeroDict }) {
  return (
    <section className="min-h-[70vh] flex flex-col items-center justify-center px-6 py-16 sm:py-24">
      <div className="mx-auto max-w-2xl text-center">
        <h1 className="text-4xl font-semibold tracking-tight text-on-surface sm:text-5xl">
          {dict.title}
        </h1>
        <p className="mt-4 text-lg text-on-surface-variant">{dict.tagline}</p>
        <p className="mt-2 text-on-surface-variant">{dict.free}</p>
        <p className="mt-4 text-base text-on-surface-variant/90 max-w-xl mx-auto">
          {dict.description}
        </p>
        <div className="mt-10 flex flex-col items-center justify-center gap-4 sm:flex-row">
          <a
            href="https://play.google.com/apps/testing/com.nousdeux.android"
            target="_blank"
            rel="noopener noreferrer"
            className="inline-flex items-center justify-center rounded-xl bg-primary px-6 py-3 text-surface font-medium transition-opacity hover:opacity-90 focus:outline-none focus:ring-2 focus:ring-primary focus:ring-offset-2 focus:ring-offset-surface"
          >
            {dict.googlePlay}
          </a>
          <span
            className="inline-flex items-center justify-center rounded-xl border border-outline px-6 py-3 text-on-surface-variant"
            aria-disabled="true"
          >
            {dict.appStoreComing}
          </span>
        </div>
      </div>
    </section>
  );
}
