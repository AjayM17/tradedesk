import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/settings_state.dart';
import '../widgets/profit_booking_card.dart';
import '../widgets/risk_reward_section.dart';
import '../widgets/trading_rules_card.dart';

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
        children: [
          const Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: 12),
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

          const TradingRulesCard(),
          const SizedBox(height: 12),

          const RiskRewardSection(),
          const SizedBox(height: 12),

          const ProfitBookingCard(),
        ],
      ),
    );
  }

  Future<void> _confirmReset(BuildContext context) async {
    final settings = context.read<SettingsState>();
    final messenger = ScaffoldMessenger.of(context);

    final confirmed =
        await showDialog<bool>(
              context: context,
              builder: (dialogContext) => AlertDialog(
                title: const Text('Reset Settings'),
                content: const Text(
                  'Reset all settings to their default values?',
                ),
                actions: [
                  TextButton(
                    onPressed: () =>
                        Navigator.of(dialogContext).pop(false),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () =>
                        Navigator.of(dialogContext).pop(true),
                    child: const Text('Reset'),
                  ),
                ],
              ),
            ) ??
            false;

    if (!confirmed) return;

    settings.resetToDefaults();

    messenger.showSnackBar(
      const SnackBar(
        content: Text('Settings reset successfully'),
      ),
    );
  }
}