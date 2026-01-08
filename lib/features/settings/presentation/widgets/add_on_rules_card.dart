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
              'Add-On Rules',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'Optional scaling using the same rules as a fresh entry',
            ),
          ),
          Divider(height: 1),

          // ───────── CORE CONDITIONS ─────────
          _RuleItem(
            text:
                'Add-On allowed only after mandatory profit booking at 1R',
            icon: Icons.lock,
          ),
          _RuleItem(
            text:
                'Add-On is taken only after a correction and formation of a new weekly structure',
            icon: Icons.lock,
          ),
          _RuleItem(
            text:
                'Trade must be clearly in profit; add-on is never allowed at breakeven or loss',
            icon: Icons.block,
            iconColor: Colors.red,
          ),

          Divider(height: 12),

          // ───────── SIZE CONTROL ─────────
          _RuleItem(
            text:
                'Add-On quantity must not exceed 25% of the original position size',
            icon: Icons.rule,
          ),

          Divider(height: 12),

          // ───────── EXIT & SL INTEGRITY ─────────
          _RuleItem(
            text:
                'Add-On follows the same Entry, Stop-Loss, and Exit rules as the base trade',
            icon: Icons.info_outline,
          ),
          _RuleItem(
            text:
                'Add-On is for trend continuation, not for averaging',
            icon: Icons.lock,
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
