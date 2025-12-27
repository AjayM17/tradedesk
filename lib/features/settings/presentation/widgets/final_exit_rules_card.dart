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

          // V1: Exit level definition (fixed)
          ListTile(
            title: Text(
              'Exit Level = min(Previous Week Low, Weekly 20 EMA)',
            ),
            trailing: Icon(Icons.lock),
          ),

          // V1: Exit condition (weekly close only)
          ListTile(
            title: Text(
              'Exit ONLY if weekly candle CLOSES below Exit Level',
            ),
            trailing: Icon(Icons.lock),
          ),

          // V1: Hard restriction
          ListTile(
            title: Text('No Intraday Exit'),
            trailing: Icon(Icons.block, color: Colors.red),
          ),
        ],
      ),
    );
  }
}
