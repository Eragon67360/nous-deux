#!/usr/bin/env python3
"""Renders the Google Play graphics from src/*.html with headless Chrome.

Usage: python3 app/store/play/render.py  (outputs in app/store/play/out/)
The screens reuse the site's app captures in website/public/screenshots/.
"""
import pathlib, subprocess, urllib.parse

HERE = pathlib.Path(__file__).resolve().parent
OUT = HERE / "out"
CHROME = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
NBSP = " "

SCREENS = {
    "fr": [
        ("01-nous", "nous", "Nous", "Votre espace à deux, et rien d'autre."),
        ("02-calendrier", "calendar", "Calendrier", "Un agenda pour deux, chacun sa couleur."),
        ("03-cycle", "cycle", "Règles", "Le cycle, partagé comme vous le choisissez."),
        ("04-petits-mots", "ping", "Petits mots", f"«{NBSP}Je{NBSP}pense{NBSP}à{NBSP}toi{NBSP}», d'un geste."),
        ("05-listes", "lists", "Listes", "Les courses, cochées des deux côtés."),
    ],
    "en": [
        ("01-us", "nous", "Us", "A space for just the two of you."),
        ("02-calendar", "calendar", "Calendar", "One calendar for two, a colour each."),
        ("03-cycle", "cycle", "Period", "The cycle, shared the way you choose."),
        ("04-notes", "ping", "Little notes", f"“Thinking{NBSP}of{NBSP}you”, in one tap."),
        ("05-lists", "lists", "Lists", "Groceries, ticked off on both phones."),
    ],
}
FEATURE = {
    "fr": ("Calendrier · Cycle · Listes", "Votre espace à deux."),
    "en": ("Calendar · Cycle · Lists", "A space for just the two of you."),
}


def shot(page, query, out, size):
    url = (HERE / "src" / page).as_uri() + "?" + urllib.parse.urlencode(query)
    subprocess.run(
        [CHROME, "--headless=new", "--disable-gpu", "--hide-scrollbars",
         "--allow-file-access-from-files", "--force-device-scale-factor=1",
         f"--window-size={size[0]},{size[1]}", "--virtual-time-budget=4000",
         f"--screenshot={out}", url],
        check=True, capture_output=True,
    )


for lang, screens in SCREENS.items():
    (OUT / lang).mkdir(parents=True, exist_ok=True)
    for name, capture, label, title in screens:
        shot("screen.html", {"label": label, "title": title, "shot": capture},
             OUT / lang / f"{name}.png", (1080, 1920))
    label, tag = FEATURE[lang]
    shot("feature.html", {"label": label, "tag": tag}, OUT / lang / "feature.png", (1024, 500))

subprocess.run(["sips", "-Z", "512", str(HERE.parent.parent / "assets/icon/app_icon.png"),
                "--out", str(OUT / "icon-512.png")], check=True, capture_output=True)
print("\n".join(str(p.relative_to(HERE)) for p in sorted(OUT.rglob("*.png"))))
