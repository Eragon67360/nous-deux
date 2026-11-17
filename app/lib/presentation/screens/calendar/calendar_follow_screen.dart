import 'package:device_calendar/device_calendar.dart' show Calendar;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart'
    show openAppSettings;

import 'package:nousdeux/core/constants/calendar_strings.dart';
import 'package:nousdeux/data/calendar_sync/calendar_sync_service.dart';
import 'package:nousdeux/presentation/providers/calendar_provider.dart';
import 'package:nousdeux/presentation/providers/calendar_sync_provider.dart';
import 'package:nousdeux/presentation/providers/profile_provider.dart';
import 'package:nousdeux/presentation/widgets/loading_content.dart';
import 'package:nousdeux/presentation/widgets/notebook.dart';

/// « Agenda du téléphone »: a switch per phone calendar. The events of the
/// followed ones are copied into the couple's calendar and kept up to date
/// (docs/CALENDAR_SYNC.md).
class CalendarFollowScreen extends ConsumerStatefulWidget {
  const CalendarFollowScreen({super.key});

  @override
  ConsumerState<CalendarFollowScreen> createState() =>
      _CalendarFollowScreenState();
}

class _CalendarFollowScreenState extends ConsumerState<CalendarFollowScreen>
    with WidgetsBindingObserver {
  /// The phone's calendars; null until read or without access.
  List<Calendar>? _calendars;
  bool _loaded = false;
  Set<String> _followed = {};
  String? _installId;
  bool _busy = false;

  /// The calendars just switched, shown while the first copy runs.
  Set<String>? _pending;

  /// Set when the person went to the app's settings, to look again on return.
  bool _openedSettings = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _openedSettings) {
      _openedSettings = false;
      _load();
    }
  }

  Future<void> _load() async {
    final prefs = ref.read(calendarFollowPrefsProvider);
    final calendars = await ref.read(phoneCalendarProvider).calendars();
    final followed = await prefs.followed();
    final installId = await prefs.installId();
    if (!mounted) return;
    setState(() {
      _calendars = calendars;
      _followed = followed;
      _installId = installId;
      _loaded = true;
    });
  }

  Future<void> _askAccess() async {
    setState(() => _busy = true);
    await ref.read(phoneCalendarProvider).requestAccess();
    await _load();
    if (mounted) setState(() => _busy = false);
  }

  /// The app's page in the phone's settings, on iPhone and Android.
  Future<void> _openSettings() async {
    _openedSettings = true;
    await openAppSettings();
  }

  /// Follows [ids] from this phone, then shows what changed.
  Future<void> _follow(Set<String> ids, String lang) async {
    setState(() {
      _busy = true;
      _pending = ids;
    });
    final outcome = await ref.read(calendarSyncServiceProvider).follow(ids);
    if (!mounted) return;
    ref
      ..invalidate(myProfileProvider)
      ..invalidate(calendarEventsProvider);
    if (outcome == CalendarSyncOutcome.failed) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(calendarFollowFailed(lang))));
    }
    await _load();
    if (mounted) {
      setState(() {
        _busy = false;
        _pending = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final me = ref.watch(myProfileProvider).valueOrNull;
    final lang = me?.language ?? 'fr';
    final partner = ref.watch(partnerProfileProvider).valueOrNull;
    final partnerName = partner?.username?.trim().isNotEmpty == true
        ? partner!.username!.trim()
        : calendarPartner(lang);
    final quiet = theme.textTheme.bodyMedium?.copyWith(
      color: scheme.onSurfaceVariant,
    );

    final calendars = _calendars;
    final device = me?.calendarSyncDevice;
    final thisPhone = device != null && device == _installId;
    final otherPhone = device != null && _installId != null && !thisPhone;
    final available = {for (final c in calendars ?? <Calendar>[]) c.id};
    final gone = calendars == null
        ? <String>{}
        : _followed.where((id) => !available.contains(id)).toSet();
    final syncedAt = me?.calendarSyncedAt;

    return Scaffold(
      appBar: AppBar(),
      body: !_loaded
          ? const LoadingContent()
          : ListView(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 40),
              children: [
                NotebookLabel(calendarFollowLabel(lang)),
                const SizedBox(height: 10),
                Text(
                  calendarFollowTitle(lang),
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  calendarFollowIntro(lang, partnerName),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const NotebookRule(space: 18),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      size: 20,
                      color: scheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(calendarFollowTip(lang), style: quiet),
                    ),
                  ],
                ),
                const NotebookRule(space: 18),
                if (calendars == null) ...[
                  Text(calendarFollowPermission(lang), style: quiet),
                  const SizedBox(height: 12),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: OutlinedButton(
                      onPressed: _busy ? null : _askAccess,
                      child: Text(calendarImportAllowAccess(lang)),
                    ),
                  ),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: TextButton(
                      onPressed: _busy ? null : _openSettings,
                      child: Text(calendarImportOpenSettings(lang)),
                    ),
                  ),
                ] else ...[
                  if (otherPhone)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(calendarFollowOtherPhone(lang), style: quiet),
                    ),
                  if (gone.isNotEmpty && thisPhone) ...[
                    Text(calendarFollowGone(lang), style: quiet),
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: TextButton(
                        onPressed: _busy
                            ? null
                            : () => _follow(_followed.difference(gone), lang),
                        child: Text(calendarFollowDropGone(lang)),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (_pending != null)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: LinearProgressIndicator(minHeight: 2),
                    ),
                  if (calendars.isEmpty)
                    Text(calendarFollowNone(lang), style: quiet),
                  for (final c in calendars)
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      secondary: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: c.color == null
                              ? scheme.outline
                              : Color(c.color!),
                        ),
                      ),
                      title: Text(c.name ?? ''),
                      subtitle: c.accountName == null
                          ? null
                          : Text(c.accountName!),
                      value:
                          _pending?.contains(c.id) ??
                          (thisPhone && _followed.contains(c.id)),
                      onChanged: _busy || c.id == null
                          ? null
                          : (on) {
                              final base = thisPhone ? _followed : <String>{};
                              _follow(
                                on
                                    ? {...base, c.id!}
                                    : (base.toSet()..remove(c.id)),
                                lang,
                              );
                            },
                    ),
                  if (thisPhone && syncedAt != null) ...[
                    const SizedBox(height: 24),
                    NotebookLabel(calendarFollowLastSync(lang)),
                    const SizedBox(height: 4),
                    Text(
                      calendarAgo(lang, syncedAt, DateTime.now()),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ],
                const SizedBox(height: 24),
                Text(calendarFollowFootnote(lang), style: quiet),
              ],
            ),
    );
  }
}
