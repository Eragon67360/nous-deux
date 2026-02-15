import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nousdeux/core/constants/app_spacing.dart';
import 'package:nousdeux/core/constants/onboarding_strings.dart';
import 'package:nousdeux/presentation/providers/profile_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _displayNameController = TextEditingController();
  String _gender = 'woman';
  String _language = 'fr';
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _displayNameController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = onboardingErrorDisplayName(_language));
      return;
    }
    setState(() {
      _error = null;
      _loading = true;
    });
    final repo = ref.read(profileRepositoryProvider);
    final result = await repo.completeOnboarding(
      username: name,
      gender: _gender,
      language: _language,
    );
    if (!mounted) return;
    setState(() => _loading = false);
    if (result.failure != null) {
      setState(
        () => _error = result.failure!.message ?? onboardingErrorGeneric(_language),
      );
      return;
    }
    ref.invalidate(myProfileProvider);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final lang = _language;
    return Scaffold(
      appBar: AppBar(title: Text(onboardingTitle(lang))),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.sm),
              Text(
                onboardingSubtitle(lang),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _displayNameController,
                decoration: InputDecoration(
                  labelText: onboardingDisplayNameLabel(lang),
                  hintText: onboardingDisplayNameHint(lang),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(onboardingGender(lang),
                  style: Theme.of(context).textTheme.titleSmall),
              RadioListTile<String>(
                title: Text(onboardingWoman(lang)),
                value: 'woman',
                groupValue: _gender,
                onChanged: (v) => setState(() => _gender = v!),
              ),
              RadioListTile<String>(
                title: Text(onboardingMan(lang)),
                value: 'man',
                groupValue: _gender,
                onChanged: (v) => setState(() => _gender = v!),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(onboardingLanguageLabel(lang),
                  style: Theme.of(context).textTheme.titleSmall),
              RadioListTile<String>(
                title: Text(onboardingFrench(lang)),
                value: 'fr',
                groupValue: _language,
                onChanged: (v) => setState(() => _language = v!),
              ),
              RadioListTile<String>(
                title: Text(onboardingEnglish(lang)),
                value: 'en',
                groupValue: _language,
                onChanged: (v) => setState(() => _language = v!),
              ),
              if (_error != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(_error!, style: TextStyle(color: colorScheme.error)),
              ],
              const SizedBox(height: AppSpacing.lg),
              FilledButton(
                onPressed: _loading ? null : _save,
                child: _loading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.onPrimary,
                        ),
                      )
                    : Text(onboardingContinue(lang)),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }
}
