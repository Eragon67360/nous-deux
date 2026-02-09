import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nousdeux/core/constants/app_spacing.dart';
import 'package:nousdeux/presentation/providers/auth_provider.dart';

class VerifyOtpScreen extends ConsumerStatefulWidget {
  const VerifyOtpScreen({super.key, required this.phone});
  final String phone;

  @override
  ConsumerState<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends ConsumerState<VerifyOtpScreen> {
  final _codeController = TextEditingController();
  bool _loading = false;
  String? _error;
  String get _phone => widget.phone;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final token = _codeController.text.trim();
    if (token.isEmpty || _phone.isEmpty) {
      setState(() => _error = 'Entrez le code reçu');
      return;
    }
    setState(() {
      _error = null;
      _loading = true;
    });
    final repo = ref.read(authRepositoryProvider);
    final result = await repo.verifyOtp(phone: _phone, token: token);
    if (!mounted) return;
    setState(() => _loading = false);
    if (result.failure != null) {
      setState(() => _error = result.failure!.message ?? 'Code invalide');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Vérification')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.md),
              Text(
                'Entrez le code envoyé au $_phone',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _codeController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: const InputDecoration(
                  labelText: 'Code',
                  hintText: '123456',
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(_error!, style: TextStyle(color: colorScheme.error)),
              ],
              const SizedBox(height: AppSpacing.md),
              FilledButton(
                onPressed: _loading ? null : _verify,
                child: _loading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.onPrimary,
                        ),
                      )
                    : const Text('Vérifier'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
