import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nousdeux/core/constants/cycle_strings.dart';
import 'package:nousdeux/core/constants/period_education.dart';
import 'package:nousdeux/core/constants/period_options.dart';
import 'package:nousdeux/domain/cycle/cycle_stats.dart';
import 'package:nousdeux/domain/entities/period_log_entity.dart';
import 'package:nousdeux/presentation/providers/auth_provider.dart';
import 'package:nousdeux/presentation/providers/cycle_provider.dart';
import 'package:nousdeux/presentation/providers/pairing_provider.dart';
import 'package:nousdeux/presentation/providers/period_provider.dart';
import 'package:nousdeux/presentation/providers/profile_provider.dart';
import 'package:nousdeux/presentation/screens/period/cycle_history_screen.dart';
import 'package:nousdeux/presentation/screens/period/cycle_log_sheet.dart';
import 'package:nousdeux/presentation/screens/period/cycle_sharing_screen.dart';
import 'package:nousdeux/presentation/screens/period/guide/guide_screen.dart';
import 'package:nousdeux/presentation/screens/period/partner_cycle_view.dart';
import 'package:nousdeux/presentation/widgets/cycle_ring.dart';
import 'package:nousdeux/presentation/widgets/notebook.dart';

/// R1: my cycle today. Where I am, when the next period should come, one
/// button for what is likely to happen next, and how today feels.
class CycleTodayView extends ConsumerWidget {
  const CycleTodayView({super.key, required this.lang});

  final String lang;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final stats = ref.watch(myCycleStatsProvider);
    final couple = ref.watch(myCoupleProvider);
    final paired = couple.valueOrNull != null;
    final partner = ref.watch(partnerProfileProvider).valueOrNull;
    final partnerName = cyclePartnerName(lang, partner?.username);
    final partnerStats = ref.watch(partnerCycleStatsProvider);
    final phase = stats.phase;

    void push(Widget page) => Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => page));

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
      children: [
        if (!paired && !couple.isLoading) ...[
          Text(
            cycleNoDataTitle(lang),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(height: 8),
          Text(cycleNeedsCouple(lang), style: theme.textTheme.bodyLarge),
        ] else if (stats.hasData)
          _Overview(stats: stats, lang: lang)
        else ...[
          Text(
            cycleNoDataTitle(lang),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            cycleNoDataBody(lang),
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        if (paired) ...[
          const SizedBox(height: 24),
          _LogButtons(stats: stats, lang: lang),
          const NotebookRule(),
          _TodayCheckin(
            key: ValueKey(stats.today),
            day: stats.today,
            lang: lang,
            seenBy: partner == null
                ? null
                : ref.watch(myProfileProvider).valueOrNull?.shareCheckins ==
                      true
                ? cycleSeenBy(lang, partnerName)
                : cycleSeenByNobody(lang),
            onSeenByTap: () => push(const CycleSharingScreen()),
          ),
          _NoteRow(day: stats.today, lang: lang),
        ],
        if (phase != null) ...[
          const NotebookRule(),
          NotebookLabel(cycleThisWeek(lang)),
          const SizedBox(height: 8),
          Text(
            cycleSelfTip(lang, phase),
            style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
          ),
          NotebookLink(
            label: cycleReadChapter(lang, cyclePhaseLabel(lang, phase)),
            onTap: () => push(const GuidePhaseScreen()),
          ),
        ],
        const NotebookRule(),
        if (stats.hasData)
          NotebookLink(
            label: cycleHistoryLink(lang),
            quiet: true,
            onTap: () => push(const CycleHistoryScreen()),
          ),
        if (partner != null)
          NotebookLink(
            label: cycleSharingLink(lang, partnerName),
            quiet: true,
            onTap: () => push(const CycleSharingScreen()),
          ),
        if (partner != null && partnerStats.hasData)
          NotebookLink(
            label: cyclePartnerLink(lang, partnerName),
            quiet: true,
            onTap: () => push(
              Scaffold(
                appBar: AppBar(),
                body: PartnerCycleView(lang: lang),
              ),
            ),
          ),
      ],
    );
  }
}

/// The ring, the phase, and when the next period should come.
class _Overview extends StatelessWidget {
  const _Overview({required this.stats, required this.lang});

