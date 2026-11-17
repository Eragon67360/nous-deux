# Ressenti for every couple (idea, parked)

Status: parked on 2026-11-17. Thomas: "It's a big change, so we keep it in mind for later." Nothing is built. Wireframes: the Claude Design canvas "Nous Deux · Ressenti pour tous" (https://claude.ai/artifact/VV1m5ArdfVtJzoLw2jxEJh, private to Thomas).

## Why

Raised by a beta tester: the app should feel made for every couple, two men included. Today:

- **The tab is named after periods.** The third tab is « Règles ». For a couple where nobody has periods, a quarter of the app says "not for you".
- **The mood check-in is locked behind the cycle.** The daily « ressenti » (mood, symptoms, « Mes mots ») only exists once someone turns on « Je suis mon cycle dans l'app ». What the tester asked for, a way to share moods, is already there, only behind periods.
- **The rest is already neutral.** There's no gender question since #124, the copy says « votre partenaire », and the captures use Alex and Camille. Lesbian couples work, since each person tracks their own cycle.

## Options

- **A. Quick win.** Anyone can log a « ressenti », cycle or not. The tab is named after what people use: « Ressenti », with the cycle as a section for whoever tracks one. It mostly reuses the existing check-in.
- **B. Recommended.** The check-in becomes the core, and the cycle becomes an optional layer.
  - **A 10-second daily check-in for everyone:** mood (words plus « Mes mots »), energy (low, medium, high), social battery, and one need (calme, un câlin, parler, de l'aide, de l'espace).
  - **The partner sees what is shared,** with one gentle idea ("a quiet evening: offer to make dinner") and a link to « Petits mots ».
  - **A week view of both,** with calm observations and no streaks or scores. It can cross-check the shared calendar ("low energy on your two busiest evenings").
  - **Cycle trackers get a band on top** (day, phase, next period) plus the cycle symptoms. Everyone else gets the same screen without it.
- **C. Later, if ever.** A wellbeing space with optional trackers: cycle, sleep, sport, and treatment reminders (the pill, PrEP, hormone therapy). It turns Nous Deux into a health app, with heavier store declarations. Treatment reminders are the one piece worth taking from it.

## Open questions (on the canvas)

1. **Where the check-in lives:**
   - its own « Ressenti » tab for everyone; or
   - a line on the « Nous » home, with a cycle tab only for whoever tracks one. A couple without a cycle then has three tabs: Nous, Calendrier, Position.
2. **How many questions:** are four (mood, energy, social battery, need) too many for ten seconds?
3. **The partner idea:** helpful, or intrusive?
4. **Nouns, not adjectives:** « Fatigue », « Stress », « Calme ». Nothing then agrees with anyone's gender, and the app needs no pronouns.

## Constraints whichever option wins

- **Privacy.** Mood data can count as health data (GDPR art. 9), so the existing cycle rules apply:
  - explicit consent, separate from the cycle consent;
  - private by default, shared item by item, notes always private;
  - push texts stay vague, as the period push does;
  - delete everything from the settings.
  - The privacy policy (`website/lib/dictionaries/{fr,en}.json`), Play's Data safety form and Apple's privacy labels change with it.
- **No made-up science.** No "male cycle". Any tip carries sources, as the cycle guide's do (`period_verified_sources.dart`).
- **French copy.** Prefer nouns over adjectives, and write « Ce que voit Alex » rather than « Ce qu'Alex voit » (elision depends on the name).
- **Data.** The check-ins table today belongs to the cycle. It becomes a general one, existing entries kept, and the cycle fields stay optional. This is a migration that rewrites existing data, so Thomas OKs it first.
- **Translations.** New text goes into the ARB files (`app/lib/l10n/`); longer tips go into the content files (`app/lib/core/constants/content/`).

## Before building

1. Ask the beta's MM couples what they'd log and what they'd share.
2. Settle the four questions on the canvas.
3. Write the plan (superpowers:writing-plans) in this file's place, the way `docs/CALENDAR_SYNC.md` was written.
