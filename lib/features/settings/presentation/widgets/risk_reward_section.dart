import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trade_desk/core/utils/number_format.dart';
import '../../data/settings_state.dart';

class RiskRewardSection extends StatelessWidget {
  const RiskRewardSection({super.key});

  static const double minCapital = 10000;
  static const double maxCapital = 100000000; // 10 Cr

  static const double minCapitalPerStock = 5.0;
  static const double maxCapitalPerStock = 25.0;

  @override
  Widget build(BuildContext context) {
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
            title: Text(
              '💰 Risk Management',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'Capital protection rules for long-duration positional trades',
            ),
          ),
          const Divider(height: 1),

          // ---------------- Total Capital ----------------
          ListTile(
            title: const Text('Total Capital'),
            subtitle: const Text('Base capital for all risk calculations'),
            trailing: _editableTrailing(
              indianCurrencyFormat.format(totalCapital),
            ),
            onTap: () => _editCapital(context, totalCapital),
          ),

          const Divider(),

          // ---------------- Risk per Trade ----------------
          ListTile(
            title: const Text('Risk per Trade'),
            subtitle: const Text(
              'Maximum acceptable loss per position (fixed rule)',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$riskPercent% • ${indianCurrencyFormat.format(riskAmount)}',
                ),
                const SizedBox(width: 6),
                const Icon(Icons.lock, size: 16),
              ],
            ),
          ),

          const Divider(),

          // ---------------- Max Portfolio Risk ----------------
          const ListTile(
            title: Text('Max Portfolio Risk'),
            subtitle: Text(
              'Total open risk across all positions at any time',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('6%'),
                SizedBox(width: 6),
                Icon(Icons.lock, size: 16),
              ],
            ),
          ),

          const Divider(),

          // ---------------- Max Capital per Stock ----------------
          ListTile(
            title: const Text('Max Capital per Stock'),
            subtitle: const Text(
              'Position concentration limit per stock',
            ),
            trailing: _editableTrailing(
              indianCurrencyFormat.format(maxCapitalAmount),
            ),
            onTap: () => _editMaxCapital(context, maxCapitalPercent),
          ),

          // ---------------- Philosophy Note ----------------
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Text(
              'Note: Risk limits are designed to survive drawdowns and '
              'allow long-term trend holding without emotional pressure.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _editableTrailing(String valueText) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(valueText),
        const SizedBox(width: 6),
        const Icon(
          Icons.edit,
          size: 16,
          color: Colors.grey,
        ),
      ],
    );
  }

  void _editCapital(BuildContext context, double current) {
    final controller =
        TextEditingController(text: current.toStringAsFixed(0));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Edit Total Capital',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                autofocus: true,
                decoration: const InputDecoration(
                  prefixText: '₹ ',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: () {
                  final value = double.tryParse(
                    controller.text.replaceAll(',', ''),
                  );

                  if (value == null) return;

                  if (value < minCapital || value > maxCapital) {
                    ScaffoldMessenger.of(sheetContext).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Capital must be between ₹10,000 and ₹10 Cr',
                        ),
                      ),
                    );
                    return;
                  }

                  final settings = sheetContext.read<SettingsState>();
                  Navigator.pop(sheetContext);
                  settings.updateTotalCapital(value);
                },
                child: const Text('Save'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _editMaxCapital(BuildContext context, double current) {
    const options = [
      minCapitalPerStock,
      10.0,
      15.0,
      20.0,
      maxCapitalPerStock,
    ];

    showModalBottomSheet(
      context: context,
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Max Capital per Stock',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              ...options.map(
                (v) => ListTile(
                  title: Text('$v%'),
                  trailing: current == v
                      ? const Icon(Icons.check, color: Colors.green)
                      : null,
                  onTap: () {
                    final settings = sheetContext.read<SettingsState>();
                    Navigator.pop(sheetContext);
                    settings.updateMaxCapitalPerStockPercent(v);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
