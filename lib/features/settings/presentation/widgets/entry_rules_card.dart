import 'package:flutter/material.dart';

class EntryRulesCard extends StatelessWidget {
  const EntryRulesCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: const [
          ListTile(
            title: Text(
              'Entry Rules',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('ALL conditions must be satisfied'),
          ),
          Divider(height: 1),

          ListTile(
            title: Text('Market Structure'),
            subtitle: Text('Weekly Higher-High & Higher-Low'),
            trailing: Icon(Icons.lock),
          ),

          ListTile(
            title: Text('Trend Filter'),
            subtitle: Text('Price above Weekly 20 EMA'),
            trailing: Icon(Icons.lock),
          ),

          ListTile(
            title: Text('Entry Trigger'),
            subtitle: Text(
              '• Pullback in uptrend\n'
              '• OR fresh weekly breakout',
            ),
            trailing: Icon(Icons.lock),
          ),
        ],
      ),
    );
  }
}
