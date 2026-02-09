import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nous_deux/presentation/providers/calendar_provider.dart';

class CalendarImportScreen extends ConsumerStatefulWidget {
  const CalendarImportScreen({super.key});

  @override
  ConsumerState<CalendarImportScreen> createState() =>
      _CalendarImportScreenState();
}

class _CalendarImportScreenState extends ConsumerState<CalendarImportScreen> {
  final _plugin = DeviceCalendarPlugin();
  List<Calendar> _calendars = [];
  Calendar? _selectedCalendar;
  DateTime _start = DateTime.now().subtract(const Duration(days: 30));
  DateTime _end = DateTime.now().add(const Duration(days: 30));
  bool _loading = false;
  String? _error;
  int _imported = 0;

  @override
  void initState() {
    super.initState();
    _loadCalendars();
  }

  Future<void> _loadCalendars() async {
    setState(() => _loading = true);
    final permResult = await _plugin.hasPermissions();
    if (!permResult.isSuccess || permResult.data != true) {
      await _plugin.requestPermissions();
    }
    final calResult = await _plugin.retrieveCalendars();
    if (!mounted) return;
    final calendars = calResult.data ?? <Calendar>[];
    setState(() {
      _calendars = calendars;
      _selectedCalendar = _calendars.isNotEmpty ? _calendars.first : null;
      _loading = false;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Importer depuis l\'agenda')),
      body: _loading && _calendars.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Choisissez un agenda et une période, puis importez les événements dans Notre Deux.',
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<Calendar>(
                  value: _selectedCalendar,
                  decoration: const InputDecoration(
                    labelText: 'Agenda',
                    border: OutlineInputBorder(),
                  ),
                  items: _calendars
                      .map(
                        (c) => DropdownMenuItem(
                          value: c,
                          child: Text(c.name ?? c.id ?? ''),
                        ),
                      )
                      .toList(),
                  onChanged: (c) => setState(() => _selectedCalendar = c),
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Du'),
                  subtitle: Text('${_start.toLocal()}'),
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
                  subtitle: Text('${_end.toLocal()}'),
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
                if (_error != null)
                  Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                if (_imported > 0) Text('$_imported événement(s) importé(s).'),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _loading ? null : _import,
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Importer'),
                ),
              ],
            ),
    );
  }
}
