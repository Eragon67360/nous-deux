import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:nousdeux/domain/entities/calendar_event_entity.dart';
import 'package:nousdeux/core/constants/app_spacing.dart';
import 'package:nousdeux/presentation/providers/auth_provider.dart';
import 'package:nousdeux/presentation/providers/calendar_provider.dart';
import 'package:nousdeux/presentation/providers/profile_provider.dart';
import 'package:nousdeux/presentation/screens/calendar/calendar_event_form_screen.dart';
import 'package:nousdeux/presentation/screens/calendar/calendar_import_screen.dart';
import 'package:nousdeux/presentation/widgets/empty_state.dart';
import 'package:nousdeux/presentation/widgets/loading_content.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

/// Marker colors from app SVG (text #722F37, accent #FF8FA3).
const Color _markerMine = Color(0xFF722F37);
const Color _markerPartner = Color(0xFFFF8FA3);

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
    final currentUserId = ref.watch(currentUserProvider).valueOrNull?.id;
    final partnerProfile = ref.watch(partnerProfileProvider).valueOrNull;
    final partnerDisplayName =
        partnerProfile?.username?.trim().isNotEmpty == true
        ? partnerProfile!.username!
        : 'Partenaire';
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendrier'),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const CalendarImportScreen(),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _openEventForm(
              context,
              selectedDate: _selectedDay ?? _focusedDay,
            ),
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        switchInCurve: Curves.easeOut,
        child: KeyedSubtree(
          key: ValueKey('${eventsAsync.isLoading}_${eventsAsync.hasValue}'),
          child: eventsAsync.when(
            data: (allEvents) {
              final eventsOnSelected = _eventsOnDay(
                allEvents,
                _selectedDay ?? _focusedDay,
              );
              return Column(
                children: [
                  TableCalendar<CalendarEventEntity>(
                    firstDay: DateTime(2000),
                    lastDay: DateTime(2100),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (d) => isSameDay(_selectedDay, d),
                    calendarFormat: _format,
                    onFormatChanged: (f) => setState(() => _format = f),
                    availableCalendarFormats: const {
                      CalendarFormat.month: 'Mois',
                      CalendarFormat.twoWeeks: '2 sem.',
                      CalendarFormat.week: 'Semaine',
                    },
                    onDaySelected: (selected, focused) => setState(() {
                      _selectedDay = selected;
                      _focusedDay = focused;
                    }),
                    eventLoader: (day) => _eventsOnDay(allEvents, day),
                    calendarBuilders: CalendarBuilders<CalendarEventEntity>(
                      markerBuilder: (context, day, events) {
                        if (events.isEmpty) return null;
                        final hasMine =
                            currentUserId != null &&
                            events.any((e) => e.createdBy == currentUserId);
                        final hasPartner =
                            currentUserId != null &&
                            events.any((e) => e.createdBy != currentUserId);
                        if (!hasMine && !hasPartner) return null;
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (hasMine)
                                Container(
                                  width: 5,
                                  height: 5,
                                  margin: const EdgeInsets.only(right: 2),
                                  decoration: const BoxDecoration(
                                    color: _markerMine,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              if (hasPartner)
                                Container(
                                  width: 5,
                                  height: 5,
                                  decoration: const BoxDecoration(
                                    color: _markerPartner,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                    calendarStyle: CalendarStyle(
                      defaultTextStyle: TextStyle(color: colorScheme.onSurface),
                      weekendTextStyle: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      selectedTextStyle: TextStyle(
                        color: colorScheme.onPrimary,
                      ),
                      todayTextStyle: TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                      selectedDecoration: BoxDecoration(
                        color: colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      todayDecoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                      outsideTextStyle: TextStyle(
                        color: colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                    headerStyle: HeaderStyle(
                      formatButtonVisible: true,
                      titleCentered: true,
                      titleTextStyle: Theme.of(context).textTheme.titleMedium!
                          .copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                      formatButtonTextStyle: TextStyle(
                        color: colorScheme.primary,
                      ),
                      leftChevronIcon: Icon(
                        Icons.chevron_left,
                        color: colorScheme.onSurface,
                      ),
                      rightChevronIcon: Icon(
                        Icons.chevron_right,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: eventsOnSelected.isEmpty
                        ? const EmptyState(
                            icon: Icons.event_available,
                            message: 'Aucun événement ce jour',
                            secondary: 'Appuyez sur + pour en ajouter un',
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            itemCount: eventsOnSelected.length,
                            itemBuilder: (_, i) {
                              final e = eventsOnSelected[i];
                              final isMine =
                                  currentUserId != null &&
                                  e.createdBy == currentUserId;
                              final creatorLabel = isMine
                                  ? 'Moi'
                                  : partnerDisplayName;
                              final timeStr = DateFormat.Hm().format(
                                e.startTime,
                              );
                              return Card(
                                margin: const EdgeInsets.only(
                                  bottom: AppSpacing.sm,
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.sm,
                                    vertical: AppSpacing.xs,
                                  ),
                                  leading: Icon(
                                    isMine
                                        ? Icons.person
                                        : Icons.person_outline,
                                    color: isMine
                                        ? colorScheme.primary
                                        : colorScheme.outline,
                                    size: 28,
                                  ),
                                  title: Text(e.title),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (e.description != null &&
                                          e.description!.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 2,
                                          ),
                                          child: Text(
                                            e.description!,
                                            style: Theme.of(
                                              context,
                                            ).textTheme.bodySmall,
                                          ),
                                        ),
                                      Text(
                                        '$creatorLabel · $timeStr',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color:
                                                  colorScheme.onSurfaceVariant,
                                            ),
                                      ),
                                    ],
                                  ),
                                  trailing: Text(
                                    timeStr,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                  onTap: () =>
                                      _openEventForm(context, event: e),
                                  onLongPress: () => _confirmDelete(context, e),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              );
            },
            loading: () => const LoadingContent(),
            error: (err, _) => EmptyState(
              icon: Icons.error_outline,
              message: 'Erreur de chargement',
              secondary: err.toString(),
              iconColor: colorScheme.error,
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            _openEventForm(context, selectedDate: _selectedDay ?? _focusedDay),
        child: const Icon(Icons.add),
      ),
    );
  }

  List<CalendarEventEntity> _eventsOnDay(
    List<CalendarEventEntity> events,
    DateTime day,
  ) {
    return events.where((e) {
      final d = e.startTime;
      return d.year == day.year && d.month == day.month && d.day == day.day;
    }).toList();
  }

  void _openEventForm(
    BuildContext context, {
    CalendarEventEntity? event,
    DateTime? selectedDate,
  }) {
    Navigator.of(context)
        .push(
          MaterialPageRoute<void>(
            builder: (_) => CalendarEventFormScreen(
              event: event,
              initialDate: selectedDate ?? event?.startTime ?? DateTime.now(),
            ),
          ),
        )
        .then((_) => ref.invalidate(calendarEventsProvider));
  }

  void _confirmDelete(BuildContext context, CalendarEventEntity e) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer l\'événement ?'),
        content: Text('« ${e.title}» sera supprimé.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
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
