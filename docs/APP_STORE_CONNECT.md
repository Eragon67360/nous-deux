# App Store Connect answers

What to enter in App Store Connect for the iOS app `app.nous-deux` (team `2Y57C77BK4`), written from the app's code. It mirrors [PLAY_CONSOLE.md](PLAY_CONSOLE.md): update both, and the privacy policy, whenever the app starts collecting something new.

## The app record

| Field | Value |
| --- | --- |
| Name | Nous Deux : app de couple. "Nous Deux" and "Nous Deux - Couple" are taken by other developers. The name can change until the first App Store release. The home screen shows "Nous Deux" either way (`CFBundleDisplayName`). |
| Apple ID | 6835108447 |
| Bundle ID | `app.nous-deux` |
| SKU | `nous-deux-ios` |
| Primary language | French; English added for TestFlight texts |
| Devices | iPhone only (`TARGETED_DEVICE_FAMILY = 1`). iPads run it as an iPhone app. |

## Builds

The "iOS TestFlight" workflow builds, signs and uploads each release to `main` that touches the app, then sends it to the public group. See [`app/ios/fastlane/README.md`](../app/ios/fastlane/README.md). It needs, in the GitHub environment `app-store` (with Thomas as required reviewer):

| Secret | What |
| --- | --- |
| `ASC_KEY_ID` | App Store Connect API key id (Users and Access → Integrations → App Store Connect API, Team key, **Admin**: cloud-managed signing needs it) |
| `ASC_ISSUER_ID` | Issuer id shown above the keys |
| `ASC_KEY_P8` | The `.p8` file's contents; Apple lets you download it once. Also kept in Proton Pass. |

`SUPABASE_URL`, `SUPABASE_ANON_KEY` and `SENTRY_DSN` are the repository secrets the Android build uses. Phone sign-in stays off: the build doesn't pass `PHONE_SIGN_IN`.

