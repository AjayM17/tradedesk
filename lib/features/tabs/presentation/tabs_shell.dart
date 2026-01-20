import 'package:flutter/material.dart';
import 'package:trade_desk/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:trade_desk/features/settings/presentation/screens/settings_screen.dart';
import 'package:trade_desk/features/trades/presentation/screens/trades_screen.dart';

class TabsShell extends StatefulWidget {
  const TabsShell({super.key});

  @override
  State<TabsShell> createState() => _TabsShellState();
}

class _TabsShellState extends State<TabsShell> {
  int _currentIndex = 0;

  final _pages = const [
    TradesScreen(),       // index 0
    DashboardScreen(),    // index 1
    SettingsScreen(),     // index 2
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.swap_horiz),
            label: 'Trades',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
