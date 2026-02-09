import 'package:flutter/material.dart';

import 'package:nous_deux/presentation/screens/calendar/calendar_screen.dart';

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key, required this.child});
  final Widget child;

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [
          CalendarScreen(),
          _PlaceholderTab(title: 'Règles'),
          _PlaceholderTab(title: 'Position'),
          _PlaceholderTab(title: 'Paramètres'),
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
