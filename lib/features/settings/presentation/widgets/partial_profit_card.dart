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
              'Single partial for risk & psychological stability',
            ),
          ),
          Divider(height: 1),

          // MANDATORY R1
          ListTile(
            title: Text('Profit Booking'),
            subtitle: Text(
              'Mandatory partial at +1R',
            ),
            trailing: Icon(Icons.lock),
          ),

          // FIXED QUANTITY
          ListTile(
            title: Text('Quantity Booked'),
            subtitle: Text(
              'Fixed 25% of position',
            ),
            trailing: Icon(Icons.lock),
          ),

          // PURPOSE OF R1
          ListTile(
            title: Text('Purpose of R1'),
            subtitle: Text(
              'Reduces risk and improves psychological stability',
            ),
            trailing: Icon(Icons.lock),
          ),

          // POST R1 MANAGEMENT
          ListTile(
            title: Text('Post-R1 Management'),
            subtitle: Text(
              'Remaining position managed only by structure or Weekly 20 EMA',
            ),
            trailing: Icon(Icons.lock),
          ),
        ],
      ),
    );
  }
}
