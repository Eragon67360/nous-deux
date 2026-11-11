import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nousdeux/core/constants/cycle_strings.dart';
import 'package:nousdeux/core/constants/period_education.dart';
import 'package:nousdeux/domain/cycle/cycle_stats.dart';
import 'package:nousdeux/domain/entities/period_log_entity.dart';
import 'package:nousdeux/presentation/providers/auth_provider.dart';
import 'package:nousdeux/presentation/providers/cycle_provider.dart';
import 'package:nousdeux/presentation/providers/period_provider.dart';
import 'package:nousdeux/presentation/providers/profile_provider.dart';
import 'package:nousdeux/presentation/screens/period/period_log_form_screen.dart';
import 'package:nousdeux/presentation/theme/app_theme.dart';
import 'package:nousdeux/presentation/widgets/notebook.dart';

/// R1: my past cycles, the averages they give, and a way to fix them.
class CycleHistoryScreen extends ConsumerWidget {
  const CycleHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final lang = ref.watch(myProfileProvider).valueOrNull?.language ?? 'fr';
    final stats = ref.watch(myCycleStatsProvider);
    final me = ref.watch(currentUserProvider).valueOrNull?.id;
    final logs = [
      for (final log in ref.watch(periodLogsProvider).valueOrNull ?? const [])
        if (log.userId == me) log,
    ];
    PeriodLogEntity? logFor(DateTime start) {
      for (final log in logs) {
        if (daysBetween(log.startDate, start) == 0) return log;
      }
      return null;
    }

    final current = stats.dayOfCycle;
    final longest = [
      28,
      ?current,
      for (final s in stats.history) s.length,
    ].reduce(math.max);

    return Scaffold(
      appBar: AppBar(title: Text(cycleHistoryTitle(lang))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
        children: [
          Row(
            children: [
              Expanded(
                child: _Figure(
                  label: cycleAverage(lang),
                  value: stats.cycleLength,
                  unit: cycleDaysWord(lang),
                ),
              ),
              Expanded(
                child: _Figure(
                  label: cyclePeriod(lang),
                  value: stats.periodLength,
                  unit: cycleDaysWord(lang),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            stats.cyclesUsed >= 2
                ? cycleRegularity(
                    lang,
                    stats.cyclesUsed,
                    stats.shortestCycle!,
                    stats.longestCycle!,
                  )
                : cycleNeedTwo(lang),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const NotebookRule(),
          if (!stats.hasData)
            Text(cycleHistoryEmpty(lang), style: theme.textTheme.bodyLarge)
          else ...[
            _CycleRow(
              lang: lang,
              start: stats.lastStart!,
              detail: cycleCurrentRow(lang, current!),
              length: current,
              periodDays: stats.lastEnd == null
                  ? math.min(current, stats.periodLength)
                  : daysBetween(stats.lastStart!, stats.lastEnd!) + 1,
              longest: longest,
              log: logFor(stats.lastStart!),
            ),
            for (final span in stats.history)
              _CycleRow(
                lang: lang,
                start: span.start,
                detail: cycleSpanRow(lang, span.length, span.periodDays),
                length: span.length,
                periodDays: span.periodDays,
                longest: longest,
                log: logFor(span.start),
              ),
            const SizedBox(height: 16),
            const _Legend(),
            const SizedBox(height: 8),
            Text(
              cycleHistoryHint(lang),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Figure extends StatelessWidget {
  const _Figure({required this.label, required this.value, required this.unit});

  final String label;
  final int value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NotebookLabel(label),
        const SizedBox(height: 4),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '$value',
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w200,
                ),
              ),
              TextSpan(text: ' $unit', style: theme.textTheme.bodyLarge),
            ],
          ),
        ),
      ],
    );
  }
}

/// One cycle: when it started, how long it lasted, and a bar drawn to scale.
class _CycleRow extends ConsumerWidget {
  const _CycleRow({
    required this.lang,
    required this.start,
    required this.detail,
    required this.length,
    required this.periodDays,
    required this.longest,
    required this.log,
  });

  final String lang;
  final DateTime start;
  final String detail;
  final int length;
  final int? periodDays;
  final int longest;

  /// The log behind this cycle, to fix or delete it.
  final PeriodLogEntity? log;

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final log = this.log!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(periodDeleteConfirmTitle(lang)),
        content: Text(cycleShortDate(lang, log.startDate)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(periodCancel(lang)),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(periodDelete(lang)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final failure = await ref.read(periodRepositoryProvider).deleteLog(log.id);
    if (failure != null && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(cycleSaveFailed(lang))));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final bleeding = math.min(periodDays ?? 0, length);
    return InkWell(
      onTap: log == null
          ? null
          : () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => PeriodLogFormScreen(log: log),
              ),
            ),
      onLongPress: log == null ? null : () => _delete(context, ref),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: scheme.outlineVariant)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 72,
                  child: Text(
                    cycleShortDate(lang, start),
                    style: theme.textTheme.bodyLarge,
                  ),
                ),
                Expanded(
                  child: Text(
                    detail,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ExcludeSemantics(
              child: Row(
                children: [
                  if (bleeding > 0)
                    Expanded(
                      flex: bleeding,
                      child: Container(
                        height: 6,
                        color: CoupleColors.of(context).mine,
                      ),
                    ),
                  if (length > bleeding)
                    Expanded(
                      flex: length - bleeding,
                      child: Container(
                        height: 6,
                        color: scheme.surfaceContainerHigh,
                      ),
                    ),
                  if (longest > length)
                    Expanded(flex: longest - length, child: const SizedBox()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Legend extends ConsumerWidget {
  const _Legend();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final lang = ref.watch(myProfileProvider).valueOrNull?.language ?? 'fr';
    Widget item(Color color, String text) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 6, color: color),
        const SizedBox(width: 6),
        Text(text, style: theme.textTheme.bodySmall),
      ],
    );
    return ExcludeSemantics(
      child: Wrap(
        spacing: 18,
        children: [
          item(CoupleColors.of(context).mine, cyclePeriod(lang)),
          item(theme.colorScheme.surfaceContainerHigh, cycleRestOfCycle(lang)),
        ],
      ),
    );
  }
}
