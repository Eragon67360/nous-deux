import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nousdeux/core/constants/onboarding_strings.dart';
import 'package:nousdeux/core/errors/failures.dart';
import 'package:nousdeux/presentation/providers/profile_provider.dart';
import 'package:nousdeux/presentation/screens/onboarding/onboarding_screen.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/test_app.dart';

void main() {
  Future<TestDeps> pumpOnboarding(WidgetTester tester) async {
    final deps = TestDeps(
      myProfile: profile(username: null, onboarded: false),
      deviceLanguage: 'en',
    );
    await pumpScreen(tester, const OnboardingScreen(), deps: deps);
    return deps;
  }

  testWidgets('starts in French with woman preselected, whatever the device', (
    tester,
  ) async {
    await pumpOnboarding(tester);

    expect(find.text(onboardingTitle('fr')), findsOneWidget);
    expect(find.text(onboardingDisplayNameLabel('fr')), findsOneWidget);
    expect(find.text(onboardingContinue('fr')), findsOneWidget);

    final gender = tester.widget<SegmentedButton<String>>(
      find.byType(SegmentedButton<String>).first,
    );
    expect(gender.selected, {'woman'});
  });

  testWidgets('switching to English relabels the screen', (tester) async {
    await pumpOnboarding(tester);

    await tester.tap(find.text(onboardingEnglish('fr')));
    await tester.pumpAndSettle();

    expect(find.text(onboardingTitle('en')), findsOneWidget);
    expect(find.text(onboardingContinue('en')), findsOneWidget);
    expect(find.text(onboardingWoman('en')), findsOneWidget);
  });

  testWidgets('an empty name shows an error in the chosen language', (
    tester,
  ) async {
    final deps = await pumpOnboarding(tester);

    await tester.tap(find.text(onboardingContinue('fr')));
    await tester.pump();
    expect(find.text(onboardingErrorDisplayName('fr')), findsOneWidget);

    await tester.tap(find.text(onboardingEnglish('fr')));
    await tester.enterText(find.byType(TextField), '   ');
    await tester.tap(find.text(onboardingContinue('en')));
    await tester.pump();
    expect(find.text(onboardingErrorDisplayName('en')), findsOneWidget);

    expect(deps.profiles.completeOnboardingCalls, isEmpty);
  });

  testWidgets('sends the trimmed name with the defaults', (tester) async {
    final deps = await pumpOnboarding(tester);

    await tester.enterText(find.byType(TextField), '  Camille ');
    await tester.tap(find.text(onboardingContinue('fr')));
    await tester.pumpAndSettle();

    expect(deps.profiles.completeOnboardingCalls, [
      (username: 'Camille', gender: 'woman', language: 'fr'),
    ]);
  });

  testWidgets('sends the chosen gender and language', (tester) async {
    final deps = await pumpOnboarding(tester);

    await tester.enterText(find.byType(TextField), 'Alex');
    await tester.tap(find.text(onboardingMan('fr')));
    await tester.tap(find.text(onboardingEnglish('fr')));
    await tester.pumpAndSettle();
    await tester.tap(find.text(onboardingContinue('en')));
    await tester.pumpAndSettle();

    expect(deps.profiles.completeOnboardingCalls, [
      (username: 'Alex', gender: 'man', language: 'en'),
    ]);
  });

  testWidgets('on success the profile is reloaded', (tester) async {
    final deps = await pumpOnboarding(tester);
    final container = containerOf(tester);
    // The screen itself does not watch the profile (the router does).
    container.listen(myProfileProvider, (_, _) {});
    await tester.pumpAndSettle();
    expect(
      container.read(myProfileProvider).valueOrNull?.hasCompletedOnboarding,
      isFalse,
    );
    final loadsBefore = deps.profiles.getOrCreateCalls;

    await tester.enterText(find.byType(TextField), 'Camille');
    await tester.tap(find.text(onboardingContinue('fr')));
    await tester.pumpAndSettle();

    expect(deps.profiles.getOrCreateCalls, greaterThan(loadsBefore));
    expect(
      container.read(myProfileProvider).valueOrNull?.hasCompletedOnboarding,
      isTrue,
    );
  });

  testWidgets('a failure shows its message, or the generic one', (
    tester,
  ) async {
    final deps = await pumpOnboarding(tester);
    await tester.enterText(find.byType(TextField), 'Camille');

    deps.profiles.nextFailure = const ServerFailure('Pseudo déjà pris');
    await tester.tap(find.text(onboardingContinue('fr')));
    await tester.pumpAndSettle();
    expect(find.text('Pseudo déjà pris'), findsOneWidget);

    deps.profiles.nextFailure = const ServerFailure();
    await tester.tap(find.text(onboardingContinue('fr')));
    await tester.pumpAndSettle();
    expect(find.text(onboardingErrorGeneric('fr')), findsOneWidget);
  });
}
