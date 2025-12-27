import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trade_desk/features/settings/data/settings_state.dart';
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
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          IconButton(
            tooltip: 'Reset to defaults',
            icon: const Icon(Icons.restore),
            onPressed: () => _confirmReset(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: const [
          // 🔒 TAGLINE (SUBTLE, ONCE)
          Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Center(
              child: Text(
                'No Rule. No Trade.',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
            ),
          ),

          TradingStyleCard(),
          SizedBox(height: 8),

          RiskRewardSection(), // 💰 RISK FIRST
          SizedBox(height: 12),

          EntryRulesCard(),
          SizedBox(height: 8),

          StopLossRulesCard(),
          SizedBox(height: 8),

          PartialProfitCard(),
          SizedBox(height: 8),

          // AddOnRulesCard(), // V1: intentionally disabled
          SizedBox(height: 8),

          FinalExitRulesCard(),
        ],
      ),
    );
  }

  // ---------------------------
  // Reset Confirmation
  // ---------------------------
  void _confirmReset(BuildContext context) async {
    final settings = context.read<SettingsState>();
    final messenger = ScaffoldMessenger.of(context);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text(
          'This will reset all risk and rule settings '
          'to their default values.\n\n'
          'Do you want to continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      settings.resetToDefaults();

      messenger.showSnackBar(
        const SnackBar(
          content: Text('Settings reset to defaults'),
        ),
      );
    }
  }
}
