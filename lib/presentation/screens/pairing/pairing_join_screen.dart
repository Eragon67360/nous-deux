import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:nous_deux/presentation/providers/pairing_provider.dart';
import 'package:nous_deux/presentation/providers/profile_provider.dart';

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

  Future<void> _join() async {
    final code = _codeController.text.trim().toUpperCase();
    if (code.isEmpty) {
      setState(() => _error = 'Entrez le code');
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
      setState(() => _error = result.failure!.message ?? 'Code invalide');
      return;
    }
    ref.invalidate(myCoupleProvider);
    ref.invalidate(myProfileProvider);
    if (mounted) context.go('/main');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rejoindre'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              const Text('Entrez le code à 6 caractères partagé par votre partenaire.'),
              const SizedBox(height: 24),
              TextField(
                controller: _codeController,
                textCapitalization: TextCapitalization.characters,
                maxLength: 6,
                decoration: const InputDecoration(
                  labelText: 'Code',
                  hintText: 'ABC123',
                  border: OutlineInputBorder(),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ],
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _loading ? null : _join,
                child: _loading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Rejoindre'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
