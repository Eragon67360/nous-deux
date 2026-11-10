/// Every route path in one place.
abstract final class AppRoutes {
  AppRoutes._();

  static const splash = '/';
  static const auth = '/auth';
  static const authVerify = '/auth/verify';
  static const onboarding = '/onboarding';
  static const pairing = '/pairing';
  static const pairingJoin = '/pairing/join';
  static const pairingScan = '/pairing/scan';

  // The four tabs.
  static const home = '/main';
  static const calendar = '/main/calendar';
  static const period = '/main/period';
  static const position = '/main/position';

  /// Opened from the avatar on the Nous tab; not a tab.
  static const settings = '/settings';
  static const settingsInfo = '/settings/info';

  static const tabs = [home, calendar, period, position];
}
