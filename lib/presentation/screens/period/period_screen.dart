import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:nousdeux/core/constants/app_spacing.dart';
import 'package:nousdeux/core/constants/period_education.dart';
import 'package:nousdeux/domain/entities/period_log_entity.dart';
import 'package:nousdeux/presentation/providers/auth_provider.dart';
import 'package:nousdeux/presentation/providers/period_provider.dart';
import 'package:nousdeux/presentation/providers/profile_provider.dart';
import 'package:nousdeux/presentation/screens/period/period_guide_content.dart';
import 'package:nousdeux/presentation/screens/period/period_log_form_screen.dart';
import 'package:nousdeux/presentation/widgets/empty_state.dart';
import 'package:nousdeux/presentation/widgets/loading_content.dart';

class PeriodScreen extends ConsumerStatefulWidget {
  const PeriodScreen({super.key});

  @override
  ConsumerState<PeriodScreen> createState() => _PeriodScreenState();
}

class _PeriodScreenState extends ConsumerState<PeriodScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _partnerMode = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _lang(WidgetRef ref) {
    return ref.watch(myProfileProvider).valueOrNull?.language ?? 'fr';
  }

  bool _isPartnerByLogs(List<PeriodLogEntity> logs, String? currentUserId) {
    if (currentUserId == null || logs.isEmpty) return false;
    int myCount = 0, partnerCount = 0;
    for (final log in logs) {
      if (log.userId == currentUserId) {
        myCount++;
      } else {
        partnerCount++;
      }
    }
    return partnerCount > myCount;
  }

  @override
  Widget build(BuildContext context) {
    final lang = _lang(ref);
    final logsAsync = ref.watch(periodLogsProvider);
    final currentUserId = ref.watch(currentUserProvider).valueOrNull?.id;
    final partnerProfile = ref.watch(partnerProfileProvider).valueOrNull;
    final partnerDisplayName =
        partnerProfile?.username?.trim().isNotEmpty == true
        ? partnerProfile!.username!
        : periodPartner(lang);
    final colorScheme = Theme.of(context).colorScheme;
    final phase = ref.watch(currentCyclePhaseProvider);
    final hasPartner = partnerProfile != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(periodScreenTitle(lang)),
        actions: [
          if (hasPartner) ...[
            FilterChip(
              label: Text(periodPartnerModeLabel(lang)),
              selected: _partnerMode,
              onSelected: (v) => setState(() => _partnerMode = v),
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: periodTabLogs(lang)),
            Tab(text: periodTabGuide(lang)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          logsAsync.when(
            data: (logs) {
              final partnerByLogs = _isPartnerByLogs(logs, currentUserId);
              final showPartnerBanner =
                  hasPartner && (_partnerMode || partnerByLogs);
              return Stack(
                children: [
                  ListView(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    children: [
                      if (showPartnerBanner) ...[
                        Card(
                          color: colorScheme.surfaceContainerHigh,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.xs,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.person_outline,
                                  size: 20,
                                  color: colorScheme.primary,
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: Text(
                                    lang == 'fr'
                                        ? 'Vous consultez le journal de $partnerDisplayName.'
                                        : 'Viewing $partnerDisplayName\'s log.',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                      ],
                      if (logs.isEmpty) ...[
                        const SizedBox(height: AppSpacing.md),
                        Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.lg),
                          child: EmptyState(
                            icon: Icons.favorite_border,
                            message: periodEmptyMessage(lang),
                            secondary: periodEmptySecondary(lang),
                          ),
                        ),
                      ] else ...[
                        const SizedBox(height: AppSpacing.sm),
                        ...List.generate(logs.length, (i) {
                          final log = logs[i];
                          final isMine =
                              currentUserId != null &&
                              log.userId == currentUserId;
                          return Card(
                            margin: const EdgeInsets.only(
                              bottom: AppSpacing.sm,
                            ),
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
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleSmall,
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
                                      isMine
                                          ? periodMe(lang)
                                          : partnerDisplayName,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                            color: isMine
                                                ? colorScheme.onPrimaryContainer
                                                : colorScheme.onSurfaceVariant,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: _buildSubtitle(context, ref, log, lang),
                              onTap: () {
                                if (isMine) {
                                  Navigator.of(context)
                                      .push(
                                        MaterialPageRoute<void>(
                                          builder: (_) =>
                                              PeriodLogFormScreen(log: log),
                                        ),
                                      )
                                      .then(
                                        (_) =>
                                            ref.invalidate(periodLogsProvider),
                                      );
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
                  ),
                ],
              );
            },
            loading: () => const LoadingContent(),
            error: (err, _) => EmptyState(
              icon: Icons.error_outline,
              message: periodErrorLoad(lang),
              secondary: err.toString(),
              iconColor: colorScheme.error,
            ),
          ),
          PeriodGuideContent(
            language: lang,
            phase: phase,
            isPartnerMode:
                _partnerMode ||
                (hasPartner &&
                    logsAsync.valueOrNull != null &&
                    currentUserId != null &&
                    _isPartnerByLogs(logsAsync.valueOrNull!, currentUserId)),
          ),
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton(
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
            )
          : null,
    );
  }

  String _formatDateRange(
    BuildContext context,
    WidgetRef ref,
    DateTime start,
    DateTime? end,
  ) {
    final language = _lang(ref);
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

  Widget? _buildSubtitle(
    BuildContext context,
    WidgetRef ref,
    PeriodLogEntity log,
    String lang,
  ) {
    final parts = <String>[];
    if (log.mood != null && log.mood!.isNotEmpty) {
      parts.add(periodMoodOptionLabel(log.mood!, lang));
    }
    if (log.symptoms.isNotEmpty) {
      parts.add(
        log.symptoms.map((s) => periodSymptomOptionLabel(s, lang)).join(', '),
      );
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
    final lang = _lang(ref);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(periodDeleteConfirmTitle(lang)),
        content: Text(
          _formatDateRange(context, ref, log.startDate, log.endDate),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(periodCancel(lang)),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(periodRepositoryProvider).deleteLog(log.id);
              if (context.mounted) ref.invalidate(periodLogsProvider);
            },
            child: Text(periodDelete(lang)),
          ),
        ],
      ),
    );
  }
}
