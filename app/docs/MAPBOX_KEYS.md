# Mapbox token (optional)

The Position screen uses **Mapbox Maps SDK for Flutter** (3D map with pitch, Mapbox Standard style) when a token is configured on **Android and iOS**. On web and desktop it falls back to **flutter_map** with OpenStreetMap. To get the 3D Mapbox map, you need a Mapbox public access token.

## Getting a token

1. Sign up at [account.mapbox.com](https://account.mapbox.com/auth/signup).
2. Open [Tokens](https://account.mapbox.com/access-tokens/) and create a token or use the default public token.
3. Use a token with scope **public** only; do not use secret tokens in the app.

## Configuring the project

- **Local dev:** set `mapboxAccessTokenLocal` in `lib/core/config/mapbox_keys.dart`, or pass the token via `--dart-define=MAPBOX_ACCESS_TOKEN=your_token`.
- **CI/production:** pass `MAPBOX_ACCESS_TOKEN` via `--dart-define` (from secrets). Do not commit the token.

The app does not use Mapbox by default; this file is for when you integrate `mapbox_maps_flutter` and need to set `MapboxOptions.setAccessToken(...)` at startup.
