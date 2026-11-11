import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nousdeux/core/constants/cycle_strings.dart';
import 'package:nousdeux/core/constants/period_education.dart';
import 'package:nousdeux/presentation/providers/cycle_provider.dart';
import 'package:nousdeux/presentation/providers/profile_provider.dart';
import 'package:nousdeux/presentation/screens/period/cycle_today_view.dart';
import 'package:nousdeux/presentation/screens/period/guide/guide_screen.dart';
import 'package:nousdeux/presentation/screens/period/partner_cycle_view.dart';
import 'package:nousdeux/presentation/widgets/loading_content.dart';

/// The Règles tab. Asks once whether I track a cycle, then shows my cycle
/// (R1) or my partner's (R3). The guide (R4) opens from the top bar.
class PeriodScreen extends ConsumerStatefulWidget {
  const PeriodScreen({super.key, this.openGuide = false});

  /// Opens the guide on top once the tab shows (from `?tab=guide`).
  final bool openGuide;

  @override
  ConsumerState<PeriodScreen> createState() => _PeriodScreenState();
}

class _PeriodScreenState extends ConsumerState<PeriodScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.openGuide) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _openGuide();
      });
    }
  }

  void _openGuide() => Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (_) => const GuideScreen()));

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(myProfileProvider).valueOrNull?.language ?? 'fr';
    final role = ref.watch(myCycleRoleProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(periodScreenTitle(lang)),
        actions: [
          TextButton(
            onPressed: _openGuide,
            child: Text('${guideLabel(lang)} ›'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: switch (role) {
        null => const LoadingContent(),
        CycleRole.unasked => _AskWhoTracks(lang: lang),
        CycleRole.tracker => CycleTodayView(lang: lang),
        CycleRole.supporter => PartnerCycleView(lang: lang),
      },
    );
  }
}

/// Asked once; the answer can be changed in Settings.
class _AskWhoTracks extends ConsumerStatefulWidget {
  const _AskWhoTracks({required this.lang});

  final String lang;

  @override
  ConsumerState<_AskWhoTracks> createState() => _AskWhoTracksState();
}

class _AskWhoTracksState extends ConsumerState<_AskWhoTracks> {
  bool _saving = false;

  Future<void> _answer(bool tracks) async {
    setState(() => _saving = true);
    final result = await ref
        .read(profileRepositoryProvider)
        .updateCycleSettings(tracksCycle: tracks);
    if (!mounted) return;
    if (result.failure != null) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(cycleSaveFailed(widget.lang))));
      return;
    }
    ref.invalidate(myProfileProvider);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = widget.lang;
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
      children: [
        Text(
          cycleAskTitle(lang),
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w300,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          cycleAskBody(lang),
          style: theme.textTheme.bodyLarge?.copyWith(
            height: 1.5,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 32),
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
          onPressed: _saving ? null : () => _answer(true),
          child: Text(cycleAskYes(lang)),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
          ),
          onPressed: _saving ? null : () => _answer(false),
          child: Text(cycleAskNo(lang)),
        ),
      ],
    );
  }
}
