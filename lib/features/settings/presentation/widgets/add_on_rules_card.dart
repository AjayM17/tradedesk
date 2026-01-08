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
              'Optional scaling into an existing profitable trade',
            ),
          ),
          Divider(height: 1),

          // ───────── CORE CONDITIONS ─────────
          _RuleItem(
            text: 'Add-On allowed only after partial profit at 1R',
            icon: Icons.lock,
          ),
          _RuleItem(
            text: 'Never add to a losing or breakeven trade',
            icon: Icons.block,
            iconColor: Colors.red,
          ),

          Divider(height: 12),

          // ───────── SIZE CONTROL ─────────
          _RuleItem(
            text: 'Add-On quantity must not exceed 25% of original position',
            icon: Icons.rule,
          ),

          Divider(height: 12),

          // ───────── EXIT & SL INTEGRITY ─────────
          _RuleItem(
            text: 'Add-On does not change Stop-Loss or Exit rules',
            icon: Icons.info_outline,
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
