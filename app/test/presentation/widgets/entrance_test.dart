import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nousdeux/presentation/theme/app_motion.dart';
import 'package:nousdeux/presentation/widgets/entrance.dart';

import '../../helpers/test_app.dart';

double _opacityAbove(WidgetTester tester, Finder child) {
  final opacity = tester.widget<Opacity>(
    find.ancestor(of: child, matching: find.byType(Opacity)).first,
  );
  return opacity.opacity;
}

Offset _translationAbove(WidgetTester tester, Finder child) {
  final transform = tester.widget<Transform>(
    find.ancestor(of: child, matching: find.byType(Transform)).first,
  );
  final t = transform.transform.getTranslation();
  return Offset(t.x, t.y);
}

void main() {
  final child = find.text('Bonjour');

  testWidgets('reduced motion: child is fully visible on the first frame', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      const Entrance(delay: Duration(seconds: 5), child: Text('Bonjour')),
      settle: false,
    );

    expect(_opacityAbove(tester, child), 1);
    expect(_translationAbove(tester, child), Offset.zero);
  });

  testWidgets('animated: starts hidden and offset, then fades and rises in', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      const Entrance(child: Text('Bonjour')),
      reducedMotion: false,
      settle: false,
    );

    expect(_opacityAbove(tester, child), 0);
    expect(_translationAbove(tester, child), const Offset(0, 12));

    await tester.pump(Duration.zero); // zero-delay timer starts the fade
    await tester.pump(AppMotion.slow ~/ 2);
    final mid = _opacityAbove(tester, child);
    expect(mid, inExclusiveRange(0, 1));

    await tester.pumpAndSettle();
    expect(_opacityAbove(tester, child), 1);
    expect(_translationAbove(tester, child), Offset.zero);
  });

  testWidgets('animated: waits for the delay before starting', (tester) async {
    await pumpScreen(
      tester,
      const Entrance(
        delay: Duration(milliseconds: 200),
        offset: 20,
        child: Text('Bonjour'),
      ),
      reducedMotion: false,
      settle: false,
    );

    await tester.pump(const Duration(milliseconds: 150));
    expect(_opacityAbove(tester, child), 0);
    expect(_translationAbove(tester, child), const Offset(0, 20));

    await tester.pump(const Duration(milliseconds: 100)); // delay elapsed
    await tester.pump(const Duration(milliseconds: 100));
    expect(_opacityAbove(tester, child), greaterThan(0));

    await tester.pumpAndSettle();
    expect(_opacityAbove(tester, child), 1);
  });
}
