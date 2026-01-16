import 'package:flutter/material.dart';

class TradingStyleCard extends StatelessWidget {
  const TradingStyleCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: const [
          ListTile(
            title: Text(
              'Trading Style',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'Rule-based weekly positional system',
              style: TextStyle(fontSize: 12),
            ),
          ),
          Divider(height: 1),

          ListTile(
            title: Text('Style'),
            subtitle: Text('Weekly positional trend trading'),
            trailing: Icon(Icons.lock),
          ),

          ListTile(
            title: Text('Timeframe'),
            subtitle: Text('Weekly candles only'),
            trailing: Icon(Icons.lock),
          ),

          ListTile(
            title: Text('Trend Definition'),
            subtitle: Text('Weekly HH–HL structure (primary)'),
            trailing: Icon(Icons.lock),
          ),

          ListTile(
            title: Text('Breakout Logic'),
            subtitle: Text('Breakout may start a new HH–HL cycle'),
            trailing: Icon(Icons.lock),
          ),

          ListTile(
            title: Text('Noise'),
            subtitle: Text('Daily & intraday ignored'),
            trailing: Icon(Icons.lock),
          ),
        ],
      ),
    );
  }
}
