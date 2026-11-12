import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:nousdeux/core/constants/app_spacing.dart';
import 'package:nousdeux/core/constants/lists_strings.dart';
import 'package:nousdeux/core/constants/nous_strings.dart';
import 'package:nousdeux/core/utils/app_routes.dart';
import 'package:nousdeux/core/utils/date_only.dart';
import 'package:nousdeux/domain/entities/ping_entity.dart';
import 'package:nousdeux/domain/nous/nous_dates.dart';
import 'package:nousdeux/presentation/providers/lists_provider.dart';
import 'package:nousdeux/presentation/providers/nous_provider.dart';
import 'package:nousdeux/presentation/providers/pairing_provider.dart';
import 'package:nousdeux/presentation/providers/profile_provider.dart';
import 'package:nousdeux/presentation/theme/app_motion.dart';
import 'package:nousdeux/presentation/theme/app_theme.dart';
import 'package:nousdeux/presentation/widgets/empty_state.dart';
import 'package:nousdeux/presentation/widgets/entrance.dart';
import 'package:nousdeux/presentation/widgets/notebook.dart';

/// The home tab, laid out like a notebook page: how long you have been
/// together, a little note to send, what is coming up and your lists,
/// separated by thin lines rather than cards.
class NousScreen extends ConsumerWidget {
  const NousScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(myProfileProvider).valueOrNull;
    final lang = profile?.language ?? 'fr';
    final since = ref.watch(togetherSinceProvider);
    final paired = profile?.hasPartner ?? false;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            28,
            AppSpacing.sm,
            28,
            AppSpacing.lg,
          ),
          children: [
            Row(
              children: [
                Expanded(child: NotebookLabel(nousTitle(lang))),
                _AvatarButton(
                  initial: _initial(profile?.username),
                  tooltip: nousSettingsTooltip(lang),
                  onPressed: () => context.push(AppRoutes.settings),
                ),
              ],
            ),
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
              const SizedBox(height: 28),
              Entrance(
                child: _DaysBlock(lang: lang, since: since),
              ),
              const NotebookRule(),
              Entrance(
                delay: const Duration(milliseconds: 60),
                child: _PingSection(lang: lang),
              ),
              const NotebookRule(),
              Entrance(
                delay: const Duration(milliseconds: 120),
                child: _UpcomingSection(lang: lang, since: since),
              ),
              const NotebookRule(),
              Entrance(
                delay: const Duration(milliseconds: 180),
                child: _ListsPreview(lang: lang),
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
        color: Colors.transparent,
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
                  color: scheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DaysBlock extends ConsumerWidget {
  const _DaysBlock({required this.lang, required this.since});

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                nousSinceDate(lang, since),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
            TextButton(
              onPressed: () => _edit(context, ref),
              child: Text(nousEdit(lang)),
            ),
          ],
        ),
        TweenAnimationBuilder<double>(
          tween: Tween(
            begin: reduced ? days.toDouble() : 0,
            end: days.toDouble(),
          ),
          duration: reduced ? Duration.zero : const Duration(milliseconds: 900),
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
                    fontSize: 104,
                    fontWeight: FontWeight.w200,
                    letterSpacing: -5,
                    height: 0.95,
                  ),
                ),
                const SizedBox(width: 12),
                ExcludeSemantics(
                  child: Text(
                    nousDaysUnit(lang, days),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontSize: 30,
                      fontWeight: FontWeight.w300,
                      color: scheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
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
        NotebookLabel(nousSendNote(lang)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 18,
          children: [
            for (final kind in PingKind.values)
              _NoteWord(
                label: pingLabel(lang, kind),
                busy: _sending == kind,
                onPressed: _sending == null ? () => _send(kind) : null,
              ),
          ],
        ),
        if (partnerPing != null) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: CoupleColors.of(context).partner,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
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
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

/// One of the five notes, written as an underlined word you tap.
class _NoteWord extends StatelessWidget {
  const _NoteWord({
    required this.label,
    required this.busy,
    required this.onPressed,
  });

  final String label;
  final bool busy;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: scheme.onSurface,
        disabledForegroundColor: scheme.onSurface.withValues(alpha: 0.45),
        padding: const EdgeInsets.symmetric(vertical: 8),
        minimumSize: const Size(0, 48),
        shape: const RoundedRectangleBorder(),
      ),
      child: AnimatedOpacity(
        opacity: busy ? 0.45 : 1,
        duration: AppMotion.fast,
        child: Container(
          padding: const EdgeInsets.only(bottom: 3),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: scheme.outline)),
          ),
          child: Text(
            label,
            style: theme.textTheme.titleLarge?.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w400,
              letterSpacing: -0.2,
            ),
          ),
        ),
      ),
    );
  }
}

class _UpcomingSection extends ConsumerWidget {
  const _UpcomingSection({required this.lang, required this.since});

  final String lang;
  final DateTime since;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    ref.watch(minuteTickProvider);
    final now = ref.watch(clockProvider)();
    final next = ref.watch(upcomingCountdownsProvider).firstOrNull;
    final anniversary = nextAnniversary(since, now);
    final quiet = theme.textTheme.bodyMedium?.copyWith(
      color: scheme.onSurfaceVariant,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        NotebookLabel(nousNextPlan(lang)),
        InkWell(
          onTap: () => context.go(AppRoutes.calendar),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: next == null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nousNoCountdown(lang),
                        style: theme.textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(nousNoCountdownHint(lang), style: quiet),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Expanded(
                        child: Text(
                          next.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.headlineSmall,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        nousInDays(lang, daysUntil(next.startTime, now)),
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: scheme.primary,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        Row(
          children: [
            Text('${nousAnniversary(lang)} · ', style: quiet),
            Expanded(
              child: Text(
                nousYearsTogether(lang, anniversary.years),
                overflow: TextOverflow.ellipsis,
                style: quiet,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              nousInDays(lang, anniversary.inDays),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ListsPreview extends ConsumerWidget {
  const _ListsPreview({required this.lang});

  final String lang;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final lists = ref.watch(sharedListsProvider).valueOrNull ?? const [];

    Widget row(String title, String trailing, VoidCallback onTap) {
      return InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
                  ),
                ),
              ),
              Text(
                trailing,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final shown = lists.take(2).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: NotebookLabel(listsTitle(lang))),
            TextButton(
              onPressed: () => context.push(AppRoutes.lists),
              child: Text(listsSeeAll(lang)),
            ),
          ],
        ),
        if (shown.isEmpty)
          row(listsNew(lang), '+', () => context.push(AppRoutes.lists))
        else
          for (final list in shown)
            Consumer(
              builder: (context, ref, _) {
                final counts = ref.watch(listCountsProvider(list.id));
                return row(
                  list.name,
                  listsCounts(lang, counts.open, counts.total),
                  () => context.push(AppRoutes.listDetail(list.id)),
                );
              },
            ),
      ],
    );
  }
}