  final CycleStats stats;
  final String lang;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final day = stats.dayOfCycle!;
    final span = stats.phaseSpan;
    final next = stats.nextStart;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: CycleRing(
            day: day,
            cycleLength: stats.cycleLength,
            periodLength: stats.periodLength,
            phaseStart: span?.start ?? 0,
            phaseEnd: span?.end ?? -1,
            semanticsLabel: cycleRingLabel(lang, day, stats.cycleLength),
            size: 176,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  cycleDayWord(lang),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  '$day',
                  style: theme.textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.w200,
                    height: 1.05,
                  ),
                ),
                Text(
                  cycleOfAbout(lang, stats.cycleLength),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        if (stats.phase case final phase?)
          Center(child: NotebookLabel(cyclePhaseLabel(lang, phase))),
        const SizedBox(height: 6),
        Text(
          cycleHeadline(
            lang,
            ongoing: stats.periodOngoing,
            dayOfCycle: day,
            daysUntil: stats.daysUntilNext,
          ),
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w300,
          ),
        ),
        if (!stats.periodOngoing && next != null) ...[
          const SizedBox(height: 4),
          Text(
            cycleBasis(lang, next, stats.cyclesUsed),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

/// One button for what is most likely next (start, or end while a period is
/// on), and a way to say it happened another day.
class _LogButtons extends ConsumerWidget {
  const _LogButtons({required this.stats, required this.lang});

  final CycleStats stats;
  final String lang;

  /// My log for the latest period.
  PeriodLogEntity? _latest(WidgetRef ref) {
    final me = ref.read(currentUserProvider).valueOrNull?.id;
    final logs = ref.read(periodLogsProvider).valueOrNull ?? const [];
    for (final log in logs) {
      if (log.userId == me &&
          daysBetween(log.startDate, stats.lastStart!) == 0) {
        return log;
      }
    }
    return null;
  }

  Future<void> _log(BuildContext context, WidgetRef ref, DateTime day) async {
    final repo = ref.read(periodRepositoryProvider);
    final messenger = ScaffoldMessenger.of(context);
    final latest = stats.periodOngoing ? _latest(ref) : null;

    final String done;
    final Future<void> Function() undo;
    if (latest != null) {
      final result = await repo.updateLog(
        id: latest.id,
        startDate: latest.startDate,
        endDate: day,
      );
      if (result.failure != null) return _failed(messenger);
      done = cycleLoggedEnd(lang, day);
      undo = () => repo.updateLog(
        id: latest.id,
        startDate: latest.startDate,
        endDate: latest.endDate,
      );
    } else {
      final result = await repo.createLog(startDate: day);
      final created = result.log;
      if (created == null) return _failed(messenger);
      done = cycleLoggedStart(lang, day);
      undo = () => repo.deleteLog(created.id);
    }
    HapticFeedback.lightImpact();
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(done),
          action: SnackBarAction(label: cycleUndo(lang), onPressed: undo),
        ),
      );
  }

  void _failed(ScaffoldMessengerState messenger) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(cycleSaveFailed(lang))));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ending = stats.periodOngoing;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
          onPressed: () => _log(context, ref, stats.today),
          child: Text(ending ? cycleEnded(lang) : cycleStarted(lang)),
        ),
        const SizedBox(height: 4),
        Center(
          child: NotebookLink(
            label: cycleOtherDay(lang),
            quiet: true,
            onTap: () async {
              final day = await showCycleLogSheet(
                context,
                kind: ending ? CycleLogKind.ended : CycleLogKind.started,
                lang: lang,
                today: stats.today,
                earliest: ending ? stats.lastStart : null,
              );
              if (day != null && context.mounted) {
                await _log(context, ref, day);
              }
            },
          ),
        ),
      ],
    );
  }
}

/// How today feels: tapping a word saves it at once.
class _TodayCheckin extends ConsumerStatefulWidget {
  const _TodayCheckin({
    super.key,
    required this.day,
    required this.lang,
    required this.seenBy,
    required this.onSeenByTap,
  });

  final DateTime day;
  final String lang;

  /// Who sees it, or null when there is no partner.
  final String? seenBy;
  final VoidCallback onSeenByTap;

