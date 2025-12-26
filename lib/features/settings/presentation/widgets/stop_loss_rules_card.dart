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
          ListTile(
            title: Text('SL at Weekly Structure Low'),
            trailing: Icon(Icons.lock),
          ),
          ListTile(
            title: Text('Never widen Stop-Loss'),
            trailing: Icon(Icons.block, color: Colors.red),
          ),
          ListTile(
            title: Text('Trail only using Weekly Structure'),
            trailing: Icon(Icons.lock),
          ),
          ListTile(
            title: Text('No Intraday SL changes'),
            trailing: Icon(Icons.lock),
          ),
        ],
      ),
    );
  }
}
