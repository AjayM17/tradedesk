import 'package:flutter/material.dart';

import '../widgets/trading_style_card.dart';
import '../widgets/entry_rules_card.dart';
import '../widgets/stop_loss_rules_card.dart';
import '../widgets/partial_profit_card.dart';
import '../widgets/add_on_rules_card.dart';
import '../widgets/final_exit_rules_card.dart';
import '../widgets/risk_reward_section.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: const [
          TradingStyleCard(),
          RiskRewardSection(), // 💰 RISK FIRST
          EntryRulesCard(),
          StopLossRulesCard(),
          PartialProfitCard(),
          AddOnRulesCard(),
          FinalExitRulesCard(),
        ],
      ),
    );
  }
}
