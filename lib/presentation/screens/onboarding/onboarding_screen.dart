import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nousdeux/core/constants/app_spacing.dart';
import 'package:nousdeux/core/constants/onboarding_strings.dart';
import 'package:nousdeux/presentation/providers/profile_provider.dart';
import 'package:nousdeux/presentation/widgets/entrance.dart';

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final lang = _language;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.lg),
              Entrance(
                child: Text(
                  onboardingTitle(lang),
                  style: theme.textTheme.displaySmall,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Entrance(
                delay: const Duration(milliseconds: 60),
                child: Text(
                  onboardingSubtitle(lang),
                  style: theme.textTheme.bodyLarge,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Entrance(
                delay: const Duration(milliseconds: 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _displayNameController,
                      autofocus: true,
                      autofillHints: const [AutofillHints.givenName],
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        labelText: onboardingDisplayNameLabel(lang),
                        hintText: onboardingDisplayNameHint(lang),
                        errorText: _error,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _Label(onboardingGender(lang)),
                    SegmentedButton<String>(
                      showSelectedIcon: false,
                      segments: [
                        ButtonSegment(
                          value: 'woman',
                          label: Text(onboardingWoman(lang)),
                        ),
                        ButtonSegment(
                          value: 'man',
                          label: Text(onboardingMan(lang)),
                        ),
                      ],
                      selected: {_gender},
                      onSelectionChanged: (v) =>
                          setState(() => _gender = v.first),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _Label(onboardingLanguageLabel(lang)),
                    SegmentedButton<String>(
                      showSelectedIcon: false,
                      segments: [
                        ButtonSegment(
                          value: 'fr',
                          label: Text(onboardingFrench(lang)),
                        ),
                        ButtonSegment(
                          value: 'en',
                          label: Text(onboardingEnglish(lang)),
                        ),
                      ],
                      selected: {_language},
                      onSelectionChanged: (v) =>
                          setState(() => _language = v.first),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
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

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Text(text, style: Theme.of(context).textTheme.titleSmall),
    );
  }
}
