import 'package:flutter/material.dart';

import 'package:nousdeux/core/constants/app_spacing.dart';

/// A compact card with title and bullet list; optionally expandable.
class PeriodQuickRefCard extends StatelessWidget {
  const PeriodQuickRefCard({
    super.key,
    required this.title,
    required this.bullets,
    this.initiallyExpanded = false,
  });

  final String title;
  final List<String> bullets;
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.sm, 0, AppSpacing.sm, AppSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: bullets
                  .map(
                    (b) => Padding(
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
                              b,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
