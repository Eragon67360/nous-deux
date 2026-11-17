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
import json, pathlib, subprocess, urllib.parse

HERE = pathlib.Path(__file__).resolve().parent
OUT = HERE / "out"
CHROME = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
SIZE = (1206, 2622)

# The captions live in ../copy/<lang>.json, one file per language
# (docs/LOCALIZATION.md, phase 7); every file there is rendered.
COPY = {p.stem: json.loads(p.read_text()) for p in sorted((HERE.parent / "copy").glob("*.json"))}
SCREENS = {
    lang: [(s["file"], s["shot"], s["label"], s["title"]) for s in c["screens"]]
    for lang, c in COPY.items()
}
HEADER = {lang: (c["appstore"]["headerLabel"], c["appstore"]["headerTitle"]) for lang, c in COPY.items()}
SEARCH = {lang: (c["appstore"]["searchLabel"], c["appstore"]["searchTag"]) for lang, c in COPY.items()}


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
