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

          // PARTIAL PROFIT
          ListTile(
            title: Text('Partial Profit at 1R'),
            subtitle: Text('Mandatory'),
            trailing: Icon(Icons.lock),
          ),

          // FIXED R VALUE
          ListTile(
            title: Text('1R Profit Booking'),
            trailing: Text(
              '25%',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),

          // SL HANDLING (OPTIONAL, RISK ONLY)
          ListTile(
            title: Text(
              'SL may be moved to Breakeven after 1R',
            ),
            subtitle: Text(
              'Optional • Risk reduction only • Not for profit trailing',
            ),
            trailing: Icon(Icons.lock),
          ),
        ],
      ),
    );
  }
}
