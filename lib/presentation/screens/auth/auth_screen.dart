import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:nousdeux/core/constants/app_spacing.dart';
import 'package:nousdeux/core/constants/auth_strings.dart';
import 'package:nousdeux/presentation/providers/auth_provider.dart';
import 'package:nousdeux/presentation/providers/locale_provider.dart';

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

  Future<void> _sendOtp(String lang) async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      setState(() => _error = authErrorEnterPhone(lang));
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
      setState(() => _error = result.failure!.message ?? authErrorGeneric(lang));
      return;
    }
    context.push(
      '/auth/verify',
      extra: {'phone': phone.startsWith('+') ? phone : '+33$phone'},
    );
  }

  Future<void> _signInWithGoogle(String lang) async {
    setState(() {
      _error = null;
      _loading = true;
    });
    final repo = ref.read(authRepositoryProvider);
    final result = await repo.signInWithGoogle();
    if (!mounted) return;
    setState(() => _loading = false);
    if (result.failure != null) {
      setState(() => _error = result.failure!.message ?? authErrorGeneric(lang));
    }
  }

  Future<void> _signInWithApple(String lang) async {
    setState(() {
      _error = null;
      _loading = true;
    });
    final repo = ref.read(authRepositoryProvider);
    final result = await repo.signInWithApple();
    if (!mounted) return;
    setState(() => _loading = false);
    if (result.failure != null) {
      setState(() => _error = result.failure!.message ?? authErrorGeneric(lang));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final lang = ref.watch(deviceLanguageProvider);
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
                authTitle(lang),
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                authSubtitle(lang),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: authPhoneLabel(lang),
                  hintText: authPhoneHint(lang),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(_error!, style: TextStyle(color: colorScheme.error)),
              ],
              const SizedBox(height: AppSpacing.sm),
              FilledButton(
                onPressed: _loading ? null : () => _sendOtp(lang),
                child: _loading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.onPrimary,
                        ),
                      )
                    : Text(authSendCode(lang)),
              ),
              const SizedBox(height: AppSpacing.md),
              const Divider(),
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton.icon(
                onPressed: _loading ? null : () => _signInWithGoogle(lang),
                icon: const Icon(Icons.g_mobiledata, size: 24),
                label: Text(authContinueWithGoogle(lang)),
              ),
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton.icon(
                onPressed: _loading ? null : () => _signInWithApple(lang),
                icon: const Icon(Icons.apple, size: 24),
                label: Text(authContinueWithApple(lang)),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }
}
