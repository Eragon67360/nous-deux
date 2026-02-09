import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:nousdeux/core/constants/app_spacing.dart';
import 'package:nousdeux/core/constants/settings_strings.dart';
import 'package:nousdeux/presentation/providers/profile_provider.dart';

class AppInfoScreen extends ConsumerWidget {
  const AppInfoScreen({super.key});

  static const String _repoUrl = 'https://github.com/Eragon67360/nous-deux/';
  static const String _thomasGithubUrl = 'https://github.com/Eragon67360';

  Future<void> _openUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(myProfileProvider).valueOrNull?.language ?? 'fr';
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(appInfoTitle(lang))),
      body: Scrollbar(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Intro Text
              Text(
                appInfoDescription(lang),
                style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                softWrap: true,
              ),
              const SizedBox(height: AppSpacing.md),

              Text(
                appInfoFree(lang),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
                softWrap: true,
              ),
              const SizedBox(height: AppSpacing.xl),

              // Source Code
              _SectionTitle(title: appInfoSource(lang)),
              const SizedBox(height: AppSpacing.sm),
              InkWell(
                onTap: () => _openUrl(context, _repoUrl),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.code,
                        size: 20,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _repoUrl,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            decoration: TextDecoration.underline,
                            decorationColor: theme.colorScheme.primary
                                .withOpacity(0.5),
                          ),
                          // WRAP: Ensure long URL wraps
                          softWrap: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Contributors
              _SectionTitle(title: appInfoContributors(lang)),
              const SizedBox(height: AppSpacing.md),

              _ContributorCard(
                name: 'Thomas Moser',
                role: appInfoThomasMoser(lang),
                url: _thomasGithubUrl,
                onTap: () => _openUrl(context, _thomasGithubUrl),
              ),
              const SizedBox(height: AppSpacing.sm),
              _ContributorCard(
                name: 'Evah Baumlin',
                role: appInfoEvahBaumlin(lang),
              ),
              const SizedBox(height: AppSpacing.sm),
              _ContributorCard(
                name: lang == 'fr' ? 'Les amis' : 'Friends',
                role: appInfoFriends(lang),
              ),

              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      softWrap: true,
    );
  }
}

class _ContributorCard extends StatelessWidget {
  const _ContributorCard({
    required this.name,
    required this.role,
    this.url,
    this.onTap,
  });

  final String name;
  final String role;
  final String? url;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // We use a Card to group name and role visually
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.start, // Align top if multiline
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: TextStyle(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name Row
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            name,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              decoration: url != null
                                  ? TextDecoration.underline
                                  : null,
                            ),
                            // WRAP
                            softWrap: true,
                          ),
                        ),
                        if (url != null) ...[
                          const SizedBox(width: 4),
                          Icon(
                            Icons.open_in_new,
                            size: 14,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Role text
                    Text(
                      role,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      // WRAP: Ensure role description wraps
                      softWrap: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
