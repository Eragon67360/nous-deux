import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:nousdeux/core/constants/pairing_strings.dart';
import 'package:nousdeux/core/errors/failures.dart';
import 'package:nousdeux/domain/entities/couple_entity.dart';
import 'package:nousdeux/presentation/providers/pairing_provider.dart';
import 'package:nousdeux/presentation/screens/pairing/pairing_screen.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/test_app.dart';

Future<GoRouter> _pumpPairing(
  WidgetTester tester,
  TestDeps deps, {
  List<Override> overrides = const [],
}) {
  return pumpRouter(
    tester,
    deps: deps,
    overrides: overrides,
    initialLocation: '/pairing',
    routes: [
      screenRoute(
        '/pairing',
        const PairingScreen(),
        routes: [stubRoute('join'), stubRoute('scan')],
      ),
    ],
  );
}

void main() {
  group('without a code yet', () {
    testWidgets('offers to generate one, or to join with a code or a QR', (
      tester,
    ) async {
      await _pumpPairing(tester, TestDeps());

      expect(find.text(pairingInviteTitle('fr')), findsOneWidget);
      expect(find.text(pairingIntro('fr')), findsOneWidget);
      expect(find.text(pairingGenerateCode('fr')), findsOneWidget);
      expect(find.text(pairingAlreadyHaveCode('fr')), findsOneWidget);
      expect(find.text(pairingJoinWithCode('fr')), findsOneWidget);
      expect(find.text(pairingScanQr('fr')), findsOneWidget);
      expect(find.byType(QrImageView), findsNothing);
    });

    testWidgets('generating a code shows it with its QR code', (tester) async {
      final deps = TestDeps()..pairing.generatedCode = 'XK7P2M';
      await _pumpPairing(tester, deps);

      await tester.tap(find.text(pairingGenerateCode('fr')));
      await tester.pumpAndSettle();

      expect(deps.pairing.createCalls, 1);
      expect(find.text('XK7P2M'), findsOneWidget);
      expect(find.byType(QrImageView), findsOneWidget);
      expect(find.text(pairingGenerateCode('fr')), findsNothing);
    });

    testWidgets('a failed generation shows the error and keeps the button', (
      tester,
    ) async {
      final deps = TestDeps()..pairing.nextFailure = const ServerFailure();
      await _pumpPairing(tester, deps);

      await tester.tap(find.text(pairingGenerateCode('fr')));
      await tester.pumpAndSettle();

      expect(find.text(pairingError('fr')), findsOneWidget);
      expect(find.text(pairingGenerateCode('fr')), findsOneWidget);
      expect(find.byType(QrImageView), findsNothing);
    });

    testWidgets('a failure message from the server is shown as is', (
      tester,
    ) async {
      final deps = TestDeps()
        ..pairing.nextFailure = const ServerFailure('Déjà en couple');
      await _pumpPairing(tester, deps);

      await tester.tap(find.text(pairingGenerateCode('fr')));
      await tester.pumpAndSettle();

      expect(find.text('Déjà en couple'), findsOneWidget);
    });

    testWidgets('"I have a code" and "Scan" open their screens', (
      tester,
    ) async {
      final router = await _pumpPairing(tester, TestDeps());

      await tester.tap(find.text(pairingJoinWithCode('fr')));
      await tester.pumpAndSettle();
      expect(router.state.uri.path, '/pairing/join');

      router.pop();
      await tester.pumpAndSettle();
      await tester.tap(find.text(pairingScanQr('fr')));
      await tester.pumpAndSettle();
      expect(router.state.uri.path, '/pairing/scan');
    });
  });

  testWidgets('with a pending code: QR, code and join options', (tester) async {
    await _pumpPairing(
      tester,
      TestDeps(couple: couple(user2Id: null, pairingCode: 'ABC234')),
    );

    expect(find.text(pairingScanQrPrompt('fr')), findsOneWidget);
    final qr = tester.widget<QrImageView>(find.byType(QrImageView));
    expect(qr.size, 200);
    expect(find.text(pairingOrEnterCode('fr')), findsOneWidget);
    expect(find.text('ABC234'), findsOneWidget);
    expect(find.byType(SelectableText), findsOneWidget);
    expect(find.text(pairingJoinWithCode('fr')), findsOneWidget);
    expect(find.text(pairingScanQr('fr')), findsOneWidget);
    expect(find.text(pairingGenerateCode('fr')), findsNothing);
  });

  testWidgets('already paired: says so', (tester) async {
    await _pumpPairing(tester, TestDeps(couple: couple()));

    expect(find.text(pairingAlreadyPaired('fr')), findsOneWidget);
    expect(find.byType(QrImageView), findsNothing);
  });

  testWidgets('uses the profile language over the device language', (
    tester,
  ) async {
    await _pumpPairing(
      tester,
      TestDeps(
        myProfile: profile(language: 'en'),
        deviceLanguage: 'fr',
      ),
    );

    expect(find.text(pairingInviteTitle('en')), findsOneWidget);
    expect(find.text(pairingGenerateCode('en')), findsOneWidget);
  });

  testWidgets('falls back to the device language without a profile', (
    tester,
  ) async {
    await _pumpPairing(tester, TestDeps(user: null, deviceLanguage: 'en'));

    expect(find.text(pairingInviteTitle('en')), findsOneWidget);
  });

  testWidgets('shows an error state when the couple cannot be loaded', (
    tester,
  ) async {
    await _pumpPairing(
      tester,
      TestDeps(),
      overrides: [
        myCoupleProvider.overrideWith(
          (ref) => Future<CoupleEntity?>.error(Exception('offline')),
        ),
      ],
    );

    expect(find.text(pairingError('fr')), findsOneWidget);
    expect(find.byIcon(Icons.wifi_off_outlined), findsOneWidget);
  });
}
