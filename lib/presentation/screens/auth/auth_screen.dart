import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:nousdeux/core/constants/app_spacing.dart';
import 'package:nousdeux/core/constants/auth_strings.dart';
import 'package:nousdeux/core/utils/app_routes.dart';
import 'package:nousdeux/core/utils/phone_utils.dart';
import 'package:nousdeux/presentation/providers/auth_provider.dart';
import 'package:nousdeux/presentation/providers/locale_provider.dart';
import 'package:nousdeux/presentation/widgets/entrance.dart';
import 'package:nousdeux/presentation/widgets/merging_rings.dart';

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
    final phone = normalizePhone(_phoneController.text);
    if (phone.isEmpty) {
      setState(() => _error = authErrorEnterPhone(lang));
      return;
    }
    setState(() {
      _error = null;
      _loading = true;
    });
    final repo = ref.read(authRepositoryProvider);
    final result = await repo.signInWithOtp(phone: phone);
    if (!mounted) return;
    setState(() => _loading = false);
    if (result.failure != null) {
      setState(() => _error = result.failure!.message ?? authErrorGeneric(lang));
      return;
    }
    context.push(AppRoutes.authVerify, extra: {'phone': phone});
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
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
              const Center(
                child: Hero(
                  tag: MergingRings.heroTag,
                  child: MergingRings(size: 96),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Entrance(
                delay: const Duration(milliseconds: 60),
                child: Column(
                  children: [
                    Text(
                      authTitle(lang),
                      style: theme.textTheme.displaySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      authSubtitle(lang),
                      style: theme.textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Entrance(
                delay: const Duration(milliseconds: 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      autofillHints: const [AutofillHints.telephoneNumber],
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _loading ? null : _sendOtp(lang),
                      decoration: InputDecoration(
                        labelText: authPhoneLabel(lang),
                        hintText: authPhoneHint(lang),
                        errorText: _error,
                      ),
                    ),
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
                    _OrDivider(label: authOr(lang)),
                    const SizedBox(height: AppSpacing.md),
                    OutlinedButton.icon(
                      onPressed: _loading ? null : () => _signInWithApple(lang),
                      icon: const Icon(Icons.apple, size: 22),
                      label: Text(authContinueWithApple(lang)),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    OutlinedButton.icon(
                      onPressed: _loading ? null : () => _signInWithGoogle(lang),
                      icon: const _GoogleMark(),
                      label: Text(authContinueWithGoogle(lang)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}

/// A plain "G" in the button's color. Avoids shipping Google's logo asset.
class _GoogleMark extends StatelessWidget {
  const _GoogleMark();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 22,
      child: Text(
        'G',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: IconTheme.of(context).color,
        ),
      ),
    );
  }
}
