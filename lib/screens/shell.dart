import 'package:flutter/material.dart';

import '../app_state.dart';
import 'account_screen.dart';
import 'bookings_screen.dart';
import 'home_screen.dart';

/// Bottom navigation: Home, Bookings, Account.
class Shell extends StatelessWidget {
  const Shell({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    return Scaffold(
      body: IndexedStack(
        index: app.tabIndex,
        children: const [HomeScreen(), BookingsScreen(), AccountScreen()],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: app.tabIndex,
        onDestinationSelected: app.setTab,
        destinations: [
          NavigationDestination(
              icon: const Icon(Icons.home_outlined), selectedIcon: const Icon(Icons.home), label: app.t('home')),
          NavigationDestination(
              icon: const Icon(Icons.event_note_outlined),
              selectedIcon: const Icon(Icons.event_note),
              label: app.t('bookings')),
          NavigationDestination(
              icon: const Icon(Icons.person_outline), selectedIcon: const Icon(Icons.person), label: app.t('account')),
        ],
      ),
    );
  }
}
