# Store copy

The captions on the store images, one file per language, read by
`app/store/play/render.py` and `app/store/appstore/render.py` (every file here
is rendered).

- `screens`: the five screenshots, in order. `file` names the output image,
  `shot` the app capture in `website/public/screenshots/` (`en/…` for English),
  `label` the small gold word, `title` the sentence under it.
- `play`: the Play feature graphic. `appstore`: the product page header and the
  search results image (`\n` breaks the line).
- Non-breaking spaces are written `\u00a0` so they stay visible: French puts
  one inside « » and before `:`, `;`, `?` and `!`.

Adding a language: copy `en.json` to `xx.json`, translate the values, take the
captures into `website/public/screenshots/xx/` and point `shot` there.
