/// Application-wide constants for Nous Deux.
abstract class AppConstants {
  AppConstants._();

  // Supabase (override via env or Flutter config in production)
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  // Google sign-in OAuth client ids (public identifiers, not secrets). The
  // web client id is the token audience the auth server checks; iOS also
  // needs its own client id.
  // Google Cloud project nous-deux-7bf2f; --dart-define can override them.
  static const String googleWebClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
    defaultValue:
        '836600962251-ujn657ltoii9ofj3u4098afidd1li9ni.apps.googleusercontent.com',
  );
  static const String googleIosClientId = String.fromEnvironment(
    'GOOGLE_IOS_CLIENT_ID',
    defaultValue:
        '836600962251-gev8n6ko7l11f78hka962jv8lje7pq41.apps.googleusercontent.com',
  );

  // Pairing
  static const int pairingCodeLength = 6;
  static const String pairingCodeChars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

  // Location
  static const int locationUpdateIntervalSeconds = 30;

  // Storage bucket for profile photos, one folder per user id.
  static const String avatarsBucket = 'avatars';

  // Mapbox (optional; used only if integrating mapbox_maps_flutter)
  static const String mapboxAccessToken = String.fromEnvironment(
    'MAPBOX_ACCESS_TOKEN',
    defaultValue: '',
  );

  // Validation
  static const int eventTitleMaxLength = 200;
  static const int eventDescriptionMaxLength = 2000;
}
