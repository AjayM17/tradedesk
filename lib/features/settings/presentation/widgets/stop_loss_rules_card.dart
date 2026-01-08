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

          // RISK REDUCTION (NOT TRAILING)
          ListTile(
            title: Text(
              'SL may be tightened to reduce risk (not for trailing)',
            ),
            subtitle: Text('Only after weekly close • No profit booking'),
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
              'EMA-based SL trailing is used only for profit protection',
            ),
            subtitle: Text(
              'Weekly EMA • One-way movement • Never for risk reduction',
            ),
            trailing: Icon(Icons.lock),
          ),

          // 👇 REMINDER NOTE (NOT A RULE)
          Padding(
            padding: EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Text(
              'Reminder: Weekly EMA values such as 20 (slower, trend survival) '
              'and 9 (faster, profit lock) are references only. '
              'Choice affects aggressiveness, not exit rules.',
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
