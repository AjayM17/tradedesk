import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../features/trades/presentation/screens/trades_screen.dart';

class TradeDeskApp extends StatelessWidget {
  const TradeDeskApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TradeDesk',
      theme: AppTheme.lightTheme,
      home: const TradesScreen(),
    );
  }
}
