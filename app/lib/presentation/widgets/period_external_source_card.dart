import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:nousdeux/core/constants/period_ui_strings.dart';
import 'package:nousdeux/core/constants/period_verified_sources.dart';

/// A verified external source as a link line; opens it outside the app.
class PeriodExternalSourceCard extends StatelessWidget {
  const PeriodExternalSourceCard({
    super.key,
    required this.source,
    required this.language,
  });

  final VerifiedSource source;
  final String language;

  Future<void> _open(BuildContext context) async {
    final uri = Uri.parse(source.url);
    // Social links open their app; websites open in the in-app browser.
    final mode = switch (source.platform) {
      VerifiedSourcePlatform.instagram ||
      VerifiedSourcePlatform.youtube => LaunchMode.externalApplication,
      VerifiedSourcePlatform.web ||
      VerifiedSourcePlatform.other => LaunchMode.platformDefault,
    };
    var opened = false;
    try {
      opened = await launchUrl(uri, mode: mode);
      if (!opened && mode == LaunchMode.externalApplication) {
        opened = await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (_) {
      opened = false;
    }
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(periodCouldNotOpenLink(language))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Semantics(
      link: true,
      label:
          '${source.name(language)}, ${source.credential(language)}. ${source.summary(language)}',
      excludeSemantics: true,
      child: InkWell(
        onTap: () => _open(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      source.name(language),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: scheme.primary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${source.credential(language)} · ${source.summary(language)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Icon(Icons.open_in_new, size: 16, color: scheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
