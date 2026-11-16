import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:nousdeux/core/constants/app_spacing.dart';
import 'package:nousdeux/core/constants/nous_strings.dart';
import 'package:nousdeux/domain/entities/ping_entity.dart';
import 'package:nousdeux/presentation/theme/app_motion.dart';
import 'package:nousdeux/presentation/theme/app_theme.dart';

/// Full-screen moment when the partner's little note arrives while the app
/// is open, or when its notification is tapped: your two rings slide almost
/// into one, with the note inside. Two quick replies; tap anywhere else or go
/// Back to close. It stays until then, so there is time to read and answer.
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
  late final AnimationController _fade = AnimationController(
    vsync: this,
    duration: AppMotion.slow,
  )..forward();
  late final Animation<double> _closeIn = CurvedAnimation(
    parent: _fade,
    curve: AppMotion.enter,
  );
  bool _leaving = false;

  @override
  void initState() {
    super.initState();
    HapticFeedback.mediumImpact();
  }

  @override
  void dispose() {
    _fade.dispose();
    super.dispose();
  }

  Future<void> _dismiss() async {
    if (_leaving) return;
    _leaving = true;
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
    final title = pingReceivedTitle(lang, widget.kind, widget.partnerName);
    final titleStyle = _Rings.fitTitle(
      title,
      (theme.textTheme.headlineMedium ?? const TextStyle()).copyWith(
        fontSize: 26,
        fontWeight: FontWeight.w300,
        height: 1.15,
      ),
      MediaQuery.textScalerOf(context),
    );
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
                        // The rings' frame is wider than a 360-point phone
                        // leaves between the margins; shrink it whole so the
                        // rings, the dot and the note stay on one centre.
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: AnimatedBuilder(
                            animation: _closeIn,
                            builder: (context, _) => _Rings(
                              // How far apart the rings start; they end 10 px
                              // from each other, almost one.
                              gap: reduced
                                  ? 10
                                  : 10 + 70 * (1 - _closeIn.value),
                              above: Semantics(
                                liveRegion: true,
                                child: Text(
                                  title,
                                  textAlign: TextAlign.center,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: titleStyle,
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

  /// The title's box: inset from both sides of the frame, its bottom this
  /// far above the centre.
  static const double _titleInset = 50;
  static const double _titleGap = 22;

  /// How far from a ring's centre the title may reach once the rings rest
  /// 10 px apart: inside both, clear of their 1.5 px stroke.
  static const double _restOffset = 5;
  static const double _inner = _ring / 2 - 1.5 - 4;

  /// [style] at the largest size, from its own down to 14, at which every
  /// line of [title] stays inside both rings. Long titles and long names
  /// ("Marie-Charlotte sends you a kiss.") would otherwise cross them.
  static TextStyle fitTitle(String title, TextStyle style, TextScaler scaler) {
    for (var size = style.fontSize ?? 26; size > 14; size -= 1) {
      final candidate = style.copyWith(fontSize: size);
      if (_fits(title, candidate, scaler)) return candidate;
    }
    return style.copyWith(fontSize: 14);
  }

  static bool _fits(String title, TextStyle style, TextScaler scaler) {
    const width = _frame - 2 * _titleInset;
    final painter = TextPainter(
      text: TextSpan(text: title, style: style),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
      textScaler: scaler,
      maxLines: 3,
    )..layout(minWidth: width, maxWidth: width);
    try {
      if (painter.didExceedMaxLines) return false;
      final lines = painter.getBoxesForSelection(
        TextSelection(baseOffset: 0, extentOffset: title.length),
      );
      for (final line in lines) {
        for (final x in [line.left, line.right]) {
          for (final y in [line.top, line.bottom]) {
            // From the frame's centre; the rings sit at ±_restOffset.
            final dx = x - width / 2;
            final dy = y - painter.height - _titleGap;
            for (final ring in [-_restOffset, _restOffset]) {
              final d = sqrt(pow(dx - ring, 2) + pow(dy - ring, 2));
              if (d > _inner) return false;
            }
          }
        }
      }
      return true;
    } finally {
      painter.dispose();
    }
  }

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
          Positioned(
            left: _titleInset,
            right: _titleInset,
            bottom: center + _titleGap,
            child: above,
          ),
          Positioned(left: 50, right: 50, top: center + 24, child: below),
        ],
      ),
    );
  }
}
