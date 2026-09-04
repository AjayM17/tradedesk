import 'package:flutter/material.dart';

class TradingRulesCard extends StatelessWidget {
  const TradingRulesCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: const [
          ListTile(
            title: Text(
              'Trading Rules',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Divider(height: 1),

          ListTile(
            title: Text('Time Frame'),
            trailing: _LockedText(value: 'Weekly'),
          ),

          Divider(height: 1),

          ListTile(
            title: Text('Max Active Trades'),
            trailing: _LockedText(value: '6'),
          ),
        ],
      ),
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
        const Icon(Icons.lock, size: 16),
      ],
    );
  }
}