  @override
  ConsumerState<_TodayCheckin> createState() => _TodayCheckinState();
}

class _TodayCheckinState extends ConsumerState<_TodayCheckin> {
  /// What I picked here, ahead of the live list catching up.
  Set<String>? _symptoms;
  String? _mood;
  bool _moodTouched = false;
  Future<void> _saving = Future.value();

  void _save(Set<String> symptoms, String? mood) {
    final before = (symptoms: _symptoms, mood: _mood, touched: _moodTouched);
    setState(() {
      _symptoms = symptoms;
      _mood = mood;
      _moodTouched = true;
    });
    HapticFeedback.selectionClick();
    final messenger = ScaffoldMessenger.of(context);
    // One save at a time, in the order tapped.
    _saving = _saving.then((_) async {
      final failure = await ref
          .read(cycleRepositoryProvider)
          .saveCheckin(
            day: widget.day,
            symptoms: symptoms.toList()..sort(),
            mood: mood,
          );
      if (failure == null || !mounted) return;
      setState(() {
        _symptoms = before.symptoms;
        _mood = before.mood;
        _moodTouched = before.touched;
      });
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(cycleSaveFailed(widget.lang))));
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = widget.lang;
    final saved = ref.watch(myTodayCheckinProvider);
    final symptoms = _symptoms ?? {...?saved?.symptoms};
    final mood = _moodTouched ? _mood : saved?.mood;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            NotebookLabel(cycleToday(lang)),
            const Spacer(),
            if (widget.seenBy case final seenBy?)
              InkWell(
                onTap: widget.onSeenByTap,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    seenBy,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final symptom in periodSymptoms)
              FilterChip(
                label: Text(periodSymptomOptionLabel(symptom, lang)),
                selected: symptoms.contains(symptom),
                onSelected: (on) => _save(
                  on
                      ? {...symptoms, symptom}
                      : ({...symptoms}..remove(symptom)),
                  mood,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final value in periodMoods)
              ChoiceChip(
                label: Text(periodMoodOptionLabel(value, lang)),
                selected: mood == value,
                onSelected: (on) => _save(symptoms, on ? value : null),
              ),
          ],
        ),
      ],
    );
  }
}

/// My private note for today: only I can read it.
class _NoteRow extends ConsumerWidget {
  const _NoteRow({required this.day, required this.lang});

  final DateTime day;
  final String lang;

  Future<void> _edit(BuildContext context, WidgetRef ref, String? note) async {
    final text = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _NoteSheet(lang: lang, initial: note ?? ''),
    );
    if (text == null || text.trim() == (note ?? '').trim()) return;
    final failure = await ref.read(cycleRepositoryProvider).saveNote(day, text);
    ref.invalidate(cycleNoteProvider(day));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            failure == null ? cycleNoteSaved(lang) : cycleSaveFailed(lang),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final note = ref.watch(cycleNoteProvider(day)).valueOrNull;
    final hasNote = note != null && note.trim().isNotEmpty;
    return InkWell(
      onTap: () => _edit(context, ref, note),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Icon(
              Icons.lock_outline,
              size: 18,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasNote ? note : cycleNoteLabel(lang),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyLarge,
                  ),
                  if (!hasNote)
                    Text(
                      cycleNoteHint(lang),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

class _NoteSheet extends StatefulWidget {
  const _NoteSheet({required this.lang, required this.initial});

  final String lang;
  final String initial;

  @override
  State<_NoteSheet> createState() => _NoteSheetState();
}

class _NoteSheetState extends State<_NoteSheet> {
  late final _text = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.lang;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        0,
        24,
        16 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NotebookLabel(cycleNoteLabel(lang)),
          const SizedBox(height: 8),
          TextField(
            controller: _text,
            autofocus: true,
            minLines: 3,
            maxLines: 8,
            maxLength: 2000,
            decoration: InputDecoration(hintText: cycleNoteHint(lang)),
          ),
          const SizedBox(height: 12),
          FilledButton(
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
            ),
            onPressed: () => Navigator.of(context).pop(_text.text),
            child: Text(cycleSave(lang)),
          ),
        ],
      ),
    );
  }
}
