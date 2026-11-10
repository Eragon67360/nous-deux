import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:nousdeux/core/constants/app_spacing.dart';
import 'package:nousdeux/core/constants/nous_strings.dart';
import 'package:nousdeux/domain/entities/ping_entity.dart';
import 'package:nousdeux/presentation/theme/app_motion.dart';
import 'package:nousdeux/presentation/widgets/merging_rings.dart';

/// Full-screen moment when the partner's little note arrives while the app
/// is open. Two quick replies; tap anywhere else to close. Leaves on its own.
class PingReceived extends StatefulWidget {
  const PingReceived({
    super.key,
    required this.lang,
    required this.partnerName,
    required this.kind,
    required this.onReply,
    required this.onDismissed,
  });

  final String lang;
  final String partnerName;
  final PingKind kind;
  final ValueChanged<PingKind> onReply;
  final VoidCallback onDismissed;

  @override
  State<PingReceived> createState() => _PingReceivedState();
}

class _PingReceivedState extends State<PingReceived>
    with SingleTickerProviderStateMixin {
  static const _stay = Duration(seconds: 6);

  late final AnimationController _fade = AnimationController(
    vsync: this,
    duration: AppMotion.medium,
  )..forward();
  Timer? _timer;
  bool _leaving = false;

  @override
  void initState() {
    super.initState();
    HapticFeedback.mediumImpact();
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

  void _reply(PingKind kind) {
    widget.onReply(kind);
    _dismiss();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final lang = widget.lang;
    return FadeTransition(
      opacity: _fade,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _dismiss,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0, -0.15),
              radius: 0.85,
              colors: [
                Color.alphaBlend(
                  scheme.primary.withValues(alpha: 0.14),
                  scheme.surface,
                ),
                scheme.surface.withValues(alpha: 0.97),
              ],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const ExcludeSemantics(child: MergingRings(size: 168)),
                    const SizedBox(height: AppSpacing.md),
                    Semantics(
                      liveRegion: true,
                      child: Text(
                        pingReceivedTitle(lang, widget.kind, widget.partnerName),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.displaySmall,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(pingJustNow(lang), style: theme.textTheme.bodyMedium),
                    const SizedBox(height: AppSpacing.lg),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      alignment: WrapAlignment.center,
                      children: [
                        FilledButton(
                          onPressed: () => _reply(PingKind.thinkingOfYou),
                          style: FilledButton.styleFrom(shape: const StadiumBorder()),
                          child: Text(pingReplyMeToo(lang)),
                        ),
                        OutlinedButton(
                          onPressed: () => _reply(PingKind.kiss),
                          style: OutlinedButton.styleFrom(shape: const StadiumBorder()),
                          child: Text(pingLabel(lang, PingKind.kiss)),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    TextButton(
                      onPressed: _dismiss,
                      child: Text(
                        pingTapToClose(lang),
                        style: TextStyle(color: scheme.onSurfaceVariant),
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
