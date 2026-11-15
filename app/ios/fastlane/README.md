# TestFlight (fastlane)

The "iOS TestFlight" GitHub workflow (`.github/workflows/ios-testflight.yml`)
builds the iPhone app, uploads it to TestFlight and sends it to the external
group « Bêta publique », whose public link is on nous-deux.app/beta. It runs on
each release to `main` that touches the app, or by hand from Actions.

- **Signing:** automatic, with the App Store Connect API key in the GitHub
  environment `app-store` (`ASC_KEY_ID`, `ASC_ISSUER_ID`, `ASC_KEY_P8`). The
  key must be Admin: Apple's cloud-managed distribution certificate needs it.
  The environment waits for Thomas's approval before each run.
- **Version:** `version:` in `app/pubspec.yaml`, like Android. The first build
  of each version (`0.3.4`, `0.4.0`…) goes through Apple's beta review, usually
  within a day; later builds of the same version reach testers at once.
- **What testers read:** `testflight/what_to_test.{fr,en}.txt`, sent with each
  build. Everything else (test description, feedback email, beta review
  contact, sign-in account and notes) is set once in App Store Connect, see
  `docs/APP_STORE_CONNECT.md`.
- **Lanes:** `beta` (archive, upload, send to the group), `send` (send the
  newest build again after a failed send).

Locally, with the key file at hand:
`ASC_KEY_ID=… ASC_ISSUER_ID=… ASC_KEY_PATH=… bundle exec fastlane ios send`.
