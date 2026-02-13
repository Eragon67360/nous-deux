import FeatureCard from "./FeatureCard";

const FEATURES = [
  {
    id: "calendar",
    title: "Calendrier partagé",
    description:
      "Événements communs, synchronisés entre vous et votre partenaire. Une seule vue pour coordonner vos agendas.",
    imagePath: "/screenshots/calendar.png",
    imageAlt: "Aperçu du calendrier partagé dans l’application Nous Deux",
  },
  {
    id: "period",
    title: "Suivi des règles",
    description:
      "Cycle, humeur, symptômes et notes, partagés avec votre partenaire pour faciliter l’entraide et la coordination.",
    imagePath: "/screenshots/period.png",
    imageAlt: "Aperçu du suivi des règles dans l’application Nous Deux",
  },
  {
    id: "position",
    title: "Position (optionnelle)",
    description:
      "Partage de position sur la carte en temps réel. Aucun historique conservé — uniquement pour vous retrouver.",
    imagePath: "/screenshots/position.png",
    imageAlt: "Aperçu du partage de position dans l’application Nous Deux",
  },
] as const;

export default function FeaturesSection() {
  return (
    <section className="px-6 py-16 sm:py-24" aria-labelledby="features-heading">
      <h2 id="features-heading" className="sr-only">
        Fonctionnalités
      </h2>
      <div className="mx-auto max-w-5xl">
        <ul className="grid gap-12 sm:grid-cols-2 lg:grid-cols-3">
          {FEATURES.map((feature) => (
            <li key={feature.id}>
              <FeatureCard
                title={feature.title}
                description={feature.description}
                imageSrc={feature.imagePath}
                imageAlt={feature.imageAlt}
              />
            </li>
          ))}
        </ul>
      </div>
    </section>
  );
}
