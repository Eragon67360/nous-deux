import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:nousdeux/core/constants/app_radius.dart';
import 'package:nousdeux/core/constants/app_spacing.dart';
import 'package:nousdeux/core/constants/app_strings.dart';
import 'package:nousdeux/core/constants/nous_strings.dart';
import 'package:nousdeux/core/constants/settings_strings.dart';
import 'package:nousdeux/core/utils/app_routes.dart';
import 'package:nousdeux/domain/entities/ping_entity.dart';
import 'package:nousdeux/presentation/providers/auth_provider.dart';
import 'package:nousdeux/presentation/providers/nous_provider.dart';
import 'package:nousdeux/presentation/providers/pairing_provider.dart';
import 'package:nousdeux/presentation/providers/profile_provider.dart';
import 'package:nousdeux/presentation/providers/realtime_provider.dart';
import 'package:nousdeux/presentation/widgets/merging_rings.dart';
import 'package:nousdeux/presentation/widgets/pairing_celebration.dart';
import 'package:nousdeux/presentation/widgets/ping_received.dart';

class MainShellScreen extends ConsumerStatefulWidget {
  const MainShellScreen({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends ConsumerState<MainShellScreen> {
  RealtimeChannel? _profileChannel;
  String? _subscribedUserId;
  bool _celebrating = false;

  /// The partner's note currently shown full screen, if any.
  PingEntity? _incomingPing;

  /// Who the notes stream belongs to and the partner's latest note in its
  /// first snapshot. Null until that snapshot arrives for a paired couple.
  ({String user, DateTime? latest})? _pingBaseline;

  @override
  void initState() {
    super.initState();
    ref.listenManual<AsyncValue<List<PingEntity>>>(
      couplePingsProvider,
      (_, next) => _onPings(next),
      fireImmediately: true,
    );
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
    if (mounted) setState(() => _incomingPing = latest);
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
            if (partnerId != null && partnerId.toString().isNotEmpty) {
              ref.invalidate(myProfileProvider);
              ref.invalidate(myCoupleProvider);
              if (mounted) setState(() => _celebrating = true);
            }
          },
        )
        .subscribe();
  }

  @override
  void dispose() {
    _profileChannel?.unsubscribe();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
    final showNoPartnerBubble =
        profileAsync.valueOrNull != null &&
        (profileAsync.valueOrNull!.hasPartner == false);
    final incoming = _incomingPing;
    final partnerName = ref.watch(partnerProfileProvider).valueOrNull?.username;

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
        if (incoming != null && !_celebrating)
          Positioned.fill(
            child: PingReceived(
              key: ValueKey(incoming.sentAt),
              lang: lang,
              partnerName: (partnerName?.trim().isNotEmpty ?? false)
                  ? partnerName!.trim()
                  : nousPartnerFallback(lang),
              kind: incoming.kind,
              onReply: _reply,
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
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.sm,
                  AppSpacing.xs,
                  AppSpacing.sm,
                  AppSpacing.sm,
                ),
                child: Material(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  child: InkWell(
                    onTap: () => context.push(AppRoutes.pairing),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.sm,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.person_add_outlined,
                            size: 22,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              mainNoPartnerBubble(lang),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            Expanded(child: widget.navigationShell),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        bottom: true,
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
          ),
          child: NavigationBar(
            selectedIndex: widget.navigationShell.currentIndex,
            onDestinationSelected: (i) {
              final current = widget.navigationShell.currentIndex;
              if (i != current) HapticFeedback.selectionClick();
              // Tapping the current tab again returns to its first screen.
              widget.navigationShell.goBranch(i, initialLocation: i == current);
            },
            destinations: [
              NavigationDestination(
                icon: const RingsIcon(),
                label: nousTitle(lang),
              ),
              NavigationDestination(
                icon: const Icon(Icons.calendar_today_outlined),
                selectedIcon: const Icon(Icons.calendar_today),
                label: mainNavCalendar(lang),
              ),
              NavigationDestination(
                icon: const Icon(Icons.favorite_border),
                selectedIcon: const Icon(Icons.favorite),
                label: mainNavPeriod(lang),
              ),
              NavigationDestination(
                icon: const Icon(Icons.location_on_outlined),
                selectedIcon: const Icon(Icons.location_on),
                label: mainNavPosition(lang),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
