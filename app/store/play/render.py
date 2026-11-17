#!/usr/bin/env python3
"""Renders the Google Play graphics from src/*.html with headless Chrome.

Usage: python3 app/store/play/render.py  (outputs in app/store/play/out/)
The screens reuse the site's app captures in website/public/screenshots/
(English ones in its en/ folder).
"""
import json, pathlib, subprocess, urllib.parse

HERE = pathlib.Path(__file__).resolve().parent
OUT = HERE / "out"
CHROME = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"

# The captions live in ../copy/<lang>.json, one file per language
# (docs/LOCALIZATION.md, phase 7); every file there is rendered.
COPY = {p.stem: json.loads(p.read_text()) for p in sorted((HERE.parent / "copy").glob("*.json"))}
SCREENS = {
    lang: [(s["file"], s["shot"], s["label"], s["title"]) for s in c["screens"]]
    for lang, c in COPY.items()
}
FEATURE = {lang: (c["play"]["featureLabel"], c["play"]["featureTag"]) for lang, c in COPY.items()}


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
