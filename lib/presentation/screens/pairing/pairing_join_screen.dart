import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:nousdeux/core/constants/app_spacing.dart';
import 'package:nousdeux/core/constants/pairing_strings.dart';
import 'package:nousdeux/presentation/providers/locale_provider.dart';
import 'package:nousdeux/presentation/providers/pairing_provider.dart';
import 'package:nousdeux/presentation/providers/profile_provider.dart';

class PairingJoinScreen extends ConsumerStatefulWidget {
  const PairingJoinScreen({super.key});

  @override
  ConsumerState<PairingJoinScreen> createState() => _PairingJoinScreenState();
}

class _PairingJoinScreenState extends ConsumerState<PairingJoinScreen> {
  final _codeController = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _join(String lang) async {
    final code = _codeController.text.trim().toUpperCase();
    if (code.isEmpty) {
      setState(() => _error = pairingJoinErrorCode(lang));
      return;
    }
    setState(() {
      _error = null;
      _loading = true;
    });
    final repo = ref.read(pairingRepositoryProvider);
    final result = await repo.joinByCode(code);
    if (!mounted) return;
    setState(() => _loading = false);
    if (result.failure != null) {
      setState(
        () => _error = result.failure!.message ?? pairingJoinErrorInvalid(lang),
      );
      return;
    }
    ref.invalidate(myCoupleProvider);
    ref.invalidate(myProfileProvider);
    if (mounted) context.go('/main');
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(myProfileProvider).valueOrNull?.language ??
        ref.watch(deviceLanguageProvider) ??
        'fr';
    return Scaffold(
      appBar: AppBar(
        title: Text(pairingJoinTitle(lang)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.md),
              Text(
                pairingJoinInstructions(lang),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _codeController,
                textCapitalization: TextCapitalization.characters,
                maxLength: 6,
                decoration: InputDecoration(
                  labelText: pairingJoinCodeLabel(lang),
                  hintText: pairingJoinCodeHint(lang),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              FilledButton(
                onPressed: _loading ? null : () => _join(lang),
                child: _loading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      )
                    : Text(pairingJoinButton(lang)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
