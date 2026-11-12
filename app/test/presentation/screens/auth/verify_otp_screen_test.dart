import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nousdeux/core/constants/auth_strings.dart';
import 'package:nousdeux/core/errors/failures.dart';
import 'package:nousdeux/presentation/screens/auth/verify_otp_screen.dart';

import '../../../helpers/test_app.dart';

const _phone = '+33612345678';

void main() {
  Future<TestDeps> pumpVerify(
    WidgetTester tester, {
    String phone = _phone,
    String lang = 'fr',
    TestDeps? deps,
  }) async {
    deps ??= TestDeps(user: null, deviceLanguage: lang);
    await pumpScreen(tester, VerifyOtpScreen(phone: phone), deps: deps);
    return deps;
  }

  for (final lang in ['fr', 'en']) {
    testWidgets('[$lang] tells where the code was sent', (tester) async {
      await pumpVerify(tester, lang: lang);
      expect(find.text(authVerifyTitle(lang)), findsOneWidget);
      expect(find.text(authVerifyInstructions(lang, _phone)), findsOneWidget);
      expect(find.text(authVerifyButton(lang)), findsOneWidget);
    });
  }

  testWidgets('typing the 6th digit submits on its own', (tester) async {
    final deps = await pumpVerify(tester);

    await tester.enterText(find.byType(TextField), '12345');
    await tester.pump();
    expect(deps.auth.verifyCalls, isEmpty);

    await tester.enterText(find.byType(TextField), '123456');
    await tester.pumpAndSettle();
    expect(deps.auth.verifyCalls, [(phone: _phone, token: '123456')]);
  });

  testWidgets('the field stops at 6 characters', (tester) async {
    final deps = await pumpVerify(tester);

    await tester.enterText(find.byType(TextField), '1234567');
    await tester.pumpAndSettle();

    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.controller!.text, '123456');
    expect(deps.auth.verifyCalls.single.token, '123456');
  });

  testWidgets('does not submit twice while a check is running', (tester) async {
    final deps = TestDeps(user: null)..auth.gate = Completer<void>();
    await pumpVerify(tester, deps: deps);

    await tester.enterText(find.byType(TextField), '123456');
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Editing back to 6 digits while loading does not fire again.
    await tester.enterText(find.byType(TextField), '12345');
    await tester.enterText(find.byType(TextField), '123457');
    await tester.pump();
    expect(deps.auth.verifyCalls, hasLength(1));

    deps.auth.gate!.complete();
    await tester.pumpAndSettle();
  });

  testWidgets('confirming with an empty code asks for it', (tester) async {
    final deps = await pumpVerify(tester);

    await tester.tap(find.text(authVerifyButton('fr')));
    await tester.pump();

    expect(find.text(authVerifyErrorEnterCode('fr')), findsOneWidget);
    expect(deps.auth.verifyCalls, isEmpty);
  });

  testWidgets('without a phone number it refuses to verify', (tester) async {
    final deps = await pumpVerify(tester, phone: '', lang: 'en');

    await tester.enterText(find.byType(TextField), '123456');
    await tester.pump();

    expect(find.text(authVerifyErrorEnterCode('en')), findsOneWidget);
    expect(deps.auth.verifyCalls, isEmpty);
  });

  testWidgets('the button submits a shorter code as typed', (tester) async {
    final deps = await pumpVerify(tester);

    await tester.enterText(find.byType(TextField), '1234 ');
    await tester.tap(find.text(authVerifyButton('fr')));
    await tester.pumpAndSettle();

    expect(deps.auth.verifyCalls, [(phone: _phone, token: '1234')]);
  });

  testWidgets('a wrong code shows the invalid-code message', (tester) async {
    final deps = TestDeps(user: null, deviceLanguage: 'en')
      ..auth.nextFailure = const AuthFailure();
    await pumpVerify(tester, deps: deps);

    await tester.enterText(find.byType(TextField), '000000');
    await tester.pumpAndSettle();

    expect(find.text(authVerifyErrorInvalid('en')), findsOneWidget);
  });

  testWidgets('a failure message from the server wins', (tester) async {
    final deps = TestDeps(user: null)
      ..auth.nextFailure = const AuthFailure('Token has expired');
    await pumpVerify(tester, deps: deps);

    await tester.enterText(find.byType(TextField), '000000');
    await tester.pumpAndSettle();

    expect(find.text('Token has expired'), findsOneWidget);
  });

  testWidgets('only digits reach the code field', (tester) async {
    final deps = await pumpVerify(tester);

    await tester.enterText(find.byType(TextField), ' 12a34 ');
    await tester.pump();

    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      '1234',
    );
    expect(deps.auth.verifyCalls, isEmpty);
  });
}
