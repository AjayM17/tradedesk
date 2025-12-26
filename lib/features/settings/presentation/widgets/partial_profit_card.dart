import 'package:flutter/material.dart';

class PartialProfitCard extends StatelessWidget {
  const PartialProfitCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          const ListTile(
            title: Text(
              'Partial Profit Rules',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(height: 1),
          const ListTile(
            title: Text('Mandatory Partial at 1R'),
            subtitle: Text('Required before add-on'),
            trailing: Icon(Icons.check_circle, color: Colors.green),
          ),
          ListTile(
            title: const Text('1R Profit %'),
            subtitle: const Text('Allowed: 25–30%'),
            trailing: const Text('25%'),
            onTap: () {},
          ),
          const ListTile(
            title: Text('SL moves to Breakeven after 1R'),
            trailing: Icon(Icons.lock),
          ),
        ],
      ),
    );
  }
}
