import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:nousdeux/core/constants/cycle_strings.dart';
import 'package:nousdeux/core/constants/period_verified_sources.dart';
import 'package:nousdeux/core/constants/pill_strings.dart';
import 'package:nousdeux/domain/entities/pill_entities.dart';
import 'package:nousdeux/presentation/providers/nous_provider.dart';
import 'package:nousdeux/presentation/providers/pill_provider.dart';
import 'package:nousdeux/presentation/providers/profile_provider.dart';
import 'package:nousdeux/presentation/screens/period/pill_setup_screen.dart';
import 'package:nousdeux/presentation/screens/settings/pill_settings_screen.dart';
import 'package:nousdeux/presentation/widgets/notebook.dart';

void _push(BuildContext context, Widget page) =>
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));

/// The PILULE part of Règles (boards 2 and 4): today's pill, the pack, this
/// week, and what to do when it is late. Without tracking, a link to start
/// (until « Non »). Brings its own rule above it, so nothing shows when
/// there is nothing to show.
class PillSection extends ConsumerWidget {
  const PillSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(myProfileProvider).valueOrNull?.language ?? 'fr';
    final today = ref.watch(pillTodayProvider);
    if (today == null) return const SizedBox.shrink();
    if (today.state == PillTodayState.notTracking) {
      final offered = ref.watch(pillSetupOfferedProvider).valueOrNull ?? false;
      if (!offered) return const SizedBox.shrink();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const NotebookRule(),
          NotebookLink(
            label: pillTrackLink(lang),
            quiet: true,
            onTap: () => _push(context, const PillSetupScreen()),
          ),
        ],
      );
    }
    return _Tracking(today: today, lang: lang);
  }
}

class _Tracking extends ConsumerWidget {
  const _Tracking({required this.today, required this.lang});

  final PillToday today;
  final String lang;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final settings = today.settings!;
    final schedule = settings.schedule;
    final now = ref.watch(clockProvider)();
    final day = DateTime(now.year, now.month, now.day);
    final repo = ref.read(pillRepositoryProvider);
    final messenger = ScaffoldMessenger.of(context);

    Future<void> write(Future<Object?> Function() action) async {
      final failure = await action();
      ref.invalidate(pillWeekProvider);
      if (failure != null) {
        messenger.showSnackBar(SnackBar(content: Text(cycleSaveFailed(lang))));
      }
    }

    Future<void> takenAt(DateTime at) =>
        write(() => ref.read(markPillTakenProvider)(day, at));

    Future<void> pickTakenTime() async {
      final t = settings.reminderTime;
      final picked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay(hour: t.hour, minute: t.minute),
      );
      if (picked == null) return;
      await takenAt(
        DateTime(day.year, day.month, day.day, picked.hour, picked.minute),
      );
    }

    final number = today.pillNumber;
    final state = today.state;
    final yesterday = DateTime(day.year, day.month, day.day - 1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const NotebookRule(),
        if (today.yesterdayPending) ...[
          // After midnight, a pill taken late last night goes on its day.
          Text(pillYesterdayPending(lang), style: theme.textTheme.bodyLarge),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () => write(
              () => ref.read(markPillTakenProvider)(
                yesterday,
                ref.read(clockProvider)(),
              ),
            ),
            child: Text(pillTookItYesterday(lang)),
          ),
          const SizedBox(height: 18),
        ],
        Row(
          children: [
            Expanded(child: NotebookLabel(pillLabel(lang))),
            if (settings.reminderOn)
              Text(
                pillReminderAt(lang, settings.reminderTime),
                style: theme.textTheme.bodyMedium?.copyWith(color: muted),
              ),
          ],
        ),
        const SizedBox(height: 10),
        if (state == PillTodayState.pauseDay)
          Text(
            pillDayOff(lang),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w300,
            ),
          )
        else ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${number ?? ''}',
                style: theme.textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.w200,
                  height: 1,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                pillOfPack(lang, schedule.pillsInPack),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w300,
                  color: muted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          switch (state) {
            PillTodayState.taken => Row(
              children: [
                Expanded(
                  child: Text(
                    pillTakenAt(lang, today.takenAt!),
                    style: theme.textTheme.bodyLarge,
                  ),
                ),
                _Check(color: theme.colorScheme.primary),
              ],
            ),
            PillTodayState.missed => Text(
              pillNotedMissed(lang),
              style: theme.textTheme.bodyLarge,
            ),
            // Whatever the reminder time: never « ce soir » (Evah).
            PillTodayState.late => Text(
              pillNotTickedToday(lang),
              style: theme.textTheme.bodyLarge,
            ),
            _ => Text(
              pillNotTickedToday(lang),
              style: theme.textTheme.bodyLarge?.copyWith(color: muted),
            ),
          },
          const SizedBox(height: 14),
          if (state == PillTodayState.due)
            FilledButton(
              onPressed: () => takenAt(ref.read(clockProvider)()),
              child: Text(pillTakeButton(lang)),
            ),
          if (state == PillTodayState.late) ...[
            FilledButton(
              onPressed: () => takenAt(ref.read(clockProvider)()),
              child: Text(pillTakingNow(lang)),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: pickTakenTime,
              child: Text(pillTookItAt(lang)),
            ),
          ],
          if (state == PillTodayState.taken || state == PillTodayState.missed)
            NotebookLink(
              label: pillUntick(lang),
              quiet: true,
              onTap: () => write(() => repo.unmark(day)),
            ),
        ],
        const SizedBox(height: 16),
        _PackGrid(today: day, settings: settings),
        const SizedBox(height: 10),
        Text(
          pillPackLine(lang, schedule, day),
          style: theme.textTheme.bodyMedium?.copyWith(color: muted),
        ),
        Text(
          pillNextPack(lang, schedule.nextPackStart(day)),
          style: theme.textTheme.bodyMedium?.copyWith(color: muted),
        ),
        if (state == PillTodayState.late) ...[
          const NotebookRule(),
          NotebookLabel(pillIfMissed(lang)),
          const SizedBox(height: 8),
          Text(
            pillIfMissedBody(lang),
            style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
          ),
          for (final source in sourcesMissedPill(lang))
            NotebookLink(
              label: pillOfficialSheet(lang, source.name(lang)),
              onTap: () => launchUrl(
                Uri.parse(source.url),
                mode: LaunchMode.externalApplication,
              ),
            ),
          NotebookLink(
            label: pillNoteMissed(lang),
            quiet: true,
            onTap: () => write(() => repo.markMissed(day)),
          ),
          Text(
            pillNoScore(lang),
            style: theme.textTheme.bodySmall?.copyWith(color: muted),
          ),
        ],
        const SizedBox(height: 8),
        _ThisWeek(lang: lang, today: day, settings: settings),
        NotebookLink(
          label: pillSettingsTitle(lang),
          quiet: true,
          onTap: () => _push(context, const PillSettingsScreen()),
        ),
      ],
    );
  }
}

