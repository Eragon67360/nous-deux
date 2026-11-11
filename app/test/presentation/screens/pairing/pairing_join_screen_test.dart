import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:nousdeux/core/constants/pairing_strings.dart';
import 'package:nousdeux/core/errors/failures.dart';
import 'package:nousdeux/presentation/providers/pairing_provider.dart';
import 'package:nousdeux/presentation/screens/pairing/pairing_join_screen.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/test_app.dart';

Future<GoRouter> _pumpJoin(WidgetTester tester, TestDeps deps) {
  return pumpRouter(
    tester,
    deps: deps,
    initialLocation: '/pairing/join',
    routes: [
      stubRoute(
        '/pairing',
        routes: [screenRoute('join', const PairingJoinScreen())],
      ),
      stubRoute('/main'),
    ],
  );
}

void main() {
  for (final lang in ['fr', 'en']) {
    testWidgets('[$lang] explains what to type', (tester) async {
      await _pumpJoin(tester, TestDeps(myProfile: profile(language: lang)));

      expect(find.text(pairingJoinTitle(lang)), findsOneWidget);
      expect(find.text(pairingJoinInstructions(lang)), findsOneWidget);
      expect(find.text(pairingJoinCodeLabel(lang)), findsOneWidget);
      expect(find.text(pairingJoinButton(lang)), findsOneWidget);
    });
  }

  testWidgets('an empty code asks for one and sends nothing', (tester) async {
    final deps = TestDeps();
    await _pumpJoin(tester, deps);

    await tester.tap(find.text(pairingJoinButton('fr')));
    await tester.pump();

    expect(find.text(pairingJoinErrorCode('fr')), findsOneWidget);
    expect(deps.pairing.joinCodes, isEmpty);
  });

  testWidgets('an invalid code shows the error and stays', (tester) async {
    final deps = TestDeps(myProfile: profile(language: 'en'))
      ..pairing.nextFailure = const ServerFailure();
    final router = await _pumpJoin(tester, deps);

    await tester.enterText(find.byType(TextField), 'ZZZZZZ');
    await tester.tap(find.text(pairingJoinButton('en')));
    await tester.pumpAndSettle();

    expect(find.text(pairingJoinErrorInvalid('en')), findsOneWidget);
    expect(router.state.uri.path, '/pairing/join');
  });

  for (final (problem, message) in [
    (PairingProblem.invalidCode, pairingJoinErrorInvalid),
    (PairingProblem.codeUsed, pairingJoinErrorUsed),
    (PairingProblem.ownCode, pairingJoinErrorOwnCode),
  ]) {
    testWidgets('$problem is explained in the app language', (tester) async {
      final deps = TestDeps(myProfile: profile(language: 'en'))
        ..pairing.nextFailure = PairingFailure(problem);
      await _pumpJoin(tester, deps);

      await tester.enterText(find.byType(TextField), 'ZZZZZZ');
      await tester.tap(find.text(pairingJoinButton('en')));
      await tester.pumpAndSettle();

      expect(find.text(message('en')), findsOneWidget);
    });
  }

  testWidgets('trims and uppercases the code before joining', (tester) async {
    final deps = TestDeps();
    await _pumpJoin(tester, deps);

    await tester.enterText(find.byType(TextField), ' ab2c ');
    await tester.tap(find.text(pairingJoinButton('fr')));
    await tester.pumpAndSettle();

    expect(deps.pairing.joinCodes, ['AB2C']);
  });

  testWidgets('the field stops at 6 characters', (tester) async {
    await _pumpJoin(tester, TestDeps());

    await tester.enterText(find.byType(TextField), 'ABC2345');
    await tester.pump();

    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.controller!.text, 'ABC234');
  });

  testWidgets('a valid code joins, refreshes the couple and goes home', (
    tester,
  ) async {
    final deps = TestDeps();
    final router = await _pumpJoin(tester, deps);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(PairingJoinScreen)),
    );
    container.listen(myCoupleProvider, (_, _) {});
    await tester.pumpAndSettle();
    expect(container.read(myCoupleProvider).valueOrNull, isNull);

    await tester.enterText(find.byType(TextField), 'abc234');
    await tester.tap(find.text(pairingJoinButton('fr')));
    await tester.pumpAndSettle();

    expect(deps.pairing.joinCodes, ['ABC234']);
    expect(router.state.uri.path, '/main');
    expect(container.read(myCoupleProvider).valueOrNull?.isPaired, isTrue);
  });

  testWidgets('the back arrow pops', (tester) async {
    final router = await _pumpJoin(tester, TestDeps());

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(router.state.uri.path, '/pairing');
  });
}
