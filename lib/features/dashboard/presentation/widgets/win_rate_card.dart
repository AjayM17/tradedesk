import 'package:flutter/material.dart';

class WinRateCard extends StatelessWidget {
  final String value;
  final String subtitle;

  const WinRateCard({
    super.key,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Win Rate', style: textTheme.labelLarge),
            const SizedBox(height: 12),
            Text(
              value,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(subtitle, style: textTheme.labelLarge),
          ],
        ),
      ),
    );
  }
}
