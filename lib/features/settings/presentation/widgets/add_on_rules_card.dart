import 'package:flutter/material.dart';

class AddOnRulesCard extends StatelessWidget {
  const AddOnRulesCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          ListTile(
            title: Text(
              'Add-On Rules (V2)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'Rules for adding to an existing profitable position',
            ),
          ),
          Divider(height: 1),

          // ───────── PRE-CONDITIONS ─────────
          _RuleItem(
            text: 'Add-On is allowed only after R1 booking',
            icon: Icons.lock,
          ),
          _RuleItem(
            text:
                'Remaining position must be in profit (minimum 25%)',
            icon: Icons.lock,
          ),
          _RuleItem(
            text: 'Never add to a losing or breakeven trade',
            icon: Icons.block,
            iconColor: Colors.red,
          ),

          Divider(height: 12),

          // ───────── QUANTITY RULE ─────────
          _RuleItem(
            text:
                'Maximum Add-On quantity is 25% of original position',
            icon: Icons.rule,
          ),

          Divider(height: 12),

          // ───────── STOP-LOSS ─────────
          _RuleItem(
            text:
                'Add-On does not modify Stop-Loss automatically',
            icon: Icons.info_outline,
          ),
          _RuleItem(
            text:
                'Stop-Loss tightening is a separate manual decision',
            icon: Icons.info_outline,
          ),

          Divider(height: 12),

          // ───────── SAFETY AFTER ADD-ON ─────────
          _RuleItem(
            text:
                'After Add-On, total position must remain profitable',
            icon: Icons.shield,
          ),
          _RuleItem(
            text:
                'Trade must retain a minimum safety buffer (10%)',
            icon: Icons.shield,
          ),

          Divider(height: 12),

          // ───────── FUTURE NOTE ─────────
          Padding(
            padding: EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Text(
              'Note: R2 booking will be introduced in a future version.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RuleItem extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color? iconColor;

  const _RuleItem({
    required this.text,
    required this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: Icon(
        icon,
        size: 18,
        color: iconColor ?? Colors.grey,
      ),
      title: Text(
        text,
        style: const TextStyle(fontSize: 13),
      ),
    );
  }
}
