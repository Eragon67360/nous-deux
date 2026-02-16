const BUY_ME_A_COFFEE_URL = "https://buymeacoffee.com/thomasmoser";

function CoffeeIcon() {
  return (
    <svg
      xmlns="http://www.w3.org/2000/svg"
      width="20"
      height="20"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="2"
      strokeLinecap="round"
      strokeLinejoin="round"
      aria-hidden
    >
      <path d="M18 8h1a4 4 0 0 1 0 8h-1" />
      <path d="M2 8h16v9a4 4 0 0 1-4 4H6a4 4 0 0 1-4-4V8Z" />
      <line x1="6" x2="6" y1="2" y2="4" />
      <line x1="10" x2="10" y1="2" y2="4" />
      <line x1="14" x2="14" y1="2" y2="4" />
    </svg>
  );
}

type SupportDict = {
  heading: string;
  description: string;
  button: string;
};

export default function SupportSection({ dict }: { dict: SupportDict }) {
  return (
    <section className="px-6 py-16 sm:py-24" aria-labelledby="support-heading">
      <div className="mx-auto max-w-2xl text-center">
        <h2
          id="support-heading"
          className="text-2xl font-semibold text-on-surface sm:text-3xl"
        >
          {dict.heading}
        </h2>
        <p className="mt-4 text-on-surface-variant leading-relaxed">
          {dict.description}
        </p>
        <a
          href={BUY_ME_A_COFFEE_URL}
          target="_blank"
          rel="noopener noreferrer"
          className="mt-8 inline-flex items-center justify-center gap-2 rounded-xl bg-primary px-6 py-3 text-surface font-medium transition-opacity hover:opacity-90 focus:outline-none focus:ring-2 focus:ring-primary focus:ring-offset-2 focus:ring-offset-surface"
        >
          <CoffeeIcon />
          {dict.button}
        </a>
      </div>
    </section>
  );
}
