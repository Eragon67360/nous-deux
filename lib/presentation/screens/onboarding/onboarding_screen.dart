import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nous_deux/presentation/providers/profile_provider.dart';

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
    return Scaffold(
      appBar: AppBar(title: const Text('Configurez votre compte')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              Text(
                'Une dernière étape pour personnaliser votre compte.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _displayNameController,
                decoration: const InputDecoration(
                  labelText: 'Nom d\'affichage',
                  hintText: 'Prénom ou pseudo',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 24),
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
              const SizedBox(height: 24),
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
                const SizedBox(height: 8),
                Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: 32),
              FilledButton(
                onPressed: _loading ? null : _save,
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Continuer'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
