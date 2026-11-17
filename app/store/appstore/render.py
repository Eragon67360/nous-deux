#!/usr/bin/env python3
"""Renders the App Store screenshots (src/screen.html), the search results
image (src/search.html) and the product page header (src/header.html) with
headless Chrome.

Usage: python3 app/store/appstore/render.py  (outputs in app/store/appstore/out/)
Same look as the Google Play graphics (../play). Screenshots at the iPhone
6.3" size App Store Connect asks for (1206 × 2622); the search results image
at 3840 × 2560. Both from the site's app captures in website/public/screenshots/
(English ones in its en/ folder).
"""
import pathlib, subprocess, urllib.parse

HERE = pathlib.Path(__file__).resolve().parent
OUT = HERE / "out"
CHROME = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
NBSP = " "
SIZE = (1206, 2622)

SCREENS = {
    "fr": [
        ("01-nous", "nous", "Nous", "Votre espace à deux, et rien d'autre."),
        ("02-calendrier", "calendar", "Calendrier", "Un agenda pour deux, chacun sa couleur."),
        ("03-cycle", "cycle", "Règles", "Le cycle, partagé comme vous le choisissez."),
        ("04-petits-mots", "ping", "Petits mots", f"«{NBSP}Je{NBSP}pense{NBSP}à{NBSP}toi{NBSP}», ou vos propres mots."),
        ("05-listes", "lists", "Listes", "Les courses, cochées des deux côtés."),
    ],
    "en": [
        ("01-us", "en/nous", "Us", "A space for just the two of you."),
        ("02-calendar", "en/calendar", "Calendar", "One calendar for two, a colour each."),
        ("03-cycle", "en/cycle", "Period", "The cycle, shared the way you choose."),
        ("04-notes", "en/ping", "Little notes", f"“Thinking{NBSP}of{NBSP}you”, or your own words."),
        ("05-lists", "en/lists", "Lists", "Groceries, ticked off on both phones."),
    ],
}

HEADER = {
    "fr": ("Agenda · Cycle · Listes · Petits mots", "Votre espace à deux,\net rien d'autre."),
    "en": ("Calendar · Cycle · Lists · Notes", "A space for just\nthe two of you."),
}
SEARCH = {
    "fr": ("Agenda · Cycle · Listes", "Votre espace à deux, gratuit et sans publicité."),
    "en": ("Calendar · Cycle · Lists", "A space for just the two of you, free and ad-free."),
}


def shot(page, query, out, size, scale=1):
    url = (HERE / "src" / page).as_uri() + "?" + urllib.parse.urlencode(query)
    subprocess.run(
        [CHROME, "--headless=new", "--disable-gpu", "--hide-scrollbars",
         "--allow-file-access-from-files", f"--force-device-scale-factor={scale}",
         f"--window-size={size[0]},{size[1]}", "--virtual-time-budget=4000",
         f"--screenshot={out}", url],
        check=True, capture_output=True,
    )
    print(out.relative_to(HERE))


for lang, screens in SCREENS.items():
    (OUT / lang).mkdir(parents=True, exist_ok=True)
    for name, capture, label, title in screens:
        shot("screen.html", {"label": label, "title": title, "shot": capture},
             OUT / lang / f"{name}.png", SIZE)
    # Search results: 1920 × 1280 at 2×, so 3840 × 2560, one of Apple's sizes.
    label, tag = SEARCH[lang]
    shot("search.html", {"label": label, "tag": tag, "lang": lang},
         OUT / lang / "search.png", (1920, 1280), scale=2)
    # Product page header: 2622 × 1475 at 2×, so 5244 × 2950, one of Apple's sizes.
    label, title = HEADER[lang]
    shot("header.html", {"label": label, "title": title, "lang": lang},
         OUT / lang / "header.png", (2622, 1475), scale=2)
