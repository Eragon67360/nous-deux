import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:nousdeux/core/constants/app_spacing.dart';
import 'package:nousdeux/core/constants/nous_strings.dart';
import 'package:nousdeux/domain/entities/ping_entity.dart';
import 'package:nousdeux/presentation/theme/app_motion.dart';
import 'package:nousdeux/presentation/theme/app_theme.dart';

/// Full-screen moment when the partner's little note arrives while the app
/// is open: your two rings slide almost into one, with the note inside. Two
/// quick replies; tap anywhere else or go Back to close. Leaves on its own
/// after a few seconds, except with a screen reader on, where it waits to be
/// closed.
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
    duration: AppMotion.slow,
  )..forward();
  late final Animation<double> _closeIn = CurvedAnimation(
    parent: _fade,
    curve: AppMotion.enter,
  );
  Timer? _timer;
  bool _leaving = false;

  @override
  void initState() {
    super.initState();
    HapticFeedback.mediumImpact();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final screenReader = MediaQuery.accessibleNavigationOf(context);
    if (screenReader) {
      _timer?.cancel();
      _timer = null;
    } else if (_timer == null && !_leaving) {
      _timer = Timer(_stay, _dismiss);
    }
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
    final reduced = AppMotion.reduced(context);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _dismiss();
      },
      // Screen readers stay on the note, not the tab underneath.
      child: BlockSemantics(
        child: FadeTransition(
          opacity: _fade,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _dismiss,
            child: ColoredBox(
              color: scheme.surfaceContainerLowest.withValues(alpha: 0.98),
              child: SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedBuilder(
                          animation: _closeIn,
                          builder: (context, _) => _Rings(
                            // How far apart the rings start; they end 10 px
                            // from each other, almost one.
                            gap: reduced ? 10 : 10 + 70 * (1 - _closeIn.value),
                            above: Semantics(
                              liveRegion: true,
                              child: Text(
                                pingReceivedTitle(
                                  lang,
                                  widget.kind,
                                  widget.partnerName,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w300,
                                  height: 1.15,
                                ),
                              ),
                            ),
                            below: Text(
                              pingJustNow(lang).toUpperCase(),
                              textAlign: TextAlign.center,
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontSize: 11,
                                letterSpacing: 2,
                                color: scheme.primary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        Wrap(
                          spacing: 14,
                          runSpacing: 10,
                          alignment: WrapAlignment.center,
                          children: [
                            FilledButton(
                              onPressed: () => _reply(PingKind.thinkingOfYou),
                              style: FilledButton.styleFrom(
                                shape: const StadiumBorder(),
                                minimumSize: const Size(0, 56),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 30,
                                ),
                              ),
                              child: Text(pingReplyMeToo(lang)),
                            ),
                            FilledButton.tonal(
                              onPressed: () => _reply(PingKind.kiss),
                              style: FilledButton.styleFrom(
                                shape: const StadiumBorder(),
                                minimumSize: const Size(0, 56),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 30,
                                ),
                                backgroundColor: scheme.surfaceContainer,
                                foregroundColor: scheme.onSurface,
                              ),
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
        ),
      ),
    );
  }
}

/// Your ring (cream) and your partner's (gold), offset by [gap] px, with the
/// partner dot at the centre, [above] just over it and [below] just under it.
/// The frame keeps the size of the closest position so nothing around it
/// moves while the rings slide together.
class _Rings extends StatelessWidget {
  const _Rings({required this.gap, required this.above, required this.below});

  final double gap;
  final Widget above;
  final Widget below;

  static const double _ring = 260;
  static const double _maxGap = 80;
  static const double _frame = _ring + _maxGap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    const center = _frame / 2;
    final offset = gap / 2;
    Widget ring(Color color) => ExcludeSemantics(
      child: Container(
        width: _ring,
        height: _ring,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 1.5),
        ),
      ),
    );
    return SizedBox(
      width: _frame,
      height: _frame,
      child: Stack(
        children: [
          Positioned(
            left: center - _ring / 2 - offset,
            top: center - _ring / 2 - offset,
            child: ring(scheme.onSurface),
          ),
          Positioned(
            left: center - _ring / 2 + offset,
            top: center - _ring / 2 + offset,
            child: ring(scheme.primary),
          ),
          Positioned(
            left: center - 9,
            top: center - 9,
            child: ExcludeSemantics(
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: CoupleColors.of(context).partner,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          Positioned(left: 50, right: 50, bottom: center + 22, child: above),
          Positioned(left: 50, right: 50, top: center + 24, child: below),
        ],
      ),
    );
  }
}
