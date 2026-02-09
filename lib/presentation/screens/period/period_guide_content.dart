import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:nousdeux/core/constants/app_spacing.dart';
import 'package:nousdeux/core/constants/period_education.dart';
import 'package:nousdeux/presentation/providers/period_provider.dart';
import 'package:nousdeux/presentation/widgets/period_cycle_timeline.dart';
import 'package:nousdeux/presentation/widgets/period_quick_ref_card.dart';
import 'package:nousdeux/presentation/widgets/period_tip_of_the_day.dart';

/// Scrollable educational guide content for the Period feature.
class PeriodGuideContent extends ConsumerWidget {
  const PeriodGuideContent({
    super.key,
    required this.language,
    this.phase,
    this.isPartnerMode = false,
  });

  final String language;
  final CyclePhase? phase;
  final bool isPartnerMode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final reminderEnabledAsync = ref.watch(partnerReminderEnabledProvider);
    final nextPmsDate = ref.watch(nextPartnerPmsDateProvider);
    final sections = <Widget>[
      PeriodTipOfTheDay(language: language, phase: phase),
      const SizedBox(height: AppSpacing.md),
      _SectionHeader(
        title: sectionCycleTitle(language),
        subtitle: sectionCycleSubtitle(language),
      ),
      const SizedBox(height: AppSpacing.sm),
      PeriodCycleTimeline(language: language),
      const SizedBox(height: AppSpacing.sm),
      Text(sectionCycleIntro(language), style: theme.textTheme.bodyMedium),
      const SizedBox(height: AppSpacing.sm),
      ...cyclePhasesData.map(
        (p) => _PhaseExpandable(phase: p, language: language),
      ),
      const SizedBox(height: AppSpacing.lg),
      _SectionHeader(
        title: sectionPhysicalEmotionalTitle(language),
        subtitle: sectionPhysicalEmotionalSubtitle(language),
      ),
      const SizedBox(height: AppSpacing.sm),
      ExpansionTile(
        title: Text(
          sectionPsychologicalTitle(language),
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sectionPsychologicalIntro(language),
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  pmsDefinition(language),
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  pmddDefinition(language),
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  whenToSeekHelp(language),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: AppSpacing.lg),
      _SectionHeader(
        title: sectionPartnerSupportTitle(language),
        subtitle: sectionPartnerSupportSubtitle(language),
      ),
      const SizedBox(height: AppSpacing.sm),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                sectionPartnerSupportIntro(language),
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                partnerDoSay(language),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                partnerDontSay(language),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                comfortKitTitle(language),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(comfortKitBody(language), style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      ),
      const SizedBox(height: AppSpacing.lg),
      _SectionHeader(
        title: sectionCommunicationTitle(language),
        subtitle: sectionCommunicationSubtitle(language),
      ),
      const SizedBox(height: AppSpacing.sm),
      ...communicationTemplates.map(
        (t) => Card(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '✗ ${t.avoid(language)}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '✓ ${t.tryInstead(language)}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                expressingNeedsTitle(language),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                expressingNeedsBody(language),
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                boundariesTitle(language),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(boundariesBody(language), style: theme.textTheme.bodyMedium),
              const SizedBox(height: AppSpacing.sm),
              Text(
                planningTogetherTitle(language),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                planningTogetherBody(language),
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: AppSpacing.lg),
      _SectionHeader(
        title: sectionMythBustersTitle(language),
        subtitle: sectionMythBustersSubtitle(language),
      ),
      const SizedBox(height: AppSpacing.sm),
      ...mythBustersList.map(
        (m) => Card(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  m.myth(language),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.error,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(m.fact(language), style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ),
      ),
      const SizedBox(height: AppSpacing.lg),
      _SectionHeader(
        title: sectionQuickRefTitle(language),
        subtitle: sectionQuickRefSubtitle(language),
      ),
      const SizedBox(height: AppSpacing.sm),
      ...quickRefCards.asMap().entries.map(
        (e) => PeriodQuickRefCard(
          title: e.value.title(language),
          bullets: e.value.bullets(language),
          initiallyExpanded: e.key == 0,
        ),
      ),
      const SizedBox(height: AppSpacing.lg),
      Text(
        sectionFaqTitle(language),
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: AppSpacing.sm),
      ...faqList.map(
        (f) => ExpansionTile(
          title: Text(f.question(language), style: theme.textTheme.titleSmall),
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Text(
                f.answer(language),
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: AppSpacing.lg),
      Semantics(
        label: disclaimerTitle(language),
        child: Card(
          color: theme.colorScheme.surfaceContainerHigh,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  disclaimerTitle(language),
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  disclaimerBody(language),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
      const SizedBox(height: AppSpacing.xl),
    ];

    final reminderCard = isPartnerMode
        ? reminderEnabledAsync.when(
            data: (enabled) => Card(
              child: SwitchListTile(
                title: Text(
                  periodReminderSwitchTitle(language),
                  style: theme.textTheme.titleSmall,
                ),
                subtitle: nextPmsDate != null
                    ? Text(
                        '${periodReminderEstimated(language)}${DateFormat.yMMMd(language == 'fr' ? 'fr_FR' : 'en_US').format(nextPmsDate)}',
                        style: theme.textTheme.bodySmall,
                      )
                    : Text(
                        periodReminderNoDate(language),
                        style: theme.textTheme.bodySmall,
                      ),
                value: enabled,
                onChanged: (v) async {
                  await setPartnerReminderEnabled(
                    ref,
                    enabled: v,
                    lang: language,
                  );
                },
              ),
            ),
            loading: () => const SizedBox.shrink(),
            error: (e, st) => const SizedBox.shrink(),
          )
        : null;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.sm),
      children: [
        if (isPartnerMode)
          Card(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Row(
                children: [
                  Icon(
                    Icons.favorite,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      language == 'fr'
                          ? 'Contenu adapté au partenaire : soutien et communication en premier.'
                          : 'Content tailored for partners: support and communication first.',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (isPartnerMode) const SizedBox(height: AppSpacing.sm),
        if (reminderCard != null) ...[
          reminderCard,
          const SizedBox(height: AppSpacing.sm),
        ],
        ...sections,
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _PhaseExpandable extends StatelessWidget {
  const _PhaseExpandable({required this.phase, required this.language});

  final PhaseData phase;
  final String language;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ExpansionTile(
      title: Text(
        '${phase.name(language)} (j${phase.dayRange})',
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                phase.description(language),
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                phase.hormoneHint(language),
                style: theme.textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                language == 'fr' ? 'Physique' : 'Physical',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              ...phase
                  .physical(language)
                  .map(
                    (s) => Padding(
                      padding: const EdgeInsets.only(left: AppSpacing.sm),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('• ', style: theme.textTheme.bodyMedium),
                          Expanded(
                            child: Text(s, style: theme.textTheme.bodyMedium),
                          ),
                        ],
                      ),
                    ),
                  ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                language == 'fr' ? 'Émotionnel' : 'Emotional',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              ...phase
                  .emotional(language)
                  .map(
                    (s) => Padding(
                      padding: const EdgeInsets.only(left: AppSpacing.sm),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('• ', style: theme.textTheme.bodyMedium),
                          Expanded(
                            child: Text(s, style: theme.textTheme.bodyMedium),
                          ),
                        ],
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ],
    );
  }
}
