import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nousdeux/core/constants/nous_strings.dart';
import 'package:nousdeux/domain/entities/ping_entity.dart';
import 'package:nousdeux/presentation/theme/app_theme.dart';
import 'package:nousdeux/presentation/widgets/ping_received.dart';

/// The real Manrope, so line widths are the ones a phone draws (the default
/// test font makes every glyph a square).
Future<void> _loadManrope() async {
  final loader = FontLoader(AppTheme.fontFamily);
  for (final weight in [
    'ExtraLight',
    'Light',
    'Regular',
    'Medium',
    'SemiBold',
  ]) {
    loader.addFont(rootBundle.load('assets/fonts/Manrope-$weight.ttf'));
  }
  await loader.load();
}

Future<void> _pump(
  WidgetTester tester, {
  required String lang,
  required PingKind kind,
  required String name,
  // An iPhone 16 Plus by default.
  Size size = const Size(430, 932),
}) async {
  tester.view.physicalSize = size * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(
        body: PingReceived(
          lang: lang,
          partnerName: name,
          kind: kind,
          onReply: (_) {},
          onDismissed: () {},
        ),
      ),
    ),
  );
  // The rings finish sliding together; the overlay stays until closed.
  await tester.pump(const Duration(seconds: 2));
}

/// Centres of the two 260-point rings, in global coordinates.
List<Offset> _ringCentres(WidgetTester tester) {
  final rings = find.byWidgetPredicate(
    (w) =>
        w is Container &&
        w.constraints == BoxConstraints.tight(const Size(260, 260)),
  );
  expect(rings, findsNWidgets(2));
  return [
    for (final e in rings.evaluate())
      tester.getRect(find.byWidget(e.widget)).center,
  ];
}

/// Every corner of every line of the title, in global coordinates.
List<Offset> _titleLineCorners(WidgetTester tester, String title) {
  final paragraph = tester.renderObject<RenderParagraph>(find.text(title));
  final origin = paragraph.localToGlobal(Offset.zero);
  final boxes = paragraph.getBoxesForSelection(
    TextSelection(baseOffset: 0, extentOffset: title.length),
  );
  expect(boxes, isNotEmpty);
  return [
    for (final b in boxes) ...[
      origin + Offset(b.left, b.top),
      origin + Offset(b.right, b.top),
      origin + Offset(b.left, b.bottom),
      origin + Offset(b.right, b.bottom),
    ],
  ];
}

void main() {
  setUpAll(_loadManrope);

  // Inside both rings, a few points clear of their 1.5-point stroke.
  const inner = 130 - 1.5 - 4;

  for (final lang in ['fr', 'en']) {
    for (final name in ['Camille', 'Marie-Charlotte']) {
      for (final kind in PingKind.values) {
        testWidgets('[$lang] "${pingReceivedTitle(lang, kind, name)}" stays '
            'inside the rings', (tester) async {
          await _pump(tester, lang: lang, kind: kind, name: name);
          final title = pingReceivedTitle(lang, kind, name);
          final centres = _ringCentres(tester);
          for (final corner in _titleLineCorners(tester, title)) {
            for (final c in centres) {
              final d = sqrt(
                pow(corner.dx - c.dx, 2) + pow(corner.dy - c.dy, 2),
              );
              expect(
                d,
                lessThanOrEqualTo(inner),
                reason: '$corner is ${d.toStringAsFixed(1)} from a ring centre',
              );
            }
          }
          // Never cut short.
          expect(
            tester
                .renderObject<RenderParagraph>(find.text(title))
                .didExceedMaxLines,
            isFalse,
          );
        });
      }
    }
  }

  for (final width in [360.0, 320.0]) {
    testWidgets('on a phone ${width.toInt()} points wide, the rings, the dot '
        'and the note share one centre and fit on screen', (tester) async {
      await _pump(
        tester,
        lang: 'fr',
        kind: PingKind.kiss,
        name: 'Evah',
        size: Size(width, 780),
      );
      final title = pingReceivedTitle('fr', PingKind.kiss, 'Evah');
      final centres = _ringCentres(tester);
      final ringsMid = (centres[0].dx + centres[1].dx) / 2;
      final dot = tester.getRect(
        find.byWidgetPredicate(
          (w) =>
              w is Container &&
              w.constraints == BoxConstraints.tight(const Size(18, 18)),
        ),
      );
      expect(ringsMid, moreOrLessEquals(width / 2, epsilon: 0.5));
      expect(dot.center.dx, moreOrLessEquals(width / 2, epsilon: 0.5));
      expect(
        tester.getCenter(find.text(title)).dx,
        moreOrLessEquals(width / 2, epsilon: 0.5),
      );
      // Both rings drawn whole: the frame holding them is on screen.
      for (final e
          in find
              .byWidgetPredicate(
                (w) =>
                    w is Container &&
                    w.constraints == BoxConstraints.tight(const Size(260, 260)),
              )
              .evaluate()) {
        final ring = tester.getRect(find.byWidget(e.widget));
        expect(ring.left, greaterThanOrEqualTo(0));
        expect(ring.right, lessThanOrEqualTo(width));
      }
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('a short title keeps the full 26-point size', (tester) async {
    await _pump(tester, lang: 'fr', kind: PingKind.onMyWay, name: 'Léo');
    final text = tester.widget<Text>(
      find.text(pingReceivedTitle('fr', PingKind.onMyWay, 'Léo')),
    );
    expect(text.style?.fontSize, 26);
  });
}
