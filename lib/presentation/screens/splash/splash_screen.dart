import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;

import 'package:nousdeux/core/constants/app_spacing.dart';
import 'package:nousdeux/core/constants/app_strings.dart';
import 'package:nousdeux/core/utils/app_log.dart';
import 'package:nousdeux/presentation/providers/locale_provider.dart';
import 'package:nousdeux/presentation/providers/splash_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _mainController;
  late final AnimationController _pulseController;

  // Staggered Animations
  late final Animation<double> _logoScaleAnimation;
  late final Animation<double> _logoRotateAnimation;
  late final Animation<Offset> _textSlideAnimation;
  late final Animation<double> _textFadeAnimation;
  late final Animation<double> _loaderFadeAnimation;

  @override
  void initState() {
    super.initState();
    appLog('SPLASH', message: 'initState (splash mounted)', color: '\x1B[35m');

    ref.read(splashAnimationCompleteProvider.notifier).state = false;

    // 1. Main Entrance Controller (2 seconds)
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // 2. Continuous Background Pulse Controller
    _pulseController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    // --- Definitions ---

    // Logo: Elastic pop effect
    _logoScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    // Logo: Slight rotation for dynamism
    _logoRotateAnimation = Tween<double>(begin: -0.2, end: 0.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    // Text: Slide up and Fade in
    _textSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _mainController,
            curve: const Interval(0.4, 0.8, curve: Curves.easeOutCubic),
          ),
        );

    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.4, 0.7, curve: Curves.easeIn),
      ),
    );

    // Loader: Fade in last
    _loaderFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.7, 1.0, curve: Curves.easeIn),
      ),
    );

    _mainController.forward();
    _mainController.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        ref.read(splashAnimationCompleteProvider.notifier).state = true;
      }
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    appLog('SPLASH', message: 'build', color: '\x1B[35m');

    final colorScheme = Theme.of(context).colorScheme;
    final lang = ref.watch(deviceLanguageProvider);

    return Scaffold(
      body: Stack(
        children: [
          // 1. Animated Gradient Background (app theme colors)
          _AnimatedBackground(
            controller: _pulseController,
            color1: colorScheme.surface,
            color2: colorScheme.primary,
          ),

          // 2. Main Content centered
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated Logo
                AnimatedBuilder(
                  animation: _mainController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _logoScaleAnimation.value,
                      child: Transform.rotate(
                        angle: _logoRotateAnimation.value,
                        child: _InterlockingLogo(
                          size: 100,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: AppSpacing.lg),

                // Animated Text
                SlideTransition(
                  position: _textSlideAnimation,
                  child: FadeTransition(
                    opacity: _textFadeAnimation,
                    child: Column(
                      children: [
                        Text(
                          appName(lang),
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w300,
                            letterSpacing: 1.5,
                            fontFamily: 'Didot',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          splashTagline(lang),
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontStyle: FontStyle.italic,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 3. Footer Loader
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _loaderFadeAnimation,
              child: Center(
                child: _PulsingDots(color: colorScheme.onSurfaceVariant),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// SUB-WIDGETS (Design Elements)
// ---------------------------------------------------------------------------

/// A subtle animated gradient background using app theme colors.
class _AnimatedBackground extends StatelessWidget {
  final AnimationController controller;
  final Color color1;
  final Color color2;

  const _AnimatedBackground({
    required this.controller,
    required this.color1,
    required this.color2,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(color1, color2, controller.value)!,
                Color.lerp(color2, color1, controller.value)!,
              ],
            ),
          ),
        );
      },
    );
  }
}

/// A custom logo representing "Two" entities interlocking
class _InterlockingLogo extends StatelessWidget {
  final double size;
  final Color color;

  const _InterlockingLogo({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 0.8, // Slightly wider than tall
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Left Circle
          Positioned(
            left: 0,
            child: Container(
              width: size * 0.6,
              height: size * 0.6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: color.withOpacity(0.9),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(2, 2),
                  ),
                ],
              ),
            ),
          ),
          // Right Circle (Overlapping)
          Positioned(
            right: 0,
            child: Container(
              width: size * 0.6,
              height: size * 0.6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.2), // Glass effect
                border: Border.all(color: color, width: 3),
              ),
              child: BackdropFilter(
                filter: import_ui_blur(), // Helper for filter
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper to allow generic ImageFilter without import clutter in snippets
  import_ui_blur() =>
      const ColorFilter.mode(Colors.transparent, BlendMode.srcOver);
}

/// A modern replacement for CircularProgressIndicator
class _PulsingDots extends StatefulWidget {
  final Color color;

  const _PulsingDots({required this.color});

  @override
  State<_PulsingDots> createState() => _PulsingDotsState();
}

class _PulsingDotsState extends State<_PulsingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(3, (index) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              // Create a wave effect by offsetting the sin wave
              final value = math.sin(
                (_controller.value * 2 * math.pi) - (index * 1.0),
              );
              // Map -1..1 to 0.4..1.0 opacity/scale
              final scale = 0.5 + (0.5 * (0.5 * value + 0.5));

              return Transform.scale(
                scale: scale,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: widget.color.withOpacity(0.8),
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
