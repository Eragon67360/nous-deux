import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nousdeux/core/constants/app_spacing.dart';
import 'package:nousdeux/core/constants/settings_strings.dart';
import 'package:nousdeux/presentation/providers/location_provider.dart';
import 'package:nousdeux/presentation/providers/pairing_provider.dart';
import 'package:nousdeux/presentation/providers/period_provider.dart';
import 'package:nousdeux/presentation/providers/profile_provider.dart';
import 'package:nousdeux/presentation/providers/settings_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(myProfileProvider);
    final lang = profileAsync.valueOrNull?.language ?? 'fr';
    final avatarState = ref.watch(avatarControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(settingsTitle(lang)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(permissionsProvider);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(settingsPermissionsReloadDone(lang)),
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            tooltip: settingsPermissionsReloadTooltip(lang),
          ),
        ],
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (profile) {
          if (profile == null) return const SizedBox.shrink();

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              // 1. Profile Header
              _ProfileHeaderSection(
                profile: profile,
                lang: lang,
                isUploading: avatarState.isLoading,
                onEditAvatar: () => ref
                    .read(avatarControllerProvider.notifier)
                    .pickAndUploadAvatar(context),
                onEditUsername: () => _showEditUsernameDialog(
                  context,
                  ref,
                  profile.username,
                  lang,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // 2. Language
              _SettingsGroup(
                title: settingsLanguage(lang),
                children: [
                  _LanguageTile(lang: lang),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // 3. Account & Info Group
              _SettingsGroup(
                title: settingsAboutApp(lang),
                children: [
                  _SettingsTile(
                    icon: Icons.info_outline,
                    title: settingsAboutApp(lang),
                    onTap: () => context.push('/main/settings/info'),
                  ),
                  _SettingsTile(
                    icon: Icons.settings_applications_outlined,
                    title: settingsOpenAppSettings(lang),
                    onTap: () => openAppSettings(),
                    showChevron: false,
                    trailing: const Icon(Icons.launch, size: 18),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // 3. Permissions Group
              _SettingsGroup(
                title: settingsPermissions(lang),
                children: const [_PermissionsListBody()],
              ),
              const SizedBox(height: AppSpacing.lg),

              // 4. Position / Share location Group
              _SettingsGroup(
                title: settingsLocation(lang),
                children: const [_LocationSharingSwitchBody()],
              ),
              const SizedBox(height: AppSpacing.lg),

              // 6. Notifications Group
              _SettingsGroup(
                title: settingsNotifications(lang),
                children: const [_NotificationSwitchesBody()],
              ),

              // Bottom spacing
              const SizedBox(height: AppSpacing.lg),
            ],
          );
        },
      ),
    );
  }

  void _showEditUsernameDialog(
    BuildContext context,
    WidgetRef ref,
    String? current,
    String lang,
  ) {
    final controller = TextEditingController(text: current ?? '');
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(settingsEditUsername(lang)),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: settingsUsername(lang),
            hintText: lang == 'fr' ? 'Prénom ou pseudo' : 'Name or nickname',
            border: const OutlineInputBorder(),
          ),
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          maxLines: null, // Allow wrapping in input
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(settingsCancel(lang)),
          ),
          FilledButton(
            onPressed: () async {
              final name = controller.text.trim();
              Navigator.pop(ctx);
              if (name.isEmpty) return;

              final result = await ref
                  .read(profileRepositoryProvider)
                  .updateProfile(username: name);
              ref.invalidate(myProfileProvider);

              if (result.failure != null && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(result.failure!.message ?? '')),
                );
              }
            },
            child: Text(settingsSave(lang)),
          ),
        ],
      ),
    );
  }
}

// --- Visual Components ---

class _ProfileHeaderSection extends StatelessWidget {
  final dynamic profile; // Replace with actual Profile type
  final String lang;
  final bool isUploading;
  final VoidCallback onEditAvatar;
  final VoidCallback onEditUsername;

