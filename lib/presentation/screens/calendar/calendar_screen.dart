import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:nousdeux/domain/entities/calendar_event_entity.dart';
import 'package:nousdeux/core/constants/app_spacing.dart';
import 'package:nousdeux/core/constants/calendar_strings.dart';
import 'package:nousdeux/presentation/providers/auth_provider.dart';
import 'package:nousdeux/presentation/providers/calendar_provider.dart';
import 'package:nousdeux/presentation/providers/profile_provider.dart';
import 'package:nousdeux/presentation/screens/calendar/calendar_event_form_screen.dart';
import 'package:nousdeux/presentation/screens/calendar/calendar_import_screen.dart';
import 'package:nousdeux/presentation/widgets/loading_content.dart';

class CalendarHomeScreen extends ConsumerStatefulWidget {
  const CalendarHomeScreen({super.key});

  @override
  ConsumerState<CalendarHomeScreen> createState() => _CalendarHomeScreenState();
}

class _CalendarHomeScreenState extends ConsumerState<CalendarHomeScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat =
      CalendarFormat.twoWeeks; // Format par défaut pour l'accueil

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final eventsAsync = ref.watch(calendarEventsProvider);
    final currentUser = ref.watch(currentUserProvider).valueOrNull;
    final partnerProfile = ref.watch(partnerProfileProvider).valueOrNull;
    final lang = ref.watch(myProfileProvider).valueOrNull?.language ?? 'fr';

    final partnerName = partnerProfile?.username?.trim().isNotEmpty == true
        ? partnerProfile!.username!
        : calendarPartner(lang);

    final currentUserId = currentUser?.id;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // 1. En-tête (Date & Actions)
            _HomeHeader(
              lang: lang,
              onTodayTap: () {
                setState(() {
                  _focusedDay = DateTime.now();
                  _selectedDay = DateTime.now();
                });
              },
              onImportTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CalendarImportScreen()),
              ),
            ),

            // 2. Widget Calendrier
            eventsAsync.when(
              data: (allEvents) {
                return _CalendarSection(
                  language: lang,
                  focusedDay: _focusedDay,
                  selectedDay: _selectedDay,
                  calendarFormat: _calendarFormat,
                  events: allEvents,
                  currentUserId: currentUserId,
                  onDaySelected: _onDaySelected,
                  onFormatChanged: (format) =>
                      setState(() => _calendarFormat = format),
                  onPageChanged: (focused) => _focusedDay = focused,
                );
              },
              loading: () =>
                  const SizedBox(height: 140, child: LoadingContent()),
              error: (_, __) => const SizedBox.shrink(),
            ),

            const Divider(height: 1, thickness: 1),

            // 3. Liste des événements
            Expanded(
              child: eventsAsync.when(
                data: (allEvents) {
                  final dayEvents = _getEventsForDay(
                    allEvents,
                    _selectedDay ?? _focusedDay,
                  );

                  if (dayEvents.isEmpty) {
                    return _EmptyDayState(
                      lang: lang,
                      date: _selectedDay ?? _focusedDay,
                      onAddPressed: () => _openEventForm(context),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                      horizontal: AppSpacing.md,
                    ),
                    itemCount: dayEvents.length,
                    itemBuilder: (context, index) {
                      final event = dayEvents[index];
                      return _EventCard(
                        lang: lang,
                        event: event,
                        currentUserId: currentUserId,
                        partnerName: partnerName,
                        onTap: () => _openEventForm(context, event: event),
                        onLongPress: () => _confirmDelete(context, event),
                      );
                    },
                  );
                },
                loading: () => const LoadingContent(),
                error: (e, _) =>
                    Center(child: Text(e.toString(), softWrap: true)),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEventForm(context),
        icon: const Icon(Icons.add),
        label: Text(calendarAdd(lang)),
        elevation: 2,
      ),
    );
  }

  // --- Helpers Logiques ---

  List<CalendarEventEntity> _getEventsForDay(
    List<CalendarEventEntity> events,
    DateTime day,
  ) {
    return events.where((event) {
      return isSameDay(event.startTime, day);
    }).toList();
  }

  void _openEventForm(BuildContext context, {CalendarEventEntity? event}) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => CalendarEventFormScreen(
              event: event,
              initialDate: _selectedDay ?? _focusedDay,
            ),
          ),
        )
        .then((_) => ref.invalidate(calendarEventsProvider));
  }

  void _confirmDelete(BuildContext context, CalendarEventEntity event) {
    final lang = ref.read(myProfileProvider).valueOrNull?.language ?? 'fr';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(calendarDeleteEventTitle(lang)),
        content: Text(
          calendarDeleteEventConfirm(lang, event.title),
          softWrap: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(calendarCancel(lang)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(calendarRepositoryProvider).deleteEvent(event.id);
              if (context.mounted) ref.invalidate(calendarEventsProvider);
            },
            child: Text(calendarDelete(lang)),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// SOUS-WIDGETS (UI)
// -----------------------------------------------------------------------------

class _HomeHeader extends StatelessWidget {
  final String lang;
  final VoidCallback onTodayTap;
  final VoidCallback onImportTap;

  const _HomeHeader({
    required this.lang,
    required this.onTodayTap,
    required this.onImportTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = DateTime.now();
    final locale = lang == 'fr' ? 'fr_FR' : 'en_US';
    final dateString = DateFormat.yMMMMd(locale).format(today);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.sm,
        AppSpacing.xs,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  calendarTitle(lang),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                  softWrap: true,
                ),
                Text(
                  dateString,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  softWrap: true,
                ),
              ],
            ),
          ),
          IconButton.filledTonal(
            onPressed: onTodayTap,
            icon: const Icon(Icons.today),
            tooltip: calendarToday(lang),
          ),
          const SizedBox(width: 8),
          IconButton.outlined(
            onPressed: onImportTap,
            icon: const Icon(Icons.upload_file),
            tooltip: calendarImportTooltip(lang),
          ),
        ],
      ),
    );
  }
}

