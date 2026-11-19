import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:nousdeux/core/constants/cycle_strings.dart';
import 'package:nousdeux/core/constants/period_education.dart'
    show periodCancel;
import 'package:nousdeux/core/constants/pill_strings.dart';
import 'package:nousdeux/domain/entities/pill_entities.dart';
import 'package:nousdeux/domain/pill/pill_schedule.dart';
import 'package:nousdeux/presentation/providers/nous_provider.dart';
import 'package:nousdeux/presentation/providers/pill_provider.dart';
import 'package:nousdeux/presentation/providers/profile_provider.dart';
import 'package:nousdeux/presentation/widgets/notebook.dart';

/// « Non » to tracking a pill: Règles doesn't offer it again (Settings
/// still does).
const pillSetupDeclinedKey = 'pill_setup_declined';

/// « Plus tard »: the day Règles offers it again.
const pillSetupLaterUntilKey = 'pill_setup_later_until';

enum _Answer { yes, no, later }

/// Board 1: whether this person takes a hormonal pill, and if so the
/// reminder time, today's pill and the pack type. Saving needs the consent,
/// like the cycle: it is health data.
class PillSetupScreen extends ConsumerStatefulWidget {
  const PillSetupScreen({super.key});

  @override
  ConsumerState<PillSetupScreen> createState() => _PillSetupScreenState();
}

class _PillSetupScreenState extends ConsumerState<PillSetupScreen> {
  _Answer _answer = _Answer.yes;
  TimeOfDayValue _time = (hour: 21, minute: 0);
  int _pill = 1;
  PackType _type = PackType.p21x7;
  bool _saving = false;

  int get _maxPill => PillSchedule(_type, DateTime(2000)).pillsInPack;

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _time.hour, minute: _time.minute),
    );
    if (picked != null) {
      setState(() => _time = (hour: picked.hour, minute: picked.minute));
    }
  }

  Future<bool> _consent(String lang) async {
    final theme = Theme.of(context);
    final agreed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(pillConsentTitle(lang)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                pillConsent(lang),
                style: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.5,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              TextButton.icon(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(44, 44),
                ),
                onPressed: () => launchUrl(Uri.parse(cyclePrivacyUrl(lang))),
                icon: const Icon(Icons.open_in_new, size: 16),
                label: Text(cyclePrivacyPolicy(lang)),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(periodCancel(lang)),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(cycleConsentAccept(lang)),
          ),
        ],
      ),
    );
    return agreed ?? false;
  }

  Future<void> _continue(String lang) async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final now = ref.read(clockProvider)();
    final today = DateTime(now.year, now.month, now.day);
    if (_answer != _Answer.yes) {
      final prefs = await SharedPreferences.getInstance();
      if (_answer == _Answer.no) {
        await prefs.setBool(pillSetupDeclinedKey, true);
      } else {
        final until = DateTime(today.year, today.month, today.day + 7);
        await prefs.setString(pillSetupLaterUntilKey, until.toIso8601String());
      }
      ref.invalidate(pillSetupOfferedProvider);
      if (navigator.canPop()) navigator.pop();
      return;
    }
    if (!await _consent(lang)) return;
    setState(() => _saving = true);
    final failure = await ref
        .read(pillRepositoryProvider)
        .saveSettings(
          PillSettings(
            packType: _type,
            packStartedOn: DateTime(
              today.year,
              today.month,
              today.day - (_pill - 1),
            ),
            reminderTime: _time,
          ),
        );
    if (!mounted) return;
    setState(() => _saving = false);
    if (failure != null) {
      messenger.showSnackBar(SnackBar(content: Text(cycleSaveFailed(lang))));
      return;
    }
    ref
      ..invalidate(pillSettingsProvider)
      ..invalidate(pillWeekProvider);
    if (navigator.canPop()) navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(myProfileProvider).valueOrNull?.language ?? 'fr';
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;

    Widget choice(_Answer a, String label) => RadioListTile<_Answer>(
      value: a,
      // ignore: deprecated_member_use
      groupValue: _answer,
      // ignore: deprecated_member_use
      onChanged: (v) => setState(() => _answer = v ?? _answer),
      title: Text(label),
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.trailing,
    );

    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
        children: [
          NotebookLabel(pillLabel(lang)),
          const SizedBox(height: 18),
          Text(
            pillSetupQuestion(lang),
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w300,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            pillSetupWhy(lang),
            style: theme.textTheme.bodyLarge?.copyWith(
              color: muted,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          choice(_Answer.yes, pillSetupYes(lang)),
          choice(_Answer.no, pillSetupNo(lang)),
          choice(_Answer.later, pillSetupLater(lang)),
          if (_answer == _Answer.yes) ...[
            const NotebookRule(space: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: NotebookLabel(pillReminderLabel(lang)),
              trailing: Text(
                pillClock(lang, _time),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w300,
                ),
              ),
              onTap: _pickTime,
            ),
            Row(
              children: [
                Expanded(child: NotebookLabel(pillTodayLabel(lang))),
                IconButton(
                  tooltip: '-',
                  onPressed: _pill > 1 ? () => setState(() => _pill--) : null,
                  icon: const Icon(Icons.remove),
                ),
                Text(
                  pillNumberToday(lang, _pill),
                  style: theme.textTheme.titleMedium,
                ),
                IconButton(
                  tooltip: '+',
                  onPressed: _pill < _maxPill
                      ? () => setState(() => _pill++)
                      : null,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 12),
            NotebookLabel(pillPackLabel(lang)),
            const SizedBox(height: 10),
            SegmentedButton<PackType>(
              showSelectedIcon: false,
              segments: [
                for (final t in PackType.values)
                  ButtonSegment(value: t, label: Text(pillPackType(lang, t))),
              ],
              selected: {_type},
              onSelectionChanged: (s) => setState(() {
                _type = s.first;
                if (_pill > _maxPill) _pill = _maxPill;
              }),
            ),
            const SizedBox(height: 16),
            Text(
              pillHealthNote(lang),
              style: theme.textTheme.bodySmall?.copyWith(
                color: muted,
                height: 1.5,
              ),
            ),
          ],
          const SizedBox(height: 28),
          FilledButton(
            onPressed: _saving ? null : () => _continue(lang),
            child: Text(pillContinue(lang)),
          ),
        ],
      ),
    );
  }
}

/// Whether Règles offers to track a pill: not after « Non », and not until
/// the day « Plus tard » set.
final pillSetupOfferedProvider = FutureProvider<bool>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  if (prefs.getBool(pillSetupDeclinedKey) ?? false) return false;
  final until = DateTime.tryParse(
    prefs.getString(pillSetupLaterUntilKey) ?? '',
  );
  return until == null || !ref.read(clockProvider)().isBefore(until);
});
