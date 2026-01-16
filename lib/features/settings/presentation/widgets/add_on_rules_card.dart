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
              'Optional scaling after R1 within intact weekly structure',
            ),
          ),
          Divider(height: 1),

          // ───────── PRECONDITIONS ─────────
          _RuleItem(
            text: 'Add-On allowed only after mandatory R1 booking',
            icon: Icons.lock,
          ),
          _RuleItem(
            text:
                'Base trade must be active, profitable, and in a valid weekly trend',
            icon: Icons.lock,
          ),
          _RuleItem(
            text:
                'Weekly structure must offer a fresh continuation setup after correction',
            icon: Icons.lock,
          ),

          Divider(height: 12),

          // ───────── PROFIT CONDITION ─────────
          _RuleItem(
            text:
                'After add-on, the combined position must remain at least +10% in profit',
            icon: Icons.lock,
          ),

          Divider(height: 12),

          // ───────── RESTRICTIONS ─────────
          _RuleItem(
            text:
                'No add-on during vertical, overextended, or unstable price moves',
            icon: Icons.block,
            iconColor: Colors.red,
          ),
          _RuleItem(
            text:
                'Add-On is strictly for trend continuation, not for averaging',
            icon: Icons.lock,
          ),

          Divider(height: 12),

          // ───────── SIZE CONTROL ─────────
          _RuleItem(
            text:
                'Add-On quantity must not exceed 25% of the original position',
            icon: Icons.rule,
          ),

          Divider(height: 12),

          // ───────── EXIT & SL ─────────
          _RuleItem(
            text:
                'Add-On shares the same stop-loss and exit as the base trade',
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
