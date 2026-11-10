import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:nousdeux/core/constants/app_radius.dart';
import 'package:nousdeux/core/constants/app_spacing.dart';
import 'package:nousdeux/core/constants/pairing_strings.dart';
import 'package:nousdeux/core/utils/app_routes.dart';
import 'package:nousdeux/presentation/providers/locale_provider.dart';
import 'package:nousdeux/presentation/providers/pairing_provider.dart';
import 'package:nousdeux/presentation/providers/profile_provider.dart';
import 'package:nousdeux/presentation/theme/app_motion.dart';
import 'package:nousdeux/presentation/widgets/empty_state.dart';
import 'package:nousdeux/presentation/widgets/entrance.dart';
import 'package:nousdeux/presentation/widgets/loading_content.dart';
import 'package:nousdeux/presentation/widgets/merging_rings.dart';

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
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
            duration: AppMotion.medium,
            switchInCurve: AppMotion.enter,
            child: KeyedSubtree(
              key: ValueKey('${coupleAsync.isLoading}_${coupleAsync.hasValue}'),
              child: coupleAsync.when(
                data: (couple) {
                  if (couple == null || !couple.isPaired) {
                    final code = couple?.pairingCode;
                    final joinOptions = <Widget>[
                      OutlinedButton.icon(
                        onPressed: () => context.push(AppRoutes.pairingJoin),
                        icon: const Icon(Icons.keyboard_outlined),
                        label: Text(pairingJoinWithCode(lang)),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      OutlinedButton.icon(
                        onPressed: () => context.push(AppRoutes.pairingScan),
                        icon: const Icon(Icons.qr_code_scanner),
                        label: Text(pairingScanQr(lang)),
                      ),
                    ];
                    if (code == null || code.isEmpty) {
                      return SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: AppSpacing.lg),
                            const Entrance(
                              child: Center(child: MergingRings(size: 120)),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            Entrance(
                              delay: const Duration(milliseconds: 60),
                              child: Text(
                                pairingIntro(lang),
                                style: theme.textTheme.bodyLarge,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            if (_error != null) ...[
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                _error!,
                                style: TextStyle(color: colorScheme.error),
                                textAlign: TextAlign.center,
                              ),
                            ],
                            const SizedBox(height: AppSpacing.xl),
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
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              pairingAlreadyHaveCode(lang),
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            ...joinOptions,
                            const SizedBox(height: AppSpacing.md),
                          ],
                        ),
                      );
                    }
                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            pairingScanQrPrompt(lang),
                            style: theme.textTheme.bodyLarge,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Center(
                            child: Entrance(
                              child: Container(
                                padding: const EdgeInsets.all(AppSpacing.sm),
                                decoration: BoxDecoration(
                                  // QR codes need a light, high-contrast field.
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.md,
                                  ),
                                ),
                                child: QrImageView(
                                  data: code,
                                  version: QrVersions.auto,
                                  size: 200,
                                  padding: EdgeInsets.zero,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Text(
                            pairingOrEnterCode(lang),
                            style: theme.textTheme.titleSmall,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          SelectableText(
                            code,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.displaySmall?.copyWith(
                              letterSpacing: 6,
                              color: colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          Text(
                            pairingAlreadyHaveCode(lang),
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          ...joinOptions,
                          const SizedBox(height: AppSpacing.md),
                        ],
                      ),
                    );
                  }
                  return Center(child: Text(pairingAlreadyPaired(lang)));
                },
                loading: () => const LoadingContent(),
                error: (e, _) => EmptyState(
                  icon: Icons.wifi_off_outlined,
                  message: pairingError(lang),
                ),
              ),
            ),
          ),
        ),
      ), // SafeArea
    );
  }
}
