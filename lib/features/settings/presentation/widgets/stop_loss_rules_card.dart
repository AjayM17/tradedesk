import 'package:flutter/material.dart';

class StopLossRulesCard extends StatelessWidget {
  const StopLossRulesCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: const [
          ListTile(
            title: Text(
              'Stop-Loss Rules',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Divider(height: 1),

          // INITIAL SL
          ListTile(
            title: Text('Initial SL at Weekly Structure Low'),
            trailing: Icon(Icons.lock),
          ),

          // HARD RULE
          ListTile(
            title: Text('Never widen Stop-Loss'),
            trailing: Icon(Icons.block, color: Colors.red),
          ),

          // STRUCTURE-BASED RISK REDUCTION
          ListTile(
            title: Text(
              'SL may be tightened only if weekly structure improves',
            ),
            subtitle: Text(
              'Weekly close only • Risk reduction, not profit trailing',
            ),
            trailing: Icon(Icons.lock),
          ),

          // TIME DISCIPLINE
          ListTile(
            title: Text('No Intraday SL changes'),
            trailing: Icon(Icons.lock),
          ),

          // EMA TRAILING (PROFIT ONLY)
          ListTile(
            title: Text(
              'EMA-based trailing is used only after trade is profitable',
            ),
            subtitle: Text(
              'Weekly 20 EMA • One-way movement • Profit protection only',
            ),
            trailing: Icon(Icons.lock),
          ),

          // 👇 FINAL DISCIPLINE NOTE
          Padding(
            padding: EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Text(
              'Note: A single Weekly 20 EMA is used for exit discipline. '
              'Extended distance from EMA is expected in strong trends '
              'and is not a reason to exit early.',
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
}
