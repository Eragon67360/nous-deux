import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:nous_deux/presentation/providers/profile_provider.dart';
import 'package:nous_deux/presentation/screens/calendar/calendar_screen.dart';

class MainShellScreen extends ConsumerStatefulWidget {
  const MainShellScreen({super.key, required this.child});
  final Widget child;

  @override
  ConsumerState<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends ConsumerState<MainShellScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(myProfileProvider);
    final showNoPartnerBubble =
        profileAsync.valueOrNull != null &&
        (profileAsync.valueOrNull!.hasPartner == false);

    return Scaffold(
      body: Column(
        children: [
          if (showNoPartnerBubble)
            Material(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: InkWell(
                onTap: () => context.push('/pairing'),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.person_add_outlined,
                        size: 20,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Pas encore de partenaire ? Invitez-le ou invitez-la.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Expanded(
            child: IndexedStack(
              index: _index,
              children: const [
                CalendarScreen(),
                _PlaceholderTab(title: 'Règles'),
                _PlaceholderTab(title: 'Position'),
                _PlaceholderTab(title: 'Paramètres'),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.calendar_today),
            label: 'Calendrier',
          ),
          NavigationDestination(icon: Icon(Icons.favorite), label: 'Règles'),
          NavigationDestination(
            icon: Icon(Icons.location_on),
            label: 'Position',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings),
            label: 'Paramètres',
          ),
        ],
      ),
    );
  }
}

class _PlaceholderTab extends StatelessWidget {
  const _PlaceholderTab({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('$title — à venir'));
  }
}
