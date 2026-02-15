import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:nousdeux/core/constants/app_spacing.dart';
import 'package:nousdeux/core/constants/period_ui_strings.dart';
import 'package:nousdeux/core/constants/period_verified_sources.dart';
import 'package:nousdeux/core/services/period_guide_analytics.dart';

/// Card that shows a verified external source and opens the URL on tap.
class PeriodExternalSourceCard extends StatelessWidget {
  const PeriodExternalSourceCard({
    super.key,
    required this.source,
    required this.language,
  });

  final VerifiedSource source;
  final String language;

  Future<void> _openUrl(BuildContext context, String url) async {
    PeriodGuideAnalytics.recordExternalLinkClick(source);
    final uri = Uri.parse(url);

    // Determine the best launch mode based on the platform type
    LaunchMode mode;
    switch (source.platform) {
      case VerifiedSourcePlatform.instagram:
      case VerifiedSourcePlatform.youtube:
        // Force external application (Deep Link) for social apps
        mode = LaunchMode.externalApplication;
        break;
      case VerifiedSourcePlatform.web:
      case VerifiedSourcePlatform.other:
      default:
        // Use Platform Default (Custom Tabs / Safari VC) for standard websites
        mode = LaunchMode.platformDefault;
        break;
    }

    try {
      // 1. Try with the preferred mode
      final success = await launchUrl(uri, mode: mode);

      // 2. Fallback: If external app failed (e.g. app not installed), try browser
      if (!success && mode == LaunchMode.externalApplication) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      } else if (!success) {
        throw Exception('Could not launch url');
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              periodCouldNotOpenLink(language),
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      button: true,
      label:
          '${source.name(language)}, ${source.platformLabel(language)}. ${source.summary(language)}',
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _openUrl(context, source.url),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(
                      _iconForPlatform(source.platform),
                      size: 22,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        source.name(language),
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Icon(
                      Icons.open_in_new,
                      size: 18,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${source.platformLabel(language)} · ${source.credential(language)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  source.summary(language),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _iconForPlatform(VerifiedSourcePlatform platform) {
    switch (platform) {
      case VerifiedSourcePlatform.web:
        return Icons.language;
      case VerifiedSourcePlatform.youtube:
        return Icons.play_circle_outline;
      case VerifiedSourcePlatform.instagram:
        return Icons.camera_alt_outlined;
      case VerifiedSourcePlatform.other:
        return Icons.link;
    }
  }
}
