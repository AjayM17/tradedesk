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
              'Fixed for Trading Engine – V1',
              style: TextStyle(fontSize: 12),
            ),
          ),
          Divider(height: 1),

          ListTile(
            title: Text('Style'),
            subtitle: Text('Weekly Positional Trend Following'),
            trailing: Icon(Icons.lock),
          ),

          ListTile(
            title: Text('Timeframe'),
            subtitle: Text('Weekly candles only'),
            trailing: Icon(Icons.lock),
          ),

          ListTile(
            title: Text('Noise Definition'),
            subtitle: Text('Daily & intraday movements ignored'),
            trailing: Icon(Icons.lock),
          ),
        ],
      ),
    );
  }
}
