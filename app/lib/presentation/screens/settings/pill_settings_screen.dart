import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nousdeux/core/constants/cycle_strings.dart';
import 'package:nousdeux/core/constants/period_education.dart'
    show periodCancel;
import 'package:nousdeux/core/constants/pill_strings.dart';
import 'package:nousdeux/core/services/local_notifications.dart';
import 'package:nousdeux/core/services/pill_reminders.dart';
import 'package:nousdeux/domain/entities/pill_entities.dart';
import 'package:nousdeux/domain/pill/pill_schedule.dart';
import 'package:nousdeux/presentation/providers/nous_provider.dart';
import 'package:nousdeux/presentation/providers/pill_provider.dart';
import 'package:nousdeux/presentation/providers/profile_provider.dart';
import 'package:nousdeux/presentation/screens/period/pill_setup_screen.dart';
import 'package:nousdeux/presentation/widgets/notebook.dart';

/// Board 7: the reminder (on or off, its time, what the lock screen says),
/// the pack (its type, today's pill), what the partner sees, and « Arrêter
/// le suivi ».
class PillSettingsScreen extends ConsumerWidget {
  const PillSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(myProfileProvider).valueOrNull?.language ?? 'fr';
    final settingsAsync = ref.watch(pillSettingsProvider);
    final partner = ref.watch(partnerProfileProvider).valueOrNull;
    final name = cyclePartnerName(lang, partner?.username);
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final messenger = ScaffoldMessenger.of(context);

    Future<void> save(PillSettings s) async {
      final failure = await ref.read(pillRepositoryProvider).saveSettings(s);
      if (failure != null) {
        messenger.showSnackBar(SnackBar(content: Text(cycleSaveFailed(lang))));
      }
      ref.invalidate(pillSettingsProvider);
    }

    final settings = settingsAsync.valueOrNull;
    return Scaffold(
      appBar: AppBar(title: Text(pillSettingsTitle(lang))),
      body: settings == null
          ? ListView(
              padding: const EdgeInsets.all(24),
              children: [
                if (settingsAsync.hasValue)
                  NotebookLink(
                    label: pillTrackLink(lang),
                    onTap: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute<void>(
                        builder: (_) => const PillSetupScreen(),
                      ),
                    ),
                  ),
              ],
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
              children: [
                NotebookLabel(pillReminderLabel(lang)),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: Text(pillReminderDaily(lang)),
                  value: settings.reminderOn,
                  activeThumbColor: theme.colorScheme.primary,
                  onChanged: (on) => save(settings.copyWith(reminderOn: on)),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(pillReminderTime(lang)),
                  trailing: Text(
                    pillClock(lang, settings.reminderTime),
                    style: theme.textTheme.titleMedium,
                  ),
                  onTap: () async {
                    final t = settings.reminderTime;
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay(hour: t.hour, minute: t.minute),
                    );
                    if (picked == null) return;
                    await save(
                      settings.copyWith(
                        reminderTime: (
                          hour: picked.hour,
                          minute: picked.minute,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 4),
                Text(
                  pillLockScreen(lang),
                  style: theme.textTheme.bodyMedium?.copyWith(color: muted),
                ),
                const SizedBox(height: 8),
                SegmentedButton<ReminderText>(
                  showSelectedIcon: false,
                  segments: [
                    for (final style in ReminderText.values)
                      ButtonSegment(
                        value: style,
                        label: Text(pillLockScreenChoice(lang, style)),
                      ),
                  ],
                  selected: {settings.reminderText},
                  onSelectionChanged: (s) =>
                      save(settings.copyWith(reminderText: s.first)),
                ),
                const NotebookRule(),
                NotebookLabel(pillPackLabel(lang)),
                const SizedBox(height: 10),
                SegmentedButton<PackType>(
                  showSelectedIcon: false,
                  segments: [
                    for (final t in PackType.values)
                      ButtonSegment(
                        value: t,
                        label: Text(pillPackType(lang, t)),
                      ),
                  ],
                  selected: {settings.packType},
                  onSelectionChanged: (s) =>
                      save(settings.copyWith(packType: s.first)),
                ),
                _TodayPill(lang: lang, settings: settings, onSave: save),
                const NotebookRule(),
                NotebookLabel(pillWithPartner(lang, name)),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: Text(pillShareWith(lang, name)),
                  subtitle: Text(pillShareWithNote(lang)),
                  value: settings.shareWithPartner,
                  activeThumbColor: theme.colorScheme.primary,
                  onChanged: (on) =>
                      save(settings.copyWith(shareWithPartner: on)),
                ),
                const NotebookRule(),
                TextButton(
                  style: TextButton.styleFrom(
                    alignment: AlignmentDirectional.centerStart,
                    padding: EdgeInsets.zero,
                    foregroundColor: theme.colorScheme.error,
                  ),
                  onPressed: () => _stop(context, ref, lang),
                  child: Text(pillStop(lang)),
                ),
                Text(
                  pillStopNote(lang, name),
                  style: theme.textTheme.bodySmall?.copyWith(color: muted),
                ),
              ],
            ),
    );
  }

  Future<void> _stop(BuildContext context, WidgetRef ref, String lang) async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final sure = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(pillStopConfirmTitle(lang)),
        content: Text(pillStopConfirmBody(lang)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(periodCancel(lang)),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(pillStopConfirm(lang)),
          ),
        ],
      ),
    );
    if (sure != true) return;
    final failure = await ref.read(pillRepositoryProvider).stopTracking();
    if (failure != null) {
      messenger.showSnackBar(SnackBar(content: Text(cycleSaveFailed(lang))));
      return;
    }
    try {
      await ref
          .read(localNotificationsProvider)
          .cancelRange(pillReminderFirstId, pillSnoozeId);
    } catch (_) {}
    ref
      ..invalidate(pillSettingsProvider)
      ..invalidate(pillWeekProvider);
    if (navigator.canPop()) navigator.pop();
  }
}

/// « Comprimé d'aujourd'hui »: moves the pack so today is that pill.
class _TodayPill extends ConsumerWidget {
  const _TodayPill({
    required this.lang,
    required this.settings,
    required this.onSave,
  });

  final String lang;
  final PillSettings settings;
  final Future<void> Function(PillSettings) onSave;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = ref.watch(clockProvider)();
    final today = DateTime(now.year, now.month, now.day);
    final schedule = settings.schedule;
    final day = schedule.dayInPack(today);
    final max = schedule.pillsInPack;

    void moveTo(int pill) => onSave(
      settings.copyWith(
        packStartedOn: DateTime(today.year, today.month, today.day - pill + 1),
      ),
    );

    return Row(
      children: [
        Expanded(child: Text(pillTodayPill(lang))),
        IconButton(
          tooltip: '-',
          onPressed: day > 1 ? () => moveTo(day - 1) : null,
          icon: const Icon(Icons.remove),
        ),
        Text(
          day <= max ? pillNumberToday(lang, day) : pillDayOff(lang),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        IconButton(
          tooltip: '+',
          onPressed: day < 28 ? () => moveTo(day + 1) : null,
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }
}
