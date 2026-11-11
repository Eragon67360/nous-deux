import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nousdeux/core/constants/app_strings.dart';
import 'package:nousdeux/presentation/providers/splash_provider.dart';
import 'package:nousdeux/presentation/screens/splash/splash_screen.dart';
import 'package:nousdeux/presentation/theme/app_motion.dart';
import 'package:nousdeux/presentation/widgets/merging_rings.dart';

import '../../../helpers/test_app.dart';

bool _splashDone(WidgetTester tester) =>
    containerOf(tester).read(splashAnimationCompleteProvider);

double _taglineOpacity(WidgetTester tester, String lang) => tester
    .widget<FadeTransition>(
      find
          .ancestor(
            of: find.text(splashTagline(lang)),
            matching: find.byType(FadeTransition),
          )
          .first,
    )
    .opacity
    .value;

void main() {
  for (final lang in ['fr', 'en']) {
    testWidgets('[$lang] shows the name, the tagline and the rings', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        const SplashScreen(),
        deps: TestDeps(user: null, deviceLanguage: lang),
      );

      expect(find.text(appName(lang)), findsOneWidget);
      expect(find.text(splashTagline(lang)), findsOneWidget);
      expect(find.byType(AnimatedMergingRings), findsOneWidget);
    });
  }

  testWidgets('reduced motion: text shown and router released right away', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      const SplashScreen(),
      deps: TestDeps(user: null),
      settle: false,
    );

    expect(_splashDone(tester), isTrue);
    expect(_taglineOpacity(tester, 'fr'), 1);
  });

  testWidgets(
    'animated: the router waits until the rings lock and the text settles',
    (tester) async {
      await pumpScreen(
        tester,
        const SplashScreen(),
        deps: TestDeps(user: null),
        reducedMotion: false,
        settle: false,
      );

      expect(_splashDone(tester), isFalse);
      expect(_taglineOpacity(tester, 'fr'), 0);

      await tester.pump(); // first tick of the rings
      await tester.pump(const Duration(milliseconds: 1000)); // 71%: not locked
      expect(_taglineOpacity(tester, 'fr'), 0);
      expect(_splashDone(tester), isFalse);

      await tester.pump(const Duration(milliseconds: 100)); // locked
      await tester.pump(AppMotion.slow ~/ 2);
      expect(_taglineOpacity(tester, 'fr'), inExclusiveRange(0, 1));
      expect(_splashDone(tester), isFalse);

      await tester.pump(AppMotion.slow);
      expect(_taglineOpacity(tester, 'fr'), 1);
      expect(_splashDone(tester), isTrue);

      // The loading dots repeat forever; unmount instead of settling.
      await tester.pumpWidget(const SizedBox());
    },
  );
}
