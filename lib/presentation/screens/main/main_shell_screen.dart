import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:nousdeux/core/constants/app_radius.dart';
import 'package:nousdeux/core/constants/app_spacing.dart';
import 'package:nousdeux/core/constants/app_strings.dart';
import 'package:nousdeux/core/constants/settings_strings.dart';
import 'package:nousdeux/presentation/providers/auth_provider.dart';
import 'package:nousdeux/presentation/providers/pairing_provider.dart';
import 'package:nousdeux/presentation/providers/profile_provider.dart';
import 'package:nousdeux/presentation/providers/realtime_provider.dart';
import 'package:nousdeux/presentation/widgets/pairing_celebration.dart';

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
                    onTap: () => context.push('/pairing'),
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
              if (i != widget.navigationShell.currentIndex) {
                HapticFeedback.selectionClick();
              }
              const paths = [
                '/main',
                '/main/period',
                '/main/position',
                '/main/settings',
              ];
              context.go(paths[i]);
              widget.navigationShell.goBranch(i);
            },
            destinations: [
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
              NavigationDestination(
                icon: const Icon(Icons.settings_outlined),
                selectedIcon: const Icon(Icons.settings),
                label: mainNavSettings(lang),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
