import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:nousdeux/core/constants/auth_strings.dart';
import 'package:nousdeux/core/errors/failures.dart';
import 'package:nousdeux/presentation/screens/auth/auth_screen.dart';

import '../../../helpers/test_app.dart';

/// Most tests cover phone sign-in, so they turn it on; the beta build keeps
/// it off (see the "phone sign-in off" group).
Future<GoRouter> _pumpAuth(
  WidgetTester tester,
  TestDeps deps, {
  bool phoneSignIn = true,
}) {
  return pumpRouter(
    tester,
    deps: deps,
    initialLocation: '/auth',
    routes: [
      screenRoute(
        '/auth',
        AuthScreen(phoneSignIn: phoneSignIn),
        routes: [stubRoute('verify')],
      ),
    ],
  );
}

void main() {
  group('phone sign-in off (the beta build)', () {
    testWidgets('is the default', (tester) async {
      expect(const AuthScreen().phoneSignIn, isFalse);
    });

    testWidgets(
      'shows only Apple and Google',
      (tester) async {
        await _pumpAuth(tester, TestDeps(user: null), phoneSignIn: false);

        expect(find.byType(TextField), findsNothing);
        expect(find.text(authSendCode('fr')), findsNothing);
        expect(find.text(authOr('fr')), findsNothing);
        expect(find.text(authContinueWithApple('fr')), findsOneWidget);
        expect(find.text(authContinueWithGoogle('fr')), findsOneWidget);
      },
      variant: TargetPlatformVariant.only(TargetPlatform.iOS),
    );

    testWidgets('a sign-in failure still shows its error', (tester) async {
      final deps = TestDeps(user: null)..auth.nextFailure = const AuthFailure();
      await _pumpAuth(tester, deps, phoneSignIn: false);

      await tester.tap(find.text(authContinueWithGoogle('fr')));
      await tester.pumpAndSettle();

      expect(deps.auth.googleCalls, 1);
      expect(find.text(authErrorGeneric('fr')), findsOneWidget);
    });

    testWidgets('shows a spinner and disables Google while signing in', (
      tester,
    ) async {
      final deps = TestDeps(user: null);
      final gate = deps.auth.gate = Completer<void>();
      await _pumpAuth(tester, deps, phoneSignIn: false);

      await tester.tap(find.text(authContinueWithGoogle('fr')));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      final google = tester.widget<OutlinedButton>(
        find.ancestor(
          of: find.text(authContinueWithGoogle('fr')),
          matching: find.byWidgetPredicate((w) => w is OutlinedButton),
        ),
      );
      expect(google.onPressed, isNull);

      gate.complete();
      await tester.pumpAndSettle();
    });
  });

  for (final lang in ['fr', 'en']) {
    testWidgets(
      '[$lang] shows the sign-in options in the device language',
      (tester) async {
        await _pumpAuth(tester, TestDeps(user: null, deviceLanguage: lang));

        expect(find.text(authSubtitle(lang)), findsOneWidget);
        expect(find.text(authPhoneLabel(lang)), findsOneWidget);
        expect(find.text(authSendCode(lang)), findsOneWidget);
        expect(find.text(authContinueWithApple(lang)), findsOneWidget);
        expect(find.text(authContinueWithGoogle(lang)), findsOneWidget);
      },
      variant: TargetPlatformVariant.only(TargetPlatform.iOS),
    );
  }

  testWidgets(
    'Android offers Google but not Apple',
    (tester) async {
      await _pumpAuth(tester, TestDeps(user: null));

      expect(find.text(authContinueWithApple('fr')), findsNothing);
      expect(find.text(authContinueWithGoogle('fr')), findsOneWidget);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.android),
  );

  testWidgets('an empty phone number shows an error and sends nothing', (
    tester,
  ) async {
    final deps = TestDeps(user: null);
    await _pumpAuth(tester, deps);

    await tester.tap(find.text(authSendCode('fr')));
    await tester.pump();

    expect(find.text(authErrorEnterPhone('fr')), findsOneWidget);
    expect(deps.auth.otpPhones, isEmpty);
  });

  testWidgets('spaces only count as empty', (tester) async {
    final deps = TestDeps(user: null, deviceLanguage: 'en');
    await _pumpAuth(tester, deps);

    await tester.enterText(find.byType(TextField), '   ');
    await tester.tap(find.text(authSendCode('en')));
    await tester.pump();

    expect(find.text(authErrorEnterPhone('en')), findsOneWidget);
    expect(deps.auth.otpPhones, isEmpty);
  });

  testWidgets(
    'a French number is normalized, sent, and opens the code screen',
    (tester) async {
      final deps = TestDeps(user: null);
      final router = await _pumpAuth(tester, deps);

      await tester.enterText(find.byType(TextField), '06 12 34 56 78');
      await tester.tap(find.text(authSendCode('fr')));
      await tester.pumpAndSettle();

      expect(deps.auth.otpPhones, ['+33612345678']);
      expect(router.state.uri.path, '/auth/verify');
      expect(router.state.extra, {'phone': '+33612345678'});
    },
  );

  testWidgets('the keyboard send action submits too', (tester) async {
    final deps = TestDeps(user: null);
    await _pumpAuth(tester, deps);

    await tester.enterText(find.byType(TextField), '+1 234 567 8900');
    await tester.testTextInput.receiveAction(TextInputAction.send);
    await tester.pumpAndSettle();

    expect(deps.auth.otpPhones, ['+12345678900']);
  });

  testWidgets('shows a spinner and disables every button while sending', (
    tester,
  ) async {
    final deps = TestDeps(user: null)..auth.gate = Completer<void>();
    await _pumpAuth(tester, deps);

    await tester.enterText(find.byType(TextField), '0612345678');
    await tester.tap(find.text(authSendCode('fr')));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text(authSendCode('fr')), findsNothing);
    for (final button in tester.widgetList<ButtonStyleButton>(
      find.byWidgetPredicate((w) => w is ButtonStyleButton),
    )) {
      expect(button.onPressed, isNull);
    }

    deps.auth.gate!.complete();
    await tester.pumpAndSettle();
    expect(deps.auth.otpPhones, ['+33612345678']);
  });

  testWidgets('a failure shows its message and stays on the screen', (
    tester,
  ) async {
    final deps = TestDeps(user: null)
      ..auth.nextFailure = const AuthFailure('Numéro invalide');
    final router = await _pumpAuth(tester, deps);

    await tester.enterText(find.byType(TextField), '0612345678');
    await tester.tap(find.text(authSendCode('fr')));
    await tester.pumpAndSettle();

    expect(find.text('Numéro invalide'), findsOneWidget);
    expect(router.state.uri.path, '/auth');
  });

  testWidgets('a failure without a message falls back to the generic error', (
    tester,
  ) async {
    final deps = TestDeps(user: null, deviceLanguage: 'en')
      ..auth.nextFailure = const UnknownFailure();
    await _pumpAuth(tester, deps);

    await tester.enterText(find.byType(TextField), '0612345678');
    await tester.tap(find.text(authSendCode('en')));
    await tester.pumpAndSettle();

    expect(find.text(authErrorGeneric('en')), findsOneWidget);
  });

  testWidgets(
    'Apple and Google buttons call their sign-in',
    (tester) async {
      final deps = TestDeps(user: null);
      await _pumpAuth(tester, deps);

      await tester.tap(find.text(authContinueWithApple('fr')));
      await tester.pumpAndSettle();
      await tester.tap(find.text(authContinueWithGoogle('fr')));
      await tester.pumpAndSettle();

      expect(deps.auth.appleCalls, 1);
      expect(deps.auth.googleCalls, 1);
      expect(deps.auth.otpPhones, isEmpty);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.iOS),
  );

  testWidgets('a social sign-in failure shows the generic error', (
    tester,
  ) async {
    final deps = TestDeps(user: null)..auth.nextFailure = const AuthFailure();
    await _pumpAuth(tester, deps);

    await tester.tap(find.text(authContinueWithGoogle('fr')));
    await tester.pumpAndSettle();

    expect(find.text(authErrorGeneric('fr')), findsOneWidget);
  });
}
