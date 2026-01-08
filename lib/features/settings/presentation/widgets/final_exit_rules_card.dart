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
          ),
          Divider(height: 1),

          // EMA-BASED EXIT (PRIMARY)
          ListTile(
            title: Text(
              'Exit if weekly candle CLOSES below Weekly 20 EMA',
            ),
            subtitle: Text(
              'Weekly close only • Single EMA exit reference',
            ),
            trailing: Icon(Icons.lock),
          ),

          // STRUCTURE-BASED EXIT (SECONDARY)
          ListTile(
            title: Text(
              'Exit on weekly structure breakdown',
            ),
            subtitle: Text(
              'Weekly close below last valid support',
            ),
            trailing: Icon(Icons.lock),
          ),

          // EXECUTION DISCIPLINE
          ListTile(
            title: Text(
              'Exit on next trading session after weekly close',
            ),
            subtitle: Text(
              'No candle wait • Gap up or gap down accepted',
            ),
            trailing: Icon(Icons.lock),
          ),

          // HARD RULE
          ListTile(
            title: Text('No Intraday Exit'),
            trailing: Icon(Icons.block, color: Colors.red),
          ),
        ],
      ),
    );
  }
}
