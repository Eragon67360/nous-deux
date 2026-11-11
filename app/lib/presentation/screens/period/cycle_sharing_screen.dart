import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nousdeux/core/constants/cycle_strings.dart';
import 'package:nousdeux/presentation/providers/profile_provider.dart';

/// R3: what my partner may see of my cycle. Two switches; notes are never
/// shared (the database refuses it, not just this screen).
class CycleSharingScreen extends ConsumerStatefulWidget {
  const CycleSharingScreen({super.key});

  @override
  ConsumerState<CycleSharingScreen> createState() => _CycleSharingScreenState();
}

class _CycleSharingScreenState extends ConsumerState<CycleSharingScreen> {
  /// Switches as last set here, ahead of the profile reloading.
  bool? _cycle;
  bool? _checkins;
  bool _saving = false;

  Future<void> _set({bool? cycle, bool? checkins}) async {
    final before = (cycle: _cycle, checkins: _checkins);
    setState(() {
      _cycle = cycle ?? _cycle;
      _checkins = checkins ?? _checkins;
      _saving = true;
    });
    final result = await ref
        .read(profileRepositoryProvider)
        .updateCycleSettings(shareCycle: cycle, shareCheckins: checkins);
    if (!mounted) return;
    setState(() => _saving = false);
    if (result.failure != null) {
      setState(() {
        _cycle = before.cycle;
        _checkins = before.checkins;
      });
      final lang = ref.read(myProfileProvider).valueOrNull?.language ?? 'fr';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(cycleSaveFailed(lang))));
      return;
    }
    ref.invalidate(myProfileProvider);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final profile = ref.watch(myProfileProvider).valueOrNull;
    final lang = profile?.language ?? 'fr';
    final name = cyclePartnerName(
      lang,
      ref.watch(partnerProfileProvider).valueOrNull?.username,
    );
    final cycle = _cycle ?? profile?.shareCycle ?? true;
    final checkins = _checkins ?? profile?.shareCheckins ?? true;
    TextStyle? hint() =>
        theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant);

    return Scaffold(
      appBar: AppBar(title: Text(cycleSharingTitle(lang, name))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 40),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
            child: Text(
              cycleSharingIntro(lang),
              style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
            ),
          ),
          SwitchListTile.adaptive(
            title: Text(cycleShareCycle(lang)),
            subtitle: Text(cycleShareCycleHint(lang), style: hint()),
            value: cycle,
            onChanged: profile == null || _saving
                ? null
                : (v) => _set(cycle: v),
          ),
          Divider(height: 1, indent: 16, color: scheme.outlineVariant),
          SwitchListTile.adaptive(
            title: Text(cycleShareCheckins(lang)),
            subtitle: Text(cycleShareCheckinsHint(lang), style: hint()),
            value: checkins,
            onChanged: profile == null || _saving
                ? null
                : (v) => _set(checkins: v),
          ),
          Divider(height: 1, indent: 16, color: scheme.outlineVariant),
          ListTile(
            title: Text(cycleNotesRow(lang)),
            subtitle: Text(cycleNotesAlwaysPrivate(lang), style: hint()),
            trailing: Icon(Icons.lock_outline, color: scheme.onSurfaceVariant),
          ),
          if (cycle || checkins) ...[
            const SizedBox(height: 24),
            Center(
              child: TextButton(
                onPressed: profile == null || _saving
                    ? null
                    : () => _set(cycle: false, checkins: false),
                child: Text(cycleStopSharing(lang)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
