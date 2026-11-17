# Captures de l'app

Captures réelles de l'app (iPhone 16 Plus, 1290×2796, app en français), utilisées par la page d'accueil, par `portfolio-hover/` et par les images des stores (`app/store/*/render.py`). Prises le 17 novembre 2026 sur la version 0.3.6 (26).

| Fichier | Écran | Utilisé par |
| --- | --- | --- |
| `calendar.png` | Calendrier partagé, événements des deux, aujourd'hui le 17 | Deux agendas, Un seul espace (fusion), Ce que vous partagez |
| `merge-me.png` | Calendrier avec les seuls événements d'Alex | Un seul espace (téléphone « Moi ») |
| `merge-partner.png` | Calendrier de Camille, ses seuls événements | Un seul espace (téléphone « Toi ») |
| `cycle.png` | Règles, vue du jour : « Besoin de chocolat », un état écrit par Alex, coché à côté de « + Autre » | Ce que vous partagez › Cycle |
| `position.png` | Carte MapLibre (style de jour d'OpenFreeMap) avec les deux positions | Ce que vous partagez › Position |
| `nous.png` | Onglet Nous : jours ensemble, petits mots avec « Écrire… » et « Mes mots », le mot écrit par Camille, rendez-vous, listes | Ce que vous partagez › Vos jours |
| `ping.png` | Petit mot écrit par Camille, reçu dans les anneaux (« Répondre par un mot ») | Ce que vous partagez › Petits mots |
| `lists.png` | Liste de courses partagée | Ce que vous partagez › Listes |

Le couple (Alex et Camille), les lieux et les événements sont inventés. Les captures sont faites sur la copie locale du backend (pile Docker de répétition), jamais sur `api.nous-deux.app`, avec la barre d'état fixée à 9:41 (`xcrun simctl status_bar … override`). La carte suit l'heure du téléphone (style de nuit avant 6 h et après 20 h) : ces captures, prises le matin, ont le style de jour.

## English (`en/`)

The same eight screens with the app and its data in English (British spelling, as on the site), used by the `/en` pages through `lib/screenshots.ts` and by the English store images. Taken on 17 November 2026 from build 0.3.6 (26), right after the French ones: Camille's written note ("Can't wait for tonight") in the Us line and in the rings, Alex's own state "Need chocolate" in Period › Today, the day map. Same invented couple, same local backend, status bar at 9:41.
