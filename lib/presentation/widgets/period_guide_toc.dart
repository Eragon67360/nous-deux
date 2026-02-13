import 'package:flutter/material.dart';

import 'package:nousdeux/core/constants/app_spacing.dart';
import 'package:nousdeux/core/constants/period_guide_sections.dart';

/// Table of contents for the Period Guide. Tapping an item scrolls to that section.
class PeriodGuideToc extends StatelessWidget {
  const PeriodGuideToc({
    super.key,
    required this.language,
    required this.visibleSections,
    required this.onSectionTap,
    this.bookmarkedSections = const {},
    this.onBookmarkToggle,
    this.readSections = const {},
  });

  final String language;
  final Set<PeriodGuideSection> visibleSections;
  final ValueChanged<PeriodGuideSection> onSectionTap;
  final Set<PeriodGuideSection> bookmarkedSections;
  final ValueChanged<PeriodGuideSection>? onBookmarkToggle;
  final Set<PeriodGuideSection> readSections;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sectionsToShow = periodGuideSectionOrder
        .where((s) => visibleSections.contains(s))
        .toList();

    return Semantics(
      label: language == 'fr' ? 'Sommaire du guide' : 'Guide table of contents',
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.xs,
            horizontal: AppSpacing.sm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                language == 'fr' ? 'Sommaire' : 'Table of contents',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              ...sectionsToShow.map(
                (section) => Semantics(
                  button: true,
                  label: '${language == 'fr' ? 'Aller à' : 'Go to'} ${periodGuideSectionTitle(section, language)}',
                  child: InkWell(
                    onTap: () => onSectionTap(section),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.xs,
                      horizontal: AppSpacing.xs,
                    ),
                    child: Row(
                      children: [
                        if (readSections.contains(section))
                          Icon(
                            Icons.check_circle,
                            size: 18,
                            color: theme.colorScheme.primary,
                          ),
                        if (readSections.contains(section))
                          const SizedBox(width: AppSpacing.xs),
                        Icon(
                          Icons.article_outlined,
                          size: 18,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            periodGuideSectionTitle(section, language),
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                        if (onBookmarkToggle != null)
                          IconButton(
                            tooltip: bookmarkedSections.contains(section)
                                ? (language == 'fr'
                                    ? 'Retirer des enregistrés'
                                    : 'Remove from saved')
                                : (language == 'fr'
                                    ? 'Enregistrer cette section'
                                    : 'Save this section'),
                            icon: Icon(
                              bookmarkedSections.contains(section)
                                  ? Icons.bookmark
                                  : Icons.bookmark_border,
                              size: 20,
                              color: bookmarkedSections.contains(section)
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurfaceVariant,
                            ),
                            onPressed: () => onBookmarkToggle!(section),
                            style: IconButton.styleFrom(
                              minimumSize: const Size(36, 36),
                              padding: EdgeInsets.zero,
                            ),
                          ),
                        Icon(
                          Icons.chevron_right,
                          size: 20,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ),
                ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
