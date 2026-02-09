import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:nousdeux/core/constants/app_spacing.dart';
import 'package:nousdeux/presentation/providers/auth_provider.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _phoneController = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      setState(() => _error = 'Entrez votre numéro');
      return;
    }
    setState(() {
      _error = null;
      _loading = true;
    });
    final repo = ref.read(authRepositoryProvider);
    final result = await repo.signInWithOtp(
      phone: phone.startsWith('+') ? phone : '+33$phone',
    );
    if (!mounted) return;
    setState(() => _loading = false);
    if (result.failure != null) {
      setState(() => _error = result.failure!.message ?? 'Erreur');
      return;
    }
    context.push(
      '/auth/verify',
      extra: {'phone': phone.startsWith('+') ? phone : '+33$phone'},
    );
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _error = null;
      _loading = true;
    });
    final repo = ref.read(authRepositoryProvider);
    final result = await repo.signInWithGoogle();
    if (!mounted) return;
    setState(() => _loading = false);
    if (result.failure != null) {
      setState(() => _error = result.failure!.message ?? 'Erreur');
    }
  }

  Future<void> _signInWithApple() async {
    setState(() {
      _error = null;
      _loading = true;
    });
    final repo = ref.read(authRepositoryProvider);
    final result = await repo.signInWithApple();
    if (!mounted) return;
    setState(() => _loading = false);
    if (result.failure != null) {
      setState(() => _error = result.failure!.message ?? 'Erreur');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
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
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Nous Deux',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Connectez-vous pour continuer',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Numéro de téléphone',
                  hintText: '+33 6 12 34 56 78',
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(_error!, style: TextStyle(color: colorScheme.error)),
              ],
              const SizedBox(height: AppSpacing.sm),
              FilledButton(
                onPressed: _loading ? null : _sendOtp,
                child: _loading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.onPrimary,
                        ),
                      )
                    : const Text('Envoyer le code'),
              ),
              const SizedBox(height: AppSpacing.md),
              const Divider(),
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton.icon(
                onPressed: _loading ? null : _signInWithGoogle,
                icon: const Icon(Icons.g_mobiledata, size: 24),
                label: const Text('Continuer avec Google'),
              ),
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton.icon(
                onPressed: _loading ? null : _signInWithApple,
                icon: const Icon(Icons.apple, size: 24),
                label: const Text('Continuer avec Apple'),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }
}