class _CalendarSection extends StatelessWidget {
  final String language;
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final CalendarFormat calendarFormat;
  final List<CalendarEventEntity> events;
  final String? currentUserId;
  final void Function(DateTime, DateTime) onDaySelected;
  final void Function(CalendarFormat) onFormatChanged;
  final void Function(DateTime) onPageChanged;

  // Couleurs définies dans les spécifications
  static const Color _markerMine = Color(0xFF722F37);
  static const Color _markerPartner = Color(0xFFFF8FA3);

  const _CalendarSection({
    required this.language,
    required this.focusedDay,
    required this.selectedDay,
    required this.calendarFormat,
    required this.events,
    required this.currentUserId,
    required this.onDaySelected,
    required this.onFormatChanged,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = language == 'fr' ? 'fr_FR' : 'en_US';

    return TableCalendar<CalendarEventEntity>(
      firstDay: DateTime(2020),
      lastDay: DateTime(2030),
      focusedDay: focusedDay,
      selectedDayPredicate: (day) => isSameDay(selectedDay, day),
      calendarFormat: calendarFormat,
      startingDayOfWeek: StartingDayOfWeek.monday,
      locale: locale,
      // Styles visuels
      calendarStyle: CalendarStyle(
        markersMaxCount: 1,
        outsideDaysVisible: true,
        defaultTextStyle: theme.textTheme.bodyMedium!,
        weekendTextStyle: theme.textTheme.bodyMedium!.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
        selectedDecoration: BoxDecoration(
          color: theme.colorScheme.primary,
          shape: BoxShape.circle,
        ),
        todayDecoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          shape: BoxShape.circle,
        ),
        todayTextStyle: TextStyle(
          color: theme.colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.bold,
        ),
      ),

      headerStyle: HeaderStyle(
        formatButtonVisible: true,
        titleCentered: true,
        formatButtonShowsNext: false,
        decoration: const BoxDecoration(),
        titleTextStyle: theme.textTheme.titleMedium!.copyWith(
          fontWeight: FontWeight.bold,
        ),
        formatButtonDecoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outline),
          borderRadius: BorderRadius.circular(12),
        ),
        formatButtonTextStyle: theme.textTheme.labelSmall!,
      ),

