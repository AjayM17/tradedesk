import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/settings_state.dart';

class RiskRewardSection extends StatelessWidget {
  const RiskRewardSection({super.key});

  @override
  Widget build(BuildContext context) {
    // Fine-grained rebuilds only
    final totalCapital =
        context.select<SettingsState, double>((s) => s.totalCapital);
    final riskPercent =
        context.select<SettingsState, double>((s) => s.riskPerTradePercent);
    final riskAmount =
        context.select<SettingsState, double>((s) => s.riskAmountPerTrade);
    final maxCapitalPercent =
        context.select<SettingsState, double>((s) => s.maxCapitalPerStockPercent);
    final maxCapitalAmount =
        context.select<SettingsState, double>((s) => s.maxCapitalPerStockAmount);

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ListTile(
            title: Text('💰 Risk / Reward',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          const Divider(height: 1),

          // Total Capital
          ListTile(
            title: const Text('Total Capital'),
            subtitle: const Text('Used for all risk calculations'),
            trailing: Text('₹${totalCapital.toStringAsFixed(0)}'),
            onTap: () => _editCapital(context, totalCapital),
          ),

          const Divider(),

          // Risk per Trade
          ListTile(
            title: const Text('Risk per Trade'),
            subtitle: const Text('Max loss per trade'),
            trailing:
                Text('$riskPercent% (₹${riskAmount.toStringAsFixed(0)})'),
            onTap: () => _editRiskPercent(context, riskPercent),
          ),

          const Divider(),

          // Max Capital per Stock
          ListTile(
            title: const Text('Max Capital per Stock'),
            subtitle: const Text('Position concentration limit'),
            trailing: Text(
              '$maxCapitalPercent% (₹${maxCapitalAmount.toStringAsFixed(0)})',
            ),
            onTap: () => _editMaxCapital(context, maxCapitalPercent),
          ),
        ],
      ),
    );
  }

  // -------- Total Capital --------
  void _editCapital(BuildContext context, double current) {
    final controller =
        TextEditingController(text: current.toStringAsFixed(0));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Edit Total Capital',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  prefixText: '₹ ',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  final value =
                      double.tryParse(controller.text.replaceAll(',', ''));
                  if (value != null) {
                    final settings = context.read<SettingsState>(); // capture
                    Navigator.pop(context); // close first
                    settings.updateTotalCapital(value); // safe
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
        );
      },
    );
  }

  // -------- Risk % --------
  void _editRiskPercent(BuildContext context, double current) {
    const options = [0.5, 1.0, 1.5, 2.0];

    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('Select Risk per Trade',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            ...options.map((v) => ListTile(
                  title: Text('$v%'),
                  trailing:
                      current == v ? const Icon(Icons.check, color: Colors.green) : null,
                  onTap: () {
                    final settings = context.read<SettingsState>(); // capture
                    Navigator.pop(context);
                    settings.updateRiskPerTradePercent(v);
                  },
                )),
          ]),
        );
      },
    );
  }

  // -------- Max Capital per Stock % --------
  void _editMaxCapital(BuildContext context, double current) {
    const options = [5.0, 10.0, 15.0, 20.0, 25.0];

    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('Max Capital per Stock',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            ...options.map((v) => ListTile(
                  title: Text('$v%'),
                  trailing:
                      current == v ? const Icon(Icons.check, color: Colors.green) : null,
                  onTap: () {
                    final settings = context.read<SettingsState>(); // capture
                    Navigator.pop(context);
                    settings.updateMaxCapitalPerStockPercent(v);
                  },
                )),
          ]),
        );
      },
    );
  }
}
