import 'package:flutter/material.dart';

class StopLossRulesCard extends StatelessWidget {
  const StopLossRulesCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: const [
          ListTile(
            title: Text(
              'Stop-Loss Rules',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'Structure-first • Weekly-only • One-way protection',
            ),
          ),
          Divider(height: 1),

          // INITIAL SL
          ListTile(
            title: Text('Initial Stop-Loss'),
            subtitle: Text(
              'Breakout support OR confirmed Weekly Higher Low (wick low)',
            ),
            trailing: Icon(Icons.lock),
          ),

          // BREAKOUT CONTEXT
          ListTile(
            title: Text('Breakout Trades'),
            subtitle: Text(
              'If no HH–HL exists, breakout support is valid initial SL\n'
              'Breakout may start a new HH–HL cycle',
            ),
            trailing: Icon(Icons.lock),
          ),

          // HL DEFINITION
          ListTile(
            title: Text('Higher Low (HL) Definition'),
            subtitle: Text(
              'Pullback low after HH, confirmed by continuation\n'
              'Pullback ≠ HL until confirmed',
            ),
            trailing: Icon(Icons.lock),
          ),

          // CORE PHILOSOPHY
          ListTile(
            title: Text('Do NOT wait for Lower Low'),
            subtitle: Text(
              'After HH → protect trade at HL',
            ),
            trailing: Icon(Icons.lock),
          ),

          // SL PRIORITY
          ListTile(
            title: Text('SL Priority'),
            subtitle: Text(
              'Clear HL → use HL\n'
              'HL unclear or below EMA → use Weekly 20 EMA',
            ),
            trailing: Icon(Icons.lock),
          ),

          // EMA ROLE
          ListTile(
            title: Text('EMA Role'),
            subtitle: Text(
              'Weekly 20 EMA is fallback / safety net\n'
              'Used mainly for profit trailing',
            ),
            trailing: Icon(Icons.lock),
          ),

          // HARD RULES
          ListTile(
            title: Text('Hard Rules'),
            subtitle: Text(
              'Never widen SL • No intraday or daily SL changes',
            ),
            trailing: Icon(Icons.block, color: Colors.red),
          ),
        ],
      ),
    );
  }
}