class _Check extends StatelessWidget {
  const _Check({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: 24,
    height: 24,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    child: Icon(
      Icons.check,
      size: 16,
      color: Theme.of(context).colorScheme.surface,
    ),
  );
}

/// The pack as dots: taken in gold, today as a ring, days off dark, and a
/// missed day with a short line, in grey rather than red: noted, not judged
/// (Evah and Thomas, 2026-11-19).
class _PackGrid extends ConsumerWidget {
  const _PackGrid({required this.today, required this.settings});

  final DateTime today;
  final PillSettings settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final schedule = settings.schedule;
    final days = {
      for (final i in ref.watch(pillWeekProvider).valueOrNull ?? const [])
        i.day: i,
    };
    final first = DateTime(
      today.year,
      today.month,
      today.day - schedule.dayInPack(today) + 1,
    );
    Widget dot(DateTime d) {
      final off = !schedule.isPillDay(d);
      final taken = days[d]?.taken ?? false;
      final missed = days[d] != null && !taken;
      final isToday = d == today;
      if (missed) {
        return Container(
          key: const ValueKey('pill-dot-missed'),
          width: 14,
          height: 14,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isToday ? scheme.onSurface : scheme.outline,
              width: isToday ? 2 : 1,
            ),
          ),
          child: Container(width: 6, height: 1.5, color: scheme.outline),
        );
      }
      return Container(
        width: 14,
        height: 14,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: taken
              ? scheme.primary
              : off
              ? scheme.surfaceContainerHighest
              : null,
          border: taken || off
              ? null
              : Border.all(
                  color: isToday ? scheme.onSurface : scheme.outline,
                  width: isToday ? 2 : 1,
                ),
        ),
      );
    }

    // A row per week of the pack.
    return Column(
      key: const ValueKey('pill-grid'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var week = 0; week < 4; week++)
          Padding(
            padding: EdgeInsets.only(bottom: week < 3 ? 10 : 0),
            child: Row(
              children: [
                for (var k = 0; k < 7; k++) ...[
                  if (k > 0) const SizedBox(width: 12),
                  dot(
                    DateTime(first.year, first.month, first.day + week * 7 + k),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

/// CETTE SEMAINE: the last seven days, with the time each pill was taken.
class _ThisWeek extends ConsumerWidget {
  const _ThisWeek({
    required this.lang,
    required this.today,
    required this.settings,
  });

  final String lang;
  final DateTime today;
  final PillSettings settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final days = {
      for (final i in ref.watch(pillWeekProvider).valueOrNull ?? const [])
        i.day: i,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        NotebookLabel(pillThisWeek(lang)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 16,
          runSpacing: 6,
          children: [
            for (var i = 6; i >= 1; i--)
              () {
                final d = DateTime(today.year, today.month, today.day - i);
                final intake = days[d];
                final what = !settings.schedule.isPillDay(d)
                    ? pillWeekOff(lang)
                    : intake == null
                    ? '—'
                    : intake.taken
                    ? pillTime(lang, intake.takenAt!)
                    : pillWeekMissed(lang);
                return Text(
                  '${pillWeekday(lang, d)} $what',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                );
              }(),
          ],
        ),
      ],
    );
  }
}

/// The partner's line (board 5): « Pilule prise à 21:04 » or « pas encore
/// cochée », for today; nothing on a day off or when nothing is shared.
/// Brings its own rule above it.
class PartnerPillLine extends ConsumerWidget {
  const PartnerPillLine({super.key, required this.lang});

  final String lang;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(partnerPillLiveProvider);
    final p = ref.watch(partnerPillTodayProvider).valueOrNull;
    if (p == null || !p.tracking || !p.expected) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final takenAt = p.takenAt;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const NotebookRule(),
        NotebookLabel(pillLabel(lang)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Text(
                takenAt != null
                    ? pillPartnerTaken(lang, takenAt)
                    : pillPartnerNotYet(lang),
                style: theme.textTheme.bodyLarge,
              ),
            ),
            if (takenAt != null) _Check(color: theme.colorScheme.primary),
          ],
        ),
      ],
    );
  }
}
