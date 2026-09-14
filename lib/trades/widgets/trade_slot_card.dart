import 'package:flutter/material.dart';

class TradeSlotCard extends StatelessWidget {
  final bool enabled;
  final String? disabledReason;
  final VoidCallback? onTap;

  const TradeSlotCard({
    super.key,
    required this.enabled,
    this.disabledReason,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = enabled
        ? Colors.white
        : const Color(0xFFF5F5F7);

    final borderColor = enabled
        ? const Color(0xFFE0E0E4)
        : const Color(0xFFE5E5E8);

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: borderColor,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: enabled ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 22,
          ),
          child: Column(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: enabled
                      ? const Color(0xFFF0F2F7)
                      : const Color(0xFFE8E8EC),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  enabled
                      ? Icons.add
                      : Icons.lock_outline,
                  size: 21,
                  color: enabled
                      ? const Color(0xFF101A31)
                      : const Color(0xFFAEB3BD),
                ),
              ),

              const SizedBox(height: 10),

              Text(
                enabled
                    ? 'Empty Trade Slot'
                    : 'Trade Slot Locked',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: enabled
                      ? const Color(0xFF101A31)
                      : const Color(0xFF8A8F9B),
                ),
              ),

              const SizedBox(height: 4),

              Text(
                enabled
                    ? 'Tap to add trade'
                    : disabledReason ??
                        'Trade cannot be added',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  height: 1.4,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}