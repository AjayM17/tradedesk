import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/settings_state.dart';

class ProfitBookingCard extends StatelessWidget {
  const ProfitBookingCard({super.key});

  @override
  Widget build(BuildContext context) {
    final targetR =
        context.select<SettingsState, double>((s) => s.targetR);

    return Card(
      child: Column(
        children: [
          const ListTile(
            title: Text(
              '🎯 Profit Booking',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(height: 1),

          ListTile(
            title: const Text('Target R'),
            trailing: _editable('${targetR.toStringAsFixed(1)}R'),
            onTap: () => _editTargetR(context, targetR),
          ),

          const Divider(height: 1),

          const ListTile(
            title: Text('Exit Strategy'),
            trailing: _LockedText(value: 'Daily 20 EMA'),
          ),
        ],
      ),
    );
  }

  static Widget _editable(String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value),
        const SizedBox(width: 6),
        const Icon(
          Icons.edit,
          size: 16,
          color: Colors.grey,
        ),
      ],
    );
  }

  void _editTargetR(BuildContext context, double current) {
    final controller = TextEditingController(
      text: current.toStringAsFixed(
        current.truncateToDouble() == current ? 0 : 1,
      ),
    );

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
                'Edit Target R',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  suffixText: 'R',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 12),

              ElevatedButton(
                onPressed: () {
                  final value = double.tryParse(controller.text);

                  if (value == null ||
                      value < 1 ||
                      value > 20) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Enter a value between 1R and 20R',
                        ),
                      ),
                    );
                    return;
                  }

                  ctx.read<SettingsState>()
                      .updateTargetR(value);

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
}

class _LockedText extends StatelessWidget {
  final String value;

  const _LockedText({
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value),
        const SizedBox(width: 6),
        const Icon(
          Icons.lock,
          size: 16,
        ),
      ],
    );
  }
}