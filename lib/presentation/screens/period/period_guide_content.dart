import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nousdeux/core/constants/app_spacing.dart';
import 'package:nousdeux/core/constants/period_education.dart';
import 'package:nousdeux/core/constants/period_guide_sections.dart';
import 'package:nousdeux/core/constants/period_reminder_prefs.dart';
import 'package:nousdeux/core/constants/period_verified_sources.dart';
import 'package:nousdeux/core/services/period_guide_analytics.dart';
import 'package:nousdeux/core/utils/app_log.dart';
import 'package:nousdeux/presentation/providers/period_provider.dart';
import 'package:nousdeux/presentation/widgets/period_cycle_timeline.dart';
import 'package:nousdeux/presentation/widgets/period_external_source_card.dart';
import 'package:nousdeux/presentation/widgets/period_guide_toc.dart';
import 'package:nousdeux/presentation/widgets/period_quick_ref_card.dart';
import 'package:nousdeux/presentation/widgets/period_tip_of_the_day.dart';

/// Scrollable educational guide content for the Period feature.
class PeriodGuideContent extends ConsumerStatefulWidget {
  const PeriodGuideContent({
    super.key,
    required this.language,
    this.phase,
    this.isPartnerMode = false,
    this.partnerPathOnly = false,
    this.visibleSectionIds,
  });

  final String language;
  final CyclePhase? phase;
  final bool isPartnerMode;
  /// When true, show only sections in [partnerPathSections].
  final bool partnerPathOnly;
  /// When non-null, show only these sections (e.g. from search filter).
  final Set<PeriodGuideSection>? visibleSectionIds;

  @override
  ConsumerState<PeriodGuideContent> createState() => _PeriodGuideContentState();
}

