import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:nousdeux/core/constants/app_spacing.dart';
import 'package:nousdeux/core/constants/calendar_strings.dart';
import 'package:nousdeux/core/l10n/app_languages.dart';
import 'package:nousdeux/core/utils/date_only.dart';
import 'package:nousdeux/domain/entities/calendar_event_entity.dart';
import 'package:nousdeux/presentation/providers/auth_provider.dart';
import 'package:nousdeux/presentation/providers/calendar_provider.dart';
import 'package:nousdeux/presentation/providers/profile_provider.dart';
import 'package:nousdeux/presentation/screens/calendar/calendar_event_form_screen.dart';
import 'package:nousdeux/presentation/screens/calendar/calendar_follow_screen.dart';
import 'package:nousdeux/presentation/theme/app_motion.dart';
import 'package:nousdeux/presentation/theme/app_theme.dart';
import 'package:nousdeux/presentation/widgets/empty_state.dart';
import 'package:nousdeux/presentation/widgets/loading_content.dart';
import 'package:nousdeux/presentation/widgets/notebook.dart';

/// The calendar as a diary: one month at a time, each day that has something
/// planned written as a large number with its events beside it.
class CalendarHomeScreen extends ConsumerStatefulWidget {
  const CalendarHomeScreen({super.key});

  @override
  ConsumerState<CalendarHomeScreen> createState() => _CalendarHomeScreenState();
}

class _CalendarHomeScreenState extends ConsumerState<CalendarHomeScreen> {
  DateTime _month = _monthOf(DateTime.now());

  static DateTime _monthOf(DateTime day) => DateTime(day.year, day.month);

  bool get _isCurrentMonth => _month == _monthOf(DateTime.now());

  /// Which way the last page turn went: 1 to a later month, -1 to an
  /// earlier one. The new month slides in from that side.
  int _turn = 1;

  /// How far the finger has moved sideways in the current drag.
  double _dragged = 0;

  void _showMonth(DateTime month) {
    if (month == _month) return;
    setState(() {
      _turn = month.isAfter(_month) ? 1 : -1;
      _month = month;
    });
  }

  void _shiftMonth(int delta) =>
      _showMonth(DateTime(_month.year, _month.month + delta));