Export compliance: `ITSAppUsesNonExemptEncryption` is `false` in `Info.plist` (HTTPS and the system's encryption only), so TestFlight doesn't ask for each build.

## TestFlight

### Test information (set once, French and English)
- **Beta app description**
  - fr: Nous Deux, votre espace à deux : calendrier partagé, cycle, position (seulement quand vous l'activez), listes et petits mots. Gratuit, sans publicité. L'app se teste à deux : envoyez le lien à votre partenaire.
  - en: Nous Deux, a space for just the two of you: shared calendar, cycle, location (only when you turn it on), lists and little notes. Free, no ads. It takes two to test: send the link to your partner.
- **Feedback email:** the contact address on the site.
- **Marketing URL:** `https://nous-deux.app/fr/beta` (English: `https://nous-deux.app/en/beta`)
- **Privacy policy URL:** `https://nous-deux.app/fr/politique-de-confidentialite` (English: `https://nous-deux.app/en/politique-de-confidentialite`)

### Beta app review information (Thomas)
- **Contact:** Thomas's name, email and phone.
- **Sign-in required:** `review1@nous-deux.app` and its password from Proton Pass.
- **Notes**, with the second account's password added where it says so:

> Nous Deux is a private space for a couple: shared calendar, cycle tracking, live location (only when the person turns it on), shared lists and short notes. It is free, with no ads and no purchases.
>
> Sign in on the first screen with "Sign in with email" ("Se connecter avec un e-mail" in French) using the account above. Most features appear only once two accounts are paired. Use the second review account, review2@nous-deux.app (password: …), on another device: on one device choose "Generate a code", on the other "I have a code" and type the 6 characters or scan the QR code. To pair again, use Settings > Leave couple.
>
> Sign in with Apple and Google are also available. Account deletion is in Settings > Account. The app follows the device language (French or English).

### Groups
- **Bêta publique**: external group, public link https://testflight.apple.com/join/kScrT3Sk (no tester limit), shared on nous-deux.app/beta and in `promo/`. The workflow adds every build and submits the first build of each version for beta review. Created on 2026-11-15 through the App Store Connect API: the web page offered no external group even with the test information complete.

## App Store product page

Filled on 2026-11-17 for version « 1.0 » (not submitted, no build yet). French is the primary language; English (United States) was added then, with its own name, subtitle, texts and screenshots.

### App Information (all versions)

| Field | French | English (US) |
| --- | --- | --- |
| Name (30) | Nous Deux : app de couple | Nous Deux: app for couples |
| Subtitle (30) | Agenda, cycle et petits mots | Calendar, cycle, little notes |
| Privacy policy URL | `https://nous-deux.app/fr/politique-de-confidentialite` | `https://nous-deux.app/en/politique-de-confidentialite` |

- **Category:** Lifestyle (« Style de vie »), secondary Productivity (« Productivité »), like Play.
- **Price:** free (US base price $0.00). It takes effect once the app is "Ready for Sale".

### Version page

| Field | French | English (US) |
| --- | --- | --- |
| Promotional text (170, can change without review) | Nouveau : écrivez vos propres petits mots et vos propres ressentis du jour. Gratuit, sans publicité, vos données restent sur nos serveurs en Allemagne. | New: write your own little notes and your own daily states. Free, no ads, and your data stays on our own servers in Germany. |
| Keywords (100, commas, no words from the name) | `amoureux,agenda partagé,calendrier,règles,cycle menstruel,position,liste de courses,petit mot` | `couples,relationship,shared calendar,period tracker,cycle,location sharing,grocery list,love notes` |
| Support URL | `https://nous-deux.app/fr/beta` (the contact address is on it) | `https://nous-deux.app/en/beta` |
| Marketing URL | `https://nous-deux.app/fr` | `https://nous-deux.app/en` |

- **Copyright:** 2026 Thomas Moser
- **Release:** manual (« Publier cette version manuellement »), so an approval doesn't put the app live by itself.
- **App Review:** sign-in required with `review1@nous-deux.app`; the notes are the TestFlight ones above. The two passwords (review1 in the field, review2 in the notes) and the contact are Thomas's to enter.

**Description, French**

> Nous Deux réunit vos deux vies sur le même écran, et rien d'autre.
>
> Calendrier : un agenda pour deux, chaque événement garde la couleur de la personne qui l'a ajouté. Reliez un agenda de votre téléphone et ses événements restent à jour, changez de mois d'un glissement et suivez le compte à rebours jusqu'au prochain rendez-vous.
>
> Cycle : la personne qui suit son cycle choisit ce que son partenaire voit. Dates, ressenti du jour, avec vos propres mots si vous voulez, et un guide pour chacun des deux, écrit à partir de sources de santé publique. Les notes restent privées.
>
> Position : en direct, seulement quand vous l'activez. Aucun historique.
>
> Listes : courses, choses à faire, idées, cochées des deux côtés en direct.
>
> Petits mots : « Je pense à toi », « Bonne nuit », « J'arrive », ou vos propres mots, envoyés d'un geste.
>
> Vos jours : le compte de vos jours ensemble.
>
> Pas de fil d'actualité, pas de publicité, pas d'inconnus. L'application est gratuite. Vos données sont sur nos propres serveurs en Allemagne et ne sont jamais revendues. Vous pouvez supprimer votre compte depuis l'application.

**Description, English**

> Nous Deux puts your two lives on one screen, and nothing else.
>
> Calendar: one calendar for two, where each event keeps the colour of whoever added it. Link a calendar from your phone and its events stay up to date, swipe between months and count down to your next date.
>
> Cycle: whoever tracks their cycle chooses what their partner sees. Dates, how you feel each day, in your own words if you like, and a guide for each of you, written from public health sources. Notes stay private.
>
> Location: live, only when you turn it on. No history.
>
> Lists: groceries, to-dos, ideas, ticked off on both phones at once.
>
> Little notes: "Thinking of you", "Good night", "On my way", or your own words, sent with one tap.
>
> Your days: how many days you've been together.
>
> No feed, no ads, no strangers. The app is free. Your data lives on our own servers in Germany and is never sold. You can delete your account from the app.

### Screenshots

The iPhone class App Store Connect asks for is now « iPhone avec Dynamic Island (écran moyen) », the 6.1/6.3-inch screens: 1206 × 2622 (or 1179 × 2556). Apple scales them for the other iPhones. iPad, iPhone Duo and Apple Watch are not needed: the app is iPhone only.

`python3 app/store/appstore/render.py` renders them, with the captions in `app/store/copy/<lang>.json`, from the site's captures (`website/public/screenshots/`, English from its `en/` folder) in the Play graphics' look. Upload them one at a time to keep the order. The French set is the shared one. The English set was uploaded with the page switched to English, where it replaces « Utilisation des ressources existantes ».

| Order | French | English |
| --- | --- | --- |
| 1 | `fr/01-nous.png` | `en/01-us.png` |
| 2 | `fr/02-calendrier.png` | `en/02-calendar.png` |
| 3 | `fr/03-cycle.png` | `en/03-cycle.png` |
| 4 | `fr/04-petits-mots.png` | `en/04-notes.png` |
| 5 | `fr/05-listes.png` | `en/05-lists.png` |

The Position capture is left out of the store sets. On 2026-11-17 all ten screenshots, both search images and both headers were replaced by renders of the build 26 captures (#117): Camille's written note, « Écrire… », and an own state in Règles. Files were uploaded as `*-1117.png`; the earlier ones stay in « Bibliothèque de ressources ». Removing a screenshot, header or search image asks for confirmation and keeps it in the library.

### « En-tête et résultats de recherche » (optional)

A newer tab next to the screenshots, about the App Store only (not web search engines). **En-tête** is one wide banner at the top of the product page (5244 × 2950 or 3840 × 1646). **Résultats de recherche** is one landscape image shown in the app's row in App Store search results (5244 × 2950, 3840 × 2560 or 1920 × 1280); without it, search results show the first screenshots.

Set on 2026-11-17: `out/fr/search.png` and `out/en/search.png` (3840 × 2560, from `src/search.html` in the same render script): the rings, « Nous Deux », a tagline, and the Nous, Calendrier and Règles captures. French was uploaded first; with the page switched to English, its own English image replaces « Ressource de résultats de recherche utilisée : Français ». Apple's « Aperçu » showed it whole, under the name and subtitle.

Header set on 2026-11-17: `out/fr/header.png` and `out/en/header.png` (5244 × 2950, from `src/header.html`): the rings, a gold label, the line « Votre espace à deux, / et rien d'autre. » ("A space for just / the two of you.") and five phones fanned out below. Apple's preview crops it per device:
- **iPhone, upright:** only the middle ~54% of the width and the top ~70% of the height show; the Dynamic Island covers the top ~6% and the back and share buttons sit on either side about 28% down. Everything that matters is in that window, which is why the line is on two short lines and the English label is "Calendar · Cycle · Lists · Notes" (with "Little notes" it touched the share button).
- **iPad (landscape):** the whole width shows but only a band of the height; the App Store's floating tab bar covers the rings. The label, the line and the tops of the phones show. Landscape isn't offered for iPhone.
The first versions of both headers were removed from the page; they stay in « Bibliothèque de ressources » until deleted there.

### Age rating (set 2026-11-17)

Apple's questionnaire (7 steps) computed **13+**; it is raised to **18+** (« Remplacer par une classification d'âge plus élevée »), as on Play: the app pairs adults and stores health data, and in France under-15s can't consent to health-data processing alone. Shown: 18+ in 173 countries, 19+ in South Korea, 17+ on systems older than 26.

| Question | Answer | Why |
| --- | --- | --- |
| Parental controls, age assurance | No | |
| Unrestricted web access | No | Only fixed links (guide sources, policy) |
| User-generated content, social networking | No | Nothing is distributed beyond the one partner |
| Messaging and chat | **Yes** | Little notes, written ones included, go between the two partners |
| Advertising | No | |
| Profanity, horror, alcohol/tobacco/drugs | None | |
| Medical or treatment information | **Infrequent** | The cycle guide gives care advice and "see a doctor if…", no diagnosis |
| Health or wellness topics | **Yes** | The cycle guide and the weekly tips |
| Mature or suggestive themes | **Infrequent** | A couple's app with links to sexual and reproductive health sources; rated up rather than down |
| Sexual content or nudity, violence, weapons, gambling, contests, loot boxes | None / No | |

### Other settings (2026-11-17)

- **Content rights:** "Yes, it contains third-party content and I have the rights": the map shows OpenFreeMap tiles built from OpenStreetMap (ODbL), credited in MapLibre's « ⓘ » button.
- **Availability:** 174 countries or regions, all but mainland China, which needs a security assessment and an AI-content declaration (« Conformité de l'app »). New countries are added automatically.
- **Version:** left at Apple's default « 1.0 » with no build. Thomas plans to ship the App Store release as 1.0.0 once the app is ready (2026-11-17); the build number freeze at 0.3.6 ends then.
- **App Review information:** contact and both review accounts entered by Thomas.
- **Conformité de l'app:** the Digital Services Act trader information is still to configure. It is account-wide (the same Apple team holds Le Bon Tempérament's apps), so it is Thomas's. No medical-device declaration is needed (category Lifestyle, medical information "infrequent").

## App Privacy

Same facts as Play's Data safety table, in Apple's terms. Apple counts crash and diagnostic data under **App Functionality** ("minimize app crashes"), where Play calls it Analytics. Nothing is used for tracking, and nothing goes to data brokers or advertisers.

- **Privacy policy URL:** `https://nous-deux.app/fr/politique-de-confidentialite`
- **Do you or your third-party partners collect data from this app?** Yes.

| Data type | Linked to the user | Tracking | Purpose | What it is |
| --- | --- | --- | --- | --- |
| Contact Info › Name | Yes | No | App Functionality | Display name entered at onboarding |
| Contact Info › Email Address | Yes | No | App Functionality | From Google or Apple sign-in (Apple may give a relay address) |
| Health & Fitness › Health | Yes | No | App Functionality | Period dates, daily symptoms and mood, private cycle notes; only with cycle tracking on |
| Location › Precise Location | Yes | No | App Functionality | Latest position only, while sharing is on |
| User Content › Photos or Videos | Yes | No | App Functionality | Profile photo |
| User Content › Emails or Text Messages | Yes | No | App Functionality | Little notes: a preset or a text the person writes (40 characters at most), only the latest per person; never in the push |
| User Content › Other User Content | Yes | No | App Functionality | Calendar events (copied from followed phone calendars too: title and times), shared lists, the relationship's start date |
| Identifiers › User ID | Yes | No | App Functionality | Account id |
| Identifiers › Device ID | Yes | No | App Functionality | Push notification token; a random id of the phone that follows calendars |
| Diagnostics › Crash Data | No | No | App Functionality | Crash and error reports to our GlitchTip, kept 30 days, no account, IP or location |
| Diagnostics › Other Diagnostic Data | No | No | App Functionality | Sent with each report: phone model, system version, memory, storage, battery, network, language, time zone |

Gender is no longer collected (2026-11-17): the app stopped asking (#124) and the server cleared the stored values and drops what builds up to 26 still send (migration `20261117100000_gender_cleared`), so **Other Data › Other Data Types** is no longer declared.

Since build 26 (2026-11-17) a little note can be a text the person writes, so notes are declared as **Emails or Text Messages** (« E-mails ou SMS », the contents of a message), as Play's "Messages › Other in-app messages" already does. Before, as preset phrases, they were under Other User Content.

**Not collected:** phone number (phone sign-in is off), physical address, other contact info, financial info, contacts, audio, gameplay, customer support, browsing or search history, purchases, usage data (no analytics), advertising data, performance data, sensitive info, coarse location.
