import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:nousdeux/core/constants/app_spacing.dart';
import 'package:nousdeux/core/constants/pairing_strings.dart';
import 'package:nousdeux/presentation/providers/locale_provider.dart';
import 'package:nousdeux/presentation/providers/pairing_provider.dart';
import 'package:nousdeux/presentation/providers/profile_provider.dart';
import 'package:nousdeux/presentation/widgets/loading_content.dart';

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
      final lang =
          ref.read(myProfileProvider).valueOrNull?.language ??
          ref.read(deviceLanguageProvider) ??
          'fr';
      setState(() => _error = result.failure!.message ?? pairingError(lang));
      return;
    }
    ref.invalidate(myCoupleProvider);
  }

  @override
  Widget build(BuildContext context) {
    final coupleAsync = ref.watch(myCoupleProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final lang =
        ref.watch(myProfileProvider).valueOrNull?.language ??
        ref.watch(deviceLanguageProvider) ??
        'fr';
    return Scaffold(
      appBar: AppBar(title: Text(pairingInviteTitle(lang))),
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
                            pairingIntro(lang),
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
                                : Text(pairingGenerateCode(lang)),
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
                            pairingScanQrPrompt(lang),
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Center(
                            child: QrImageView(
                              data: code,
                              version: QrVersions.auto,
                              size: 200,
                              backgroundColor: Colors.white,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            pairingOrEnterCode(lang),
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
                            label: Text(pairingJoinWithCode(lang)),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          OutlinedButton.icon(
                            onPressed: () => context.push('/pairing/scan'),
                            icon: const Icon(Icons.qr_code_scanner),
                            label: Text(pairingScanQr(lang)),
                          ),
                          const SizedBox(height: AppSpacing.md),
                        ],
                      ),
                    );
                  }
                  return Center(child: Text(pairingAlreadyPaired(lang)));
                },
                loading: () => const LoadingContent(),
                error: (e, _) =>
                    Center(child: Text('${pairingError(lang)}: $e')),
              ),
            ),
          ),
        ),
      ), // SafeArea
    );
  }
}
