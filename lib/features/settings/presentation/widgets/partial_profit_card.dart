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
              'Profit Booking & Exit Rules',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'Scale out profits while letting winners run',
            ),
          ),

          Divider(height: 1),

          ListTile(
            leading: Icon(Icons.looks_one),
            title: Text('Target 1 (+2R)'),
            subtitle: Text(
              'Book 50% of total position',
            ),
          ),

          ListTile(
            leading: Icon(Icons.looks_two),
            title: Text('Target 2 (+3R)'),
            subtitle: Text(
              'Book 50% of remaining position',
            ),
          ),

          ListTile(
            leading: Icon(Icons.trending_up),
            title: Text('Final Exit'),
            subtitle: Text(
              'Trail remaining quantity using Daily 20 EMA',
            ),
          ),

          ListTile(
            leading: Icon(Icons.rule),
            title: Text('Execution Order'),
            subtitle: Text(
              '2R → 3R → Daily 20 EMA Trail',
            ),
          ),
        ],
      ),
    );
  }
}