  const _ProfileHeaderSection({
    required this.profile,
    required this.lang,
    required this.isUploading,
    required this.onEditAvatar,
    required this.onEditUsername,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasAvatar = profile.avatarUrl != null;

    return Column(
      children: [
        Stack(
          children: [
            GestureDetector(
              onTap: isUploading ? null : onEditAvatar,
              child: CircleAvatar(
                radius: 50,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                backgroundImage: hasAvatar
                    ? NetworkImage(profile.avatarUrl!)
                    : null,
                child: isUploading
                    ? const CircularProgressIndicator()
                    : (!hasAvatar
                          ? Icon(
                              Icons.person,
                              size: 40,
                              color: theme.colorScheme.onSurfaceVariant,
                            )
                          : null),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Material(
                color: theme.colorScheme.primary,
                shape: const CircleBorder(),
                elevation: 2,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: onEditAvatar,
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(Icons.edit, size: 16, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        InkWell(
          onTap: onEditUsername,
          borderRadius: BorderRadius.circular(AppSpacing.sm),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    profile.username?.trim().isNotEmpty == true
                        ? profile.username!
                        : '—',
                    style: theme.textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                    // FORCE WRAP: No ellipsis
                    softWrap: true,
                    overflow: TextOverflow.visible,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.edit_outlined,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsGroup({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: AppSpacing.sm,
            bottom: AppSpacing.xs,
          ),
          child: Text(
            title.toUpperCase(),
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
            // Ensure title wraps if device text scale is huge
            softWrap: true,
          ),
        ),
        Card(
          elevation: 0,
          color: theme.colorScheme.surfaceContainer,
          clipBehavior: Clip.antiAlias,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: children.map((child) {
              // Add dividers between items, but not after the last one
              final index = children.indexOf(child);
              return Column(
                children: [
                  child,
                  if (index != children.length - 1)
                    Divider(
                      height: 1,
                      thickness: 1,
                      indent: 56,
                      color: theme.colorScheme.surface,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData? icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final bool showChevron;
  final VoidCallback? onTap;

  const _SettingsTile({
    this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.showChevron = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: 16),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyLarge,
                    // CRITICAL: No ellipsis
                    softWrap: true,
                    overflow: TextOverflow.visible,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      // CRITICAL: No ellipsis
                      softWrap: true,
                      overflow: TextOverflow.visible,
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 8), trailing!],
            if (showChevron) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                size: 20,
                color: theme.colorScheme.outline,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _LanguageTile extends ConsumerWidget {
  const _LanguageTile({required this.lang});
  final String lang;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentLabel =
        lang == 'fr' ? settingsLanguageFrench(lang) : settingsLanguageEnglish(lang);

    return InkWell(
      onTap: () => _showLanguageDialog(context, ref, lang),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.language, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                settingsLanguage(lang),
                style: theme.textTheme.bodyLarge,
                softWrap: true,
                overflow: TextOverflow.visible,
              ),
            ),
            Text(
              currentLabel,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: theme.colorScheme.outline,
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, WidgetRef ref, String currentLang) {
    final screenContext = context;
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(settingsLanguage(currentLang)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: Text(settingsLanguageFrench(currentLang)),
                value: 'fr',
                groupValue: currentLang,
                onChanged: (v) => _selectLanguage(screenContext, dialogContext, ref, v!),
              ),
              RadioListTile<String>(
                title: Text(settingsLanguageEnglish(currentLang)),
                value: 'en',
                groupValue: currentLang,
                onChanged: (v) => _selectLanguage(screenContext, dialogContext, ref, v!),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _selectLanguage(
    BuildContext screenContext,
    BuildContext dialogContext,
    WidgetRef ref,
    String newLang,
  ) async {
    Navigator.of(dialogContext).pop();
    final repo = ref.read(profileRepositoryProvider);
    final result = await repo.updateProfile(language: newLang);
    ref.invalidate(myProfileProvider);
    if (!screenContext.mounted) return;
    if (result.failure != null) {
      ScaffoldMessenger.of(screenContext).showSnackBar(
        SnackBar(content: Text(result.failure!.message ?? '')),
      );
    } else {
      ScaffoldMessenger.of(screenContext).showSnackBar(
        SnackBar(
          content: Text(settingsLanguageUpdated(newLang)),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}

class _PermissionsListBody extends ConsumerWidget {
  const _PermissionsListBody();

  String _statusText(PermissionStatus s, String lang) {
    switch (s) {
      case PermissionStatus.granted:
      case PermissionStatus.limited:
      case PermissionStatus.provisional:
        return settingsPermissionGranted(lang);
      case PermissionStatus.denied:
        return settingsPermissionDenied(lang);
      case PermissionStatus.restricted:
        return settingsPermissionRestricted(lang);
      case PermissionStatus.permanentlyDenied:
        return settingsPermissionPermanentDenied(lang);
    }
  }

  Color _statusColor(PermissionStatus s, ThemeData theme) {
    return s.isGranted ? theme.colorScheme.primary : theme.colorScheme.error;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(myProfileProvider).valueOrNull?.language ?? 'fr';
    final permsAsync = ref.watch(permissionsProvider);
    final theme = Theme.of(context);

    return permsAsync.when(
      data: (statuses) {
        final items = [
          (Permission.calendar, settingsCalendars(lang)),
          (Permission.notification, settingsNotificationsPerm(lang)),
          (Permission.location, settingsLocation(lang)),
          (Permission.camera, settingsCamera(lang)),
        ];

        return Column(
          children: [
            for (var i = 0; i < items.length; i++) ...[
              if (i > 0)
                Divider(
                  height: 1,
                  indent: 16,
                  color: theme.colorScheme.surface,
                ),
              InkWell(
                onTap: openAppSettings,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          items[i].$2,
                          style: theme.textTheme.bodyMedium,
                          softWrap: true,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Status Text
                      Container(
                        constraints: const BoxConstraints(
                          maxWidth: 120,
                        ), // Prevent taking whole row
                        child: Text(
                          _statusText(
                            statuses[items[i].$1] ?? PermissionStatus.denied,
                            lang,
                          ),
                          textAlign: TextAlign.end,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: _statusColor(
                              statuses[items[i].$1] ?? PermissionStatus.denied,
                              theme,
                            ),
                            fontWeight: FontWeight.bold,
                          ),
                          softWrap:
                              true, // Allow status text to wrap if translation is long
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _LocationSharingSwitchBody extends ConsumerWidget {
  const _LocationSharingSwitchBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(myProfileProvider).valueOrNull?.language ?? 'fr';
    final theme = Theme.of(context);
    final coupleAsync = ref.watch(myCoupleProvider);
    final locationAsync = ref.watch(myLocationSharingProvider);

    return coupleAsync.when(
      data: (couple) {
        final hasCouple = couple != null;
        return locationAsync.when(
          data: (myLocation) {
            final isSharing = myLocation?.isSharing ?? false;
            return SwitchListTile.adaptive(
              title: Text(settingsShareMyLocation(lang), softWrap: true),
              subtitle: Text(
                settingsShareMyLocationSubtitle(lang),
                softWrap: true,
                style: theme.textTheme.bodySmall,
              ),
              value: isSharing,
              activeColor: theme.colorScheme.primary,
              onChanged: hasCouple ? (v) => _onLocationSharingChanged(context, ref, couple.id, v, lang) : null,
            );
          },
          loading: () => const Padding(
            padding: EdgeInsets.all(16),
            child: LinearProgressIndicator(),
          ),
          error: (_, __) => const SizedBox.shrink(),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Future<void> _onLocationSharingChanged(
    BuildContext context,
    WidgetRef ref,
    String coupleId,
    bool enable,
    String lang,
  ) async {
    if (enable) {
      final status = await Permission.location.request();
      final allowed = status.isGranted ||
          status == PermissionStatus.limited ||
          status == PermissionStatus.provisional;
      if (!allowed) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(settingsLocationRequiredForSharing(lang)),
              behavior: SnackBarBehavior.floating,
              action: status.isPermanentlyDenied
                  ? SnackBarAction(
                      label: settingsOpenAppSettings(lang),
                      onPressed: openAppSettings,
                    )
                  : null,
            ),
          );
        }
        return;
      }
    }

    final repo = ref.read(locationRepositoryProvider);
    final result = await repo.setMyLocationSharing(
      isSharing: enable,
      coupleId: coupleId,
      lat: null,
      lng: null,
    );
    ref.invalidate(myLocationSharingProvider);
    if (result.failure != null && result.failure!.message != null) {
      return;
    }
    if (enable) {
      await ref.read(locationUpdateNotifierProvider.notifier).pushCurrentPosition();
    }
  }
}

class _NotificationSwitchesBody extends ConsumerWidget {
  const _NotificationSwitchesBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(myProfileProvider).valueOrNull?.language ?? 'fr';
    final theme = Theme.of(context);
    final periodEnabled = ref.watch(partnerReminderEnabledProvider);
    final calendarEnabled = ref.watch(calendarPrefsProvider);

    return Column(
      children: [
        periodEnabled.when(
          data: (enabled) => SwitchListTile.adaptive(
            title: Text(settingsPeriodReminder(lang), softWrap: true),
            value: enabled,
            activeColor: theme.colorScheme.primary,
            onChanged: (v) =>
                setPartnerReminderEnabled(ref, enabled: v, lang: lang),
          ),
          loading: () => const Padding(
            padding: EdgeInsets.all(16),
            child: LinearProgressIndicator(),
          ),
          error: (_, __) => const SizedBox.shrink(),
        ),
        Divider(height: 1, indent: 16, color: theme.colorScheme.surface),
        calendarEnabled.when(
          data: (enabled) => SwitchListTile.adaptive(
            title: Text(settingsCalendarReminders(lang), softWrap: true),
            subtitle: Text(
              settingsCalendarRemindersSubtitle(lang),
              softWrap: true,
              style: theme.textTheme.bodySmall,
            ),
            value: enabled,
            activeColor: theme.colorScheme.primary,
            onChanged: (v) =>
                ref.read(calendarPrefsProvider.notifier).toggle(v),
          ),
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }
}
