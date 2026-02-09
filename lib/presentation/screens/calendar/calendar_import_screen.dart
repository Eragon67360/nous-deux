import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:nous_deux/core/constants/app_spacing.dart';
import 'package:nous_deux/presentation/providers/calendar_provider.dart';
import 'package:nous_deux/presentation/providers/profile_provider.dart';
import 'package:nous_deux/presentation/widgets/loading_content.dart';

class CalendarImportScreen extends ConsumerStatefulWidget {
  const CalendarImportScreen({super.key});

  @override
  ConsumerState<CalendarImportScreen> createState() =>
      _CalendarImportScreenState();
}

class _CalendarImportScreenState extends ConsumerState<CalendarImportScreen>
    with WidgetsBindingObserver {
  final _plugin = DeviceCalendarPlugin();
  List<Calendar> _calendars = [];
  Calendar? _selectedCalendar;
  DateTime _start = DateTime.now().subtract(const Duration(days: 30));
  DateTime _end = DateTime.now().add(const Duration(days: 30));
  bool _loading = false;
  bool _permissionGranted = false;
  bool _hasCompletedInitialLoad = false;
  String? _error;
  int _imported = 0;

  /// Set when user taps "Ouvrir les réglages"; we only re-check on resume when this is set.
  DateTime? _openedSettingsAt;
  DateTime? _lastResumeCheckAt;
  static const _resumeDebounce = Duration(seconds: 3);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadCalendars();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed || _permissionGranted || _loading)
      return;
    // Only re-check when user likely returned from app settings (they tapped "Ouvrir les réglages").
    if (_openedSettingsAt == null) return;
    final now = DateTime.now();
    if (_lastResumeCheckAt != null &&
        now.difference(_lastResumeCheckAt!) < _resumeDebounce)
      return;
    _lastResumeCheckAt = now;
    _openedSettingsAt = null;
    _loadCalendars();
  }

  static const _settingsChannel = MethodChannel('com.nous_deux.app/settings');

  Future<void> _openAppSettings() async {
    try {
      await _settingsChannel.invokeMethod<void>('openAppSettings');
    } on MissingPluginException catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Redémarrez complètement l\'app (arrêt puis relance) pour que le bouton Réglages fonctionne.',
          ),
          duration: Duration(seconds: 5),
        ),
      );
    }
  }

  Future<void> _loadCalendars() async {
    setState(() => _loading = true);
    var permResult = await _plugin.hasPermissions();
    if (!mounted) return;
    if (!permResult.isSuccess || permResult.data != true) {
      await _plugin.requestPermissions();
      if (!mounted) return;
      permResult = await _plugin.hasPermissions();
    }
    var calendars = <Calendar>[];
    try {
      final calResult = await _plugin.retrieveCalendars();
      if (!mounted) return;
      calendars = calResult.data ?? <Calendar>[];
    } on PlatformException catch (e) {
      if (!mounted) return;
      if (e.code == '401' || (e.message?.contains('not allowed') ?? false)) {
        setState(() {
          _permissionGranted = false;
          _calendars = [];
          _selectedCalendar = null;
          _loading = false;
          _hasCompletedInitialLoad = true;
        });
        return;
      }
      rethrow;
    }
    // Deduplicate by id so DropdownButtonFormField never sees duplicate values
    final seenIds = <String>{};
    final deduped = calendars
        .where((c) => c.id != null && seenIds.add(c.id!))
        .toList();
    setState(() {
      _permissionGranted = permResult.data == true;
      _calendars = deduped;
      _selectedCalendar = _calendars.isNotEmpty ? _calendars.first : null;
      _loading = false;
      _hasCompletedInitialLoad = true;
    });
  }

  Future<void> _import() async {
    if (_selectedCalendar == null) return;
    setState(() {
      _error = null;
      _loading = true;
      _imported = 0;
    });
    final eventsResult = await _plugin.retrieveEvents(
      _selectedCalendar!.id!,
      RetrieveEventsParams(startDate: _start, endDate: _end),
    );
    if (!mounted) return;
    final list = eventsResult.data ?? <Event>[];
    final repo = ref.read(calendarRepositoryProvider);
    for (final e in list) {
      if (e.title == null || e.start == null) continue;
      final result = await repo.createEvent(
        title: e.title!,
        description: e.description,
        startTime: e.start!,
        endTime: e.end,
      );
      if (result.failure == null) _imported++;
    }
    if (!mounted) return;
    setState(() {
      _loading = false;
    });
    ref.invalidate(calendarEventsProvider);
  }

  Future<void> _onTapAllowCalendar() async {
    await _loadCalendars();
  }

  String _formatDate(BuildContext context, DateTime d) {
    final language = ref.watch(myProfileProvider).valueOrNull?.language ?? 'fr';
    final locale = language == 'fr' ? 'fr_FR' : 'en_US';
    final dateFormat = language == 'fr'
        ? DateFormat('d MMM y', locale)
        : DateFormat('MMM d, y', locale);
    return dateFormat.format(d.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Importer depuis l\'agenda')),
      body: _loading && _calendars.isEmpty && !_hasCompletedInitialLoad
          ? const LoadingContent(message: 'Chargement des agendas...')
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.sm),
              children: [
                Text(
                  'Choisissez un agenda et une période, puis importez les événements dans Nous Deux.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: AppSpacing.sm),
                if (!_permissionGranted) ...[
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.errorContainer.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'L\'accès au calendrier est nécessaire pour importer les événements. Si la demande n\'apparaît pas, ouvrez les réglages pour l\'activer.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        OutlinedButton.icon(
                          onPressed: _loading ? null : _onTapAllowCalendar,
                          icon: _loading
                              ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                )
                              : const Icon(Icons.calendar_today, size: 20),
                          label: Text(
                            _loading
                                ? 'Vérification...'
                                : 'Autoriser l\'accès au calendrier',
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        TextButton.icon(
                          onPressed: _loading
                              ? null
                              : () async {
                                  setState(
                                    () => _openedSettingsAt = DateTime.now(),
                                  );
                                  await _openAppSettings();
                                },
                          icon: const Icon(Icons.settings, size: 20),
                          label: const Text('Ouvrir les réglages'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
                if (_permissionGranted && _calendars.isEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Aucun calendrier trouvé sur cet appareil.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
                if (_calendars.isNotEmpty) ...[
                  Builder(
                    builder: (context) {
                      final calendarIds = _calendars
                          .where((c) => c.id != null)
                          .map((c) => c.id!)
                          .toList();
                      final value =
                          _selectedCalendar?.id != null &&
                              calendarIds.contains(_selectedCalendar!.id)
                          ? _selectedCalendar!.id!
                          : (calendarIds.isNotEmpty ? calendarIds.first : null);
                      if (value != null &&
                          value != _selectedCalendar?.id &&
                          mounted) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (!mounted) return;
                          try {
                            final cal = _calendars.firstWhere(
                              (c) => c.id == value,
                            );
                            setState(() => _selectedCalendar = cal);
                          } catch (_) {}
                        });
                      }
                      return DropdownButtonFormField<String>(
                        value: value,
                        isExpanded: true,
                        decoration: const InputDecoration(labelText: 'Agenda'),
                        items: _calendars
                            .where((c) => c.id != null)
                            .map(
                              (c) => DropdownMenuItem<String>(
                                value: c.id!,
                                child: Text(c.name ?? c.id ?? ''),
                              ),
                            )
                            .toList(),
                        onChanged: (id) {
                          if (id == null) return;
                          final c = _calendars.firstWhere(
                            (cal) => cal.id == id,
                          );
                          setState(() => _selectedCalendar = c);
                        },
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ListTile(
                    title: const Text('Du'),
                    subtitle: Text(_formatDate(context, _start)),
                    onTap: () async {
                      final d = await showDatePicker(
                        context: context,
                        initialDate: _start,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (d != null && mounted) setState(() => _start = d);
                    },
                  ),
                  ListTile(
                    title: const Text('Au'),
                    subtitle: Text(_formatDate(context, _end)),
                    onTap: () async {
                      final d = await showDatePicker(
                        context: context,
                        initialDate: _end,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (d != null && mounted) setState(() => _end = d);
                    },
                  ),
                ],
                if (_error != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
                if (_imported > 0) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '$_imported événement(s) importé(s).',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                FilledButton(
                  onPressed:
                      (_loading ||
                          !_permissionGranted ||
                          _calendars.isEmpty ||
                          _selectedCalendar == null)
                      ? null
                      : _import,
                  child: _loading
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            const Text('Importation...'),
                          ],
                        )
                      : const Text('Importer'),
                ),
              ],
            ),
    );
  }
}
