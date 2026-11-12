import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nousdeux/core/config/app_config.dart';
import 'package:nousdeux/core/utils/app_router.dart';
import 'package:nousdeux/presentation/providers/profile_provider.dart';
import 'package:nousdeux/presentation/screens/auth/auth_screen.dart';
import 'package:nousdeux/presentation/screens/main/main_shell_screen.dart';
import 'package:nousdeux/presentation/screens/onboarding/onboarding_screen.dart';
import 'package:nousdeux/presentation/screens/settings/settings_screen.dart';
import 'package:nousdeux/presentation/screens/splash/splash_screen.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/test_app.dart';

// The app's router mounted the way main.dart mounts it: one MaterialApp.router
// fed by appRouterProvider. These tests follow the router across auth and
// profile changes, which the redirect tests (app_router_test.dart) can't see.

Future<ProviderContainer> _pumpApp(WidgetTester tester, TestDeps deps) async {
  final container = ProviderContainer(overrides: deps.overrides);
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: Consumer(
        builder: (context, ref, _) => MaterialApp.router(
          theme: testTheme,
          locale: const Locale('fr'),
          supportedLocales: const [Locale('fr'), Locale('en')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          routerConfig: ref.watch(appRouterProvider),
          // Reduced motion: the splash releases the router on its first frame.
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: true),
            child: child!,
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

void main() {
  final supabaseSkip = AppConfig.isSupabaseConfigured
      ? false
      : 'The router only redirects with Supabase configured.';

  group('app router across profile changes', skip: supabaseSkip, () {
    testWidgets(
      'finishing onboarding opens the app without going back through the splash',
      (tester) async {
        final deps = TestDeps(myProfile: profile(onboarded: false));
        final container = await _pumpApp(tester, deps);
        expect(find.byType(OnboardingScreen), findsOneWidget);

        // What the onboarding screen does once the form is saved.
        await deps.profiles.completeOnboarding(
          username: 'Camille',
          gender: 'woman',
          language: 'fr',
        );
        container.invalidate(myProfileProvider);
        await tester.pump();
        expect(find.byType(SplashScreen), findsNothing);
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.byType(MainShellScreen), findsOneWidget);
      },
    );

    testWidgets('a profile change keeps you where you are', (tester) async {
      final deps = TestDeps();
      final container = await _pumpApp(tester, deps);
      container.read(appRouterProvider).go('/settings');
      // Settings keeps an indicator spinning, so time is advanced by hand.
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(SettingsScreen), findsOneWidget);

      // Saving a new name in Settings reloads the profile like this.
      container.invalidate(myProfileProvider);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(tester.takeException(), isNull);
      expect(find.byType(SettingsScreen), findsOneWidget);
      expect(find.byType(SplashScreen), findsNothing);
    });

    testWidgets('signing in from the sign-in screen opens the app', (
      tester,
    ) async {
      final deps = TestDeps(user: null);
      await _pumpApp(tester, deps);
      expect(find.byType(AuthScreen), findsOneWidget);

      deps.auth.emit(me);
      await tester.pumpAndSettle();

      // The profile still says "nobody" for an instant after the session
      // arrives; that must not read as "signed in without a profile".
      expect(deps.auth.signOutCalls, 0);
      expect(find.byType(MainShellScreen), findsOneWidget);
    });

    testWidgets('signing out returns to the sign-in screen', (tester) async {
      final deps = TestDeps();
      await _pumpApp(tester, deps);
      expect(find.byType(MainShellScreen), findsOneWidget);

      deps.auth.emit(null);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(AuthScreen), findsOneWidget);
    });
  });
}
