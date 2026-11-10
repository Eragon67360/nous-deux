import 'package:flutter/material.dart';

import 'package:nousdeux/presentation/theme/app_motion.dart';
import 'package:nousdeux/presentation/theme/app_theme.dart';

/// The Nous Deux mark: two rings that drift in from either side and lock
/// together, with a small dot where they overlap.
///
/// The same motion is the website's signature move, so the app and the site
/// tell the same story. [progress] runs from 0 (apart, invisible) to 1
/// (locked, dot shown).
class MergingRings extends StatelessWidget {
  const MergingRings({super.key, required this.size, this.progress = 1});

  /// Shared [Hero] tag so the mark travels from the splash into the next screen.
  static const heroTag = 'nous-deux-rings';

  final double size;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: size,
      height: size * 0.62,
      child: CustomPaint(
        painter: _RingsPainter(
          progress: progress.clamp(0, 1),
          left: scheme.primary,
          right: scheme.onSurface,
          dot: CoupleColors.of(context).partner,
        ),
      ),
    );
  }
}

/// Plays [MergingRings] once. Fires [onMerged] when the rings lock (a good
/// moment for a haptic) and [onCompleted] when the dot has landed.
/// Under reduced motion it shows the final state and fires both callbacks.
class AnimatedMergingRings extends StatefulWidget {
  const AnimatedMergingRings({
    super.key,
    required this.size,
    this.duration = AppMotion.signature,
    this.onMerged,
    this.onCompleted,
  });

  final double size;
  final Duration duration;
  final VoidCallback? onMerged;
  final VoidCallback? onCompleted;

  @override
  State<AnimatedMergingRings> createState() => _AnimatedMergingRingsState();
}

class _AnimatedMergingRingsState extends State<AnimatedMergingRings>
    with SingleTickerProviderStateMixin {
  static const double _lockPoint = 0.72;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );
  bool _merged = false;
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (AppMotion.reduced(context)) {
      _controller.value = 1;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        widget.onMerged?.call();
        widget.onCompleted?.call();
      });
      return;
    }
    _controller
      ..addListener(_maybeMerged)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) widget.onCompleted?.call();
      })
      ..forward();
  }

  void _maybeMerged() {
    if (_merged || _controller.value < _lockPoint) return;
    _merged = true;
    widget.onMerged?.call();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) =>
          MergingRings(size: widget.size, progress: _controller.value),
    );
  }
}

class _RingsPainter extends CustomPainter {
  _RingsPainter({
    required this.progress,
    required this.left,
    required this.right,
    required this.dot,
  });

  final double progress;
  final Color left;
  final Color right;
  final Color dot;

  static const double _lockPoint = 0.72;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.height * 0.42;
    final stroke = (size.height * 0.055).clamp(2.0, 6.0);
    final center = size.center(Offset.zero);
    final lockedGap = radius * 0.78;

    // Travel: 0 → lockPoint, emphasized ease so the rings settle, not snap.
    final travel = AppMotion.emphasized.transform(
      (progress / _lockPoint).clamp(0.0, 1.0),
    );
    final apart = size.width * 0.5;
    final gap = lockedGap + (apart - lockedGap) * (1 - travel);
    final fade = Curves.easeOut.transform((progress / 0.3).clamp(0.0, 1.0));

    // A tiny "click" once they lock.
    final settle = ((progress - _lockPoint) / (1 - _lockPoint)).clamp(0.0, 1.0);
    final click = 1 + 0.04 * (1 - Curves.easeOut.transform(settle)) *
        (settle > 0 ? 1 : 0);

    Paint ring(Color c) => Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..isAntiAlias = true
      ..color = c.withValues(alpha: c.a * fade);

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(click);
    canvas.drawCircle(Offset(-gap / 2, 0), radius, ring(left));
    canvas.drawCircle(Offset(gap / 2, 0), radius, ring(right));

    if (settle > 0) {
      final dotScale = Curves.easeOutBack.transform(settle);
      canvas.drawCircle(
        Offset.zero,
        stroke * 1.6 * dotScale,
        Paint()..color = dot,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_RingsPainter old) =>
      old.progress != progress ||
      old.left != left ||
      old.right != right ||
      old.dot != dot;
}
