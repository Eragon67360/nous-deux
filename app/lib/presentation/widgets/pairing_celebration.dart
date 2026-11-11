import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:nousdeux/core/constants/app_spacing.dart';
import 'package:nousdeux/core/constants/app_strings.dart';
import 'package:nousdeux/presentation/theme/app_motion.dart';
import 'package:nousdeux/presentation/widgets/merging_rings.dart';

/// Full-screen moment shown once, when the partner joins the couple.
/// The rings merge (with a haptic as they lock), then the words settle in.
/// Tap anywhere to dismiss; it also leaves on its own.
class PairingCelebration extends StatefulWidget {
  const PairingCelebration({
    super.key,
    required this.lang,
    required this.onDismissed,
  });

  final String lang;
  final VoidCallback onDismissed;

  @override
  State<PairingCelebration> createState() => _PairingCelebrationState();
}

class _PairingCelebrationState extends State<PairingCelebration>
    with SingleTickerProviderStateMixin {
  static const _stay = Duration(milliseconds: 3600);

  late final AnimationController _fade = AnimationController(
    vsync: this,
    duration: AppMotion.medium,
  )..forward();
  bool _showWords = false;
  bool _leaving = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(_stay, _dismiss);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _fade.dispose();
    super.dispose();
  }

  Future<void> _dismiss() async {
    if (_leaving) return;
    _leaving = true;
    _timer?.cancel();
    await _fade.reverse();
    if (mounted) widget.onDismissed();
  }

  void _onMerged() {
    HapticFeedback.mediumImpact();
    if (mounted) setState(() => _showWords = true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final reduced = AppMotion.reduced(context);

    return FadeTransition(
      opacity: _fade,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _dismiss,
        child: ColoredBox(
          color: scheme.surface.withValues(alpha: 0.94),
          child: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedMergingRings(size: 168, onMerged: _onMerged),
                    const SizedBox(height: AppSpacing.lg),
                    AnimatedOpacity(
                      opacity: _showWords ? 1 : 0,
                      duration: reduced ? Duration.zero : AppMotion.slow,
                      curve: AppMotion.enter,
                      child: Semantics(
                        liveRegion: true,
                        child: Column(
                          children: [
                            Text(
                              pairingCelebrationTitle(widget.lang),
                              style: theme.textTheme.displaySmall,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              pairingCelebrationBody(widget.lang),
                              style: theme.textTheme.bodyLarge,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
