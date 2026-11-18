import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nousdeux/core/constants/app_spacing.dart';
import 'package:nousdeux/core/constants/app_strings.dart';
import 'package:nousdeux/core/constants/settings_strings.dart';
import 'package:nousdeux/presentation/providers/auth_provider.dart';
import 'package:nousdeux/presentation/providers/locale_provider.dart';
import 'package:nousdeux/presentation/providers/profile_provider.dart';

/// Signed in, but the profile couldn't load at start (no network, a server
/// error). The session stays: "Réessayer" loads the profile again, and the
/// router moves on once it arrives. Signing out stays possible.
class ProfileUnavailableScreen extends ConsumerWidget {
  const ProfileUnavailableScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // No profile, so no profile language: the phone's.
    final lang = ref.watch(deviceLanguageProvider);
    final loading = ref.watch(myProfileProvider).isLoading;
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                profileUnavailableTitle(lang),
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                profileUnavailableBody(lang),
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: AppSpacing.xl),
              FilledButton(
                onPressed: loading
                    ? null
                    : () => ref.invalidate(myProfileProvider),
                child: loading
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(profileUnavailableRetry(lang)),
              ),
              const SizedBox(height: AppSpacing.xs),
              TextButton(
                onPressed: () => ref.read(authRepositoryProvider).signOut(),
                child: Text(settingsSignOut(lang)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