  /// A quick swipe, or a slow drag across about a quarter of the screen,
  /// turns the page: to the left for the next month, to the right for the
  /// one before. Anything shorter leaves the month alone.
  void _onSwipeEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    final dragged = _dragged;
    _dragged = 0;
    if (velocity.abs() >= 300) {
      _shiftMonth(velocity < 0 ? 1 : -1);
    } else if (dragged.abs() >= 96) {
      _shiftMonth(dragged < 0 ? 1 : -1);
    }
  }

  /// The viewed month's events, grouped by the day they start, in order.
  static List<(DateTime, List<CalendarEventEntity>)> _diary(
    List<CalendarEventEntity> events,
    DateTime month,
  ) {
    final inMonth =
        events
            .where(
              (e) =>
                  e.startTime.year == month.year &&
                  e.startTime.month == month.month,
            )
            .toList()
          ..sort((a, b) => a.startTime.compareTo(b.startTime));
    final days = <(DateTime, List<CalendarEventEntity>)>[];
    for (final event in inMonth) {
      final day = dayOf(event.startTime);
      if (days.isNotEmpty && days.last.$1 == day) {
        days.last.$2.add(event);
      } else {
        days.add((day, [event]));
      }
    }
    return days;
  }

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(calendarEventsProvider);
    final currentUserId = ref.watch(currentUserProvider).valueOrNull?.id;
    final partnerProfile = ref.watch(partnerProfileProvider).valueOrNull;
    final lang = ref.watch(myProfileProvider).valueOrNull?.language ?? 'fr';
    final partnerName = partnerProfile?.username?.trim().isNotEmpty == true
        ? partnerProfile!.username!.trim()
        : calendarPartner(lang);
    final partnerSyncedAt = partnerProfile?.calendarSyncDevice == null
        ? null
        : partnerProfile?.calendarSyncedAt;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _DiaryHeader(
              lang: lang,
              month: _month,
              onPrevious: () => _shiftMonth(-1),
              onNext: () => _shiftMonth(1),
              onToday: () => _showMonth(_monthOf(DateTime.now())),
              partnerFresh: partnerSyncedAt == null
                  ? null
                  : calendarPartnerFresh(
                      lang,
                      partnerName,
                      calendarAgo(lang, partnerSyncedAt, DateTime.now()),
                    ),
              onFollow: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CalendarFollowScreen()),
              ),
              onAdd: () => _openEventForm(context),
            ),
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onHorizontalDragUpdate: (d) => _dragged += d.primaryDelta ?? 0,
                onHorizontalDragEnd: _onSwipeEnd,
                onHorizontalDragCancel: () => _dragged = 0,
                child: AnimatedSwitcher(
                  duration: AppMotion.reduced(context)
                      ? Duration.zero
                      : AppMotion.medium,
                  switchInCurve: AppMotion.enter,
                  switchOutCurve: AppMotion.exit,
                  layoutBuilder: (current, previous) => Stack(
                    fit: StackFit.expand,
                    children: [...previous, ?current],
                  ),
                  // The new month comes in a little from the side it was
                  // swiped from; the old one leaves the other way.
                  transitionBuilder: (child, animation) {
                    final incoming = child.key == ValueKey(_month);
                    final from = Offset((incoming ? 0.06 : -0.06) * _turn, 0);
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween(
                          begin: from,
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: KeyedSubtree(
                    key: ValueKey(_month),
                    child: eventsAsync.when(
                      data: (allEvents) {
                        final days = _diary(allEvents, _month);
                        if (days.isEmpty) {
                          return EmptyState(
                            icon: Icons.event_note_outlined,
                            message: calendarNothingInMonth(
                              lang,
                              DateFormat.MMMM(
                                AppLanguages.dateLocale(lang),
                              ).format(_month),
                            ),
                            actionLabel: calendarCreateEvent(lang),
                            onAction: () => _openEventForm(context),
                          );
                        }
                        final today = dayOf(DateTime.now());
                        return ListView(
                          padding: const EdgeInsets.fromLTRB(
                            28,
                            0,
                            28,
                            AppSpacing.lg,
                          ),
                          children: [
                            for (final (i, (day, events)) in days.indexed)
                              _DiaryDay(
                                lang: lang,
                                day: day,
                                today: today,
                                events: events,
                                last: i == days.length - 1,
                                currentUserId: currentUserId,
                                partnerName: partnerName,
                                onOpen: (event) => event.isSynced
                                    ? _openSynced(context, event, partnerName)
                                    : _openEventForm(context, event: event),
                                onDelete: (event) => event.isSynced
                                    ? _openSynced(context, event, partnerName)
                                    : _confirmDelete(context, event),
                              ),
                            const SizedBox(height: AppSpacing.sm),
                            _Legend(lang: lang, partnerName: partnerName),
                          ],
                        );
                      },
                      loading: () => const LoadingContent(),
                      error: (e, _) =>
                          Center(child: Text(e.toString(), softWrap: true)),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openEventForm(BuildContext context, {CalendarEventEntity? event}) {
    // A new event starts today in the current month, else on the 1st.
    final initialDate = _isCurrentMonth ? DateTime.now() : _month;
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) =>
                CalendarEventFormScreen(event: event, initialDate: initialDate),
          ),
        )
        .then((_) => ref.invalidate(calendarEventsProvider));
  }

  /// A copy from a followed phone calendar: shown read-only, since it is
  /// changed on its owner's phone; only its countdown can be switched.
  void _openSynced(
    BuildContext context,
    CalendarEventEntity event,
    String partnerName,
  ) {
    final lang = ref.read(myProfileProvider).valueOrNull?.language ?? 'fr';
    final mine =
        event.createdBy == ref.read(currentUserProvider).valueOrNull?.id;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => _SyncedEventSheet(
        lang: lang,
        event: event,
        mine: mine,
        partnerName: partnerName,
      ),
    ).then((_) => ref.invalidate(calendarEventsProvider));
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

class _DiaryHeader extends StatelessWidget {
  const _DiaryHeader({
    required this.lang,
    required this.month,
    required this.onPrevious,
    required this.onNext,
    required this.onToday,
    required this.onFollow,
    required this.onAdd,
    this.partnerFresh,
  });

  final String lang;
  final DateTime month;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onToday;
  final VoidCallback onFollow;
  final VoidCallback onAdd;

  /// When the partner's followed calendars last synced, if they follow any.
  final String? partnerFresh;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final locale = AppLanguages.dateLocale(lang);
    final outlined = IconButton.styleFrom(
      side: BorderSide(color: scheme.outlineVariant),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(28, AppSpacing.xs, 16, AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(
                    DateFormat('MMMM y', locale).format(month).toUpperCase(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontSize: 11,
                      letterSpacing: 2,
                      color: scheme.primary,
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: onPrevious,
                tooltip: calendarPreviousMonth(lang),
                icon: const Icon(Icons.chevron_left),
              ),
              IconButton(
                onPressed: onNext,
                tooltip: calendarNextMonth(lang),
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
          if (partnerFresh != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Icon(Icons.sync, size: 14, color: scheme.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      partnerFresh!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              Expanded(
                // One line that shrinks on narrow phones or with large text,
                // instead of sending the last letters of "Calendrier" under.
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    calendarTitle(lang),
                    maxLines: 1,
                    softWrap: false,
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontSize: 36,
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: onToday,
                tooltip: calendarToday(lang),
                style: outlined,
                icon: const Icon(Icons.today_outlined, size: 20),
              ),
              const SizedBox(width: 6),
              IconButton(
                onPressed: onFollow,
                tooltip: calendarFollowLabel(lang),
                style: outlined,
                icon: const Icon(Icons.sync, size: 20),
              ),
              const SizedBox(width: 6),
              IconButton(
                onPressed: onAdd,
                tooltip: calendarAdd(lang),
                style: IconButton.styleFrom(
                  backgroundColor: scheme.primary,
                  foregroundColor: scheme.onPrimary,
                ),
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DiaryDay extends StatelessWidget {
  const _DiaryDay({
    required this.lang,
    required this.day,
    required this.today,
    required this.events,
    required this.last,
    required this.currentUserId,
    required this.partnerName,
    required this.onOpen,
    required this.onDelete,
  });

  final String lang;
  final DateTime day;
  final DateTime today;
  final List<CalendarEventEntity> events;
  final bool last;
  final String? currentUserId;
  final String partnerName;
  final void Function(CalendarEventEntity) onOpen;
  final void Function(CalendarEventEntity) onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final locale = AppLanguages.dateLocale(lang);
    final isToday = day == today;

    return Opacity(
      // Days already gone this month stay readable but step back.
      opacity: day.isBefore(today) ? 0.55 : 1,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: scheme.outlineVariant),
            bottom: last
                ? BorderSide(color: scheme.outlineVariant)
                : BorderSide.none,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 64,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${day.day}',
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontSize: 40,
                      fontWeight: FontWeight.w300,
                      height: 1,
                      color: isToday ? scheme.primary : scheme.onSurface,
                    ),
                  ),
                  Text(
                    DateFormat.E(locale).format(day),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final event in events)
                    _DiaryEvent(
                      lang: lang,
                      event: event,
                      isMine:
                          currentUserId != null &&
                          event.createdBy == currentUserId,
                      partnerName: partnerName,
                      onTap: () => onOpen(event),
                      onLongPress: () => onDelete(event),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DiaryEvent extends StatelessWidget {
  const _DiaryEvent({
    required this.lang,
    required this.event,
    required this.isMine,
    required this.partnerName,
    required this.onTap,
    required this.onLongPress,
  });

  final String lang;
  final CalendarEventEntity event;
  final bool isMine;
  final String partnerName;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final locale = AppLanguages.dateLocale(lang);
    final quiet = theme.textTheme.bodyMedium?.copyWith(
      color: scheme.onSurfaceVariant,
    );

    final row = Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            event.title,
            softWrap: true,
            style: theme.textTheme.titleMedium?.copyWith(
              fontSize: 19,
              fontWeight: FontWeight.w500,
              color: event.isCountdown ? scheme.primary : scheme.onSurface,
            ),
          ),
          if (event.description?.isNotEmpty == true) ...[
            const SizedBox(height: 2),
            Text(event.description!, softWrap: true, style: quiet),
          ],
          const SizedBox(height: 6),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 4,
            children: [
              OwnerDot(isMine: isMine),
              Text(DateFormat.Hm(locale).format(event.startTime), style: quiet),
              Text(isMine ? calendarMe(lang) : partnerName, style: quiet),
              if (event.isCountdown)
                Text(
                  calendarEventCountdown(lang),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: scheme.primary,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: !event.isSynced
          ? row
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: row),
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 8),
                  child: Icon(
                    Icons.smartphone_outlined,
                    size: 16,
                    color: scheme.onSurfaceVariant,
                    semanticLabel: calendarSyncedFrom(
                      lang,
                      partnerName,
                      mine: isMine,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

/// Whose event it is: a cream dot ringed in wine for mine, a pink dot for my
/// partner's. Wine alone is too dark to see on the dark ground.
class OwnerDot extends StatelessWidget {
  const OwnerDot({super.key, required this.isMine});

  final bool isMine;

  @override
  Widget build(BuildContext context) {
    final couple = CoupleColors.of(context);
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isMine
            ? Theme.of(context).colorScheme.onSurface
            : couple.partner,
        border: isMine ? Border.all(color: couple.mine, width: 2.5) : null,
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.lang, required this.partnerName});

  final String lang;
  final String partnerName;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );
    return ExcludeSemantics(
      child: Wrap(
        spacing: 18,
        runSpacing: 6,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const OwnerDot(isMine: true),
              const SizedBox(width: 6),
              Text(calendarMe(lang), style: style),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const OwnerDot(isMine: false),
              const SizedBox(width: 6),
              Text(partnerName, style: style),
            ],
          ),
        ],
      ),
    );
  }
}

/// A synced event, read-only: where it comes from, when, its countdown
/// switch, and where it is changed.
class _SyncedEventSheet extends ConsumerStatefulWidget {
  const _SyncedEventSheet({
    required this.lang,
    required this.event,
    required this.mine,
    required this.partnerName,
  });

  final String lang;
  final CalendarEventEntity event;
  final bool mine;
  final String partnerName;

  @override
  ConsumerState<_SyncedEventSheet> createState() => _SyncedEventSheetState();
}

class _SyncedEventSheetState extends ConsumerState<_SyncedEventSheet> {
  late bool _countdown = widget.event.isCountdown;

  Future<void> _setCountdown(bool on) async {
    setState(() => _countdown = on);
    final result = await ref
        .read(calendarRepositoryProvider)
        .setCountdown(widget.event.id, on);
    if (result.failure != null && mounted) setState(() => _countdown = !on);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final lang = widget.lang;
    final e = widget.event;
    final locale = AppLanguages.dateLocale(lang);
    final day = DateFormat.MMMEd(locale).format(e.startTime);
    final hours = e.endTime == null
        ? DateFormat.Hm(locale).format(e.startTime)
        : '${DateFormat.Hm(locale).format(e.startTime)} – '
              '${DateFormat.Hm(locale).format(e.endTime!)}';
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NotebookLabel(
              calendarSyncedFrom(lang, widget.partnerName, mine: widget.mine),
            ),
            const SizedBox(height: 10),
            Text(
              e.title,
              softWrap: true,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '$day · $hours',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const NotebookRule(space: 14),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(calendarEventCountdown(lang)),
              value: _countdown,
              onChanged: _setCountdown,
            ),
            const SizedBox(height: 8),
            Text(
              calendarSyncedReadOnly(
                lang,
                widget.partnerName,
                mine: widget.mine,
              ),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
