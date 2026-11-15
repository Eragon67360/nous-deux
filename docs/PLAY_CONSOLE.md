# Google Play Console answers

What to enter in the Play Console for `com.nousdeux.android`, written from the app's code (version 0.3.0+18). Update this file, the privacy policy and the Console together whenever the app starts collecting something new.

## Before you submit

1. **Closed test before production.** Personal developer accounts created after 13 November 2023 must run a closed test with at least 12 testers who stay opted in for 14 days in a row before they can apply for production. The Console's Dashboard says whether this applies to your account.
2. **The build.** Releasing `dev` to `main` without `[skip ci]` runs the Android workflow. It uploads the signed bundle to the internal testing track as a draft, and you publish it from the Console.

## Store settings

| Field | Value |
| --- | --- |
| App name | Nous Deux |
| Default language | French (France), `fr-FR`; add English (United States), `en-US` |
| App or game | App |
| Free or paid | Free |
| Category | Lifestyle |
| Tags | Calendar, Communication, Health & Fitness, Lifestyle (French Console: Agenda, Communication, Santé et remise en forme, Style de vie). Play has no Couples tag. |
| Contact email | `thomas-moser@orange.fr` (the address on the site) |
| Website | https://nous-deux.app (this field goes live as soon as it's saved, without review) |

## App content

### Privacy policy
- `https://nous-deux.app/fr/politique-de-confidentialite`
- In English: `https://nous-deux.app/en/politique-de-confidentialite`

### Ads
**No**, the app doesn't contain ads.

### App access
**All or some functionality is restricted.** Give the reviewer these instructions:

> Sign in with any Google account. After entering a name, the app asks to pair with a partner: most features (calendar, cycle sharing, location, lists, little notes) only appear inside a couple. To see them, sign in on a second device with another Google account. On the first device choose "Generate a code"; on the second choose "I have a code" and type the 6 characters, or scan the QR code. No password or test account is needed.

### Content rating (IARC questionnaire)
- **Category:** Utility, Productivity, Communication, or Other.
- **Violence, fear, sexual content, crude language, drugs, alcohol, tobacco, gambling:** No to all. The cycle guide is health information, not sexual content.
- **Users can interact or exchange content:** Yes, but only with the one partner they pair with. There is no public content and no contact with strangers.
- **Shares the user's current location with other users:** Yes, with their partner, only after they turn it on.
- **Digital purchases:** No.
- **Unrestricted internet or web browser:** No. The app only opens specific links (guide sources, the policy, the source code), in the phone's browser or an in-app browser view; there is no address bar.

### Target audience and content
- **Age groups:** 18 and over only.
- **Appeals to children:** No.

This keeps the app outside the Families policy. The app pairs adults and stores health data.

### Advertising ID
**No**, the app doesn't use the advertising ID. The built app doesn't request `com.google.android.gms.permission.AD_ID`.

### Health apps declaration
- **Feature to select:** menstrual cycle or reproductive health tracking. The exact label can differ in the Console.
- **What to say:**
  - The app keeps period dates, daily symptoms and mood, and private notes, only if the person turns cycle tracking on. It asks for explicit consent first.
  - The person chooses what their partner sees.
  - It isn't a medical device and doesn't diagnose; the guide says it doesn't replace medical advice.
  - It doesn't use Health Connect.

### Government apps, financial features, news app
**No** to each.

### Sensitive permissions
None of the permissions with their own Play declaration are used: no background location, no exact alarms, no SMS or call log, no broad photo or file access. The built app requests:
- **Fine location:** sharing where you are with your partner, only after you turn it on.
- **Camera:** scanning the pairing QR code.
- **Calendar read and write:** importing events from the phone's calendar.
- **Notifications and push (FCM):** reminders and your partner's notes.
- **Network, wake lock, vibrate.**

## Data safety

### Overview questions
| Question | Answer |
| --- | --- |
| Does your app collect or share any of the required user data types? | Yes |
| Is all of the user data collected by your app encrypted in transit? | Yes (HTTPS to `api.nous-deux.app`, Firebase and OpenFreeMap) |
| Which account creation methods does your app support? | OAuth: Google and Apple |
| Delete account URL | `https://nous-deux.app/fr/suppression-compte` |
| Can users request that some data is deleted without deleting their account? | Yes. They can delete all their cycle data, turn off location sharing (which erases their last position), leave the couple (which deletes what it shared), and delete events and list items. The deletion page explains how, under "Deleting only some of your data". |

### Data collected
Nothing is **shared** in Play's sense:
- what a partner sees is shared at the user's own request;
- the server is your own;
- Firebase (push), OpenFreeMap (map tiles) and Google/Apple (sign-in) act as service providers. The map is MapLibre, which sends no telemetry.

