import 'package:flutter/material.dart';

import 'package:nousdeux/core/constants/app_spacing.dart';
import 'package:nousdeux/core/constants/period_education.dart';

/// Tip of the day card based on current cycle phase.
class PeriodTipOfTheDay extends StatelessWidget {
  const PeriodTipOfTheDay({super.key, required this.language, this.phase});

  final String language;
  final CyclePhase? phase;

  @override
  Widget build(BuildContext context) {
    final tip = phase != null
        ? phaseTipFor(phase!).get(language)
        : tipFallback(language);
    return Semantics(
      label: tipOfTheDayTitle(language),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
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
                  Text(
                    tipOfTheDayTitle(language),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(tip, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}
