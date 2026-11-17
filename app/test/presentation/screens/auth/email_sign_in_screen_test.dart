import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nousdeux/core/constants/auth_strings.dart';
import 'package:nousdeux/core/errors/failures.dart';
import 'package:nousdeux/core/l10n/app_languages.dart';
import 'package:nousdeux/presentation/screens/auth/email_sign_in_screen.dart';

import '../../../helpers/test_app.dart';

Future<void> _pump(WidgetTester tester, TestDeps deps) async {
  await pumpRouter(
    tester,
    deps: deps,
    initialLocation: '/auth/email',
    routes: [screenRoute('/auth/email', const EmailSignInScreen())],
  );
}

Finder get _email => find.byType(TextField).at(0);
Finder get _password => find.byType(TextField).at(1);

void main() {
  for (final lang in AppLanguages.supported) {
    testWidgets('[$lang] shows the form in the device language', (
      tester,
    ) async {
      await _pump(tester, TestDeps(user: null, deviceLanguage: lang));

      expect(find.text(authEmailTitle(lang)), findsOneWidget);
      expect(find.text(authEmailIntro(lang)), findsOneWidget);
      expect(find.text(authEmailLabel(lang)), findsOneWidget);
      expect(find.text(authPasswordLabel(lang)), findsOneWidget);
      expect(find.text(authEmailButton(lang)), findsOneWidget);
    });
  }

  testWidgets('the password is hidden', (tester) async {
    await _pump(tester, TestDeps(user: null));

    expect(tester.widget<TextField>(_password).obscureText, isTrue);
  });

  testWidgets('a missing field shows an error and signs in nobody', (
    tester,
  ) async {
    final deps = TestDeps(user: null);
    await _pump(tester, deps);

    await tester.enterText(_email, 'review1@nous-deux.app');
    await tester.tap(find.text(authEmailButton('fr')));
    await tester.pump();

    expect(find.text(authEmailErrorEmpty('fr')), findsOneWidget);
    expect(deps.auth.emailSignIns, isEmpty);
  });

  testWidgets('sends the trimmed email and the password as typed', (
    tester,
  ) async {
    final deps = TestDeps(user: null);
    await _pump(tester, deps);

    await tester.enterText(_email, '  review1@nous-deux.app ');
    await tester.enterText(_password, ' pass word ');
    await tester.tap(find.text(authEmailButton('fr')));
    await tester.pumpAndSettle();

    expect(deps.auth.emailSignIns, [
      (email: 'review1@nous-deux.app', password: ' pass word '),
    ]);
    expect(find.text(authEmailErrorWrong('fr')), findsNothing);
  });

  testWidgets('the keyboard done action on the password submits', (
    tester,
  ) async {
    final deps = TestDeps(user: null);
    await _pump(tester, deps);

    await tester.enterText(_email, 'review1@nous-deux.app');
    await tester.enterText(_password, 'secret');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(deps.auth.emailSignIns, hasLength(1));
  });

  testWidgets('a wrong pair says so in the device language', (tester) async {
    final deps = TestDeps(user: null, deviceLanguage: 'en')
      ..auth.nextFailure = const WrongCredentialsFailure();
    await _pump(tester, deps);

    await tester.enterText(_email, 'review1@nous-deux.app');
    await tester.enterText(_password, 'nope');
    await tester.tap(find.text(authEmailButton('en')));
    await tester.pumpAndSettle();

    expect(find.text(authEmailErrorWrong('en')), findsOneWidget);
  });

  testWidgets('any other failure shows the generic error, not the server '
      'message', (tester) async {
    final deps = TestDeps(user: null)
      ..auth.nextFailure = const AuthFailure('Request rate limit reached');
    await _pump(tester, deps);

    await tester.enterText(_email, 'review1@nous-deux.app');
    await tester.enterText(_password, 'secret');
    await tester.tap(find.text(authEmailButton('fr')));
    await tester.pumpAndSettle();

    expect(find.text(authErrorGeneric('fr')), findsOneWidget);
    expect(find.text('Request rate limit reached'), findsNothing);
  });

  testWidgets('shows a spinner and disables the button while signing in', (
    tester,
  ) async {
    final deps = TestDeps(user: null);
    final gate = deps.auth.gate = Completer<void>();
    await _pump(tester, deps);

    await tester.enterText(_email, 'review1@nous-deux.app');
    await tester.enterText(_password, 'secret');
    await tester.tap(find.text(authEmailButton('fr')));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNull);

    gate.complete();
    await tester.pumpAndSettle();
    expect(find.text(authEmailButton('fr')), findsOneWidget);
  });
}
