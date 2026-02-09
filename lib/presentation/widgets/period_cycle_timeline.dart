import 'package:flutter/material.dart';

import 'package:nousdeux/core/constants/app_spacing.dart';
import 'package:nousdeux/core/constants/period_education.dart';

/// Horizontal timeline of the 4 menstrual cycle phases with day ranges.
class PeriodCycleTimeline extends StatelessWidget {
  const PeriodCycleTimeline({super.key, required this.language});

  final String language;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final colors = [
      colorScheme.primaryContainer,
      colorScheme.surfaceContainerHighest,
      colorScheme.primary.withValues(alpha: 0.25),
      colorScheme.surfaceContainerHigh,
    ];
    return Semantics(
      label: 'Cycle phases timeline',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: List.generate(cyclePhasesData.length, (i) {
              final phase = cyclePhasesData[i];
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(
                    right: i < cyclePhasesData.length - 1 ? 2 : 0,
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.sm,
                    horizontal: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: colors[i % colors.length],
                    borderRadius: BorderRadius.horizontal(
                      left: Radius.circular(i == 0 ? 12 : 4),
                      right: Radius.circular(
                        i == cyclePhasesData.length - 1 ? 12 : 4,
                      ),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        phase.name(language),
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'J${phase.dayRange}',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
