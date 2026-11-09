
import 'package:flutter/material.dart';
import 'package:trade_desk/app/dashboard/dashboard_page.dart';

import '../../settings/settings_page.dart';
import '../../trades/trades_page.dart';
import '../../watchlist/watchlist_page.dart';

class TabsShell extends StatefulWidget {
  const TabsShell({super.key});

  @override
  State<TabsShell> createState() => _TabsShellState();
}

class _TabsShellState extends State<TabsShell> {
  int _currentIndex = 0;

late final GlobalKey<TradesPageState> _tradesPageKey;

late final List<Widget> _pages;

@override
void initState() {
  super.initState();

  _tradesPageKey = GlobalKey<TradesPageState>();

  _pages = [
    const DashboardPage(),
    TradesPage(key: _tradesPageKey),
    const WatchlistPage(),
    const SettingsPage(),
  ];
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
    onDestinationSelected: (index) {
  setState(() {
    _currentIndex = index;
  });

  if (index == 1) {
    _tradesPageKey.currentState?.refreshTrades();
  }
},
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.swap_horiz_outlined),
            selectedIcon: Icon(Icons.swap_horiz),
            label: 'Trades',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_outline),
            selectedIcon: Icon(Icons.bookmark),
            label: 'Watchlist',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