      availableCalendarFormats: {
        CalendarFormat.month: calendarFormatMonth(language),
        CalendarFormat.twoWeeks: calendarFormatTwoWeeks(language),
        CalendarFormat.week: calendarFormatWeek(language),
      },

      // Logique
      onDaySelected: onDaySelected,
      onFormatChanged: onFormatChanged,
      onPageChanged: onPageChanged,
      eventLoader: (day) =>
          events.where((e) => isSameDay(e.startTime, day)).toList(),

      // Marqueurs personnalisés (Points sous les dates)
      calendarBuilders: CalendarBuilders(
        markerBuilder: (context, day, dayEvents) {
          if (dayEvents.isEmpty) return null;

          final hasMine =
              currentUserId != null &&
              dayEvents.any((e) => e.createdBy == currentUserId);
          final hasPartner =
              currentUserId != null &&
              dayEvents.any((e) => e.createdBy != currentUserId);

          // Si l'utilisateur n'est pas connecté, on met une couleur générique
          if (currentUserId == null) {
            return _buildDot(theme.colorScheme.primary);
          }

          return Positioned(
            bottom: 5,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (hasMine) _buildDot(_markerMine),
                if (hasMine && hasPartner) const SizedBox(width: 2),
                if (hasPartner) _buildDot(_markerPartner),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDot(Color color) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

class _EventCard extends StatelessWidget {
  final String lang;
  final CalendarEventEntity event;
  final String? currentUserId;
  final String partnerName;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  // Couleurs
  static const Color _colorMine = Color(0xFF722F37);
  static const Color _colorPartner = Color(0xFFFF8FA3);

  const _EventCard({
    required this.lang,
    required this.event,
    required this.currentUserId,
    required this.partnerName,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMine = currentUserId != null && event.createdBy == currentUserId;

    final accentColor = isMine ? _colorMine : _colorPartner;
    final creatorLabel = isMine ? calendarMe(lang) : partnerName;

    final locale = lang == 'fr' ? 'fr_FR' : 'en_US';
    final startTime = DateFormat.Hm(locale).format(event.startTime);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Bande latérale de couleur
                Container(width: 6, color: accentColor),

                // 2. Contenu
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Titre
                        Text(
                          event.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          softWrap: true, // JAMAIS d'ellipse
                        ),

                        // Description (si existante)
                        if (event.description?.isNotEmpty == true) ...[
                          const SizedBox(height: 4),
                          Text(
                            event.description!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            softWrap: true, // JAMAIS d'ellipse
                          ),
                        ],

                        const SizedBox(height: 8),

                        // Métadonnées (Heure & Propriétaire)
                        Row(
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 14,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              startTime,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                              softWrap: true,
                            ),
                            const SizedBox(width: 12),

                            // Badge Propriétaire
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: accentColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                creatorLabel,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: accentColor,
                                  fontWeight: FontWeight.bold,
                                ),
                                softWrap: true,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyDayState extends StatelessWidget {
  final String lang;
  final DateTime date;
  final VoidCallback onAddPressed;

  const _EmptyDayState({
    required this.lang,
    required this.date,
    required this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isToday = isSameDay(date, DateTime.now());
    final locale = lang == 'fr' ? 'fr_FR' : 'en_US';
    final dateStr = DateFormat.MMMMd(locale).format(date);
    final message = isToday
        ? calendarNothingToday(lang)
        : calendarNoEventsOn(lang, dateStr);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.event_note,
                size: 64,
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                softWrap: true,
              ),
              const SizedBox(height: AppSpacing.sm),
              TextButton.icon(
                onPressed: onAddPressed,
                icon: const Icon(Icons.add),
                label: Text(calendarCreateEvent(lang)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
