import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nousdeux/core/constants/cycle_strings.dart';
import 'package:nousdeux/core/constants/nous_strings.dart';
import 'package:nousdeux/core/constants/period_education.dart';
import 'package:nousdeux/domain/entities/ping_entity.dart';
import 'package:nousdeux/presentation/providers/cycle_provider.dart';
import 'package:nousdeux/presentation/providers/nous_provider.dart';
import 'package:nousdeux/presentation/providers/profile_provider.dart';
import 'package:nousdeux/presentation/widgets/notebook.dart';

/// R3: my partner's cycle, seen from my side, with what tends to help now.
class PartnerCycleView extends ConsumerWidget {
  const PartnerCycleView({super.key, required this.lang});

  final String lang;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final partner = ref.watch(partnerProfileProvider).valueOrNull;
    final name = cyclePartnerName(lang, partner?.username);
    final stats = ref.watch(partnerCycleStatsProvider);
    final checkin = ref.watch(partnerTodayCheckinProvider);
    final phase = stats.phase;

    Widget message(String text) => Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Text(
        text,
        style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
      ),
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
      children: [
        if (partner == null)
          message(cycleNoPartner(lang))
        else ...[
          NotebookLabel(cyclePartnerLabel(lang, name)),
          if (!partner.shareCycle)
            message(cyclePartnerNotShared(lang, name))
          else if (!stats.hasData)
            message(
              partner.tracksCycle == false
                  ? cyclePartnerNotTracking(lang, name)
                  : cyclePartnerNothingYet(lang, name),
            )
          else ...[
            const SizedBox(height: 10),
            Text(
              cyclePartnerHeadline(
                lang,
                name,
                ongoing: stats.periodOngoing,
                day: stats.dayOfCycle!,
              ),
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              [
                if (phase != null) '${cyclePhaseLabel(lang, phase)}.',
                if (stats.nextStart case final next?)
                  cyclePartnerNext(lang, next, stats.daysUntilNext),
              ].join(' '),
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          if (phase != null) ...[
            const NotebookRule(),
            NotebookLabel(cycleWhatHelps(lang)),
            const SizedBox(height: 10),
            for (final (i, tip) in cyclePartnerTips(lang, phase).indexed)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 28,
                      child: Text(
                        '${i + 1}',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w200,
                          color: theme.colorScheme.primary,
                          height: 1.1,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        tip,
                        style: theme.textTheme.bodyLarge?.copyWith(height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
          ],
          if (checkin != null && !checkin.isEmpty) ...[
            const NotebookRule(),
            NotebookLabel(cyclePartnerNoted(lang, name)),
            const SizedBox(height: 8),
            Text(
              [
                for (final s in checkin.symptoms)
                  periodSymptomOptionLabel(s, lang),
                if (checkin.mood case final mood?)
                  periodMoodOptionLabel(mood, lang),
              ].join(' · '),
              style: theme.textTheme.bodyLarge,
            ),
          ],
          const NotebookRule(),
          NotebookLabel(cycleLittleNote(lang)),
          const SizedBox(height: 4),
          _LittleNotes(lang: lang),
          if (partner.shareCycle) ...[
            const NotebookRule(),
            _ReminderSwitch(lang: lang),
          ],
        ],
      ],
    );
  }
}

/// Three words that go straight to my partner, like on the Nous page.
class _LittleNotes extends ConsumerStatefulWidget {
  const _LittleNotes({required this.lang});

  final String lang;

  @override
  ConsumerState<_LittleNotes> createState() => _LittleNotesState();
}

class _LittleNotesState extends ConsumerState<_LittleNotes> {
  static const _kinds = [
    PingKind.thinkingOfYou,
    PingKind.kiss,
    PingKind.onMyWay,
  ];
  PingKind? _sending;

  Future<void> _send(PingKind kind) async {
    if (_sending != null) return;
    HapticFeedback.lightImpact();
    setState(() => _sending = kind);
    final result = await ref.read(pingRepositoryProvider).send(kind);
    if (!mounted) return;
    setState(() => _sending = null);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(pingResultMessage(widget.lang, kind, result.failure)),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Wrap(
      spacing: 18,
      children: [
        for (final kind in _kinds)
          TextButton(
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(44, 44),
              foregroundColor: theme.colorScheme.primary,
            ),
            onPressed: _sending == null ? () => _send(kind) : null,
            child: Text(
              pingLabel(widget.lang, kind),
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}

/// The evening-before reminder, kept on this phone.
class _ReminderSwitch extends ConsumerWidget {
  const _ReminderSwitch({required this.lang});

  final String lang;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final enabled = ref.watch(partnerReminderEnabledProvider).valueOrNull;
    final day = ref.watch(partnerReminderDayProvider);
    return SwitchListTile.adaptive(
      contentPadding: EdgeInsets.zero,
      title: Text(cycleRemindMe(lang), style: theme.textTheme.bodyLarge),
      subtitle: Text(
        day == null ? cycleRemindNoDate(lang) : cycleRemindOn(lang, day),
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      value: enabled ?? false,
      onChanged: enabled == null
          ? null
          : (v) => setPartnerReminderEnabled(ref, enabled: v),
    );
  }
}
