import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:nousdeux/presentation/theme/app_theme.dart';

/// The cycle as a ring: period days in wine, the current phase a shade
/// lighter than the track, a gold dot on today. [child] sits in the middle.
class CycleRing extends StatelessWidget {
  const CycleRing({
    super.key,
    required this.day,
    required this.cycleLength,
    required this.periodLength,
    required this.phaseStart,
    required this.phaseEnd,
    required this.semanticsLabel,
    required this.child,
    this.size = 150,
  });

  final int day;
  final int cycleLength;
  final int periodLength;

  /// First and last day of the current phase, highlighted on the track.
  final int phaseStart;
  final int phaseEnd;
  final String semanticsLabel;
  final Widget child;
  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: semanticsLabel,
      image: true,
      child: SizedBox.square(
        dimension: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: Size.square(size),
              painter: _RingPainter(
                day: day,
                cycleLength: cycleLength,
                periodLength: periodLength,
                phaseStart: phaseStart,
                phaseEnd: phaseEnd,
                track: scheme.surfaceContainerHigh,
                phase: scheme.primaryContainer,
                period: CoupleColors.of(context).mine,
                marker: scheme.primary,
                ground: scheme.surface,
              ),
            ),
            ExcludeSemantics(child: child),
          ],
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.day,
    required this.cycleLength,
    required this.periodLength,
    required this.phaseStart,
    required this.phaseEnd,
    required this.track,
    required this.phase,
    required this.period,
    required this.marker,
    required this.ground,
  });

  final int day, cycleLength, periodLength, phaseStart, phaseEnd;
  final Color track, phase, period, marker, ground;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.07;
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - stroke;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final perDay = 2 * math.pi / cycleLength;
    const top = -math.pi / 2;
    Paint line(Color c) => Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = c;

    canvas.drawCircle(center, radius, line(track));
    if (phaseEnd >= phaseStart) {
      canvas.drawArc(
        rect,
        top + (phaseStart - 1) * perDay,
        (phaseEnd - phaseStart + 1) * perDay,
        false,
        line(phase),
      );
    }
    canvas.drawArc(rect, top, periodLength * perDay, false, line(period));

    // Today, at the middle of its day; a late cycle stays on the last day.
    final position = (math.min(day, cycleLength) - 0.5) * perDay + top;
    final dot =
        center + Offset(math.cos(position), math.sin(position)) * radius;
    canvas.drawCircle(dot, stroke * 0.85, Paint()..color = ground);
    canvas.drawCircle(dot, stroke * 0.6, Paint()..color = marker);
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.day != day ||
      old.cycleLength != cycleLength ||
      old.periodLength != periodLength ||
      old.phaseStart != phaseStart ||
      old.phaseEnd != phaseEnd ||
      old.marker != marker;
}
