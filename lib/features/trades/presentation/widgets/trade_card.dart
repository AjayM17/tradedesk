import 'package:flutter/material.dart';
import 'package:trade_desk/features/trades/data/models/r1_booking.dart';
import 'package:trade_desk/features/trades/data/services/trade_firestore_service.dart';
import 'package:trade_desk/features/trades/presentation/screens/create_trade_screen.dart';
import 'package:trade_desk/features/trades/presentation/widgets/r1_booking_dialog.dart';
import '../../../../core/theme/app_theme.dart';
import '../models/trade_ui_model.dart';

class TradeCard extends StatelessWidget {
  final TradeUiModel trade;

  const TradeCard({super.key, required this.trade});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final bool isProfit = trade.pnlValue >= 0;
    final bool isR1Booked = trade.r1 != null;

    final double r1TargetPrice = trade.buyPrice + trade.oneRTarget;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ───────── Row 1: Status | Name | R1 | Actions ─────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _StatusIcon(status: trade.status),
                    const SizedBox(width: 6),
                    Text(trade.name, style: textTheme.titleSmall),
                  ],
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        if (trade.r1 != null) {
                          _showR1Info(context);
                          return;
                        }

                        final r1 = await showDialog<R1Booking>(
                          context: context,
                          builder: (_) => R1BookingDialog(trade: trade),
                        );

                        if (r1 == null) return;

                        await TradeFirestoreService().bookR1(
                          tradeId: trade.id,
                          r1: r1,
                        );

                        if (!context.mounted) return;

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('R1 booked successfully'),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          Text(
                            isR1Booked
                                ? '${trade.r1?.sellPrice.toStringAsFixed(0)}'
                                : r1TargetPrice.toStringAsFixed(0),
                            style: textTheme.bodySmall!.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            isR1Booked
                                ? Icons.emoji_events
                                : Icons.emoji_events_outlined,
                            size: 16,
                            color: isR1Booked ? Colors.orange : Colors.grey,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_vert, size: 18),
                      onPressed: () => _showActions(context),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 6),

            // ───────── Row 2: Qty | Sold | Buy | SL ─────────
            _InlineRow(
              children: [
                _inlineText('Qty', trade.remainingQuantity),
                if (trade.r1 != null) _inlineText('Sold', trade.r1!.quantity),
                _inlineText('Buy', trade.buyPrice),
                _inlineText('SL', trade.stopLoss),
              ],
            ),

            const SizedBox(height: 6),

            // ───────── Row 3: Invested | P&L ─────────
            _InlineRow(
              children: [
                _inlineText('Inv', trade.investedAmount, prefix: '₹'),
                Text(
                  'P&L: ${trade.pnlValue.toStringAsFixed(0)} '
                  '(${trade.pnlPercent.toStringAsFixed(1)}%)',
                  style: textTheme.bodySmall!.copyWith(
                    color: isProfit ? AppTheme.success : AppTheme.danger,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            // ───────── Row 4: Age | Init SL ─────────
            _InlineRow(
              children: [
                _inlineText('Age', '${trade.ageInDays}d'),
                _inlineText(
                  'Init SL',
                  trade.initialStopLoss.toStringAsFixed(0),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ───────── Action Sheet ─────────
  void _showActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                ListTile(
                  leading: const Icon(Icons.edit),
                  title: const Text('Edit Trade'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CreateTradeScreen(trade: trade),
                      ),
                    );
                  },
                ),

                if (trade.r1 != null)
                  ListTile(
                    leading: const Icon(Icons.undo, color: Colors.orange),
                    title: const Text('Undo R1 Booked'),
                    onTap: () async {
                      Navigator.pop(context);
                      await TradeFirestoreService().undoR1(trade.id);
                    },
                  ),

                const Divider(height: 24),

                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text(
                    'Delete Trade',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _confirmDelete(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ───────── R1 Info Dialog ─────────
  void _showR1Info(BuildContext context) {
    final r1 = trade.r1;
    final double targetPrice = trade.buyPrice + trade.oneRTarget;

    final int plannedQty = (trade.quantity * 0.25).floor();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.emoji_events, color: Colors.orange, size: 20),
            const SizedBox(width: 8),
            Text(
              r1 != null
                  ? 'R1 Profit – ₹${r1.profit.toStringAsFixed(0)}'
                  : 'R1 Target – ₹${targetPrice.toStringAsFixed(0)}',
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('R1 Target: ₹${targetPrice.toStringAsFixed(0)}'),
            Text('1R (Risk): ₹${trade.oneRTarget.toStringAsFixed(0)}'),
            const SizedBox(height: 6),

            // 🔥 Quantity logic
            Text(
              r1 != null
                  ? 'Quantity Sold: ${r1.quantity}'
                  : 'Planned Qty (25%): $plannedQty',
            ),

            // 🔥 Sell price only if booked
            if (r1 != null) ...[
              const SizedBox(height: 6),
              Text('Sell Price: ₹${r1.sellPrice.toStringAsFixed(0)}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Trade'),
        content: const Text('This action cannot be undone. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await TradeFirestoreService().deleteTrade(trade.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _inlineText(String label, dynamic value, {String prefix = ''}) {
    final String displayValue = value is double
        ? value.toStringAsFixed(0)
        : value.toString();

    return Text(
      '$label: $prefix$displayValue',
      style: const TextStyle(fontSize: 12),
    );
  }
}

// ───────── Helpers ─────────

class _InlineRow extends StatelessWidget {
  final List<Widget> children;

  const _InlineRow({required this.children});

  @override
  Widget build(BuildContext context) {
    return Wrap(spacing: 12, runSpacing: 4, children: children);
  }
}

class _StatusIcon extends StatelessWidget {
  final TradeStatus status;

  const _StatusIcon({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;

    switch (status) {
      case TradeStatus.active:
        color = Colors.green;
        break;
      case TradeStatus.free:
        color = Colors.blue;
        break;
      case TradeStatus.closed:
        color = Colors.grey;
        break;
    }

    return Icon(Icons.circle, size: 10, color: color);
  }
}
