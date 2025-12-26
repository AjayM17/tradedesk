import 'package:flutter/material.dart';

class RulesSection extends StatelessWidget {
  const RulesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ===== HEADER =====
          const ListTile(
            title: Text(
              '📘 Trading Rules',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Text('“No Rule, No Trade”'),
          ),
          const Divider(height: 1),

          // ===== TRADING STYLE (FIXED) =====
          _fixedTile(
            title: 'Trading Style',
            subtitle: 'Weekly positional trend-following\n'
                '• Weekly candles only\n'
                '• Intraday & daily ignored',
          ),

          _fixedTile(
            title: 'Timeframe',
            subtitle: 'Weekly',
          ),

          // ===== ENTRY RULES (FIXED) =====
          _sectionTitle('Entry Rules (ALL must match)'),

          _fixedBullet(
            'Weekly higher-high & higher-low structure',
          ),
          _fixedBullet(
            'Price above weekly 20 EMA',
          ),
          _fixedBullet(
            'Entry on pullback OR fresh weekly breakout',
          ),

          // ===== STOP LOSS RULES (FIXED) =====
          _sectionTitle('Initial Stop-Loss Rules'),

          _fixedBullet('Stop-loss at weekly structure low / support'),
          _fixedBullet('Never widen stop-loss 🚫'),
          _fixedBullet('Trail SL only using weekly structure'),
          _fixedBullet('No intraday stop-loss changes'),

          // ===== PARTIAL PROFIT (MIXED) =====
          _sectionTitle('Partial Profit Rules'),

          const SwitchListTile(
            title: Text('Mandatory Partial Profit at 1R'),
            subtitle: Text('Required before any add-on'),
            value: true,
            onChanged: null, // FIXED mandatory for now
          ),

          ListTile(
            title: const Text('1R Profit Booking %'),
            subtitle: const Text('Allowed range: 25–30%'),
            trailing: const Text('25%'),
            onTap: () {
              // STEP 3: percentage selector
            },
          ),

          // ===== ADD-ON RULES (MIXED) =====
          _sectionTitle('Add-On Rules (Same Stock Only)'),

          _fixedBullet('Trade has already achieved 1R'),
          _fixedBullet('Partial profit is booked'),
          _fixedBullet('Stop-loss at Breakeven or above'),
          _fixedBullet('Fresh weekly breakout with volume'),
          _fixedBullet('Previous resistance acts as support'),
          _fixedBullet('Never add to losing trades 🚫'),

          SwitchListTile(
            title: const Text('Allow Add-On Trades'),
            subtitle: const Text('Only when all conditions are met'),
            value: true,
            onChanged: (v) {
              // STEP 3: store toggle
            },
          ),

          ListTile(
            title: const Text('Max Add-On Quantity'),
            subtitle: const Text('Allowed: 25–30% of original'),
            trailing: const Text('25%'),
            onTap: () {},
          ),

          ListTile(
            title: const Text('Max Add-On Risk'),
            subtitle: const Text('≤ 0.5% of total capital'),
            trailing: const Text('0.5%'),
            onTap: () {},
          ),

          // ===== FINAL EXIT RULES (FIXED) =====
          _sectionTitle('Final Exit Rules (100% Exit)'),

          _fixedBullet('Exit only after weekly candle close'),
          _fixedBullet('Weekly structure breaks'),
          _fixedBullet('9 EMA closes below 20 EMA'),
          _fixedBullet('No intraday exits 🚫'),
          _fixedBullet('No partial exit at final stage 🚫'),

          // ===== GOLDEN RULES (FIXED) =====
          _sectionTitle('Golden Rules (Non-Negotiable)'),

          _fixedBullet('Never widen stop-loss'),
          _fixedBullet('Never add to losing trades'),
          _fixedBullet('Never break risk rules'),
          _fixedBullet('If rules are not met → No trade'),

          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // ===== HELPERS =====

  static Widget _fixedTile({
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.lock, size: 18),
    );
  }

  static Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  static Widget _fixedBullet(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 16, 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('•  '),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