class _PeriodGuideContentState extends ConsumerState<PeriodGuideContent> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  late final Map<PeriodGuideSection, GlobalKey> _sectionKeys;
  String _searchQuery = '';
  Set<PeriodGuideSection> _bookmarkedSections = {};
  Set<PeriodGuideSection> _readSections = {};

  @override
  void initState() {
    super.initState();
    _sectionKeys = {
      for (final s in PeriodGuideSection.values) s: GlobalKey(),
    };
    _searchController.addListener(() {
      if (_searchQuery != _searchController.text) {
        setState(() => _searchQuery = _searchController.text);
      }
    });
    _loadBookmarks();
    _loadReadSections();
  }

  Future<void> _loadReadSections() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(periodGuideReadSectionsKey) ?? '';
    final names = raw.split(',').where((s) => s.isNotEmpty).toSet();
    if (mounted) {
      setState(() {
        _readSections = PeriodGuideSection.values
            .where((e) => names.contains(e.name))
            .toSet();
      });
    }
  }

  Future<void> _markSectionRead(PeriodGuideSection section) async {
    if (_readSections.contains(section)) return;
    final next = Set<PeriodGuideSection>.from(_readSections)..add(section);
    setState(() => _readSections = next);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      periodGuideReadSectionsKey,
      next.map((e) => e.name).join(','),
    );
  }

  Future<void> _loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(periodGuideBookmarksKey) ?? '';
    final names = raw.split(',').where((s) => s.isNotEmpty).toSet();
    if (mounted) {
      setState(() {
        _bookmarkedSections = PeriodGuideSection.values
            .where((e) => names.contains(e.name))
            .toSet();
      });
    }
  }

  Future<void> _toggleBookmark(PeriodGuideSection section) async {
    final next = Set<PeriodGuideSection>.from(_bookmarkedSections);
    if (next.contains(section)) {
      next.remove(section);
    } else {
      next.add(section);
    }
    setState(() => _bookmarkedSections = next);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      periodGuideBookmarksKey,
      next.map((e) => e.name).join(','),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Set<PeriodGuideSection> get _visibleSections {
    if (widget.visibleSectionIds != null) return widget.visibleSectionIds!;
    if (_searchQuery.trim().isNotEmpty) {
      return periodGuideSectionsMatchingQuery(_searchQuery, widget.language);
    }
    if (widget.partnerPathOnly) return partnerPathSections;
    return periodGuideSectionOrder.toSet();
  }

  void _scrollToSection(PeriodGuideSection section) {
    appLog(
      'PERIOD_GUIDE',
      message: 'TOC tap: section=${section.name}',
      color: '\x1B[35m',
    );

    void doScroll() {
      final key = _sectionKeys[section];
      final ctx = key?.currentContext;
      appLog(
        'PERIOD_GUIDE',
        message:
            'doScroll: section=${section.name} hasContext=${ctx != null} mounted=$mounted',
        color: '\x1B[35m',
      );
      if (ctx != null && mounted) {
        try {
          Scrollable.ensureVisible(
            ctx,
            alignment: 0.2,
            duration: const Duration(milliseconds: 300),
          );
          appLog(
            'PERIOD_GUIDE',
            message: 'ensureVisible called for ${section.name}',
            color: '\x1B[32m',
          );
          _markSectionRead(section);
          PeriodGuideAnalytics.recordSectionView(section);
        } catch (e, st) {
          appLog(
            'PERIOD_GUIDE',
            message: 'ensureVisible error: $e\n$st',
            color: '\x1B[31m',
          );
        }
      } else {
        appLog(
          'PERIOD_GUIDE',
          message:
              'skip scroll: ctx=${ctx != null} mounted=$mounted (key exists: ${key != null})',
          color: '\x1B[33m',
        );
      }
    }

    final hasContextNow = _sectionKeys[section]?.currentContext != null;
    appLog(
      'PERIOD_GUIDE',
      message: 'context available immediately: $hasContextNow',
      color: '\x1B[35m',
    );
    if (hasContextNow) {
      doScroll();
    } else {
      appLog(
        'PERIOD_GUIDE',
        message: 'scheduling post-frame callback for ${section.name}',
        color: '\x1B[33m',
      );
      WidgetsBinding.instance.addPostFrameCallback((_) => doScroll());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final language = widget.language;
    final phase = widget.phase;
    final isPartnerMode = widget.isPartnerMode;
    final reminderEnabledAsync = ref.watch(partnerReminderEnabledProvider);
    final nextPmsDate = ref.watch(nextPartnerPmsDateProvider);
    final visible = _visibleSections;

    Widget wrapSection(PeriodGuideSection id, List<Widget> children) {
      if (!visible.contains(id)) return const SizedBox.shrink();
      return Column(
        key: _sectionKeys[id],
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      );
    }

    final sections = <Widget>[
      wrapSection(PeriodGuideSection.tip, [
        PeriodTipOfTheDay(language: language, phase: phase),
        const SizedBox(height: AppSpacing.md),
      ]),
      wrapSection(PeriodGuideSection.cycle, [
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
      ]),
      wrapSection(PeriodGuideSection.bodyMind, [
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
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    language == 'fr' ? 'En savoir plus' : 'Learn more',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  ...sourcesWhenToSeekHelp.take(2).map(
                    (s) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: PeriodExternalSourceCard(
                        source: s,
                        language: language,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
      ]),
      wrapSection(PeriodGuideSection.partnerSupport, [
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
                const SizedBox(height: AppSpacing.sm),
                Text(
                  language == 'fr' ? 'En savoir plus' : 'Learn more',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                ...sourcesPartnerSupport.take(2).map(
                  (s) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: PeriodExternalSourceCard(
                      source: s,
                      language: language,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
      ]),
      wrapSection(PeriodGuideSection.communication, [
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
      ]),
      wrapSection(PeriodGuideSection.mythBusters, [
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
      ]),
      wrapSection(PeriodGuideSection.quickRef, [
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
      ]),
      wrapSection(PeriodGuideSection.faq, [
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
      ]),
      wrapSection(PeriodGuideSection.disclaimer, [
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
      ]),
      _GuideFeedbackRow(language: language),
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

    final progressValue = periodGuideSectionOrder.isEmpty
        ? 0.0
        : _readSections.length / periodGuideSectionOrder.length;

    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
        if (periodGuideSectionOrder.isNotEmpty) ...[
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: progressValue,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '${_readSections.length}/${periodGuideSectionOrder.length}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        PeriodGuideToc(
          language: language,
          visibleSections: visible,
          onSectionTap: _scrollToSection,
          bookmarkedSections: _bookmarkedSections,
          onBookmarkToggle: _toggleBookmark,
          readSections: _readSections,
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: language == 'fr' ? 'Rechercher dans le guide…' : 'Search in guide…',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            isDense: true,
          ),
          onChanged: (value) => setState(() => _searchQuery = value),
        ),
        if (_searchQuery.trim().isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            language == 'fr'
                ? 'Sections correspondant à votre recherche'
                : 'Sections matching your search',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        if (_bookmarkedSections.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.bookmark,
                        size: 20,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        language == 'fr' ? 'Enregistrés' : 'Saved',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ..._bookmarkedSections.map(
                    (section) => ListTile(
                      title: Text(
                        periodGuideSectionTitle(section, language),
                        style: theme.textTheme.bodyMedium,
                      ),
                      trailing: const Icon(Icons.chevron_right, size: 20),
                      onTap: () => _scrollToSection(section),
                      contentPadding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.md),
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
      ),
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
    return Semantics(
      header: true,
      child: Column(
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
      ),
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

class _GuideFeedbackRow extends StatefulWidget {
  const _GuideFeedbackRow({required this.language});

  final String language;

  @override
  State<_GuideFeedbackRow> createState() => _GuideFeedbackRowState();
}

class _GuideFeedbackRowState extends State<_GuideFeedbackRow> {
  bool _voted = false;

  @override
  Widget build(BuildContext context) {
    if (_voted) return const SizedBox(height: AppSpacing.lg);
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        children: [
          Text(
            widget.language == 'fr'
                ? 'Ce guide vous a-t-il été utile ?'
                : 'Was this guide useful?',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(width: AppSpacing.sm),
          IconButton(
            icon: const Icon(Icons.thumb_up_outlined),
            onPressed: () {
              setState(() => _voted = true);
              PeriodGuideAnalytics.recordGuideFeedback(useful: true);
            },
          ),
          IconButton(
            icon: const Icon(Icons.thumb_down_outlined),
            onPressed: () {
              setState(() => _voted = true);
              PeriodGuideAnalytics.recordGuideFeedback(useful: false);
            },
          ),
        ],
      ),
    );
  }
}