Nothing is processed only temporarily (ephemeral) either; everything below is stored.

| Category › type | Required or optional | Purposes | What it is |
| --- | --- | --- | --- |
| Personal info › Name | Required | App functionality, Account management | Display name entered at onboarding |
| Personal info › Email address | Required | Account management | From Google or Apple sign-in |
| Personal info › User IDs | Required | App functionality, Account management | Account id |
| Personal info › Other info | Required | App functionality | Gender, chosen at onboarding |
| Health and fitness › Health info | Optional | App functionality | Period dates, daily symptoms and mood, private cycle notes |
| Location › Precise location | Optional | App functionality | Latest position only, no history; erased when sharing stops |
| Photos and videos › Photos | Optional | App functionality | Profile photo |
| Messages › Other in-app messages | Optional | App functionality | Little notes (latest one per person) |
| Calendar › Calendar events | Optional | App functionality | Shared calendar events, including ones imported from the phone |
| App activity › Other user-generated content | Optional | App functionality | Shared lists and items, the date the relationship started |
| Device or other IDs | Optional | App functionality | Push notification token |

**Not collected:**
- **Phone number:** phone sign-in is hidden in this build.
- **Financial info, contacts, audio, files and documents, web browsing.**
- **App activity › App interactions, and app info and performance:** there's no analytics and no crash reporting. Add crash logs and diagnostics here, and to the policy, if crash reporting is added later.

## Store listing

### Short description (80 characters at most)
- **fr-FR:** Votre espace à deux : calendrier, cycle, position, listes et petits mots.
- **en-US:** A space for just the two of you: calendar, cycle, location, lists, notes.

### Full description

**fr-FR**

> Nous Deux réunit vos deux vies sur le même écran, et rien d'autre.
>
> Calendrier : un agenda pour deux, chaque événement garde la couleur de la personne qui l'a ajouté. Importez vos événements depuis le calendrier du téléphone et suivez le compte à rebours jusqu'au prochain rendez-vous.
>
> Cycle : la personne qui suit son cycle choisit ce que son partenaire voit. Dates, ressenti du jour et un guide pour chacun des deux, écrit à partir de sources de santé publique. Les notes restent privées.
>
> Position : en direct, seulement quand vous l'activez. Aucun historique.
>
> Listes : courses, choses à faire, idées, cochées des deux côtés en direct.
>
> Petits mots : « Je pense à toi », « Bonne nuit », « J'arrive », envoyés d'un geste.
>
> Vos jours : le compte de vos jours ensemble.
>
> Pas de fil d'actualité, pas de publicité, pas d'inconnus. L'application est gratuite. Vos données sont sur nos propres serveurs en Allemagne et ne sont jamais revendues. Vous pouvez supprimer votre compte depuis l'application.

**en-US**

> Nous Deux puts your two lives on one screen, and nothing else.
>
> Calendar: one calendar for two, where each event keeps the colour of whoever added it. Import events from your phone's calendar and count down to your next date.
>
> Cycle: whoever tracks their cycle chooses what their partner sees. Dates, how you feel each day, and a guide for each of you, written from public health sources. Notes stay private.
>
> Location: live, only when you turn it on. No history.
>
> Lists: groceries, to-dos, ideas, ticked off on both phones at once.
>
> Little notes: "Thinking of you", "Good night", "On my way", sent with one tap.
>
> Your days: how many days you've been together.
>
> No feed, no ads, no strangers. The app is free. Your data lives on our own servers in Germany and is never sold. You can delete your account from the app.

The quoted note labels are the app's own, in both languages.

### Graphics
Everything is in `app/store/play/out/`, rendered by `python3 app/store/play/render.py` (headless Chrome) from the HTML in `app/store/play/src/` and the app captures in `website/public/screenshots/`.

| Asset | French (default) | English (en-US) |
| --- | --- | --- |
| App icon, 512×512 | `icon-512.png` | inherited from French |
| Feature graphic, 1024×500 | `fr/feature.png` | `en/feature.png` |
| Phone screenshots, 1080×1920, in this order | `fr/01-nous` … `fr/05-listes` | `en/01-us` … `en/05-lists` |

- **Order:** uploading several screenshots at once lands them in a random order. Upload them one at a time, or reorder them in the asset panel.
- **AI content declaration:** "Don't label". The graphics are app captures laid out in HTML and CSS, with no generated images.
- **Later:** captures from an Android phone would look more natural than the iPhone ones inside the frames.

## Closed testing
1. Create the closed testing track and add testers as an email list or a Google Group. A group is easier to share from social media: people join the group, then open the opt-in link.
2. Set the feedback channel to the contact email.
3. Publish the build from internal testing to closed testing. The 14-day clock counts from when each tester opts in, so recruit at least 12 early and add a few spares.
