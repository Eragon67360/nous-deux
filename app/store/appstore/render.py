#!/usr/bin/env python3
"""Renders the App Store screenshots from src/screen.html with headless Chrome.

Usage: python3 app/store/appstore/render.py  (outputs in app/store/appstore/out/)
Same look as the Google Play graphics (../play), at the iPhone 6.3" size App
Store Connect asks for (1206 × 2622), from the site's app captures in
website/public/screenshots/ (English ones in its en/ folder).
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

for lang, screens in SCREENS.items():
    (OUT / lang).mkdir(parents=True, exist_ok=True)
    for name, capture, label, title in screens:
        query = urllib.parse.urlencode({"label": label, "title": title, "shot": capture})
        url = (HERE / "src" / "screen.html").as_uri() + "?" + query
        out = OUT / lang / f"{name}.png"
        subprocess.run(
            [CHROME, "--headless=new", "--disable-gpu", "--hide-scrollbars",
             "--allow-file-access-from-files", "--force-device-scale-factor=1",
             f"--window-size={SIZE[0]},{SIZE[1]}", "--virtual-time-budget=4000",
             f"--screenshot={out}", url],
            check=True, capture_output=True,
        )
        print(out.relative_to(HERE))
