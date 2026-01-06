import 'package:flutter/material.dart';

import 'package:trade_desk/features/trades/data/models/trade_action_step.dart';
import 'package:trade_desk/features/trades/data/services/trade_firestore_service.dart';
import 'package:trade_desk/features/trades/data/v2/trade_v2_executor.dart';
import 'package:trade_desk/features/trades/presentation/screens/create_trade_screen.dart';
import 'package:trade_desk/features/trades/presentation/widgets/add_on_v2_dialog.dart';
import 'package:trade_desk/features/trades/presentation/widgets/r_booking_v2_dialog.dart';

import '../../../../core/theme/app_theme.dart';
import '../models/trade_ui_model.dart';

class TradeCard extends StatelessWidget {
  final TradeUiModel trade;

  const TradeCard({super.key, required this.trade});

  @override
  Widget build(BuildContext context) {
    final t = trade.trade;
    final textTheme = Theme.of(context).textTheme;
    final bool isProfit = trade.pnlValue >= 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ───────── HEADER ─────────
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
                Text('Actions ${t.actionCount}/4', style: textTheme.bodySmall),
              ],
            ),

            const SizedBox(height: 6),

            // ───────── POSITION INFO ─────────
            _row([
              _kv('Qty', t.quantity),
              _kv('Buy', t.entryPrice),
              _kv('SL', t.stopLoss),
            ]),

            const SizedBox(height: 4),

            _row([
              _kv('Init SL', t.initialStopLoss),
              _kv('Inv', '₹${trade.investedAmount.toStringAsFixed(0)}'),
              _kv('Age', '${trade.ageInDays}d'),
            ]),

            const SizedBox(height: 6),

            // ───────── P&L ─────────
            Text(
              'P&L: ${trade.pnlValue.toStringAsFixed(0)} '
              '(${trade.pnlPercent.toStringAsFixed(1)}%)',
              style: textTheme.bodySmall!.copyWith(
                color: isProfit ? AppTheme.success : AppTheme.danger,
                fontWeight: FontWeight.w600,
              ),
            ),

            // ───────── ACTION SUMMARY ─────────
            _actionSummaries(),

            const SizedBox(height: 10),

            // ───────── ACTION BAR ─────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CreateTradeScreen(trade: trade),
                          ),
                        );
                      },
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Edit'),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () => _confirmDelete(context),
                      icon: const Icon(
                        Icons.delete,
                        size: 16,
                        color: Colors.red,
                      ),
                      label: const Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),

                Row(
                  children: [
                    if (t.step == TradeActionStep.none)
                      TextButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => RBookingV2Dialog(trade: t),
                          );
                        },
                        child: const Text('Book R1'),
                      ),

                    if (t.step == TradeActionStep.r1Done)
                      TextButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => AddOnV2Dialog(trade: t),
                          );
                        },
                        child: const Text('Add-On'),
                      ),
                  ],
                ),
              ],
            ),

            // ───────── UNDO ─────────
            if (trade.actions.isNotEmpty)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => _confirmUndo(context),
                  icon: const Icon(Icons.undo, size: 16),
                  label: const Text('Undo Last Action'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Trade'),
        content: const Text(
          'This trade and all its actions will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await TradeFirestoreService().deleteTrade(trade.id);
    }
  }

  Future<void> _confirmUndo(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Undo Last Action'),
        content: const Text(
          'This will revert the most recent action.\n\n'
          'This cannot be redone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Undo'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final reverted = TradeV2Executor.undoLastAction(trade: trade.trade);

    final lastAction = trade.trade.actions.last;

    await TradeFirestoreService().undoLastAction(
      tradeId: trade.id,
      updatedTradeFields: {
        'quantity': reverted.quantity,
        'actions': reverted.actions.map((a) => a.toMap()).toList(),
      },
      lastActionMap: lastAction.toMap(),
    );
  }

  Widget _actionSummaries() {
    if (trade.actions.isEmpty) return const SizedBox.shrink();

    final List<Widget> rows = [];
    int rCount = 0;

    for (final a in trade.actions) {
      if (a.kind.name == 'rBooking') {
        rCount++;
        rows.add(
          _iconRow(
            Icons.emoji_events,
            Colors.orange,
            'R$rCount @ ${a.price.toStringAsFixed(0)}'
            ' | Qty: ${a.quantity}'
            ' | +₹${a.pnl.toStringAsFixed(0)}',
          ),
        );
      }

      if (a.kind.name == 'addOn') {
        rows.add(
          _iconRow(
            Icons.add_circle,
            Colors.blue,
            'Add-On @ ${a.price.toStringAsFixed(0)}'
            ' | Qty: ${a.quantity}',
          ),
        );
      }
    }

    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: rows,
      ),
    );
  }

  Widget _row(List<Widget> children) =>
      Wrap(spacing: 12, runSpacing: 4, children: children);

  Widget _kv(String label, dynamic value) =>
      Text('$label: $value', style: const TextStyle(fontSize: 12));

  Widget _iconRow(IconData icon, Color color, String text) => Padding(
    padding: const EdgeInsets.only(top: 2),
    child: Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    ),
  );
}

class _StatusIcon extends StatelessWidget {
  final TradeStatus status;
  const _StatusIcon({required this.status});

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.circle,
      size: 10,
      color: switch (status) {
        TradeStatus.active => Colors.green,
        TradeStatus.free => Colors.blue,
        TradeStatus.closed => Colors.grey,
      },
    );
  }
}
