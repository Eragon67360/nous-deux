import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:nousdeux/core/constants/app_spacing.dart';
import 'package:nousdeux/core/constants/period_options.dart';
import 'package:nousdeux/core/constants/period_tips.dart';
import 'package:nousdeux/domain/entities/period_log_entity.dart';
import 'package:nousdeux/presentation/providers/auth_provider.dart';
import 'package:nousdeux/presentation/providers/period_provider.dart';
import 'package:nousdeux/presentation/providers/profile_provider.dart';
import 'package:nousdeux/presentation/screens/period/period_log_form_screen.dart';
import 'package:nousdeux/presentation/widgets/empty_state.dart';
import 'package:nousdeux/presentation/widgets/loading_content.dart';

class PeriodScreen extends ConsumerStatefulWidget {
  const PeriodScreen({super.key});

  @override
  ConsumerState<PeriodScreen> createState() => _PeriodScreenState();
}

class _PeriodScreenState extends ConsumerState<PeriodScreen> {
  bool _tipsExpanded = false;

  @override
  Widget build(BuildContext context) {
    final logsAsync = ref.watch(periodLogsProvider);
    final currentUserId = ref.watch(currentUserProvider).valueOrNull?.id;
    final partnerProfile = ref.watch(partnerProfileProvider).valueOrNull;
    final partnerDisplayName =
        partnerProfile?.username?.trim().isNotEmpty == true
        ? partnerProfile!.username!
        : 'Partenaire';
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Règles')),
      body: logsAsync.when(
        data: (logs) {
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.sm),
            children: [
              _buildTipsTile(context),
              if (logs.isEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                const Padding(
                  padding: EdgeInsets.only(top: AppSpacing.lg),
                  child: EmptyState(
                    icon: Icons.favorite_border,
                    message: 'Aucun enregistrement',
                    secondary: 'Appuyez sur + pour ajouter un enregistrement',
                  ),
                ),
              ] else ...[
                const SizedBox(height: AppSpacing.sm),
                ...List.generate(logs.length, (i) {
                  final log = logs[i];
                  final isMine =
                      currentUserId != null && log.userId == currentUserId;
                  return Card(
                    margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _formatDateRange(
                                context,
                                ref,
                                log.startDate,
                                log.endDate,
                              ),
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.xs,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: isMine
                                  ? colorScheme.primaryContainer
                                  : colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              isMine ? 'Moi' : partnerDisplayName,
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: isMine
                                        ? colorScheme.onPrimaryContainer
                                        : colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      subtitle: _buildSubtitle(context, log),
                      onTap: () {
                        if (isMine) {
                          Navigator.of(context)
                              .push(
                                MaterialPageRoute<void>(
                                  builder: (_) => PeriodLogFormScreen(log: log),
                                ),
                              )
                              .then((_) => ref.invalidate(periodLogsProvider));
                        }
                      },
                      onLongPress: isMine
                          ? () => _confirmDelete(context, ref, log)
                          : null,
                    ),
                  );
                }),
              ],
            ],
          );
        },
        loading: () => const LoadingContent(),
        error: (err, _) => EmptyState(
          icon: Icons.error_outline,
          message: 'Erreur de chargement',
          secondary: err.toString(),
          iconColor: colorScheme.error,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
              .push(
                MaterialPageRoute<void>(
                  builder: (_) => const PeriodLogFormScreen(),
                ),
              )
              .then((_) => ref.invalidate(periodLogsProvider));
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTipsTile(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => setState(() => _tipsExpanded = !_tipsExpanded),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.sm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    size: 22,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Conseils',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  Icon(
                    _tipsExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
              if (_tipsExpanded) ...[
                const SizedBox(height: AppSpacing.sm),
                ...periodTips.map(
                  (tip) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '• ',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Expanded(
                          child: Text(
                            tip,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateRange(
    BuildContext context,
    WidgetRef ref,
    DateTime start,
    DateTime? end,
  ) {
    final language = ref.read(myProfileProvider).valueOrNull?.language ?? 'fr';
    final locale = language == 'fr' ? 'fr_FR' : 'en_US';
    final fmt = language == 'fr'
        ? DateFormat('d MMM y', locale)
        : DateFormat('MMM d, y', locale);
    if (end == null || _isSameDay(start, end)) {
      return fmt.format(start.toLocal());
    }
    return '${fmt.format(start.toLocal())} – ${fmt.format(end.toLocal())}';
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Widget? _buildSubtitle(BuildContext context, PeriodLogEntity log) {
    final parts = <String>[];
    if (log.mood != null && log.mood!.isNotEmpty) {
      parts.add(periodMoodLabel(log.mood));
    }
    if (log.symptoms.isNotEmpty) {
      parts.add(log.symptoms.map(periodSymptomLabel).join(', '));
    }
    if (log.notes != null && log.notes!.isNotEmpty) {
      final raw = log.notes!;
      final note = raw.length > 40 ? '${raw.substring(0, 40)}…' : raw;
      parts.add(note);
    }
    if (parts.isEmpty) return null;
    return Text(parts.join(' · '));
  }

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    PeriodLogEntity log,
  ) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer cet enregistrement ?'),
        content: Text(
          _formatDateRange(context, ref, log.startDate, log.endDate),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(periodRepositoryProvider).deleteLog(log.id);
              if (context.mounted) ref.invalidate(periodLogsProvider);
            },
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}
