import 'package:flutter_test/flutter_test.dart';

import 'package:nousdeux/core/constants/app_strings.dart';
import 'package:nousdeux/core/constants/settings_strings.dart';
import 'package:nousdeux/core/errors/failures.dart';
import 'package:nousdeux/core/l10n/app_languages.dart';
import 'package:nousdeux/presentation/screens/splash/profile_unavailable_screen.dart';

import '../../../helpers/test_app.dart';

void main() {
  for (final lang in AppLanguages.supported) {
    testWidgets('[$lang] says the server can\'t be reached, in the phone\'s '
        'language', (tester) async {
      final deps = TestDeps(deviceLanguage: lang)
        ..profiles.loadFailure = const NetworkFailure();
      await pumpScreen(tester, const ProfileUnavailableScreen(), deps: deps);

      expect(find.text(profileUnavailableTitle(lang)), findsOneWidget);
      expect(find.text(profileUnavailableBody(lang)), findsOneWidget);
      expect(find.text(profileUnavailableRetry(lang)), findsOneWidget);
      expect(find.text(settingsSignOut(lang)), findsOneWidget);
    });
  }

  testWidgets('"Réessayer" loads the profile again', (tester) async {
    final deps = TestDeps()..profiles.loadFailure = const NetworkFailure();
    await pumpScreen(tester, const ProfileUnavailableScreen(), deps: deps);
    final before = deps.profiles.getOrCreateCalls;

    await tester.tap(find.text(profileUnavailableRetry('fr')));
    await tester.pumpAndSettle();

    expect(deps.profiles.getOrCreateCalls, before + 1);
    expect(deps.auth.signOutCalls, 0);
  });

  testWidgets('"Se déconnecter" signs out', (tester) async {
    final deps = TestDeps()..profiles.loadFailure = const NetworkFailure();
    await pumpScreen(tester, const ProfileUnavailableScreen(), deps: deps);

    await tester.tap(find.text(settingsSignOut('fr')));
    await tester.pumpAndSettle();

    expect(deps.auth.signOutCalls, 1);
  });
}
