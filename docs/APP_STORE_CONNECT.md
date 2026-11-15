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
- **Bêta publique**: external group with the public link turned on, shared on nous-deux.app/beta and in `promo/`. The workflow adds every build and submits the first build of each version for beta review.

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
| User Content › Other User Content | Yes | No | App Functionality | Calendar events (imported ones too), shared lists, little notes (latest per person), the relationship's start date |
| Other Data › Other Data Types | Yes | No | App Functionality | Gender, chosen at onboarding |
| Identifiers › User ID | Yes | No | App Functionality | Account id |
| Identifiers › Device ID | Yes | No | App Functionality | Push notification token |
| Diagnostics › Crash Data | No | No | App Functionality | Crash and error reports to our GlitchTip, kept 30 days, no account, IP or location |
| Diagnostics › Other Diagnostic Data | No | No | App Functionality | Sent with each report: phone model, system version, memory, storage, battery, network, language, time zone |

**Not collected:** phone number (phone sign-in is off), physical address, other contact info, financial info, contacts, emails or text messages (little notes are preset phrases, counted under Other User Content), audio, gameplay, customer support, browsing or search history, purchases, usage data (no analytics), advertising data, performance data, sensitive info, coarse location.
