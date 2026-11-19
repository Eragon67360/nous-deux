import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:nousdeux/core/constants/app_spacing.dart';
import 'package:nousdeux/core/constants/app_strings.dart';
import 'package:nousdeux/core/constants/nous_strings.dart';
import 'package:nousdeux/core/constants/settings_strings.dart';
import 'package:nousdeux/core/services/fcm_service.dart';
import 'package:nousdeux/core/services/local_notifications.dart';
import 'package:nousdeux/core/services/pill_reminders.dart';
import 'package:nousdeux/core/utils/app_routes.dart';
import 'package:nousdeux/domain/entities/ping_entity.dart';
import 'package:nousdeux/presentation/providers/announcements_provider.dart';
import 'package:nousdeux/presentation/providers/auth_provider.dart';
import 'package:nousdeux/presentation/providers/calendar_provider.dart';
import 'package:nousdeux/presentation/providers/calendar_sync_provider.dart';
import 'package:nousdeux/presentation/providers/cycle_provider.dart';
import 'package:nousdeux/presentation/providers/nous_provider.dart';
import 'package:nousdeux/presentation/providers/pairing_provider.dart';
import 'package:nousdeux/presentation/providers/pill_provider.dart';
import 'package:nousdeux/presentation/providers/profile_provider.dart';
import 'package:nousdeux/presentation/providers/realtime_provider.dart';
import 'package:nousdeux/presentation/widgets/note_composer.dart';
import 'package:nousdeux/presentation/widgets/pairing_celebration.dart';
import 'package:nousdeux/presentation/widgets/ping_received.dart';
import 'package:nousdeux/presentation/widgets/text_tab_bar.dart';

