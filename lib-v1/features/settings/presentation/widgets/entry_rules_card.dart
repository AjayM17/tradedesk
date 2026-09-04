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

          // STRUCTURE CONTEXT
          ListTile(
            title: Text('Market Context'),
            subtitle: Text(
              'Weekly structure OR base breakout starting a new HH–HL cycle',
            ),
            trailing: Icon(Icons.lock),
          ),

          // EMA FILTER
          ListTile(
            title: Text('EMA Filter'),
            subtitle: Text(
              'Price must be above Weekly 20 EMA',
            ),
            trailing: Icon(Icons.lock),
          ),

          // ENTRY TYPE
          ListTile(
            title: Text('Entry Type'),
            subtitle: Text(
              'Fresh weekly breakout OR pullback within weekly trend',
            ),
            trailing: Icon(Icons.lock),
          ),
        ],
      ),
    );
  }
}
