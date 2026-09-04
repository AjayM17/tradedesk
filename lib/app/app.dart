import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'tabs/tabs_shell.dart';

class TradeDeskApp extends StatelessWidget {
  const TradeDeskApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Trading Engine',

      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.light,

      home: const TabsShell(),
    );
  }
}