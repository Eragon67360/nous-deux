import FeatureCard from "./FeatureCard";

type FeatureItem = {
  id: string;
  title: string;
  description: string;
  imageAlt: string;
};

type FeaturesDict = {
  heading: string;
  list: FeatureItem[];
};

export default function FeaturesSection({
  dict,
  imageFallback = "Aperçu",
}: {
  dict: FeaturesDict;
  imageFallback?: string;
}) {
  return (
    <section className="px-6 py-16 sm:py-24" aria-labelledby="features-heading">
      <h2 id="features-heading" className="sr-only">
        {dict.heading}
      </h2>
      <div className="mx-auto max-w-5xl">
        <ul className="grid gap-12 sm:grid-cols-2 lg:grid-cols-3">
          {dict.list.map((feature) => (
            <li key={feature.id}>
              <FeatureCard
                title={feature.title}
                description={feature.description}
                imageSrc={`/screenshots/${feature.id === "calendar" ? "calendar" : feature.id === "period" ? "period" : "position"}.png`}
                imageAlt={feature.imageAlt}
                imageFallback={imageFallback}
              />
            </li>
          ))}
        </ul>
      </div>
    </section>
  );
}
