import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nousdeux/core/constants/app_spacing.dart';
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
      setState(() => _error = 'Entrez un nom d\'affichage');
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
      setState(() => _error = result.failure!.message ?? 'Erreur');
      return;
    }
    ref.invalidate(myProfileProvider);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Configurez votre compte')),
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
                'Une dernière étape pour personnaliser votre compte.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _displayNameController,
                decoration: const InputDecoration(
                  labelText: 'Nom d\'affichage',
                  hintText: 'Prénom ou pseudo',
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: AppSpacing.md),
              Text('Genre', style: Theme.of(context).textTheme.titleSmall),
              RadioListTile<String>(
                title: const Text('Femme'),
                value: 'woman',
                groupValue: _gender,
                onChanged: (v) => setState(() => _gender = v!),
              ),
              RadioListTile<String>(
                title: const Text('Homme'),
                value: 'man',
                groupValue: _gender,
                onChanged: (v) => setState(() => _gender = v!),
              ),
              const SizedBox(height: AppSpacing.md),
              Text('Langue', style: Theme.of(context).textTheme.titleSmall),
              RadioListTile<String>(
                title: const Text('Français'),
                value: 'fr',
                groupValue: _language,
                onChanged: (v) => setState(() => _language = v!),
              ),
              RadioListTile<String>(
                title: const Text('English'),
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
                    : const Text('Continuer'),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }
}
