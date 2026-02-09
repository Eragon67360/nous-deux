import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:nous_deux/core/constants/app_spacing.dart';
import 'package:nous_deux/presentation/providers/pairing_provider.dart';
import 'package:nous_deux/presentation/widgets/loading_content.dart';

class PairingScreen extends ConsumerStatefulWidget {
  const PairingScreen({super.key});

  @override
  ConsumerState<PairingScreen> createState() => _PairingScreenState();
}

class _PairingScreenState extends ConsumerState<PairingScreen> {
  bool _creating = false;
  String? _error;

  Future<void> _createAndShowCode() async {
    setState(() {
      _error = null;
      _creating = true;
    });
    final repo = ref.read(pairingRepositoryProvider);
    final result = await repo.createCoupleAndGetCode();
    if (!mounted) return;
    setState(() => _creating = false);
    if (result.failure != null) {
      setState(() => _error = result.failure!.message ?? 'Erreur');
      return;
    }
    ref.invalidate(myCoupleProvider);
  }

  @override
  Widget build(BuildContext context) {
    final coupleAsync = ref.watch(myCoupleProvider);
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Inviter votre partenaire')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            switchInCurve: Curves.easeOut,
            child: KeyedSubtree(
              key: ValueKey('${coupleAsync.isLoading}_${coupleAsync.hasValue}'),
              child: coupleAsync.when(
                data: (couple) {
                  if (couple == null || !couple.isPaired) {
                    final code = couple?.pairingCode;
                    if (code == null || code.isEmpty) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            'Créez un lien pour inviter votre partenaire. Il pourra scanner le QR code ou saisir le code manuellement.',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          if (_error != null) ...[
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              _error!,
                              style: TextStyle(color: colorScheme.error),
                            ),
                          ],
                          const Spacer(),
                          FilledButton(
                            onPressed: _creating ? null : _createAndShowCode,
                            child: _creating
                                ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: colorScheme.onPrimary,
                                    ),
                                  )
                                : const Text('Générer le code'),
                          ),
                        ],
                      );
                    }
                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Votre partenaire peut scanner ce QR code :',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Center(
                            child: QrImageView(
                              data: code,
                              version: QrVersions.auto,
                              size: 200,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            'Ou saisir ce code :',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          SelectableText(
                            code,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  letterSpacing: 4,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          OutlinedButton.icon(
                            onPressed: () => context.push('/pairing/join'),
                            icon: const Icon(Icons.person_add),
                            label: const Text('Rejoindre avec un code'),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          OutlinedButton.icon(
                            onPressed: () => context.push('/pairing/scan'),
                            icon: const Icon(Icons.qr_code_scanner),
                            label: const Text('Scanner un QR code'),
                          ),
                          const SizedBox(height: AppSpacing.md),
                        ],
                      ),
                    );
                  }
                  return const Center(
                    child: Text('Vous êtes déjà en couple. Redirection...'),
                  );
                },
                loading: () => const LoadingContent(),
                error: (e, _) => Center(child: Text('Erreur: $e')),
              ),
            ),
          ),
        ),
      ), // SafeArea
    );
  }
}
