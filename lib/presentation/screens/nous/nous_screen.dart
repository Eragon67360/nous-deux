import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:nousdeux/core/constants/app_radius.dart';
import 'package:nousdeux/core/constants/app_spacing.dart';
import 'package:nousdeux/core/constants/nous_strings.dart';
import 'package:nousdeux/core/utils/app_routes.dart';
import 'package:nousdeux/core/utils/date_only.dart';
import 'package:nousdeux/domain/entities/ping_entity.dart';
import 'package:nousdeux/domain/nous/nous_dates.dart';
import 'package:nousdeux/presentation/providers/nous_provider.dart';
import 'package:nousdeux/presentation/providers/pairing_provider.dart';
import 'package:nousdeux/presentation/providers/profile_provider.dart';
import 'package:nousdeux/presentation/theme/app_motion.dart';
import 'package:nousdeux/presentation/theme/app_theme.dart';
import 'package:nousdeux/presentation/widgets/empty_state.dart';
import 'package:nousdeux/presentation/widgets/entrance.dart';
import 'package:nousdeux/presentation/widgets/merging_rings.dart';

/// The home tab: how long you have been together, a little note to send,
/// and what is coming up.
class NousScreen extends ConsumerWidget {
  const NousScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final profile = ref.watch(myProfileProvider).valueOrNull;
    final lang = profile?.language ?? 'fr';
    final since = ref.watch(togetherSinceProvider);
    final paired = profile?.hasPartner ?? false;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md - 4,
            AppSpacing.sm,
            AppSpacing.md - 4,
            AppSpacing.lg,
          ),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    nousTitle(lang),
                    style: theme.textTheme.displaySmall,
                  ),
                ),
                _AvatarButton(
                  initial: _initial(profile?.username),
                  tooltip: nousSettingsTooltip(lang),
                  onPressed: () => context.push(AppRoutes.settings),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            if (!paired || since == null)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xl),
                child: EmptyState(
                  icon: Icons.favorite_border,
                  message: nousNoPartnerTitle(lang),
                  secondary: nousNoPartnerBody(lang),
                  actionLabel: nousInvite(lang),
                  actionIcon: Icons.person_add_outlined,
                  onAction: () => context.push(AppRoutes.pairing),
                ),
              )
            else ...[
              Entrance(
                child: _DaysCard(lang: lang, since: since),
              ),
              const SizedBox(height: AppSpacing.md),
              Entrance(
                delay: const Duration(milliseconds: 60),
                child: _PingSection(lang: lang),
              ),
              const SizedBox(height: AppSpacing.md),
              Entrance(
                delay: const Duration(milliseconds: 120),
                child: _UpcomingRow(lang: lang, since: since),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static String _initial(String? name) {
    final trimmed = name?.trim() ?? '';
    return trimmed.isEmpty ? '·' : trimmed.characters.first.toUpperCase();
  }
}

class _AvatarButton extends StatelessWidget {
  const _AvatarButton({
    required this.initial,
    required this.tooltip,
    required this.onPressed,
  });

  final String initial;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: scheme.surfaceContainer,
        shape: CircleBorder(side: BorderSide(color: scheme.outlineVariant)),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox(
            width: 48,
            height: 48,
            child: Center(
              child: Text(
                initial,
                semanticsLabel: tooltip,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DaysCard extends ConsumerWidget {
  const _DaysCard({required this.lang, required this.since});

  final String lang;
  final DateTime since;

  Future<void> _edit(BuildContext context, WidgetRef ref) async {
    final today = dayOf(ref.read(clockProvider)());
    final picked = await showDatePicker(
      context: context,
      initialDate: since.isAfter(today) ? today : since,
      firstDate: DateTime(1950),
      lastDate: today,
      helpText: nousPickStartHelp(lang),
    );
    if (picked == null || !context.mounted) return;
    final failure = await ref
        .read(pairingRepositoryProvider)
        .updateTogetherSince(picked);
    if (!context.mounted) return;
    if (failure == null) {
      HapticFeedback.selectionClick();
      ref.invalidate(myCoupleProvider);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          failure == null ? nousStartSaved(lang) : nousNoteFailed(lang),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    ref.watch(minuteTickProvider);
    final days = daysTogether(since, ref.watch(clockProvider)());
    final reduced = AppMotion.reduced(context);

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Stack(
        children: [
          const Positioned(
            right: -36,
            top: -20,
            child: Opacity(
              opacity: 0.16,
              child: ExcludeSemantics(child: MergingRings(size: 220)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nousTogetherSince(lang).toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    letterSpacing: 1.4,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 6),
                TweenAnimationBuilder<double>(
                  tween: Tween(
                    begin: reduced ? days.toDouble() : 0,
                    end: days.toDouble(),
                  ),
                  duration: reduced
                      ? Duration.zero
                      : const Duration(milliseconds: 900),
                  curve: AppMotion.enter,
                  // Scales down instead of overflowing at large text sizes.
                  builder: (context, value, _) => FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: AlignmentDirectional.centerStart,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '${value.round()}',
                          semanticsLabel: '$days ${nousDaysUnit(lang, days)}',
                          style: theme.textTheme.displayLarge?.copyWith(
                            fontSize: 88,
                            height: 0.95,
                          ),
                        ),
                        const SizedBox(width: 10),
                        ExcludeSemantics(
                          child: Text(
                            nousDaysUnit(lang, days),
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      nousSinceDate(lang, since),
                      style: theme.textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () => _edit(context, ref),
                      child: Text(nousEdit(lang)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PingSection extends ConsumerStatefulWidget {
  const _PingSection({required this.lang});

  final String lang;

  @override
  ConsumerState<_PingSection> createState() => _PingSectionState();
}

class _PingSectionState extends ConsumerState<_PingSection> {
  PingKind? _sending;

  Future<void> _send(PingKind kind) async {
    if (_sending != null) return;
    HapticFeedback.lightImpact();
    setState(() => _sending = kind);
    final result = await ref.read(pingRepositoryProvider).send(kind);
    if (!mounted) return;
    setState(() => _sending = null);
    final message = pingResultMessage(widget.lang, kind, result.failure);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = widget.lang;
    final partnerPing = ref.watch(partnerLastPingProvider);
    final partnerName = ref.watch(partnerProfileProvider).valueOrNull?.username;
    ref.watch(minuteTickProvider);
    final now = ref.watch(clockProvider)();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                nousSendNote(lang),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (partnerPing != null)
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        nousReceivedLine(
                          lang,
                          (partnerName?.trim().isNotEmpty ?? false)
                              ? partnerName!.trim()
                              : nousPartnerFallback(lang),
                          partnerPing.sentAt,
                          now,
                        ),
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: CoupleColors.of(context).partner,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs + 2),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final kind in PingKind.values)
              _PingChip(
                label: pingLabel(lang, kind),
                primary: kind == PingKind.thinkingOfYou,
                busy: _sending == kind,
                onPressed: _sending == null ? () => _send(kind) : null,
              ),
          ],
        ),
      ],
    );
  }
}

class _PingChip extends StatelessWidget {
  const _PingChip({
    required this.label,
    required this.primary,
    required this.busy,
    required this.onPressed,
  });

  final String label;
  final bool primary;
  final bool busy;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    const shape = StadiumBorder();
    const padding = EdgeInsets.symmetric(horizontal: 16);
    final child = busy
        ? const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Text(label);
    return SizedBox(
      height: 44,
      child: primary
          ? FilledButton(
              onPressed: onPressed,
              style: FilledButton.styleFrom(shape: shape, padding: padding),
              child: child,
            )
          : OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                shape: shape,
                padding: padding,
                foregroundColor: Theme.of(context).colorScheme.onSurface,
                side: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
              child: child,
            ),
    );
  }
}

class _UpcomingRow extends ConsumerWidget {
  const _UpcomingRow({required this.lang, required this.since});

  final String lang;
  final DateTime since;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(minuteTickProvider);
    final now = ref.watch(clockProvider)();
    final next = ref.watch(upcomingCountdownsProvider).firstOrNull;
    final anniversary = nextAnniversary(since, now);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: next == null
              ? _SmallCard(
                  label: nousNextPlan(lang),
                  title: nousNoCountdown(lang),
                  footnote: nousNoCountdownHint(lang),
                  onTap: () => context.go(AppRoutes.calendar),
                )
              : _SmallCard(
                  label: nousNextPlan(lang),
                  title: next.title,
                  big: nousInDays(lang, daysUntil(next.startTime, now)),
                  onTap: () => context.go(AppRoutes.calendar),
                ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SmallCard(
            label: nousAnniversary(lang),
            title: nousYearsTogether(lang, anniversary.years),
            big: nousInDays(lang, anniversary.inDays),
          ),
        ),
      ],
    );
  }
}

class _SmallCard extends StatelessWidget {
  const _SmallCard({
    required this.label,
    required this.title,
    this.big,
    this.footnote,
    this.onTap,
  });

  final String label;
  final String title;
  final String? big;
  final String? footnote;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Material(
      color: scheme.surfaceContainer,
      borderRadius: BorderRadius.circular(AppRadius.md + 2),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md + 2),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (big != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(big!, style: theme.textTheme.headlineMedium),
              ],
              if (footnote != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  footnote!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
