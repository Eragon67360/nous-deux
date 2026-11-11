import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nousdeux/core/constants/app_spacing.dart';
import 'package:nousdeux/core/constants/app_strings.dart';
import 'package:nousdeux/core/utils/app_log.dart';
import 'package:nousdeux/presentation/providers/locale_provider.dart';
import 'package:nousdeux/presentation/providers/splash_provider.dart';
import 'package:nousdeux/presentation/theme/app_motion.dart';
import 'package:nousdeux/presentation/widgets/merging_rings.dart';

/// Opening screen: the two rings drift in and lock, then the name settles in.
/// The router waits for [splashAnimationCompleteProvider] before moving on.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _textController = AnimationController(
    vsync: this,
    duration: AppMotion.slow,
  );
  late final Animation<double> _textFade = CurvedAnimation(
    parent: _textController,
    curve: AppMotion.enter,
  );
  late final Animation<Offset> _textSlide = Tween<Offset>(
    begin: const Offset(0, 0.25),
    end: Offset.zero,
  ).animate(_textFade);

  @override
  void initState() {
    super.initState();
    appLog('SPLASH', message: 'initState (splash mounted)', color: '\x1B[35m');
    // No reset of splashAnimationCompleteProvider here: it starts false, and
    // writing a provider during a build throws. The router is created once,
    // so the splash only mounts at launch.
    _textController.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        ref.read(splashAnimationCompleteProvider.notifier).state = true;
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _onRingsMerged() {
    if (!mounted) return;
    if (AppMotion.reduced(context)) {
      _textController.value = 1;
      ref.read(splashAnimationCompleteProvider.notifier).state = true;
      return;
    }
    _textController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final lang = ref.watch(deviceLanguageProvider);

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.15),
            radius: 0.9,
            colors: [
              Color.alphaBlend(
                scheme.primary.withValues(alpha: 0.10),
                scheme.surface,
              ),
              scheme.surface,
            ],
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Hero(
                    tag: MergingRings.heroTag,
                    child: AnimatedMergingRings(
                      size: 132,
                      onMerged: _onRingsMerged,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SlideTransition(
                    position: _textSlide,
                    child: FadeTransition(
                      opacity: _textFade,
                      child: Column(
                        children: [
                          Text(
                            appName(lang),
                            style: theme.textTheme.displaySmall,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            splashTagline(lang),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: AppSpacing.xl,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _textFade,
                child: Center(
                  child: _PulsingDots(color: scheme.onSurfaceVariant),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Three dots breathing in a wave while the app finishes loading.
class _PulsingDots extends StatefulWidget {
  const _PulsingDots({required this.color});

  final Color color;

  @override
  State<_PulsingDots> createState() => _PulsingDotsState();
}

class _PulsingDotsState extends State<_PulsingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (AppMotion.reduced(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(3, (index) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final wave = math.sin(
                (_controller.value * 2 * math.pi) - index * 1.0,
              );
              final t = 0.5 * wave + 0.5;
              return Opacity(
                opacity: 0.35 + 0.5 * t,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: widget.color,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
