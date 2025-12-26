import 'package:flutter/material.dart';

class AddOnRulesCard extends StatelessWidget {
  const AddOnRulesCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          const ListTile(
            title: Text(
              'Add-On Rules',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(height: 1),
          const ListTile(
            title: Text('Allowed only after 1R'),
            trailing: Icon(Icons.lock),
          ),
          const ListTile(
            title: Text('Partial profit must be booked'),
            trailing: Icon(Icons.lock),
          ),
          const ListTile(
            title: Text('Never add to losing trade'),
            trailing: Icon(Icons.block, color: Colors.red),
          ),
          ListTile(
            title: const Text('Max Add-On Quantity'),
            trailing: const Text('25%'),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Max Add-On Risk'),
            trailing: const Text('0.5%'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
