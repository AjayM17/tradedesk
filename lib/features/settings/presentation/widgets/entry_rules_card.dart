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
            subtitle: Text(
              'ALL conditions must be satisfied',
            ),
          ),
          Divider(height: 1),

          // STRUCTURE FIRST
          ListTile(
            title: Text('Market Structure'),
            subtitle: Text(
              'Weekly higher-high & higher-low OR valid support / demand zone',
            ),
            trailing: Icon(Icons.lock),
          ),

          // EMA AS FILTER (WEEKLY CLOSE)
          ListTile(
            title: Text('Trend Alignment'),
            subtitle: Text(
              'Weekly close above Weekly 20 EMA',
            ),
            trailing: Icon(Icons.lock),
          ),

          // ENTRY LOCATION
          ListTile(
            title: Text('Entry Type'),
            subtitle: Text(
              'Pullback into structure OR fresh weekly breakout',
            ),
            trailing: Icon(Icons.lock),
          ),
        ],
      ),
    );
  }
}
