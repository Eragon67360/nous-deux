import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nousdeux/presentation/theme/app_motion.dart';
import 'package:nousdeux/presentation/widgets/merging_rings.dart';

import '../../helpers/test_app.dart';

double _progress(WidgetTester tester) =>
    tester.widget<MergingRings>(find.byType(MergingRings)).progress;

void main() {
  group('MergingRings', () {
    testWidgets('is size wide and 0.62 x size tall', (tester) async {
      await pumpScreen(tester, const Center(child: MergingRings(size: 100)));
      expect(tester.getSize(find.byType(MergingRings)), const Size(100, 62));
    });

    testWidgets('paints at any progress, including out of range', (
      tester,
    ) async {
      for (final p in [-1.0, 0.0, 0.5, 0.72, 0.9, 1.0, 2.0]) {
        await pumpScreen(
          tester,
          Center(child: MergingRings(size: 120, progress: p)),
        );
        expect(tester.takeException(), isNull, reason: 'progress $p');
      }
    });
  });

  group('AnimatedMergingRings', () {
    testWidgets('fires onMerged at the lock point, then onCompleted', (
      tester,
    ) async {
      final events = <String>[];
      await pumpScreen(
        tester,
        Center(
          child: AnimatedMergingRings(
            size: 120,
            duration: const Duration(milliseconds: 1000),
            onMerged: () => events.add('merged'),
            onCompleted: () => events.add('completed'),
          ),
        ),
        reducedMotion: false,
        settle: false,
      );

      expect(_progress(tester), 0);
      await tester.pump(); // first tick
      await tester.pump(const Duration(milliseconds: 700));
      expect(events, isEmpty, reason: 'rings lock at 72%');

      await tester.pump(const Duration(milliseconds: 40));
      expect(events, ['merged']);

      await tester.pump(const Duration(milliseconds: 300));
      expect(events, ['merged', 'completed']);
      expect(_progress(tester), 1);

      await tester.pumpAndSettle();
      expect(events, ['merged', 'completed'], reason: 'each fires once');
    });

    testWidgets('uses the signature duration by default', (tester) async {
      var completed = false;
      await pumpScreen(
        tester,
        Center(
          child: AnimatedMergingRings(
            size: 120,
            onCompleted: () => completed = true,
          ),
        ),
        reducedMotion: false,
        settle: false,
      );

      await tester.pump(); // first tick
      await tester.pump(AppMotion.signature - const Duration(milliseconds: 50));
      expect(completed, isFalse);
      await tester.pump(const Duration(milliseconds: 60));
      expect(completed, isTrue);
    });

    testWidgets(
      'reduced motion: shows the final state and fires both after the first frame',
      (tester) async {
        final events = <String>[];
        await pumpScreen(
          tester,
          Center(
            child: AnimatedMergingRings(
              size: 120,
              onMerged: () => events.add('merged'),
              onCompleted: () => events.add('completed'),
            ),
          ),
          settle: false,
        );

        expect(_progress(tester), 1);
        // Post-frame callbacks have run by the end of pumpWidget.
        expect(events, ['merged', 'completed']);

        await tester.pump(AppMotion.signature);
        expect(events, ['merged', 'completed']);
      },
    );

    testWidgets('callbacks are optional', (tester) async {
      await pumpScreen(
        tester,
        const Center(child: AnimatedMergingRings(size: 80)),
        reducedMotion: false,
      );
      expect(_progress(tester), 1);
    });
  });
}
