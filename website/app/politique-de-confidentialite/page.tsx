import type { Metadata } from "next";
import Link from "next/link";

export const metadata: Metadata = {
  title: "Politique de Confidentialité – Nous Deux",
  description: "Politique de confidentialité de l'application Nous Deux.",
};

const POLICY_LAST_UPDATED = "11 février 2026";
const POLICY_EFFECTIVE_DATE = "11 février 2026";

export default function PolitiqueDeConfidentialitePage() {
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
            Politique de Confidentialité
          </h1>
          <p className="mt-2 text-on-surface-variant">
            Dernière mise à jour : {POLICY_LAST_UPDATED}
          </p>
          <hr className="mt-6 border-outline/50" />
        </header>

        <article className="space-y-8 text-on-surface-variant leading-relaxed">
          <section>
            <h2 className="mb-3 text-xl font-semibold text-on-surface">
              Éditeur et contact
            </h2>
            <p>
              L’application « Nous Deux » est un projet gratuit, sans publicité,
              centré sur la vie de couple (calendrier partagé, suivi des règles,
              partage de position optionnel). Pour toute question relative à
              cette politique ou à vos données, vous pouvez nous contacter via
              le dépôt du projet :{" "}
              <a
                href="https://github.com/Eragon67360/nous-deux"
                target="_blank"
                rel="noopener noreferrer"
                className="text-primary underline hover:no-underline focus:outline-none focus:ring-2 focus:ring-primary rounded"
              >
                github.com/Eragon67360/nous-deux
              </a>
              .
            </p>
          </section>

          <section>
            <h2 className="mb-3 text-xl font-semibold text-on-surface">
              Données collectées
            </h2>
            <p className="mb-4">
              Nous collectons et traitons uniquement les données nécessaires au
              fonctionnement de l’application et au partage au sein du couple
              que vous formez avec votre partenaire.
            </p>
            <ul className="list-disc space-y-2 pl-6">
              <li>
                <strong className="text-on-surface">
                  Compte et authentification
                </strong>
                : identifiant de connexion (connexion avec Google ou Apple),
                adresse e-mail associée au compte si fournie par le fournisseur
                d’authentification.
              </li>
              <li>
                <strong className="text-on-surface">Profil</strong> : nom
                d’affichage, genre, langue de l’application, photo de profil
                (avatar), lien avec le partenaire lorsque vous formez un couple.
              </li>
              <li>
                <strong className="text-on-surface">Calendrier partagé</strong>:
                titres, descriptions, dates et heures des événements que vous ou
                votre partenaire créez, uniquement visibles au sein du couple.
              </li>
              <li>
                <strong className="text-on-surface">Suivi des règles</strong>:
                dates de cycle, humeur, symptômes, notes. Ces données sont
                partagées avec votre partenaire pour faciliter la coordination
                et l’entraide.
              </li>
              <li>
                <strong className="text-on-surface">
                  Position (optionnelle)
                </strong>
                : si vous activez le partage de position, votre position en
                temps réel (latitude, longitude) est utilisée pour l’affichage
                sur la carte. Aucun historique de position n’est conservé.
              </li>
              <li>
                <strong className="text-on-surface">Notifications</strong>:
                token de notification (FCM) pour vous envoyer des rappels (ex.
                rappel SPM partenaire) et des rappels de calendrier.
              </li>
              <li>
                <strong className="text-on-surface">Données techniques</strong>:
                permissions demandées (calendrier, notifications, position,
                appareil photo pour la photo de profil) et informations
                nécessaires au bon fonctionnement de l’application sur votre
                appareil.
              </li>
            </ul>
          </section>

          <section>
            <h2 className="mb-3 text-xl font-semibold text-on-surface">
              Finalités des traitements
            </h2>
            <p>
              Les données sont utilisées pour : fournir et sécuriser le service
              (authentification, stockage, synchronisation) ; permettre le
              partage au sein du couple (calendrier, suivi des règles, position
              si activée) ; envoyer des notifications que vous avez acceptées ;
              afficher la carte (via Mapbox) lorsque le partage de position est
              activé.
            </p>
          </section>

          <section>
            <h2 className="mb-3 text-xl font-semibold text-on-surface">
              Base légale
            </h2>
            <p>
              Le traitement des données liées à votre compte, profil, calendrier
              et suivi des règles est nécessaire à l’exécution du contrat
              (utilisation de l’application). Le partage de position et les
              notifications push sont optionnels et reposent sur votre
              consentement ; vous pouvez les désactiver à tout moment dans les
              paramètres de l’application ou de votre appareil.
            </p>
          </section>

          <section>
            <h2 className="mb-3 text-xl font-semibold text-on-surface">
              Hébergement et sous-traitants
            </h2>
            <p className="mb-4">
              Les données sont hébergées et traitées par les services suivants,
              dans le respect de leurs politiques de confidentialité et des
              règles applicables (dont le RGPD lorsque pertinent) :
            </p>
            <ul className="list-disc space-y-2 pl-6">
              <li>
                <strong className="text-on-surface">Supabase</strong> :
                authentification, base de données, stockage des photos de profil
                (hébergement possible dans l’Union européenne selon la
                configuration du projet).
              </li>
              <li>
                <strong className="text-on-surface">Firebase</strong> (Google) :
                envoi des notifications push (FCM).
              </li>
              <li>
                <strong className="text-on-surface">Mapbox</strong> : affichage
                de la carte lorsque le partage de position est activé.
              </li>
              <li>
                <strong className="text-on-surface">Google</strong> et{" "}
                <strong className="text-on-surface">Apple</strong> : fourniture
                de la connexion (Sign in with Google / Sign in with Apple) ; les
                données traitées par ces services sont régies par leurs propres
                politiques.
              </li>
            </ul>
          </section>

          <section>
            <h2 className="mb-3 text-xl font-semibold text-on-surface">
              Durée de conservation
            </h2>
            <p>
              Les données sont conservées tant que votre compte est actif. La
              position n’est pas stockée à long terme : seule la position
              actuelle est utilisée pour l’affichage en temps réel. En cas de
              suppression de compte ou de demande de suppression, les données
              vous concernant sont supprimées conformément à nos procédures et
              aux délais techniques des sous-traitants.
            </p>
          </section>

          <section>
            <h2 className="mb-3 text-xl font-semibold text-on-surface">
              Vos droits
            </h2>
            <p className="mb-4">
              Conformément au Règlement général sur la protection des données
              (RGPD) et à la loi « informatique et libertés », vous disposez des
              droits suivants :
            </p>
            <ul className="list-disc space-y-2 pl-6">
              <li>Droit d’accès à vos données personnelles</li>
              <li>
                Droit de rectification des données inexactes ou incomplètes
              </li>
              <li>
                Droit à l’effacement (sous réserve des obligations légales)
              </li>
              <li>Droit à la limitation du traitement</li>
              <li>Droit d’opposition à certains traitements</li>
              <li>Droit à la portabilité de vos données</li>
            </ul>
            <p className="mt-4">
              Pour exercer ces droits, contactez-nous via le lien GitHub indiqué
              en début de document. Vous pouvez également introduire une
              réclamation auprès de la CNIL (
              <a
                href="https://www.cnil.fr"
                target="_blank"
                rel="noopener noreferrer"
                className="text-primary underline hover:no-underline focus:outline-none focus:ring-2 focus:ring-primary rounded"
              >
                www.cnil.fr
              </a>
              ) ou de l’autorité de contrôle de votre pays de résidence.
            </p>
          </section>

          <section>
            <h2 className="mb-3 text-xl font-semibold text-on-surface">
              Modifications de la politique
            </h2>
            <p>
              Nous nous réservons le droit de modifier cette politique de
              confidentialité. La version en vigueur est celle publiée sur cette
              page ; la date de dernière mise à jour est indiquée en haut. Nous
              vous encourageons à la consulter périodiquement.
            </p>
          </section>

          <section>
            <h2 className="mb-3 text-xl font-semibold text-on-surface">
              Entrée en vigueur
            </h2>
            <p>
              La présente politique de confidentialité est entrée en vigueur le{" "}
              {POLICY_EFFECTIVE_DATE}.
            </p>
          </section>
        </article>

        <footer className="mt-14 pt-8 border-t border-outline/50">
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
