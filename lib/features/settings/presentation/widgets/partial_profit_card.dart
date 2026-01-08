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
            subtitle: Text(
              'Mandatory profit booking rule',
            ),
          ),
          Divider(height: 1),

          // MANDATORY 1R BOOKING
          ListTile(
            title: Text('Profit Booking at 1R'),
            subtitle: Text(
              'Mandatory for every trade',
            ),
            trailing: Icon(Icons.lock),
          ),

          // FIXED QUANTITY
          ListTile(
            title: Text('Quantity Booked at 1R'),
            trailing: Text(
              '25%',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),

          // SL HANDLING AFTER 1R
          ListTile(
            title: Text(
              'SL may be moved to Breakeven after 1R booking',
            ),
            subtitle: Text(
              'Optional • Weekly close only • Risk reduction, not profit trailing',
            ),
            trailing: Icon(Icons.lock),
          ),

          // CLARITY FOR REMAINING POSITION
          ListTile(
            title: Text(
              'Remaining position is managed only by Weekly 20 EMA or structure exits',
            ),
            trailing: Icon(Icons.lock),
          ),
        ],
      ),
    );
  }
}
