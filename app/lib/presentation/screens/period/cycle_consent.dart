import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:nousdeux/core/constants/cycle_strings.dart';
import 'package:nousdeux/core/constants/period_education.dart';

/// What tracking a cycle means for the person's data, with the privacy
/// policy one tap away. Shown wherever tracking is turned on: cycle data is
/// health data, so it is kept only with explicit consent.
class CycleConsentText extends StatelessWidget {
  const CycleConsentText({super.key, required this.lang});

  final String lang;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          cycleConsent(lang),
          style: theme.textTheme.bodyMedium?.copyWith(
            height: 1.5,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        TextButton.icon(
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: const Size(44, 44),
          ),
          onPressed: () => launchUrl(Uri.parse(cyclePrivacyUrl(lang))),
          icon: const Icon(Icons.open_in_new, size: 16),
          label: Text(cyclePrivacyPolicy(lang)),
        ),
      ],
    );
  }
}

/// Asks for consent before tracking is turned on from Settings. True when
/// the person agrees.
Future<bool> confirmCycleConsent(BuildContext context, String lang) async {
  final agreed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(cycleConsentTitle(lang)),
      content: SingleChildScrollView(child: CycleConsentText(lang: lang)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(periodCancel(lang)),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(cycleConsentAccept(lang)),
        ),
      ],
    ),
  );
  return agreed ?? false;
}

/// What to do with the data when tracking stops.
enum StopTracking { keepData, deleteData }

/// Asks whether to keep or delete the cycle data when tracking stops; null
/// when the person changes their mind.
Future<StopTracking?> askStopTracking(BuildContext context, String lang) {
  return showDialog<StopTracking>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(cycleStopTitle(lang)),
      content: Text(cycleStopBody(lang)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text(periodCancel(lang)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, StopTracking.deleteData),
          child: Text(cycleStopDelete(lang)),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, StopTracking.keepData),
          child: Text(cycleStopKeep(lang)),
        ),
      ],
    ),
  );
}
