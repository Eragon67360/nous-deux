import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nousdeux/core/constants/app_strings.dart';
import 'package:nousdeux/presentation/theme/app_motion.dart';
import 'package:nousdeux/presentation/widgets/pairing_celebration.dart';

import '../../helpers/test_app.dart';

double _wordsOpacity(WidgetTester tester, String lang) {
  return tester
      .widget<AnimatedOpacity>(
        find.ancestor(
          of: find.text(pairingCelebrationTitle(lang)),
          matching: find.byType(AnimatedOpacity),
        ),
      )
      .opacity;
}

void main() {
  for (final lang in ['fr', 'en']) {
    testWidgets('[$lang] shows the localized title and body', (tester) async {
      await pumpScreen(
        tester,
        PairingCelebration(lang: lang, onDismissed: () {}),
        settle: false,
      );
      await tester.pump();
      expect(find.text(pairingCelebrationTitle(lang)), findsOneWidget);
      expect(find.text(pairingCelebrationBody(lang)), findsOneWidget);
      // Leave via tap so no timer outlives the test.
      await tester.tap(find.byType(PairingCelebration));
      await tester.pumpAndSettle();
    });
  }

  testWidgets(
    'tapping dismisses after the fade-out and calls onDismissed once',
    (tester) async {
      var dismissed = 0;
      await pumpScreen(
        tester,
        PairingCelebration(lang: 'fr', onDismissed: () => dismissed++),
      );

      await tester.tap(find.byType(PairingCelebration));
      await tester.pump(); // reverse starts
      expect(dismissed, 0, reason: 'waits for the fade-out');
      // A second tap while leaving is ignored.
      await tester.tap(find.byType(PairingCelebration), warnIfMissed: false);
      await tester.pump(AppMotion.medium);
      await tester.pumpAndSettle();
      expect(dismissed, 1);

      // The auto-dismiss timer was cancelled.
      await tester.pump(const Duration(seconds: 4));
      expect(dismissed, 1);
    },
  );

  testWidgets('leaves on its own after 3.6 s', (tester) async {
    var dismissed = 0;
    await pumpScreen(
      tester,
      PairingCelebration(lang: 'fr', onDismissed: () => dismissed++),
      settle: false,
    );

    await tester.pump(const Duration(milliseconds: 3500));
    expect(dismissed, 0);
    await tester.pump(const Duration(milliseconds: 100)); // 3.6 s: timer fires
    expect(dismissed, 0, reason: 'fades out first');
    await tester.pumpAndSettle();
    expect(dismissed, 1);
  });

  testWidgets('animated: words appear once the rings lock', (tester) async {
    await pumpScreen(
      tester,
      PairingCelebration(lang: 'en', onDismissed: () {}),
      reducedMotion: false,
      settle: false,
    );

    expect(_wordsOpacity(tester, 'en'), 0);
    await tester.pump(); // first tick of the rings
    await tester.pump(const Duration(milliseconds: 900)); // before 72% of 1.4 s
    expect(_wordsOpacity(tester, 'en'), 0);
    await tester.pump(const Duration(milliseconds: 200));
    expect(_wordsOpacity(tester, 'en'), 1);

    await tester.tap(find.byType(PairingCelebration));
    await tester.pumpAndSettle();
  });

  testWidgets('reduced motion: words are shown right after the first frame', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      PairingCelebration(lang: 'fr', onDismissed: () {}),
      settle: false,
    );
    await tester.pump();
    expect(_wordsOpacity(tester, 'fr'), 1);

    await tester.tap(find.byType(PairingCelebration));
    await tester.pumpAndSettle();
  });
}
