import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../features/tabs/presentation/tabs_shell.dart';
import '../features/settings/data/settings_state.dart';

class TradeDeskApp extends StatelessWidget {
  const TradeDeskApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SettingsState(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Trading Engine',

        // ✅ Theme applied correctly
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.system,

        home: const TabsShell(),
      ),
    );
  }
}
