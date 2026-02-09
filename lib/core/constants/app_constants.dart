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

  // Pairing
  static const int pairingCodeLength = 6;
  static const String pairingCodeChars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

  // Location
  static const int locationUpdateIntervalSeconds = 30;

  // Validation
  static const int eventTitleMaxLength = 200;
  static const int eventDescriptionMaxLength = 2000;
}
