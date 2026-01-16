import 'package:flutter/material.dart';

class FinalExitRulesCard extends StatelessWidget {
  const FinalExitRulesCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: const [
          ListTile(
            title: Text(
              'Final Exit Rules',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'Weekly-only exits based on structure or EMA',
            ),
          ),
          Divider(height: 1),

          // STRUCTURE EXIT (PRIORITY)
          ListTile(
            title: Text(
              'Exit on Weekly Higher Low (HL) break',
            ),
            subtitle: Text(
              'Weekly close below confirmed HL (wick-based)',
            ),
            trailing: Icon(Icons.lock),
          ),

          // EMA EXIT (FALLBACK)
          ListTile(
            title: Text(
              'Exit on Weekly 20 EMA break',
            ),
            subtitle: Text(
              'Used only when EMA is the active stop-loss',
            ),
            trailing: Icon(Icons.lock),
          ),

          // EXECUTION DISCIPLINE
          ListTile(
            title: Text(
              'Exit Execution',
            ),
            subtitle: Text(
              'Execute on next trading session after weekly close',
            ),
            trailing: Icon(Icons.lock),
          ),

          // HARD RULE
          ListTile(
            title: Text('No Intraday or Daily Exit'),
            trailing: Icon(Icons.block, color: Colors.red),
          ),
        ],
      ),
    );
  }
}