class MainShellScreen extends ConsumerStatefulWidget {
  const MainShellScreen({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends ConsumerState<MainShellScreen>
    with WidgetsBindingObserver {
  /// The calendar's tab in [AppRoutes.tabs].
  static const _calendarTab = 1;
  static const _periodTab = 2;

  /// Taps on local notifications (the pill reminder and its buttons).
  StreamSubscription<NotificationTap>? _notificationTaps;

  RealtimeChannel? _profileChannel;
  String? _subscribedUserId;
  bool _celebrating = false;

  /// The partner's note currently shown full screen, if any.
  OpenedNote? _incomingPing;

  /// Who the notes stream belongs to and the partner's latest note in its
  /// first snapshot. Null until that snapshot arrives for a paired couple.
  ({String user, DateTime? latest})? _pingBaseline;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // The phone calendars this phone follows, brought up to date at start.
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncCalendars());
    ref.listenManual<AsyncValue<List<PingEntity>>>(
      couplePingsProvider,
      (_, next) => _onPings(next),
      fireImmediately: true,
    );
    // Not fired immediately: a note opened before this shell was built (a
    // shell rebuilt after signing in again) was already shown.
    _notificationTaps = ref
        .read(localNotificationsProvider)
        .taps
        .listen(_onNotificationTap);
    ref.listenManual<AsyncValue<OpenedPush>>(openedPushesProvider, (_, next) {
      switch (next.valueOrNull) {
        case OpenedNotePush(:final note):
          _onOpenedNote(note);
        case OpenedAnnouncementPush():
          _onOpenedAnnouncement();
        case null:
          break;
      }
    });
  }

  /// A pill reminder: « Prise » ticks its day, « Dans 30 min » brings it
  /// back half an hour later, and a tap opens Règles.
  Future<void> _onNotificationTap(NotificationTap tap) async {
    final day = pillDayFromPayload(tap.payload);
    if (day == null || !mounted) return;
    final now = ref.read(clockProvider)();
    switch (tap.actionId) {
      case pillSnoozeAction:
        await snoozePillReminder(
          ref.read(localNotificationsProvider),
          tap.payload,
          now: now,
        );
        return;
      case pillTakenAction:
        await ref.read(markPillTakenProvider)(day, now);
    }
    if (mounted) widget.navigationShell.goBranch(_periodTab);
  }

  /// A tapped message from the team opens Paramètres › Nouveautés, which
  /// reads the list again.
  void _onOpenedAnnouncement() {
    if (!mounted) return;
    ref.invalidate(announcementsProvider);
    context.push(AppRoutes.settingsNews);
  }

  /// A tapped notification opens the Nous tab with its note full screen,
  /// replies included, even though the app may already know the note.
  void _onOpenedNote(OpenedNote note) {
    if (!mounted) return;
    widget.navigationShell.goBranch(0, initialLocation: true);
    final baseline = _pingBaseline;
    final seen = baseline?.latest;
    if (baseline != null && (seen == null || note.sentAt.isAfter(seen))) {
      // So the notes stream doesn't show it a second time.
      _pingBaseline = (user: baseline.user, latest: note.sentAt);
    }
    setState(() => _incomingPing = note);
  }

  /// Only a partner note newer than what the stream first showed gets the
  /// full-screen moment: notes already there at launch were already pushed,
  /// and a stream restart (couple or account change) sets a new baseline.
  void _onPings(AsyncValue<List<PingEntity>> pings) {
    if (pings.isLoading || !pings.hasValue) return;
    final me = ref.read(currentUserProvider).valueOrNull?.id;
    final paired = ref.read(myCoupleProvider).valueOrNull?.isPaired ?? false;
    if (me == null || !paired) {
      _pingBaseline = null;
      return;
    }
    final latest = latestPing(pings.requireValue, (sender) => sender != me);
    final baseline = _pingBaseline;
    if (baseline == null || baseline.user != me) {
      _pingBaseline = (user: me, latest: latest?.sentAt);
      return;
    }
    if (latest == null) return;
    final seen = baseline.latest;
    if (seen != null && !latest.sentAt.isAfter(seen)) return;
    _pingBaseline = (user: me, latest: latest.sentAt);
    if (mounted) {
      setState(
        () => _incomingPing = (kind: latest.kind, sentAt: latest.sentAt),
      );
    }
  }

  Future<void> _reply(PingKind kind) async {
    final messenger = ScaffoldMessenger.of(context);
    final lang = ref.read(myProfileProvider).valueOrNull?.language ?? 'fr';
    final result = await ref.read(pingRepositoryProvider).send(kind);
    if (!mounted) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(pingResultMessage(lang, kind, result.failure))),
      );
  }

  void _subscribeToPartnerJoined(String userId) {
    if (userId == _subscribedUserId) return;
    _profileChannel?.unsubscribe();
    _subscribedUserId = userId;
    _profileChannel = ref
        .read(realtimeChannelFactoryProvider)('profile-partner-$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'profiles',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: userId,
          ),
          callback: (payload) {
            final newRecord = payload.newRecord;
            final partnerId = newRecord['partner_id'];
            // Realtime sends the whole row on any update (a calendar sync
            // writes it too): only the change from unpaired is a joining.
            final wasPaired =
                ref.read(myProfileProvider).valueOrNull?.hasPartner ?? false;
            if (!wasPaired &&
                partnerId != null &&
                partnerId.toString().isNotEmpty) {
              ref.invalidate(myProfileProvider);
              ref.invalidate(myCoupleProvider);
              if (mounted) setState(() => _celebrating = true);
            }
          },
        )
        .subscribe();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    _syncCalendars();
    // A message from the team may have come while the app was away.
    ref.invalidate(announcementsProvider);
    // Days ticked elsewhere, and reminders planned from today.
    ref.invalidate(pillWeekProvider);
    ref.invalidate(partnerPillTodayProvider);
    if (widget.navigationShell.currentIndex == _calendarTab) {
      _wakePartnerCalendar();
    }
  }

  /// Syncs the phone calendars this phone follows (docs/CALENDAR_SYNC.md).
  /// Best effort: the next resume tries again.
  void _syncCalendars() {
    unawaited(ref.read(calendarSyncServiceProvider).run());
  }

  /// Opening the calendar asks the server to wake the partner's phone, so
  /// their latest events arrive while it is open.
  void _wakePartnerCalendar() {
    unawaited(
      ref.read(calendarRepositoryProvider).requestPartnerCalendarSync(),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _profileChannel?.unsubscribe();
    _notificationTaps?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Règles: keep the partner's sharing switches and the reminder current
    // wherever the app is open.
    ref.watch(partnerCycleSettingsLiveProvider);
    ref.watch(partnerReminderSyncProvider);
    ref.watch(pillReminderSyncProvider);
    final userId = ref.watch(currentUserProvider).valueOrNull?.id;
    if (userId != null) {
      _subscribeToPartnerJoined(userId);
    } else {
      _profileChannel?.unsubscribe();
      _profileChannel = null;
      _subscribedUserId = null;
    }

    final profileAsync = ref.watch(myProfileProvider);
    final lang = profileAsync.valueOrNull?.language ?? 'fr';
    // Nous (tab 0) and Position (tab 3) have their own invite; the banner
    // would repeat it.
    final tab = widget.navigationShell.currentIndex;
    final showNoPartnerBubble =
        profileAsync.valueOrNull != null &&
        (profileAsync.valueOrNull!.hasPartner == false) &&
        tab != 0 &&
        tab != 3;
    final incoming = _incomingPing;
    final partnerName = ref.watch(partnerProfileProvider).valueOrNull?.username;
    final name = (partnerName?.trim().isNotEmpty ?? false)
        ? partnerName!.trim()
        : nousPartnerFallback(lang);
    // A note of one's own carries its words in the notes stream only (the
    // push leaves them out), so it waits for them before showing.
    final String? incomingText;
    if (incoming?.kind == PingKind.custom) {
      final last = ref.watch(partnerLastPingProvider);
      incomingText =
          last != null &&
              last.kind == PingKind.custom &&
              !last.sentAt.isBefore(incoming!.sentAt)
          ? last.text
          : null;
    } else {
      incomingText = null;
    }
    final showIncoming =
        incoming != null &&
        !_celebrating &&
        (incoming.kind != PingKind.custom || incomingText != null);

    return Stack(
      children: [
        _buildScaffold(context, lang, showNoPartnerBubble),
        if (_celebrating)
          Positioned.fill(
            child: PairingCelebration(
              lang: lang,
              onDismissed: () => setState(() => _celebrating = false),
            ),
          ),
        if (showIncoming)
          Positioned.fill(
            child: PingReceived(
              key: ValueKey(incoming.sentAt),
              lang: lang,
              partnerName: name,
              kind: incoming.kind,
              text: incomingText,
              onReply: _reply,
              onWrite: () =>
                  showNoteComposer(context, lang: lang, partnerName: name),
              onDismissed: () => setState(() => _incomingPing = null),
            ),
          ),
      ],
    );
  }

  Widget _buildScaffold(
    BuildContext context,
    String lang,
    bool showNoPartnerBubble,
  ) {
    return Scaffold(
      body: SafeArea(
        top: true,
        bottom: false,
        child: Column(
          children: [
            if (showNoPartnerBubble)
              // A quiet line, not a card: gold icon, the sentence, a thin
              // rule under it.
              InkWell(
                onTap: () => context.push(AppRoutes.pairing),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(28, 12, 20, 12),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.person_add_outlined,
                        size: 20,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          mainNoPartnerBubble(lang),
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        size: 20,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ),
            Expanded(child: widget.navigationShell),
          ],
        ),
      ),
      bottomNavigationBar: ColoredBox(
        color: Theme.of(context).colorScheme.surface,
        child: SafeArea(
          top: false,
          child: TextTabBar(
            selectedIndex: widget.navigationShell.currentIndex,
            onSelected: (i) {
              final current = widget.navigationShell.currentIndex;
              if (i != current) HapticFeedback.selectionClick();
              if (i == _calendarTab && i != current) _wakePartnerCalendar();
              // Tapping the current tab again returns to its first screen.
              widget.navigationShell.goBranch(i, initialLocation: i == current);
            },
            labels: [
              nousTitle(lang),
              mainNavCalendar(lang),
              mainNavPeriod(lang),
              mainNavPosition(lang),
            ],
          ),
        ),
      ),
    );
  }
}
