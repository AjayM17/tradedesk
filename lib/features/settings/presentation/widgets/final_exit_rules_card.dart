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
          ListTile(
            title: Text('Exit on Weekly Close Only'),
            trailing: Icon(Icons.lock),
          ),
          ListTile(
            title: Text('Weekly Structure Break'),
            trailing: Icon(Icons.lock),
          ),
          ListTile(
            title: Text('9 EMA closes below 20 EMA'),
            trailing: Icon(Icons.lock),
          ),
          ListTile(
            title: Text('No Intraday Exit'),
            trailing: Icon(Icons.block, color: Colors.red),
          ),
        ],
      ),
    );
  }
}
