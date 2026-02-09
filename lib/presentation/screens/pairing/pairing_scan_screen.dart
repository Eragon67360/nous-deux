import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:nous_deux/core/constants/app_spacing.dart';
import 'package:nous_deux/presentation/providers/pairing_provider.dart';
import 'package:nous_deux/presentation/providers/profile_provider.dart';

class PairingScanScreen extends ConsumerStatefulWidget {
  const PairingScanScreen({super.key});

  @override
  ConsumerState<PairingScanScreen> createState() => _PairingScanScreenState();
}

class _PairingScanScreenState extends ConsumerState<PairingScanScreen> {
  final _controller = MobileScannerController();
  bool _loading = false;
  String? _error;
  bool _joined = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _joinByCode(String code) async {
    if (_joined || _loading) return;
    setState(() {
      _error = null;
      _loading = true;
    });
    final repo = ref.read(pairingRepositoryProvider);
    final result = await repo.joinByCode(code);
    if (!mounted) return;
    setState(() {
      _loading = false;
      _joined = result.failure == null;
      _error = result.failure?.message;
    });
    if (result.failure == null) {
      ref.invalidate(myCoupleProvider);
      ref.invalidate(myProfileProvider);
      context.go('/main');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner le QR code'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: (capture) {
              final barcodes = capture.barcodes;
              for (final b in barcodes) {
                final code = b.rawValue?.trim().toUpperCase();
                if (code != null && code.length >= 4) {
                  _joinByCode(code);
                  break;
                }
              }
            },
          ),
          if (_loading)
            Center(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 32,
                        height: 32,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Connexion en cours...',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (_error != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 32,
              child: Card(
                color: Theme.of(context).colorScheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(_error!),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
