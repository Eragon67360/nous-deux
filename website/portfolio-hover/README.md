# portfolio-hover

Source of the hover preview shown on thomasmoserdev.com/projects for Nous Deux.

- `capture.mjs`: captures the real site (home, one viewport per scroll step, the feature cards) into `captures/`.
- `comp.html`: the 8s, 1280x800 loop, drawn from the captures and from the real app screenshots the site
  already ships in `../public/screenshots` (the calendar card's crop grows into the full app screen,
  then the bottom tabs are tapped: Calendrier, Règles, Guide, Position). Every frame is a function of time.
- `out/`: rendered `nous-deux.mp4` (silent H.264) and its first frame.

`engine.js`, `base.css` and `render.mjs` are copied from the portfolio's `resources/hover-videos/kit`,
which documents how to capture and render.
