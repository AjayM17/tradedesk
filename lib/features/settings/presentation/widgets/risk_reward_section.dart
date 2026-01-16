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
        children: [
          const ListTile(
            title: Text(
              '💰 Risk Management',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('Capital & loss protection rules'),
          ),
          const Divider(height: 1),

          // Total Capital (Editable)
          ListTile(
            title: const Text('Total Capital'),
            subtitle: const Text('Base for all calculations'),
            trailing: _editable(indianCurrencyFormat.format(totalCapital)),
            onTap: () => _editCapital(context, totalCapital),
          ),

          const Divider(),

          // Risk per Trade (Locked)
          ListTile(
            title: const Text('Risk per Trade'),
            subtitle: const Text('Fixed maximum loss'),
            trailing: _locked(
              '$riskPercent% • ${indianCurrencyFormat.format(riskAmount)}',
            ),
          ),

          const Divider(),

          // Max Portfolio Risk (Locked)
          const ListTile(
            title: Text('Max Portfolio Risk'),
            subtitle: Text('Total open risk limit'),
            trailing: _LockedText(value: '6%'),
          ),

          const Divider(),

          // Max Capital per Stock (Editable)
          ListTile(
            title: const Text('Max Capital per Stock'),
            subtitle: const Text('Position size cap'),
            trailing: _editable(indianCurrencyFormat.format(maxCapitalAmount)),
            onTap: () => _editMaxCapital(context, maxCapitalPercent),
          ),
        ],
      ),
    );
  }

  // ---------- UI Helpers ----------

  static Widget _editable(String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value),
        const SizedBox(width: 6),
        const Icon(Icons.edit, size: 16, color: Colors.grey),
      ],
    );
  }

  static Widget _locked(String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value),
        const SizedBox(width: 6),
        const Icon(Icons.lock, size: 16),
      ],
    );
  }

  // ---------- Editors ----------

  void _editCapital(BuildContext context, double current) {
    final controller =
        TextEditingController(text: current.toStringAsFixed(0));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Edit Total Capital',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  prefixText: '₹ ',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  final value =
                      double.tryParse(controller.text.replaceAll(',', ''));

                  if (value == null ||
                      value < minCapital ||
                      value > maxCapital) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(
                        content:
                            Text('Capital must be ₹10,000 – ₹10 Cr'),
                      ),
                    );
                    return;
                  }

                  ctx.read<SettingsState>().updateTotalCapital(value);
                  Navigator.pop(ctx);
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
    const options = [5.0, 10.0, 15.0, 20.0, 25.0];

    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Max Capital per Stock',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...options.map(
                (v) => ListTile(
                  title: Text('$v%'),
                  trailing:
                      current == v ? const Icon(Icons.check) : null,
                  onTap: () {
                    ctx
                        .read<SettingsState>()
                        .updateMaxCapitalPerStockPercent(v);
                    Navigator.pop(ctx);
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

// Small helper widget
class _LockedText extends StatelessWidget {
  final String value;
  const _LockedText({required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value),
        const SizedBox(width: 6),
        const Icon(Icons.lock, size: 16),
      ],
    );
  }
}
