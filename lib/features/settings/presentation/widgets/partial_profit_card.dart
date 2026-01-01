import 'package:flutter/material.dart';

class PartialProfitCard extends StatelessWidget {
  const PartialProfitCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: const [
          ListTile(
            title: Text(
              'Partial Profit Rules',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Divider(height: 1),

          // V1: Partial profit is MANDATORY
          ListTile(
            title: Text('Partial Profit at 1R'),
            subtitle: Text('Mandatory'),
            trailing: Icon(Icons.lock),
          ),

          // V1: Fixed reference value (display only)
          ListTile(
            title: Text('1R Profit %'),
            trailing: Text(
              '25%',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),

          // V1: SL movement is optional, not automatic
          ListTile(
            title: Text('SL may be moved to Breakeven after 1R'),
            subtitle: Text('Optional'),
            trailing: Icon(Icons.lock),
          ),
        ],
      ),
    );
  }
}
