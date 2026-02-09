import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:nous_deux/domain/entities/calendar_event_entity.dart';
import 'package:nous_deux/presentation/providers/calendar_provider.dart';
import 'package:nous_deux/presentation/screens/calendar/calendar_event_form_screen.dart';
import 'package:nous_deux/presentation/screens/calendar/calendar_import_screen.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _format = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(calendarEventsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendrier'),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const CalendarImportScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _openEventForm(context, selectedDate: _selectedDay ?? _focusedDay),
          ),
        ],
      ),
      body: eventsAsync.when(
        data: (allEvents) {
          final eventsOnSelected = _eventsOnDay(allEvents, _selectedDay ?? _focusedDay);
          return Column(
            children: [
              TableCalendar<CalendarEventEntity>(
                firstDay: DateTime(2000),
                lastDay: DateTime(2100),
                focusedDay: _focusedDay,
                selectedDayPredicate: (d) => isSameDay(_selectedDay, d),
                calendarFormat: _format,
                onFormatChanged: (f) => setState(() => _format = f),
                onDaySelected: (selected, focused) => setState(() {
                  _selectedDay = selected;
                  _focusedDay = focused;
                }),
                eventLoader: (day) => _eventsOnDay(allEvents, day),
                calendarStyle: CalendarStyle(
                  markerDecoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: true,
                  titleCentered: true,
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: eventsOnSelected.isEmpty
                    ? Center(
                        child: Text(
                          'Aucun événement ce jour',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: eventsOnSelected.length,
                        itemBuilder: (_, i) {
                          final e = eventsOnSelected[i];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              title: Text(e.title),
                              subtitle: e.description != null && e.description!.isNotEmpty
                                  ? Text(e.description!)
                                  : null,
                              trailing: Text(
                                DateFormat.Hm().format(e.startTime),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              onTap: () => _openEventForm(context, event: e),
                              onLongPress: () => _confirmDelete(context, e),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Erreur: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openEventForm(context, selectedDate: _selectedDay ?? _focusedDay),
        child: const Icon(Icons.add),
      ),
    );
  }

  List<CalendarEventEntity> _eventsOnDay(List<CalendarEventEntity> events, DateTime day) {
    return events.where((e) {
      final d = e.startTime;
      return d.year == day.year && d.month == day.month && d.day == day.day;
    }).toList();
  }

  void _openEventForm(BuildContext context, {CalendarEventEntity? event, DateTime? selectedDate}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CalendarEventFormScreen(
          event: event,
          initialDate: selectedDate ?? event?.startTime ?? DateTime.now(),
        ),
      ),
    ).then((_) => ref.invalidate(calendarEventsProvider));
  }

  void _confirmDelete(BuildContext context, CalendarEventEntity e) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer l\'événement ?'),
        content: Text('« ${e.title }» sera supprimé.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(calendarRepositoryProvider).deleteEvent(e.id);
              if (context.mounted) ref.invalidate(calendarEventsProvider);
            },
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}
