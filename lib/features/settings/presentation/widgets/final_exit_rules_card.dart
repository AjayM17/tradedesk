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

          // EXIT DECISION
          ListTile(
            title: Text(
              'Exit if Weekly RSI closes below 60',
            ),
            subtitle: Text(
              'RSI is evaluated only after weekly close',
            ),
            trailing: Icon(Icons.lock),
          ),

          // EXECUTION
          ListTile(
            title: Text(
              'Exit on next trading session',
            ),
            subtitle: Text(
              'No candle wait • Gap up or gap down ignored',
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
