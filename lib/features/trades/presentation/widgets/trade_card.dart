import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../models/trade_ui_model.dart';

class TradeCard extends StatelessWidget {
  final TradeUiModel trade;

  const TradeCard({
    super.key,
    required this.trade,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final bool isProfit = trade.pnlValue >= 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ───────────────── 1️⃣ NAME + STATUS ─────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  trade.name,
                  style: textTheme.titleMedium,
                ),
                _StatusBadge(status: trade.status),
              ],
            ),

            const SizedBox(height: 8),

            // ───────────────── 2️⃣ P&L ─────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'P&L',
                  style: textTheme.bodySmall,
                ),
                Text(
                  '${_sign(trade.pnlValue)}₹${trade.pnlValue.abs().toStringAsFixed(0)} '
                  '(${_sign(trade.pnlPercent)}${trade.pnlPercent.abs().toStringAsFixed(2)}%)',
                  style: textTheme.bodyLarge!.copyWith(
                    color: isProfit ? AppTheme.success : AppTheme.danger,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // ───────────────── 3️⃣ QTY / 25% / BUY ─────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _InfoText(label: 'Qty', value: trade.quantity.toString()),
                _InfoText(label: '25%', value: trade.partialQuantity.toString()),
                _InfoText(
                  label: 'Buy',
                  value: trade.buyPrice.toStringAsFixed(0),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // ───────────────── 4️⃣ INVESTED / SL / INIT SL ─────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _InfoText(
                  label: 'Inv',
                  value: '₹${trade.investedAmount.toStringAsFixed(0)}',
                ),
                _InfoText(
                  label: 'SL',
                  value: trade.stopLoss.toStringAsFixed(0),
                  valueColor: AppTheme.danger,
                ),
                _InfoText(
                  label: 'Init SL',
                  value: trade.initialStopLoss.toStringAsFixed(0),
                  valueColor: Colors.grey,
                ),
              ],
            ),

            const SizedBox(height: 8),

            // ───────────────── 5️⃣ META (1R / AGE / PARTIAL) ─────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '1R: ₹${trade.oneRTarget.toStringAsFixed(0)}',
                  style: textTheme.bodySmall,
                ),
                Text(
                  'Age: ${trade.ageInDays}d',
                  style: textTheme.bodySmall,
                ),
                if (trade.isPartialProfitBooked)
                  Row(
                    children: [
                      const Icon(
                        Icons.done_all,
                        size: 14,
                        color: AppTheme.success,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Partial',
                        style: textTheme.bodySmall!.copyWith(
                          color: AppTheme.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _sign(double value) => value >= 0 ? '+' : '-';
}

// ───────────────────────── INFO TEXT ─────────────────────────

class _InfoText extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoText({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.bodySmall,
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: textTheme.bodyMedium!.copyWith(
            color: valueColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ───────────────────────── STATUS BADGE ─────────────────────────

class _StatusBadge extends StatelessWidget {
  final TradeStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    late final String text;
    late final Color color;

    switch (status) {
      case TradeStatus.active:
        text = 'Active';
        color = Colors.orange;
        break;
      case TradeStatus.free:
        text = 'Free';
        color = AppTheme.success;
        break;
      case TradeStatus.closed:
        text = 'Closed';
        color = Colors.grey;
        break;
    }

    return Text(
      text,
      style: textTheme.bodySmall!.copyWith(
        color: color,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
